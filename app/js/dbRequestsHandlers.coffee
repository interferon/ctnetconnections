dataProcFn = require('./dataProcessingFunctions')
warehouseTableFns = require('./warehouseTableFns')
rowsnumber = 10


module.exports.start =  (app, db) ->
	app.post(
		'/saveitem',
		(req, res) ->
			user = req.session.login
			dataProcFn.createItem(
				req,
				db,
				(item) ->
					db.save(
						req.body.collection,
						item,
						(result) ->
							dataProcFn.runResponse(res, result, 'text/plain')
					)
			)
	)

	app.get(
		'/getsaveditems',
		(req, res) ->
			query = req.query
			# get all the items from db collection
			db.getAll(
				query.collection,
				(items) ->
					switch query.collection
					# based on the querystring collection name denormalize db data (replace id with actual objects)
						when "buildings"
							# make equipment replace only if client side supply request with building id
							if query.building_id
								collections = ['streetnames','connectors', 'equipment']
								# asynchronously get data from collections and use it for objects replacement
								dataProcFn.asyncForEach(
									collections,
									db.getAll,
									(data) ->
										buildingswithRepStreets = dataProcFn.replaceStreetIdWithStreetNames(items, data.streetnames)
										buildingsWithReplacedEquipmentIds = dataProcFn.replaceBuildingBoxesIDsWithObjects(buildingswithRepStreets, data.equipment)
										connectors = dataProcFn.replaceBuildingsIdWithBuildings(data.connectors, buildingsWithReplacedEquipmentIds, ['parent', 'out'])
										buildingsinfo = dataProcFn.prepareBuildingsInfo(
											{
												'buildings' : buildingsWithReplacedEquipmentIds,
												'connectors' : connectors,
											},
											query.building_id
										)
										dataProcFn.runResponse(res, buildingsinfo, 'text/plain')
								)

							else
								# respond just with replaced street names
								db.getAll(
									'streetnames',
									(streetnames) ->
										buildings = dataProcFn.replaceStreetIdWithStreetNames(items, streetnames)
										dataProcFn.runResponse(res, buildings, 'text/plain')
								)
						when "connectors"
							collections = ['buildings', 'streetnames']
							dataProcFn.asyncForEach(
								collections,
								db.getAll,
								(data) ->
									buildings = dataProcFn.replaceStreetIdWithStreetNames(data.buildings, data.streetnames)
									connectors = dataProcFn.replaceBuildingsIdWithBuildings(items, buildings, ['parent', 'out'])
									dataProcFn.runResponse(res, connectors, 'text/plain')
							)
						when "logs"
							if items.length > rowsnumber
								items = items.slice(items.length - rowsnumber, items.length)
							tableData = dataProcFn.createLogsTableData(items)
							dataProcFn.runResponse(res, tableData, 'text/plain')
						when "copperincome"
							switch query.type
								when 'bills'
									tableData = dataProcFn.createCopperIncomeBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createCopperIncomeTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									tableData = dataProcFn.createCopperIncomeTableData(items, getCopperCableParamsForLogin(req.session.login))
									dataProcFn.runResponse(res, tableData, 'text/plain')
						when "copperuse"
							if items.length > rowsnumber
								items = items.slice(items.length - rowsnumber, items.length)
							tableData = dataProcFn.createCopperUseTableData(items)
							dataProcFn.runResponse(res, tableData, 'text/plain')
						when "opticalincome"
							switch query.type
								when 'bills'
									tableData = dataProcFn.createOpticalIncomeBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createOpticalIncomeTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									db.getAll(
										'opticalplans',
										(plans) ->
											for i in items
												filtered = plans.filter((e) -> i._id.toString() == e.income_id)
												totalplan = 0
												for plan in filtered
													totalplan += +plan.length
												i['totalplan'] = totalplan
												i['left'] = i.length - totalplan
											tableData = dataProcFn.createOpticalIncomeTableData(items, getOpticalCableParamsForLogin(req.session.login))
											dataProcFn.runResponse(res, tableData, 'text/plain')
									)
						when "opticallogs"
							if items.length > rowsnumber
								items = items.slice(items.length - rowsnumber, items.length)
							tableData = dataProcFn.createOpticalLogsTableData(items)
							dataProcFn.runResponse(res, tableData, 'text/plain')
						when "opticaluse"
							if items.length > rowsnumber
								items = items.slice(items.length - rowsnumber, items.length)
							tableData = dataProcFn.createOpticalUseTableData(items)
							dataProcFn.runResponse(res, tableData, 'text/plain')
						when "opticalplans"
							if query.type == 'onlyitems'
								dataProcFn.runResponse(res, items, 'text/plain')
							else
								tableData = dataProcFn.createOpticalPlansTableData(items, query.income_id)
								dataProcFn.runResponse(res, tableData, 'text/plain')
						when "boxstore"
							switch query.type
								when 'bills'
									if items.length > rowsnumber
										items = items.slice(items.length - rowsnumber, items.length)
									tableData = dataProcFn.createBoxBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createBoxesStoreTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									tableData = dataProcFn.createBoxesStoreTableData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
						when "patchpanelstore"
							switch query.type
								when 'bills'
									if items.length > rowsnumber
										items = items.slice(items.length - rowsnumber, items.length)
									tableData = dataProcFn.createpatchpanelBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createpatchpanelesStoreTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									tableData = dataProcFn.createpatchpanelesStoreTableData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
						when "patchcordstore"
							switch query.type
								when 'bills'
									if items.length > rowsnumber
										items = items.slice(items.length - rowsnumber, items.length)
									tableData = dataProcFn.createpatchcordBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createpatchcordesStoreTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									tableData = dataProcFn.createpatchcordesStoreTableData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
						when "pigtailsstore"
							switch query.type
								when 'bills'
									if items.length > rowsnumber
										items = items.slice(items.length - rowsnumber, items.length)
									tableData = dataProcFn.createpigtailsBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createpigtailsesStoreTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									tableData = dataProcFn.createpigtailsesStoreTableData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
						when "socketsstore"
							switch query.type
								when 'bills'
									if items.length > rowsnumber
										items = items.slice(items.length - rowsnumber, items.length)
									tableData = dataProcFn.createsocketsBillsData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
								when 'warehouse'
									tabledata = warehouseTableFns.createsocketsesStoreTableData(items)
									dataProcFn.runResponse(res, tabledata, 'text/plain')
								when 'incometable'
									tableData = dataProcFn.createsocketsesStoreTableData(items)
									dataProcFn.runResponse(res, tableData, 'text/plain')
						else
							dataProcFn.runResponse(res, items, 'text/plain')
			)
	)

	app.get(
		"/getcopperuse",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'copperuse',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createCopperUseTableData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.get(
		"/getcopperbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'copperincome',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createCopperIncomeBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.get(
		"/getopticaluse",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'opticaluse',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createOpticalUseTableData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)
	app.get(
		"/getopticallogs",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'opticallogs',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createOpticalLogsTableData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.get(
		"/getopticalbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'opticalincome',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createOpticalIncomeBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)


	app.get(
		"/getworkercash",
		(req, res) ->
			query = req.query
			db.getAll(
				'opticaluse',
				(items) ->

			)
	)

	app.get(
		"/getchangelogs",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'logs',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createLogsTableData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)


	# delete
	app.post(
		'/deleteitem',
		(req, res) ->
			db.remove(
				req.body.collection,
				req.body._id.toString(),
				(result) ->
					dataProcFn.runResponse(res, result, 'text/plain')
			)
	)


	# update
	app.post(
		'/update',
		(req, res) ->
			db.update(
				req.body.collection,
				req.body._id.toString(),
				req.body.data,
				req.body.update_type
				(result) ->
					dataProcFn.runResponse(res, result, 'text/plain')
			)
	)



	getCopperCableParamsForLogin = (user) ->
		switch user
			when "chovgan"
				return {
						fields : ["type", "pairs", "rope", "manufacturer", "serial", "length", "price", "user"],
						headers : ['№','Тип', 'К-сть пар', 'Трос',  'Виробник', 'Серійний №', "Довжина(м)","Ціна(грн)","Додав", 'Використати']
					}
			else
				return {
						fields : ["type", "pairs", "rope", "manufacturer", "serial", "length", "user"],
						headers : ['№', 'Тип', 'К-сть пар', 'Трос',  'Виробник', 'Серійний №', "Довжина(м)", "Додав", 'Використати']
					}

	getOpticalCableParamsForLogin = (user, plans) ->
		switch user
			when 'chovgan'
				return {
						fields : ["fibers", "rope", "manufacturer", "drum", "length", "totalplan", "left", "price", "user"],
						headers : ['№','Волокон', 'Трос', 'Виробник','Барабан',  'Довжина(м)', 'Заплановано(м)', 'Вільно(м)', 'Ціна (грн)', 'Додав', 'Запланувати','Переглянути план']
					}
			else
				return {
						fields : ["fibers", "rope", "manufacturer", "drum", "length", "totalplan", "left", "user"],
						headers : ['№','Волокон', 'Трос', 'Виробник','Барабан',  'Довжина(м)', 'Заплановано(м)', 'Вільно(м)', 'Додав', 'Запланувати','Переглянути план']
					}




