dataProcFn = require('./dataProcessingFunctions')

module.exports.save = (collection, item, res, db) ->

	save = () ->
		db.save(
			collection,
			item,
			(result) ->
				dataProcFn.runResponse(res, result, 'text/plain')
		)

	saver = {
		
		buildings : (item) ->
			db.getByParam(
				'buildings',
				{
					street : item.street,
					number : item.number
				},
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є такий будинок!"},
							'text/plain'
						)
					else
						save()
			)
		
		streetnames : (item) ->
			db.getByParam(
				'streetnames',
				{ name: { $regex: item.name, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є така вулиця!"},
							'text/plain'
						)
					else
						save()
			)
		
		boxesnames : (item) ->
			db.getByParam(
				'boxesnames',
				{ name: { $regex: item.name, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є така коробка!"},
							'text/plain'
						)
					else
						save()
			)
		
		commutatornames : (item) ->
			db.getByParam(
				'commutatornames',
				{ name: { $regex: item.name, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є такий комутатор!"},
							'text/plain'
						)
					else
						save()
			)
		
		upsnames : (item) ->
			db.getByParam(
				'upsnames',
				{ name: { $regex: item.name, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є такий UPS!"},
							'text/plain'
						)
					else
						save()
			)
		
		odfnames : (item) ->
			db.getByParam(
				'odfnames',
				{ name: { $regex: item.name, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є такий ODF!"},
							'text/plain'
						)
					else
						save()
			)
		
		workers : (item) ->
			db.getByParam(
				'workers',
				{ name: { $regex: item.name, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є такий монтажник!"},
							'text/plain'
						)
					else
						save()
			)
		
		users : (item) ->
			db.getByParam(
				'users',
				{ login: { $regex: item.login, $options: 'i' } },
				(items) ->
					if items.length != 0
						dataProcFn.runResponse(
							res,
							{"result" : "У базі вже є такий логін!"},
							'text/plain'
						)
					else
						save()
			)
	}

	if saver[collection]
		saver[collection](item)
	else
		save()

