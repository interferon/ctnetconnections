express = require('express')
path = require('path')
MongoStore = require('connect-mongo')(express)
app = express()
database = require(path.join(__dirname,'/app/js/Database'))
db = new database.Database()
routes = require(path.join(__dirname,'/app/js/routes'))
fileHandlers = require(path.join(__dirname,'/app/js/fileHandlers'))
dbRequestsHandlers = require(path.join(__dirname,'/app/js/dbRequestsHandlers'))
warehouseDBRequestHandlers = require(path.join(__dirname,'/app/js/warehouseDBRequestHandlers'))


app.configure(
	'development',
	() ->
		app.use(express.cookieParser('my secret'))
		app.use(express.session(
				{
					key: 'express.sid',
					secret: 'secret',
					maxAge: null,
					store: new MongoStore({ db: 'ctnet', collection: 'sessions'})
				}
			)
		)
		app.use(express.static(__dirname))
		app.use(express.json())
		app.use(express.bodyParser({
			keepExtensions: true,
			uploadDir: __dirname + '/app/images/billsimgs'
		}))
		app.use(express.methodOverride())
		app.use(app.router)
		app.use(express.urlencoded())
		app.use(express.logger('dev'))
)

dbRequestsHandlers.start(app, db)
fileHandlers.start(app)
routes.start(app, db)
warehouseDBRequestHandlers.start(app, db)


app.get(
	'*',
	(req, res) ->
		res.sendfile('./app/view/notfound.html')
)

app.listen(8080)