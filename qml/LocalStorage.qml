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
