dataProcFn = require('./dataProcessingFunctions')
warehouseTableFns = require('./warehouseTableFns')
rowsnumber = 10
itemsSaver = require('./itemsSaver')
collectionsManager = require('./collectionsManager')


module.exports.start =  (app, db) ->
	app.post(
		'/saveitem',
		(req, res) ->
			console.log(req.body)
			dataProcFn.createItem(
				req,
				db,
				(item) ->
					itemsSaver.save(req.body.collection, item, res, db)
			)
	)

	app.get(
		'/usdadjust',
		(req, res) ->
			db.getByParam(
				'other',
				{ "adjust" : { $exists: true } }
				(items) ->
					dataProcFn.runResponse(res, items[0], 'application/json')
			)
			
	)

	app.get(
		'/getsaveditems',
		(req, res) ->
			req.query['login'] = req.session.login
			collectionsManager.processSavedItems(req.query, res, db)
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

