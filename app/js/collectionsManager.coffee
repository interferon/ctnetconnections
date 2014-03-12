dataProcFn = require('./dataProcessingFunctions')
warehouseTableFns = require('./warehouseTableFns')
dataProcFn = require('./dataProcessingFunctions')
rowsnumber = 10
itemsSaver = require('./itemsSaver')
accessParameters = require('./accessParameters')

processSavedItems = (params, res, db) ->
	collections[params.collection](params, res, db)


collections = {

	buildings : (params, res, db) ->
		# make equipment replace only if client side supply request with building id
		db.getAll(
			'buildings',
			(buildings) ->
				if params.building_id
					# asynchronously get data from collections and use it for objects replacement
					dataProcFn.asyncForEach(
						['streetnames', 'connectors', 'equipment'],
						db.getAll,
						(data) ->
							buildingswithRepStreets = dataProcFn.replaceStreetIdWithStreetNames(buildings, data.streetnames)
							buildingsWithReplacedEquipmentIds = dataProcFn.replaceBuildingBoxesIDsWithObjects(buildingswithRepStreets, data.equipment)
							connectors = dataProcFn.replaceBuildingsIdWithBuildings(data.connectors, buildingsWithReplacedEquipmentIds, ['parent', 'out'])
							buildingsinfo = dataProcFn.prepareBuildingsInfo(
								{
									'buildings' : buildingsWithReplacedEquipmentIds,
									'connectors' : connectors,
								},
								params.building_id
							)
							dataProcFn.runResponse(res, buildingsinfo, 'text/plain')
					)
				else
					# respond just with replaced street names
					db.getAll(
						'streetnames',
						(streetnames) ->
							buildings = dataProcFn.replaceStreetIdWithStreetNames(buildings, streetnames)
							dataProcFn.runResponse(res, buildings, 'text/plain')
					)
		)

	connectors : (params, res, db) -> 
		db.getAll(
			'connectors',
			(items) ->
				dataProcFn.asyncForEach(
					['buildings', 'streetnames'],
					db.getAll,
					(data) ->
						buildings = dataProcFn.replaceStreetIdWithStreetNames(data.buildings, data.streetnames)
						connectors = dataProcFn.replaceBuildingsIdWithBuildings(items, buildings, ['parent', 'out'])
						dataProcFn.runResponse(res, connectors, 'text/plain')
				)
		)
		
	logs : (params, res, db) ->
		db.getAll(
			'logs',
			(connectors) ->
				if connectors.length > rowsnumber
					connectors = connectors.slice(connectors.length - rowsnumber, connectors.length)
				tableData = dataProcFn.createLogsTableData(connectors)
				dataProcFn.runResponse(res, tableData, 'text/plain')
		)

	copperincome : (params, res, db) ->
		db.getAll(
			'copperincome',
			(items) ->
				switch params.type
					when 'bills'
						tableData = dataProcFn.createCopperIncomeBillsData(items)
						dataProcFn.runResponse(res, tableData, 'text/plain')
					when 'warehouse'
						tabledata = warehouseTableFns.createCopperIncomeTableData(items)
						dataProcFn.runResponse(res, tabledata, 'text/plain')
					when 'incometable'
						getCableTableParamsForLogin(
							db,
							params.login,
							'copper',
							(tableparams) ->
								tableData = dataProcFn.createCopperIncomeTableData(items, tableparams)
								dataProcFn.runResponse(res, tableData, 'text/plain')
						)
		)

	copperuse : (params, res, db) ->
		db.getAll(
			'copperuse',
			(items) ->
				if items.length > rowsnumber
					items = items.slice(items.length - rowsnumber, items.length)
				tableData = dataProcFn.createCopperUseTableData(items)
				dataProcFn.runResponse(res, tableData, 'text/plain')
		)

	opticalincome : (params, res, db) ->
		db.getAll(
			'opticalincome',
			(items) ->
				switch params.type
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
								getCableTableParamsForLogin(
									db,
									params.login,
									'optics',
									(tableparams) ->
										tableData = dataProcFn.createOpticalIncomeTableData(items, tableparams)
										dataProcFn.runResponse(res, tableData, 'text/plain')
								)		
						)
		)

	opticallogs : (params, res, db) ->
		db.getAll(
			'opticallogs',
			(items) ->
				if items.length > rowsnumber
					items = items.slice(items.length - rowsnumber, items.length)
				tableData = dataProcFn.createOpticalLogsTableData(items)
				dataProcFn.runResponse(res, tableData, 'text/plain')
		)

	opticaluse : (params, res, db) ->
		db.getAll(
			'opticaluse',
			(items) ->
				if items.length > rowsnumber
					items = items.slice(items.length - rowsnumber, items.length)
				tableData = dataProcFn.createOpticalUseTableData(items)
				dataProcFn.runResponse(res, tableData, 'text/plain')
		)

	opticalplans : (params, res, db) ->
		db.getAll(
			'opticalplans',
			(items) ->
				if params.type == 'onlyitems'
					dataProcFn.runResponse(res, items, 'text/plain')
				else
					tableData = dataProcFn.createOpticalPlansTableData(items, params.income_id)
					dataProcFn.runResponse(res, tableData, 'text/plain')
		)

	boxstore : (params, res, db) ->
		db.getAll(
			'boxstore',
			(items) ->
				switch params.type
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
		)

	patchpanelstore : (params, res, db) ->
		db.getAll(
			'patchpanelstore',
			(items) ->
				switch params.type
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
		)

	patchcordstore : (params, res, db) ->
		db.getAll(
			'patchcordstore',
			(items) ->
				switch params.type
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
		)

	pigtailsstore : (params, res, db) ->
		db.getAll(
			'pigtailsstore',
			(items) ->
				switch params.type
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
		)

	socketsstore : (params, res, db) ->
		db.getAll(
			'socketsstore',
			(items) ->
				switch params.type
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
		)
	
	equipment : (params, res, db) ->
		db.getAll(
			'equipment',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	boxesnames : (params, res, db) ->
		db.getAll(
			'boxesnames',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	streetnames : (params, res, db) ->
		db.getAll(
			'streetnames',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	commutatornames : (params, res, db) ->
		db.getAll(
			'commutatornames',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	upsnames : (params, res, db) ->
		db.getAll(
			'upsnames',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	odfnames : (params, res, db) ->
		db.getAll(
			'odfnames',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	users : (params, res, db) ->
		db.getAll(
			'users',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	workers : (params, res, db) ->
		db.getAll(
			'workers',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	workerscash : (params, res, db) ->
		db.getAll(
			'workerscash',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	warehouselogs : (params, res, db) ->
		db.getAll(
			'warehouselogs',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)

	sessions : (params, res, db) ->
		db.getAll(
			'sessions',
			(items) ->
				dataProcFn.runResponse(res, items, 'text/plain')
		)	
}

getCableTableParamsForLogin = (db, user, cabletype, cb) ->
	db.getByParam(
		'accesslevel',
		{user : user},
		(data) ->
			if data[0]
				accessLevel = data[0].level
			else
				accessLevel = 'standart'
			cb(accessParameters[cabletype][accessLevel])
	)


deleteUser = (login, res, db) ->
	db.getByParam('users', { login: { $regex: login, $options: 'i' } }, (items) ->
		if items.length == 0
			dataProcFn.runResponse(
				res,
				{"result" : "У базі немає такого логіна!"},
				'text/plain'
			)
		else
			db.removeByParam('users', {login : login}, (result) ->
				if result
					res.setHeader('Content-Type', 'text/plain')
					res.end(JSON.stringify({"result" : "Користувача видалено!"}))
				else
					res.end(JSON.stringify({"result" : "Такого користувача немає в базі!"}))
			)
				
	)


deleteBuilding = (id, res, db) ->
	db.remove('buildings', id.toString(), (result) ->
		dataProcFn.runResponse(res, result, 'text/plain')
	)

saveUsdAdjust = (adjust, res, db) ->
	db.removeByParam(
		'other',
		{ "adjust" : { $exists: true } }
		() ->
			db.save('other', {adjust : adjust}, (result) ->
				dataProcFn.runResponse(res, result, 'text/plain')
			)
	)
	
	


module.exports.processSavedItems = processSavedItems
module.exports.deleteUser = deleteUser
module.exports.deleteBuilding = deleteBuilding
module.exports.saveUsdAdjust = saveUsdAdjust