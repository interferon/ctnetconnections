core = require('./core')
fs = require('fs')

replaceStreetIdWithStreetNames = (buildings, streetnames) ->
			for b in buildings
				b.street = streetnames.filter((e) -> e._id.toString() is b.street)[0].name
			return buildings

replaceBuildingsIdWithBuildings = (items, buildings, params) ->
	for i in items
		for param in params
			i[param] = buildings.filter((e) -> e._id.toString() is i[param])[0]
	return items


replaceBuildingBoxesIDsWithObjects = (buildings, equipment) ->
	replace = (data) ->
		objects = []
		for elem in data
			elem = equipment.filter((e) -> e._id.toString() is elem)[0]
			objects.push(elem)
		return objects

	for building in buildings
		building.boxes = replace(building.boxes)
		for box in building.boxes
			box.odf = replace(box.odf)
			box.upses = replace(box.upses)
			box.commutators = replace(box.commutators)

	return buildings



asyncForEach = (items, fn , callback) ->
	result = {}
	count = 0
	for item in items
		do (item) ->
				fn(
					item,
					(fnResult) ->
						result[item] = fnResult
						count++
						if count == items.length then callback(result)
				)

createCableUseTableData = (items) ->
	totalcableuse = 0
	values = []
	for i in items
		rowdata = []
		rowdata.push(i.contract)
		rowdata.push(i.users.toString())
		rowdata.push(i.cablewaste)
		rowdata.push(i.type)
		rowdata.push(i.manufacturer)
		rowdata.push(i.date.split("T")[0])
		values.push(rowdata)
		totalcableuse += +i.cablewaste
	values.push(['Всього', '', totalcableuse, '', '', ''])
	return  {
		"title" : 'Звіт з використання кабелю'
		"headers" : ['Номер договору','Монтажники', 'Кількість кабелю (м)', 'Тип', 'Марка',  'Дата']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createCableIncomeTableData = (items) ->
	totalcableincome = 0
	values = []
	for i in items
		rowdata = []
		rowdata.push(i.manufacturer)
		rowdata.push(i.type)
		rowdata.push(i.income)
		rowdata.push(i.date.split("T")[0])
		values.push(rowdata)
		totalcableincome += +i.income
	values.push(['Всього', '', totalcableincome, ''])
	return  {
		"title" : 'Історія приходу кабеля'
		"headers" : ['Виробник', 'Тип', 'Прихід', 'Дата']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createLogsTableData = (items) ->
	values = []
	for i in items
		rowdata = []
		rowdata.push(i.item)
		rowdata.push(i.action)
		rowdata.push(i.adress)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.user)
		values.push(rowdata)
	return  {
		"title" : 'Історія змін в обладнанні'
		"headers" : ['Обладнання', 'Дія', 'Адреса',  'Дата', 'Користувач']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createCopperIncomeTableData = (items, params) ->
	values = []
	count = 1
	for i in items
		if i.length != 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			for field in params.fields
				rowdata.push(i[field])
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Наявний кабель'
		"headers" : params.headers
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createCopperUseTableData = (items) ->
	values = []
	for i in items
		rowdata = []
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.contract)
		rowdata.push(i.length)
		rowdata.push(i.workers)
		rowdata.push(i.user)
		values.push(rowdata)
	return  {
		"title" : 'Використаний кабель'
		"headers" : ['Дата', 'Призначення', 'Довжина (м)','Монтажники',  'Додав']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createOpticalIncomeTableData = (items, params) ->
	values = []
	count = 1
	for i in items
		if i.length != 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			for field in params.fields
				rowdata.push(i[field])
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Наявний кабель'
		"headers" : params.headers
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createOpticalPlansTableData = (items, income_id) ->
	items = items.filter((elem)-> elem.income_id.toString() == income_id)
	values = []
	for i in items
		datarow = {
			"id" : i._id,
			"rowdata" : ""
		}
		rowdata = []
		rowdata.push(i.length)
		rowdata.push(i.intensions)
		rowdata.push(i.user)
		datarow.rowdata = rowdata
		values.push(datarow)
	return  {
		planTableData : {
			"title" : 'Заплановане використання'
			"headers" : ['Довжина (м)', 'Призначення','Запланував', 'Виконати план', 'Видалити']
			"values" : values
			"style" : "table table-bordered table-hover table-condensed"
		},
		income_id : income_id
	}

createOpticalUseTableData = (items) ->
	values = []
	for i in items
		rowdata = []
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.intensions)
		rowdata.push(i.length)
		rowdata.push(i.workers)
		rowdata.push(i.user)
		values.push(rowdata)
	return  {
		"title" : 'Виконані плани'
		"headers" : ['Дата', 'Призначення', 'Довжина (м)','Монтажники',  'Додав']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createOpticalLogsTableData = (items) ->
	values = []
	for i in items
		rowdata = []
		rowdata.push(i.action)
		rowdata.push(i.length)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.intensions)
		rowdata.push(i.cable)
		rowdata.push(i.user)
		values.push(rowdata)
	return  {
		"title" : 'Лог змін'
		"headers" : ['Дія', 'Довжина', 'Дата','Заплановане використання',  'Кабель', 'Користувач']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createOpticalIncomeBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.fibers)
		rowdata.push(i.manufacturer)
		rowdata.push(i.initiallength)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)

		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Волокон','Виробник','Довжина(м)','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createCopperIncomeBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.pairs)
		rowdata.push(i.manufacturer)
		rowdata.push(i.initiallength)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='/app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)
		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Пар','Виробник','Довжина(м)','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createBoxesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.box_name)
			rowdata.push(i.quantity)
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Коробки на складі'
		"headers" : ['№','Тип','На складі', 'К-сть','Використати']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createBoxBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.box_name)
		rowdata.push(i.init_quantity)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='/app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)

		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Тип','К-сть','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpatchpanelesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.patchpanel_name)
			rowdata.push(i.quantity)
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Патч-панелі на складі'
		"headers" : ['№','Тип','На складі', 'К-сть','Використати']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpatchpanelBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.patchpanel_name)
		rowdata.push(i.init_quantity)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='/app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)
		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Тип','К-сть','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpatchcordesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.patchcord_length)
			rowdata.push(i.patchcord_types)
			rowdata.push(i.quantity)
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Патч-корди на складі'
		"headers" : ['№','Довжина','Тип','На складі','К-сть','Використати']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpatchcordBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.patchcord_types)
		rowdata.push(i.init_quantity)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='/app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)

		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Тип','К-сть','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}


createpigtailsesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.pigtails_length)
			rowdata.push(i.pigtails_types)
			rowdata.push(i.quantity)
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Піг-тейли на складі'
		"headers" :  ['№','Довжина','Тип','На складі','К-сть','Використати']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createpigtailsBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.pigtails_types)
		rowdata.push(i.init_quantity)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='/app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)

		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Тип','К-сть','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createsocketsesStoreTableData = (items) ->
	values = []
	count = 1
	for i in items
		if i.quantity > 0
			datarow = {
				"id" : i._id,
				"rowdata" : ""
			}
			rowdata = []
			rowdata.push(count)
			rowdata.push(i.sockets_type)
			rowdata.push(i.quantity)
			datarow.rowdata = rowdata
			values.push(datarow)
			count++
	return  {
		"title" : 'Розетки на складі'
		"headers" : ['№','Тип','На складі', 'К-сть','Використати']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}

createsocketsBillsData = (items) ->
	values = []
	count = 1
	for i in items
		rowdata = []
		rowdata.push(count)
		rowdata.push(i.date.split("T")[0])
		rowdata.push(i.sockets_type)
		rowdata.push(i.init_quantity)
		rowdata.push(
			"<a href=javascript:document.forms['"+i.image+"'].submit()><img src='/app/images/billsimgs/"+i.image+"'style='height: 30px; width: 30 px;' ></a><form method='get' id='"+i.image+"' action='/app/images/billsimgs/"+i.image+"'></form>"
		)

		values.push(rowdata)
		count++
	return  {
		"title" : 'Фото накладних'
		"headers" : ['№','Дата','Тип','К-сть','Фото']
		"values" : values
		"style" : "table table-bordered table-hover table-condensed"
	}




