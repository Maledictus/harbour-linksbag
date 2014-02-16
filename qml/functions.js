function addSortingKey (object)
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
