mongojs = require('mongojs')
collections = [	'buildings',
				'equipment',
				'boxesnames',
				'streetnames',
				'commutatornames',
				'upsnames',
				'odfnames',
				'connectors',
				'logs',
				'users',
				'copperincome',
				'copperuse',
				'opticalplans'
				'opticaluse',
				'opticalincome',
				'opticallogs'
				'workers',
				'boxstore',
				'patchpanelstore',
				'patchcordstore',
				'pigtailsstore',
				'socketsstore',
				'workerscash',
				'warehouselogs',
				'sessions'
			]

db = mongojs.connect('ctnet', collections)



class Database

	constructor : () ->

	save : (collection, object, callback) ->
		db[collection].save(
			object,
			(error, saved) ->
				if error
					callback({"result" : "Error: "+error})
				else
					callback({"result" : "Збережено!", "object" : saved})
		)

	drop : (collection) ->
		db[collection].drop()

	getAll : (collection, fn) ->
		db[collection].find(
						(error, items) ->
							if error then console.log("not found") else fn(items)
					)

	getByParam : (collection, param, fn) ->
		db[collection].find(
			param,
			(error, items) ->
				if error then console.log("not found") else fn(items)
		)


	getById : (collection, id, fn) ->
		_id = db.ObjectId(id)
		db[collection].find(
			{"_id" : _id},
			(error, items) ->
				if error then console.log("not found") else fn(items)
		)

	remove : (collection, item_id, callback) ->
		id = db.ObjectId(item_id)
		db[collection].remove({_id : id})
		callback({result : "Видалено!"})
		return id

	removeByParam : (collection, param, callback) ->
		db[collection].remove(param)
		callback({result : "Видалено!"})

	update : (collection, item_id, update, update_type, callback) ->
		id = db.ObjectId(item_id)
		switch update_type
			when 'set'
				db[collection].update(
					{ "_id": id },
					{
						$set : update,
					}
					(err) ->
						if err
							callback({result : "Помилка!"})
						else
							callback({result : "Вміст поля змінено!"})
				)
			when 'push'
				db[collection].update(
					{ "_id": id },
					{
						$push : update,
					}
					(err) ->
						if err
							callback({result : "Помилка!"})
						else
							callback({result : "Вміст поля змінено!"})
				)
			when 'pull'
				db[collection].update(
					{ "_id": id },
					{
						$pull : update,
					}
					(err) ->
						if err
							callback({result : "Помилка!"})
						else
							callback({result : "Вміст поля змінено!"})
				)
			when 'inc'
				db[collection].update(
					{ "_id": id },
					{
						$inc : update,
					}
					(err) ->
						if err
							callback({result : "Помилка!"})
						else
							callback({result : "Вміст поля змінено!"})
				)
	findAndModify : (collection, item_id, data, fn) ->
		console.log(db.ObjectId(item_id))
		db[collection].findAndModify(
			{
				query: { id: db.ObjectId(item_id) },
				update: { $inc: data },
				new: true
			},
			(err, doc) ->
				fn(doc)
		)

	getCollections : () ->
		return collections

	dropDatabase : () ->
		db.dropDatabase()

module.exports.Database = Database