prepareBuildingsInfo = (dbdata, building_id) ->

	building = dbdata.buildings.filter((b)-> b._id.toString() is building_id)[0]

	prepareGeneralInfo = (building) ->

		return {
			"name" : building.street + ", " + building.number,
			"entrance" : building.entrance,
			"type" : building.type,
			"flat" : building.flat,
			"ladder" : building.ladder,
			"info" : building.info,
		}

	prepareConnectionsInfo = (building, connectors) ->
		incoming = []
		outgoing = []
		for c in connectors
			if building._id is c.parent._id
				outgoing.push(
					{
						"building_name" : c.out.street+", "+c.out.number,
						"type" : c.type,
						"building_id" : c.out._id
					}
				)
			if building._id is c.out._id
				incoming.push(
					{
						"building_name" : c.parent.street+", "+c.parent.number,
						"type" : c.type,
						"building_id": c.parent._id
					}
				)
		return {
					"outgoing_connections" : outgoing,
					"incoming_connections" : incoming
				}

	prepareEquipmentInfo = (building) ->

		prepare = (data, params) ->

			elems = []
			for d in data
				elem = {}
				for param in params
					elem[param] = d[param]
				elems.push(elem)
			return elems


		commutators = null
		odf = null
		upses = null


		equipmentinfo = []
		for box in building.boxes
			equipmentinfo.push(
				{
					"box" :  {"_id" : box._id, "name" : box.name}
					"commutators" : prepare(box.commutators, ['_id', 'name', 'free', 'manageable'])
					"odf" : prepare(box.odf, ['_id', 'name', 'fotopath'])
					"upses" : prepare(box.upses, ['_id', 'name'])
				}
			)

		return equipmentinfo


	return {
		"general" : prepareGeneralInfo(building),
		"connections" : prepareConnectionsInfo(building, dbdata.connectors)
		"equipment" : prepareEquipmentInfo(building)
	}

createItem = (req, db, callback) ->
	item = null
	switch req.body.collection
		when "commutatornames"
			item = core.createCommutator(
				{
					"name" : req.body.name
					"manageable" : req.body.manageable
					"free" : 0
				}
			)
			callback(item)

		when "buildings"
			item = core.createBuilding(
				{
					"type" : req.body.item.type
					"street" : req.body.item.street
					"number" : req.body.item.number
					"entrance" : ""
					"flat" : ""
					"ladder" : ""
					"info" : ""
					"boxes" : []
				}
			)
			callback(item)

		when "connectors"
			callback(core.createBuildingsConnector(req.body.item))

		when "cableincome"
			callback({
				"income" : req.body.data.income,
				"date" : req.body.data.date,
				"manufacturer" : req.body.data.manufacturer,
				"type" : req.body.data.type
				})

		when "cableuse"
			callback({
				"contract" : req.body.data.contract,
				"cablewaste" : req.body.data.cablewaste,
				"users" : req.body.data.users,
				"date" : req.body.data.date,
				"type" : req.body.data.type,
				"manufacturer": req.body.data.manufacturer
				})

		when 'logs'
			item = req.body.data
			item.user = req.session.login
			callback(item)

		when 'opticallogs'
			item = req.body.data
			item.user = req.session.login
			db.getById(
				'opticalincome',
				req.body.income_id
				(income) ->
					cable = income[0].manufacturer+", волокон : "+income[0].fibers
					item.cable = cable
					callback(item)
			)

		when 'equipment'
			switch req.body.type
				when 'box'
					_id = req.body._id
					db.getById(
						'boxesnames',
						_id,
						(box) ->
							item = core.createBox(
								{
									"name" : box[0].name
									"commutators" : []
									"upses" : []
									"odf" : []
								}
							)
							callback(item)
					)
				when 'commutator'
					_id = req.body.data._id
					db.getById(
						'commutatornames',
						_id,
						(commutator) ->
							item = core.createCommutator(
								{
									"name" : commutator[0].name
									"free" : 0
									"manageable" : false
								}
							)
							callback(item)
					)
				when 'mancommutator'
					_id = req.body.data._id
					db.getById(
						'commutatornames',
						_id,
						(commutator) ->
							item = core.createManageableCommutator(
								{
									"name" : commutator[0].name
									"ip" : req.body.data.ip
									"login": req.body.data.login
									"pass": req.body.data.pass
									"free" : 0
									"manageable" : true
								}
							)
							callback(item)
					)

				when 'ups'
					_id = req.body.data._id
					db.getById(
						'upsnames',
						_id,
						(ups) ->
							item = core.createUps(
								{
									"name" : ups[0].name
								}
							)
							callback(item)
					)
				when 'odf'
					_id = req.body.data._id
					db.getById(
						'odfnames',
						_id,
						(odf) ->
							item = core.createODF(
								{
									"name" : odf[0].name
								}
							)
							callback(item)
					)
		else
			item = {"name" : req.body.name}
			callback(item)



