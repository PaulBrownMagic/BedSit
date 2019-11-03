const socket = new WebSocket('ws://localhost:8000/friends');

socket.onopen = function (e) {
    console.log("Socket established")
}

socket.onmessage = function (e) {
    const json = e.data
    if (json) {
        update_friends($.parseJSON(json))
    }
    else {
        console.log("ERROR: Bad Data")
    }
}

function update_friends(resp) {
    $("#friends").empty()
    for (const friend of resp.friends) {
        let el = $("#results").find(".template.knows").clone().removeClass('template d-none').appendTo('#friends').children('span').first()
        el.text(friend.name)
        el.attr("id", friend.value)
    }
    $("#knows").empty()
    for (const knows of resp.knows) {
        let el = $("#results").find(".template.knows").clone().removeClass('template d-none').appendTo('#knows').children('span').first()
        el.text(knows.name)
        el.attr("id", knows.value)
    }
}

function browse_as () {
    const action = `browse_as('${$('#browse_as').val()}')`
    socket.send(action)
    $('#lead').first().text(`Browsing as ${$('#browse_as option:selected').text()}`)
}

function add_friend () {
    const action = `add_friend('${$('#add_friend').val()}')`
    socket.send(action)
}

function remove_friend(person) {
    const action = `remove_friend('${get_label(person)}')`
    socket.send(action)
    console.log(action)
}

function get_label(person) {
    return $(person).parent().children('span').first().attr("id")
}
