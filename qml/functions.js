var itemsObject = new Object

function addItems (newItems) {
    for (var i = 0; i < newItems.length; ++i) {
        var newItem = newItems [i]
        if (itemsObject === undefined ||
                !itemsObject.hasOwnProperty (newItem.uid)) {
            itemsObject[newItem.uid] = newItem
        }
    }
}

function addItem (item) {
    if (itemsObject === undefined ||
            !itemsObject.hasOwnProperty (item.uid)) {
        var data = new Object;
        for (var key in item) {
            data [key] = item [key]
        }
        itemsObject[item.uid] = data
    }
}

function getItems () {
    var array = new Array;
    for (var key in itemsObject) {
        array.push (itemsObject [key])
    }
    return array
}

function sort (object)
{
    var sortedList = new Array ()
    for (var key in object) {
        var item = object [key]
        var uid = item.item_id
        var sortId = item.sort_id

        sortedList.push({ "uid": uid, "sortId": sortId });
    }

    sortedList.sort (function (a, b) { return b.sortId - a.sortId })

    return sortedList
}
