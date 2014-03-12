dataProcFn = require('./dataProcessingFunctions')
path = require('path')
accessChecker = require('./accessChecker')
collectionsManager = require('./collectionsManager')

module.exports.start = (app, db) ->

	checkAuth = (req, res, next) ->
		if (!req.session.login || !req.session.pass)
			res.redirect('/login')
		else
			next()

	app.get(
		'/',
		checkAuth,
		(req, res) ->
			res.sendfile(path.join(__dirname, '/../view/index.html'))
	)

	app.get(
		'/admin',
		checkAuth,
		accessChecker.checkAccess,
		(req, res) ->
			res.sendfile(path.join(__dirname, '/../view/admin.html'))
	)

	app.get(
		'/notallowed',
		(req, res) ->
			res.send('Access denied!')
	)

	app.get(
		'/logout',
		(req, res) ->
			req.session.destroy()
			db.removeByParam(
				'sessions',
				{"_id" : req.sessionID.toString()},
				(result) ->
					res.redirect('/login')
			)
	)

	app.get(
		'/warehouse',
		checkAuth,
		(req, res) ->
			res.sendfile(path.join(__dirname,'/../view/warehouse.html'))
	)

	app.post('/login',
		(req, res) ->
			login = req.body.login
			pass = req.body.pass
			db.getByParam(
				'users',
				{login : login},
				(user) ->
					if user[0]
						if user[0].pass is pass
							req.session.login = login
							req.session.pass = pass
							res.redirect('/')
						else
							res.sendfile(path.join(__dirname,'/../view/loginwrong.html'))
					else
						res.sendfile(path.join(__dirname,'/../view/loginwrong.html'))
			)
	)

	app.get(
		'/login',
		(req, res) ->
			res.sendfile(path.join(__dirname,'/../view/login.html'))
	)

	app.get(
		'/calc',
		checkAuth
		(req, res) ->
			res.sendfile(path.join(__dirname,'/../view/calc.html'))
	)

	app.post(
		'/deleteuser',
		checkAuth,
		accessChecker.checkAccess,
		(req, res) ->
			collectionsManager.deleteUser(req.body.login, res, db)
	)

	app.post(
		'/deletebuilding',
		checkAuth,
		accessChecker.checkAccess,
		(req, res) ->
			collectionsManager.deleteBuilding(req.body.id, res, db)
	)

	app.post(
		'/deleteboxequipment',
		(req, res) ->
			db.getById(
				'equipment',
				req.body.box_id,
				(box) ->
					ids = []
					ids = ids.concat(box[0].commutators).concat(box[0].upses).concat(box[0].odf)
					for id in ids
						db.remove(
							'equipment',
							id,
							() ->
						)
					res.setHeader('Content-Type', 'text/plain')
					res.end(JSON.stringify({"result" : "Related equipment deleted"}))
			)
	)

	app.post(
		'/saveusdadjust',
		checkAuth,
		accessChecker.checkAccess,
		(req, res) ->
			collectionsManager.saveUsdAdjust(req.body.adjust, res, db)
	)

	app.post(
		'/savecopperincome',
		accessChecker.checkAccess,
		(req, res) ->
			user = req.session.login
			item = req.body
			item.user = user
			db.save(
				'copperincome',
				item,
				(result) ->
					res.setHeader('Content-Type', 'text/plain')
					res.end(JSON.stringify(result))
			)
	)

	app.post(
		'/savecopperuse',
		accessChecker.checkAccess,
		(req, res) ->
			length = 0
			user = req.session.login
			item = req.body.data
			item.user = user
			db.getById(
				'copperincome',
				req.body.income_id,
				(income) ->
						length = +income[0].length - +item.length
						if length >= 0
							db.update(
								"copperincome",
								req.body.income_id,
								{"length" : length },
								'set',
								() ->
									saveCopperUse(item, res)
							)
						else
							length = length * -1
							res.setHeader('Content-Type', 'text/plain')
							res.end(JSON.stringify({result : "Допустима довжина кабелю для даного зразка "+income[0].length+" метрів"}))
			)
	)

	saveCopperUse  = (item, res) ->
		db.save(
			'copperuse',
			item,
			(result) ->
				res.setHeader('Content-Type', 'text/plain')
				res.end(JSON.stringify(result))
		)


	app.post(
		'/saveopticalincome',
		accessChecker.checkAccess,
		(req, res) ->
			user = req.session.login
			item = req.body
			item.user = user
			db.save(
				'opticalincome',
				item,
				(result) ->
					res.setHeader('Content-Type', 'text/plain')
					res.end(JSON.stringify(result))
			)
	)

	app.post(
		'/savecableplan',
		accessChecker.checkAccess,
		(req, res) ->
			user = req.session.login
			item = req.body
			item.user = user
			db.getById(
				'opticalincome',
				item.income_id,
				(income) ->
					income = income[0]
					db.getByParam(
						'opticalplans',
						{income_id : income._id.toString()}
						(plans) ->
							totalplanned = 0
							for plan in plans
								totalplanned += +plan.length
							unplanned = +income.length - totalplanned
							if unplanned >= item.length
								db.save(
									'opticalplans',
									item,
									(result) ->
										db.save(
											'opticallogs',
											{
												"action" : 'Запланував використання кабелю'
												"length" : item.length
												"date" : new Date().toISOString()
												"intensions" : item.intensions
												"cable" : income.manufacturer+", волокон : "+income.fibers
												"user" : req.session.login
											},
											() ->
										)
										res.setHeader('Content-Type', 'text/plain')
										res.end(JSON.stringify(result))
								)

							else
								res.setHeader('Content-Type', 'text/plain')
								res.end(JSON.stringify({result: 'Недостатньо вільного кабелю! Максимальна довжина для планування : '+unplanned+' (м)'}))
					)
			)
	)

	app.post(
		'/saveopticaluse',
		accessChecker.checkAccess,
		(req, res) ->
			length = 0
			user = req.session.login
			opticalusedata = req.body.data
			opticalusedata.user = user
			plan_id = req.body.plan_id
			income_id = req.body.income_id
			db.getById(
				'opticalplans',
				plan_id,
				(plan) ->
					plan = plan[0]
					opticalusedata.intensions = plan.intensions
					matchresult = ''
					plannedcablelengthleft = plan.length - opticalusedata.length
					if plannedcablelengthleft<0
						matchresult = 'overused'
					else
						matchresult = 'ok'

					switch matchresult
						when 'ok'
							db.getById(
								'opticalincome',
								income_id,
								(income) ->
									incomeobj = income[0]
									newlength = +incomeobj.length - +opticalusedata.length
									db.update(
										"opticalincome",
										income_id,
										{"length" : newlength },
										'set',
										() ->
											saveOpticalUse(opticalusedata, res, plan.intensionstype)
											saveOpticalUseLog(
												opticalusedata.length,
												opticalusedata.intensions,
												incomeobj.manufacturer,
												incomeobj.fibers,
												req.session.login
											)
											if plan.intensionstype == "1"
												saveWorkerCash(opticalusedata)
											db.remove(
												'opticalplans',
												plan_id,
												() ->
											)
									)
							)
						when 'overused'
							db.getById(
								'opticalincome',
								income_id,
								(income) ->
									incomeobj = income[0]
									# get all plans for this cable
									db.getByParam(
										'opticalplans',
										{income_id : incomeobj._id.toString()}
										(plans) ->
											# calculate total plans length
											totalplanned = 0
											for plan in plans
												totalplanned += +plan.length
											#  if actual cable use no more then actual cable left
											if (+incomeobj.length - totalplanned) >= (plannedcablelengthleft * -1)
												db.update(
													"opticalincome",
													income_id,
													{"length" : +incomeobj.length - opticalusedata.length},
													'set',
													() ->
												)
												db.remove(
													'opticalplans',
													plan_id,
													() ->
												)
												saveOpticalUse(opticalusedata, res)
												saveOpticalUseLog(
													opticalusedata.length,
													opticalusedata.intensions,
													incomeobj.manufacturer,
													incomeobj.fibers,
													req.session.login
												)
												if plan.intensionstype == "1"
													saveWorkerCash(opticalusedata)
											else
												res.setHeader('Content-Type', 'text/plain')
												res.end(JSON.stringify({result : "Вказана довжина кабелю перевищую доступну! Відмініть плани на використання кабелю і повторіть операцію або вкіжіть меншу довжину!"}))
									)
							)
			)
	)

	saveOpticalUse  = (opticalusedata, res) ->
		db.save(
			'opticaluse',
			opticalusedata,
			(result) ->
				res.setHeader('Content-Type', 'text/plain')
				res.end(JSON.stringify(result))
		)

	saveWorkerCash = (opticalusedata) ->
		cablelength = opticalusedata.length/opticalusedata.workers.length
		for worker in opticalusedata.workers
			db.save(
				'workerscash',
				{"name" : worker, "cash" : cablelength.toFixed(), "intensions" : opticalusedata.intensions},
				(result) ->
			)

	saveOpticalUseLog = (length, intensions, manufacturer, fibers, user) ->
		db.save(
			'opticallogs',
			{
				"action" : 'Виконав заплановану роботу'
				"length" : length
				"date" : new Date().toISOString()
				"intensions" : intensions
				"cable" : manufacturer+", волокон : "+fibers
				"user" : user
			},
			() ->
		)


	app.get(
		'/getworkerscash',
		accessChecker.checkAccess,
		(req, res) ->
			coeff = req.query.coefficient
			db.getAll(
				'workerscash',
				(cash) ->
					values = []
					count = 1
					for c in cash
						datarow = {
							"id" : c._id,
							"rowdata" : [],
						}
						datarow.rowdata.push(count)
						datarow.rowdata.push(c.name)
						datarow.rowdata.push(c.intensions)
						datarow.rowdata.push(c.cash)
						values.push(datarow)
						count++
					res.setHeader('Content-Type', 'text/plain')
					res.end(JSON.stringify(
								{
									"title" : "Перелік премій"
									"headers" : ['№','Монтажник', 'Робота', 'Розмір премії','Видати']
									"values" : values
									"style" : "table table-bordered table-hover table-condensed"
								}
							)
					)
			)
	)