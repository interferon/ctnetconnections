window.utils = {}

serverCommunicator = null

utils.setServerCommunicator = (sc) ->
	serverCommunicator = sc

utils.populateComboBox = (combobox, data) ->
	for i in data
		combobox.append("<option value=#{i._id}>#{i.name}</option>")

utils.randomGenerator = (max_number) ->
	random = Math.random()*max_number
	return Math.floor(random)


#  function createTable returns ready to use html table. It takes data in the following format:
# data = {
#
# 	"headers" : ['header1', 'header2', 'header3', ...],
#    			(array of string names for each column header)
#
# 	"values" : [['value1', value2, value3, ...],[],[], ...],
# 				(array of arrays with string values.
# 				number of elems in every nested array must be same,
# 				as for headers array for proper table integrity.
# 				each nested array will result in row in table)
#
#	"title" : "your  table title" ,
# 				(any title you may wish in string format)
#
#	"style" : "mytablestyle additionaltablestyle ..."
# 				(string representation of css classes,
#				multiple classes allowed separated by space)
# }
#
utils.createTable = (data) ->
	convertStringArrayToTableRow = (string_array, type) ->
		tablerow = $('<tr>')
		for str in string_array
			tablecell = renderCell(str, type)
			tablerow.append(tablecell)
		return tablerow

	renderCell = (str, type) ->
		open_elem = ''
		close_elem = ''
		switch type
			when 'values'
				open_elem = '<td style="word-wrap: break-word">'
				close_elem = '</td>'
			when 'headers'
				open_elem = '<th style="word-wrap: break-word">'
				close_elem = '</th>'
		return open_elem + str + close_elem

	$table = $('<table id="dataTable" class="'.concat(data.style).concat('">'))
	$table.attr('border', '1')
	$table.append($("<caption id='title'><b style='font-size:20px'>"+data.title+"</b></caption>"))
	$table.append(convertStringArrayToTableRow(data.headers, 'headers'))
	for row in data.values
		$table.append(convertStringArrayToTableRow(row, 'values'))
	return $table

utils.getSelectedDate = (data, hours, mins) ->
	selectedDate = data.split("-")
	year = selectedDate[0]
	month = selectedDate[1]-1
	day = selectedDate[2]
	return new Date(
		year,
		month,
		day,
		hours,
		mins
	).toISOString()


utils.getButtonGroupSelection = (group_name) ->
	status = false
	if $("input:radio[name=#{group_name}]:checked").val() == "yes"
		status = true
	return status



utils.postToServer = (path, item, fn) ->
	serverCommunicator.createRequest(
		"POST",
		path,
		JSON.stringify(item),
		(result) ->
			$("#serverMessages").addClass('alert-success')
			$("#serverMessages").text(result.result)
			$("#serverMessages").show()
			setTimeout(
				() ->
					$("#serverMessages").fadeOut('slow', () -> $("#serverMessages").removeClass('alert-success'))
				, 3000
			)
			fn(result.object)
	)



# functions takes  data in format specified below and callback function wich executes
# after server responce
#  --data format example--
# {
# 	"parameters" : [{"param_name" : "collection", "param_value" :  collection}],
# 	"path" : "getsaveditems"
# }
# -- end of data format examle--
# "path"  is a string representation of path activating corresponding handler on server side
# "parameters"  is array of jsons. Every json have name - value pair as keys for subsequent
# querystring generation (format of querystring "path?name=value)

utils.getDataFromDB = (data, fn) ->
	parametersString = ""
	parametersString += p.param_name + "=" + p.param_value + "&" for p in data.parameters
	parametersString = parametersString.substring(0, parametersString.length-1)
	serverCommunicator.createRequest(
		'GET',
		data.path+"?"+parametersString,
		null,
		(data) ->
			fn(data)
	)
