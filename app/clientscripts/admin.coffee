$(document).ready(
	() ->
		$.validator.addMethod('decimal', (value, element) ->
		    return this.optional(element) || /^[0-9,]+(\.\d{0,3})?$/.test(value); 
		, "Лише цифри, формат xx.xxx");

		$(window).keydown(
			(event) ->
				if event.keyCode == 13 
			    	event.preventDefault();
			    	return false	    
		)

		$.extend($.validator.messages, {
			required: "Заповніть поле!",
			minlength : "Мін. {0} символи!"
		})

		utils.setServerCommunicator(serverCommunicator.getInstance())

		ui = {
			getUserLogin : () -> return $("#userlogin").val().trim().toLowerCase()
			getUserPass : () -> return $("#userpass").val().trim().toLowerCase()
			getUserLoginToDelete : () -> return $("#usertodelete").val()
			getBuildingId : () -> return $("#streetid").val()
			getUSDAdjust : () -> return $("#usdadjust").val()
		}

		$('#saveuser').bind(
			'click',
			(e) ->
				if $("#newuserform").valid()
					utils.postToServer(
						"saveitem",
						{
							"collection" : "users",
							"login" : ui.getUserLogin(),
							"pass" : ui.getUserPass()
						},
						(saved) ->
							
					)
		)

		$("#deleteuser").bind(
			'click',
			(e) ->
				if $("#deleteuserform").valid()
					utils.postToServer(
						"deleteuser",
						{
							"collection" : "users",
							"login" : ui.getUserLoginToDelete(),
						},
						() ->	
					)
		)

		$("#saveadjust").bind(
			'click',
			(e) ->
				if $("#usdadjustform").valid()
					utils.postToServer(
						"saveusdadjust",
						{
							"adjust" : ui.getUSDAdjust(),
						},
						() ->	
					)
		)

		$("#deletebuilding").bind(
			'click',
			(e) ->
				if $("#deletebuildingform").valid()
					utils.postToServer(
						"deletebuilding",
						{
							"id" : ui.getBuildingId()
						},
						() ->	
					)
		)

		$("#newuserform").validate({
			rules: {
					userlogin : {
						required: true
					}
					userpass : {
						required: true
					}
				}
		})

		$("#deleteuserform").validate({
			rules: {
					usertodelete : {
						required: true
					}
				}
		})

		$("#deletebuildingform").validate({
			rules: {
					streetid : {
						required: true,
						minlength : 24
					}
				}
		})	

		$("#usdadjustform").validate({
			rules: {
					usdadjust : {
						required: true,
						decimal : true
					}
				}
		})			
)
