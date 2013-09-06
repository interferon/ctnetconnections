window.serverCommunicator = {}

serverCommunicator.getInstance = () ->
	serverCommunicator = new ServerCommunicator()
	return serverCommunicator

class ServerCommunicator
	createRequest : (method, path, request_body, fn) ->
		_httpRequest = new XMLHttpRequest()
		_httpRequest.onreadystatechange =
			() ->
				if (_httpRequest.readyState == 4)
					if (_httpRequest.status == 200)
						data = JSON.parse(_httpRequest.responseText)
						fn(data)
					else
						$("#serverMessages").addClass('alert-error')
						$("#serverMessages").text("Серверу не вдалось обробити запит!")
						$("#serverMessages").show()
						setTimeout(
							() ->
								$("#serverMessages").fadeOut('slow')
								$("#serverMessages").removeClass('alert-error')
							, 3000
						)
		_httpRequest.open(method, "http://127.0.0.1:8080/" + path, true)
		_httpRequest.setRequestHeader('Content-Type', 'application/json')
		_httpRequest.send(request_body)

