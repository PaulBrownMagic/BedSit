const socket = new WebSocket('ws://localhost:8000/todos');
setTimeout(incr_progress, 10)

socket.onopen = function (e) {
    socket.send('refresh')
}

socket.onmessage = function (e) {
    const json = e.data
    if (json) {
        update_todos($.parseJSON(json))
    }
    else {
        console.log("ERROR: Bad Data")
    }
    if ($('.progress').length > 0) { pop_progress() }
}

function update_todos(resp) {
    $("#todo").empty()
    for (const todo of resp.todo) {
        $("#results").find(".template.todo").clone().removeClass('template d-none').appendTo('#todo').children('span').first().text(todo)
    }
    $("#completed").empty()
    for (const todo of resp.completed) {
        $("#results").find(".template.completed").clone().removeClass('template d-none').appendTo('#completed').children('span').first().text(todo)
    }
}

function addTodo () {
    const label = $('#newtodo').parent().children('input').first().val()
    const action = `add_todo('${label}')`
    socket.send(action)
}

function completeTodo(todo) {
    const action = `mark_complete('${get_label(todo)}')`
    socket.send(action)
}

function removeTodo(todo) {
    const action = `remove_todo('${get_label(todo)}')`
    socket.send(action)
}

function get_label(todo) {
    return $(todo).parent().children('span').first().text()
}

function incr_progress () {
    $('.progress-bar').width($('.progress-bar').width() + 300)
    setTimeout(incr_progress, 10)
}

function pop_progress () {
    clearTimeout()
    $('.progress').remove()
}
