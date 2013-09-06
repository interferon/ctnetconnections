dataProcFn = require('./dataProcessingFunctions')
warehouseTableFns = require('./warehouseTableFns')
accessChecker = require('./accessChecker')
ROWS_NUMBER = 10

module.exports.start =  (app, db) ->

	app.post(
		'/saveboxtostore',
		accessChecker.checkAccess
		(req, res) ->
			db.save(
				'boxstore',
				req.body.data,
				(result) ->
					dataProcFn.runResponse(res, result, 'text/plain')
					saveWareHouseLogs('Надійшло на склад', 'Коробки', req.body.data.quantity, req.body.data.box_name)
			)
	)

	app.get(
		"/getboxesbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'boxstore',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createBoxBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.post(
		'/savepatchpaneltostore',
		accessChecker.checkAccess,
		(req, res) ->
			db.save(
				'patchpanelstore',
				req.body.data,
				(result) ->
					saveWareHouseLogs('Надійшло на склад', 'Патч-панель', req.body.data.quantity, req.body.data.patchpanel_name)
					dataProcFn.runResponse(res, result, 'text/plain')
			)

	)


	app.get(
		"/getpatchpanelesbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'patchpanelstore',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createpatchpanelBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.post(
		'/savepatchcordtostore',
		accessChecker.checkAccess,
		(req, res) ->
			db.save(
				'patchcordstore',
				req.body.data,
				(result) ->
					saveWareHouseLogs('Надійшло на склад', 'Патч-корд', req.body.data.quantity, "Довжина : "+req.body.data.patchcord_length+", Тип : "+req.body.data.patchcord_types)
					dataProcFn.runResponse(res, result, 'text/plain')
			)
	)

	app.get(
		"/getpatchcordesbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'patchcordstore',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createpatchcordBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.post(
		'/savepigtailstostore',
		accessChecker.checkAccess,
		(req, res) ->
			db.save(
				'pigtailsstore',
				req.body.data,
				(result) ->
					saveWareHouseLogs('Надійшло на склад','Піг-тейли', req.body.data.quantity, "Довжина : "+req.body.data.pigtails_length+", Тип : "+req.body.data.pigtails_types)
					dataProcFn.runResponse(res, result, 'text/plain')
			)

	)

	app.get(
		"/getpigtailsesbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'pigtailsstore',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createpigtailsBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.post(
		'/savesocketstostore',
		accessChecker.checkAccess,
		(req, res) ->
			db.save(
				'socketsstore',
				req.body.data,
				(result) ->
					saveWareHouseLogs('Надійшло на склад',"Розетки", req.body.data.quantity, "Тип : "+req.body.data.sockets_type)
					dataProcFn.runResponse(res, result, 'text/plain')
			)

	)

	app.get(
		"/getsocketsesbills",
		(req, res) ->
			query = req.query
			start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
			end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
			db.getByParam(
				'socketsstore',
				{"date": {"$gte": start, "$lte": end}}
				(items) ->
					tableData = dataProcFn.createsocketsBillsData(items)
					dataProcFn.runResponse(res, tableData, 'text/plain')
			)
	)

	app.get(
		"/getwarehouselogs",
		(req, res) ->
			switch req.query.type
				when 'lastlogs'
					db.getAll(
						'warehouselogs',
						(items) ->
							if items.length > ROWS_NUMBER
								items = items.slice(items.length - ROWS_NUMBER, items.length)
							tableData = warehouseTableFns.createWareHouseLogsTableData(items)
							dataProcFn.runResponse(res, tableData, 'text/plain')
					)
				when 'bydate'
					query = req.query
					start = new Date(query.syear, query.smonth, query.sday, 23, 59).toISOString()
					end = new Date(query.eyear, query.emonth, query.eday, 23, 59).toISOString()
					db.getByParam(
						'warehouselogs',
						{"date": {"$gte": start, "$lte": end}}
						(items) ->
							tableData = warehouseTableFns.createWareHouseLogsTableData(items)
							dataProcFn.runResponse(res, tableData, 'text/plain')
					)
	)

	app.post(
		"/savewarehouseuselog",
		(req, res) ->
			switch req.body.collection
				when "boxstore"
					db.getById(
						'boxstore',
						req.body.id,
						(data) ->
							saveWareHouseLogs('Використано', "Коробки", req.body.quantity, data[0].box_name)
							dataProcFn.runResponse(res, {result : "Вміст поля змінено!"}, 'text/plain')
					)
				when "patchpanelstore"
					db.getById(
						'patchpanelstore',
						req.body.id,
						(data) ->
							saveWareHouseLogs('Використано', 'Патч-панель', req.body.quantity, data[0].patchpanel_name)
							dataProcFn.runResponse(res, {result : "Вміст поля змінено!"}, 'text/plain')
					)
				when "patchcordstore"
					db.getById(
						'patchcordstore',
						req.body.id,
						(data) ->
							saveWareHouseLogs('Використано', 'Патч-корд', req.body.quantity, "Довжина : "+data[0].patchcord_length+", Тип : "+data[0].patchcord_types)
							dataProcFn.runResponse(res, {result : "Вміст поля змінено!"}, 'text/plain')
					)
				when "pigtailsstore"
					db.getById(
						'pigtailsstore',
						req.body.id,
						(data) ->
							saveWareHouseLogs('Використано','Піг-тейли', req.body.quantity, "Довжина : "+data[0].pigtails_length+", Тип : "+data[0].pigtails_types)
							dataProcFn.runResponse(res, {result : "Вміст поля змінено!"}, 'text/plain')
					)
				when "socketsstore"
					db.getById(
						'socketsstore',
						req.body.id,
						(data) ->
							saveWareHouseLogs('Використано',"Розетки", req.body.quantity, "Тип : "+data[0].sockets_type)
							dataProcFn.runResponse(res, {result : "Вміст поля змінено!"}, 'text/plain')
					)


	)

	saveWareHouseLogs = (action, name , quantity, type ) ->
		db.save(
			'warehouselogs',
			{"action" : action, "quantity" : quantity, "type" : type, "date" : new Date().toISOString(), "name" : name},
			() ->
				console.log("log saved")
		)