# --------------------------------------------------------------------------------------------
utils.getUserSelectedDatesInterval = (from, till) ->
	start = from.val()
	end = till.val()
	date = {
		start : utils.getSelectedDate(start, 3, 0),
		end: utils.getSelectedDate(end, 26, 59)
	}
	return date

utils.formatDateForTable = (dateInputField) ->
	selectedDate = dateInputField.val().split("-")
	year = selectedDate[0]
	month = selectedDate[1]
	day = selectedDate[2]
	return day + "." + month + "." + year

utils.getCurrentDate = () ->
	return new Date()

utils.getCurrentDateInMyFormat = () ->
	date = new Date().toISOString().substring(0,10).split("-")
	newdate = date[2]+"-"+date[1]+"-"+date[0]
	return newdate

utils.compareBuildings = (a, b) ->
			result = 0
			if (a.street < b.street)
				result =  -1
			if (a.street > b.street)
				result = 1
			return result

utils.compareConnections = (a, b) ->
	result = 0
	if (a.parent.street < b.parent.street)
		result =  -1
	if (a.parent.street > b.parent.street)
		result = 1
	return result

utils.compare = (a, b) ->
	result = 0
	if (a.name < b.name)
		result =  -1
	if (a.name > b.name)
		result = 1
	return result

utils.compareNumbers = (a, b) ->
	result = 0
	if (a.number < b.number)
		result =  -1
	if (a.number > b.number)
		result = 1
	return result

utils.fillselectors = (objects_array, selectors, params) ->
	generateMiddlePart = (params, object) ->
		content = ''
		for param in params
			content += object[param] + " "
		return content

	for selector in selectors
		selector.empty()
		for object in objects_array
			tagStart = '<option value='+object._id+'>'
			tagContent = generateMiddlePart(params, object)
			tagEnd = '</option>'
			selector.append(tagStart + tagContent + tagEnd)
		selector.trigger('click')

utils.displayIfInvisible = (elem) ->
	if !elem.is(":visible")
		elem.show()
	else
		elem.hide()

utils.getFilesList = (params, fn) ->
	serverCommunicator.createRequest(
		'GET',
		params.path+"?foldername="+params.value,
		null,
		(data) ->
			fn(data)
	)

utils.sendGetRequest = (path, fn) ->
	serverCommunicator.createRequest(
		'GET',
		path,
		null,
		(result) ->
			$("#serverMessages").text(result.message)
			$("#serverMessages").show()
			setTimeout(
				() ->
					$("#serverMessages").fadeOut('slow', () -> )
				, 3000
			)
			fn()
	)

