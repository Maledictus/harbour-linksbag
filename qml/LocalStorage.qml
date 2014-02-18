/*
    Copyright (c) 2014 Oleg Linkin <MaledictusDeMagog@gmail.com>

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
*/

import QtQuick.LocalStorage 2.0 as Sql
import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: localStorage

    property string dbName: "linksbag"
    property string dbVersion: "1.0"
    property string dbDisplayName: "linksbag"
    property int dbEstimatedSize: 100

    function setSettingsValue (key, value) {
        var db = Sql.LocalStorage.openDatabaseSync (dbName, dbVersion,
                dbDisplayName, dbEstimatedSize);
        db.transaction (
            function (tx) {
                tx.executeSql ('CREATE TABLE IF NOT EXISTS Keys (key TEXT PRIMARY KEY, value TEXT)')
                var rs = tx.executeSql ('SELECT * FROM Keys WHERE key==?', [ key ])

                if (rs.rows.length === 0) {
                    tx.executeSql ('INSERT INTO Keys VALUES(?, ?)', [ key, value ])
                } else {
                    tx.executeSql ('UPDATE Keys SET value=? WHERE key==?', [value, key])
                }
            }
        )
    }

    function getSettingsValue (key, default_value) {
        var db = Sql.LocalStorage.openDatabaseSync(dbName, dbVersion,
                dbDisplayName, dbEstimatedSize);
        var result = "";
        db.transaction (
            function (tx) {
                tx.executeSql ('CREATE TABLE IF NOT EXISTS Keys (key TEXT PRIMARY KEY, value TEXT)')
                var rs = tx.executeSql ('SELECT * FROM Keys WHERE key=?', [ key ])
                if (rs.rows.length === 1 && rs.rows.item (0).value.length > 0) {
                    result = rs.rows.item (0).value
                } else {
                    result = default_value;
                    console.log (key + " : " + result + " (default)")
                }
            }
        )
        return result;
    }
}