writeImageToDisk = (path, data) ->
	fs.writeFile(
		path,
		data,
		(err) ->
			if err
				console.log(err)
			console.log('written')
	)

createLogObject = (item, action, user) ->
	return core.createLogObject(
		{
			"item" : item
			"action" : action
			"date" : getCurrentDateInMyFormat()
			"user" : user
		}
	)



runResponse = (res, data, content_type) ->
	res.setHeader('Content-Type', content_type)
	res.end(JSON.stringify(data))


getCurrentDateInMyFormat = () ->
	date = new Date().toISOString().substring(0,10).split("-")
	newdate = date[2]+"-"+date[1]+"-"+date[0]
	return newdate

module.exports.replaceStreetIdWithStreetNames = replaceStreetIdWithStreetNames
module.exports.replaceBuildingsIdWithBuildings = replaceBuildingsIdWithBuildings
module.exports.prepareBuildingsInfo = prepareBuildingsInfo
module.exports.createCableUseTableData = createCableUseTableData
module.exports.createCableIncomeTableData = createCableIncomeTableData
module.exports.asyncForEach = asyncForEach
module.exports.createItem = createItem
module.exports.runResponse = runResponse
module.exports.replaceBuildingBoxesIDsWithObjects = replaceBuildingBoxesIDsWithObjects
module.exports.createLogObject = createLogObject
module.exports.createLogsTableData = createLogsTableData
module.exports.createCopperIncomeTableData = createCopperIncomeTableData
module.exports.createCopperUseTableData = createCopperUseTableData
module.exports.createOpticalIncomeTableData = createOpticalIncomeTableData
module.exports.createOpticalPlansTableData = createOpticalPlansTableData
module.exports.createOpticalUseTableData = createOpticalUseTableData
module.exports.createOpticalLogsTableData = createOpticalLogsTableData
module.exports.createOpticalIncomeBillsData = createOpticalIncomeBillsData
module.exports.createCopperIncomeBillsData = createCopperIncomeBillsData
module.exports.createBoxesStoreTableData = createBoxesStoreTableData
module.exports.createBoxBillsData = createBoxBillsData
module.exports.createpatchpanelesStoreTableData = createpatchpanelesStoreTableData
module.exports.createpatchpanelBillsData = createpatchpanelBillsData
module.exports.createpatchcordesStoreTableData = createpatchcordesStoreTableData
module.exports.createpatchcordBillsData = createpatchcordBillsData
module.exports.createpigtailsesStoreTableData = createpigtailsesStoreTableData
module.exports.createpigtailsBillsData = createpigtailsBillsData
module.exports.createsocketsesStoreTableData = createsocketsesStoreTableData
module.exports.createsocketsBillsData = createsocketsBillsData