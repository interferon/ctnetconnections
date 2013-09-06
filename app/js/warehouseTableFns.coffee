createCopperIncomeTableData = (items) ->
	fields = ["type", "pairs", "rope", "manufacturer", "serial", "length"]
	values = []
	count = 1
	for i in items
		if i.length != 0
			rowdata = []
			rowdata.push(count)
			for field in fields
				rowdata.push(i[field])
			values.push(rowdata)
			count++
	return  {
		"title" : 'Звита пара'
		"headers" : ['№','Тип', 'К-сть пар', 'Трос',  'Виробник', 'Серійний №', "Довжина(м)"]
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createOpticalIncomeTableData = (items) ->
	fields = ["fibers", "rope", "manufacturer", "drum", "length"]
	values = []
	count = 1
	for i in items
		if i.length != 0
			rowdata = []
			rowdata.push(count)
			for field in fields
				rowdata.push(i[field])
			values.push(rowdata)
			count++
	return  {
		"title" : 'Оптоволокно'
		"headers" : ['№','Волокон', 'Трос', 'Виробник','Барабан',  'Довжина(м)']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createBoxesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.box_name)
			rowdata.push(i.quantity)
			values.push(rowdata)
			count++
	return  {
		"title" : 'Коробки на складі'
		"headers" : ['№','Тип','Кількість']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpatchpanelesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.patchpanel_name)
			rowdata.push(i.quantity)
			values.push(rowdata)
			count++
	return  {
		"title" : 'Патч-панелі на складі'
		"headers" : ['№','Тип','Кількість']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpatchcordesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.patchcord_length)
			rowdata.push(i.patchcord_types)
			rowdata.push(i.quantity)
			values.push(rowdata)
			count++
	return  {
		"title" : 'Патч-корди на складі'
		"headers" : ['№','Довжина','Тип','Кількість']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpigtailsesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.pigtails_length)
			rowdata.push(i.pigtails_types)
			rowdata.push(i.quantity)
			values.push(rowdata)
			count++
	return  {
		"title" : 'Піг-тейли на складі'
		"headers" :  ['№','Довжина','Тип','Кількість']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createsocketsesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.sockets_type)
			rowdata.push(i.quantity)
			values.push(rowdata)
			count++
	return  {
		"title" : 'Розетки на складі'
		"headers" : ['№','Тип','Кількість']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createWareHouseLogsTableData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.action)
		rowdata.push(i.name)
		rowdata.push(i.type)
		rowdata.push(i.quantity)
		rowdata.push(i.date.split("T")[0])
		values.push(rowdata)
		count++
	return  {
		"title" : 'Лог змін в обладнанні'
		"headers" : ['№','Дія','Тип','Назва','Кількість','Дата']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

module.exports.createBoxesStoreTableData = createBoxesStoreTableData
module.exports.createCopperIncomeTableData = createCopperIncomeTableData
module.exports.createOpticalIncomeTableData = createOpticalIncomeTableData
module.exports.createsocketsesStoreTableData = createsocketsesStoreTableData
module.exports.createpigtailsesStoreTableData = createpigtailsesStoreTableData
module.exports.createpatchcordesStoreTableData = createpatchcordesStoreTableData
module.exports.createpatchpanelesStoreTableData = createpatchpanelesStoreTableData
module.exports.createWareHouseLogsTableData = createWareHouseLogsTableData