utils.createTableWithActiveElements = (data, fn, parameters) ->
	convertStringArrayToTableRow = (string_array, id, type) ->
		tablerow = $("<tr  value='"+id+"'>")
		for str in string_array
			tablecell = renderCell(str, type)
			tablerow.append(tablecell)
		if parameters
			value = parameters.selector
			switch value
				when 'copperincome'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					lastcell = $("<td>")
					lastcell.append(button)
					tablerow.append(lastcell)
				when 'opticalincome'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					lastcell = $("<td>")
					lastcell.append(button)
					tablerow.append(lastcell)
					plan = $("<td><button value='"+id+"' class='btn btn'><i value='"+id+"' class='icon-list '></i></button></td>")
					plan.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							parameters.fn(value)
					)
					tablerow.append(plan)
				when 'opticalplan'
					button = $("<button class='btn btn-danger' income_id='"+parameters.income_id+"' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							income_id = e.target.getAttribute('income_id')
							fn(value, income_id)
					)
					lastcell = $("<td>")
					lastcell.append(button)
					tablerow.append(lastcell)
					del = $("<td><button value='"+id+"' class='btn btn-danger'><i value='"+id+"' class='icon-trash '></i></button></td>")
					del.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							parameters.fn(value)
					)
					tablerow.append(del)
				when 'boxesstore'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					boxquantity = $("<input class='input-small' id="+id+">")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					quantityfield = $("<td>")
					lastcell = $("<td>")
					lastcell.append(button)
					quantityfield.append(boxquantity)
					tablerow.append(quantityfield)
					tablerow.append(lastcell)
				when 'patchpanelesstore'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					patchpanelquantity = $("<input class='input-small' id="+id+">")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					quantityfield = $("<td>")
					lastcell = $("<td>")
					lastcell.append(button)
					quantityfield.append(patchpanelquantity)
					tablerow.append(quantityfield)
					tablerow.append(lastcell)
				when 'patchcordesstore'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					patchcordquantity = $("<input class='input-small' id="+id+">")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					quantityfield = $("<td>")
					lastcell = $("<td>")
					lastcell.append(button)
					quantityfield.append(patchcordquantity)
					tablerow.append(quantityfield)
					tablerow.append(lastcell)
				when 'pigtailsesstore'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					pigtailsquantity = $("<input class='input-small' id="+id+">")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					quantityfield = $("<td>")
					lastcell = $("<td>")
					lastcell.append(button)
					quantityfield.append(pigtailsquantity)
					tablerow.append(quantityfield)
					tablerow.append(lastcell)
				when 'socketsesstore'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					socketsquantity = $("<input class='input-small' id="+id+">")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					quantityfield = $("<td>")
					lastcell = $("<td>")
					lastcell.append(button)
					quantityfield.append(socketsquantity)
					tablerow.append(quantityfield)
					tablerow.append(lastcell)
				when 'workerscash'
					button = $("<button class='btn btn-danger' value='"+id+"'><i value='"+id+"' class='icon-edit '><i/></button>")
					button.bind(
						'click',
						(e) ->
							value = e.target.getAttribute('value')
							fn(value)
					)
					lastcell = $("<td>")
					lastcell.append(button)
					tablerow.append(lastcell)

		return tablerow

	convertStringArrayToTableHeaders = (string_array) ->
		tablerow = $('<tr>')
		for str in string_array
			tablecell = renderCell(str, 'headers')
			tablerow.append(tablecell)
		return tablerow

	renderCell = (str, type) ->
		open_elem = ''
		close_elem = ''
		switch type
			when 'values'
				open_elem = '<td style="word-wrap: break-word">'
				close_elem = '</td>'
			when 'headers'
				open_elem = '<th style="word-wrap: break-word">'
				close_elem = '</th>'
		return open_elem + str + close_elem

	$table = $('<table id="dataTable" class="'.concat(data.style).concat('">'))
	$table.attr('border', '1')
	$table.append($("<caption id='title'><b style='font-size:20px'>"+data.title+"</b></caption>"))
	$table.append(convertStringArrayToTableHeaders(data.headers))
	for row in data.values
		$table.append(convertStringArrayToTableRow(row.rowdata, row.id,  'values'))
	return $table


utils.saveImageToServer = (file, path, serverCallback) ->
	showProgressInfo = (message) ->
		$('div.progress').hide()
		$('strong.message').text(message)
		$('div.alert').show()
	$('div.progress').show();
	formData = new FormData();
	formData.append('file', file);
	xmlhttpreq = new XMLHttpRequest();
	xmlhttpreq.open('post', path, true);
	xmlhttpreq.upload.onprogress = (e) ->
		if (e.lengthComputable)
			percentage = (e.loaded / e.total) * 100;
			$('div.progress div.bar').css('width', percentage + '%');
	xmlhttpreq.onerror = (e) ->
		showProgressInfo('Під час завантаження сталася помилка!')
	xmlhttpreq.onload = () ->
		showProgressInfo(this.statusText);
	xmlhttpreq.onreadystatechange = () ->
		if (xmlhttpreq.readyState == 4)
			if (xmlhttpreq.status == 200)
				image = xmlhttpreq.responseText
				serverCallback(image)
	xmlhttpreq.send(formData)
