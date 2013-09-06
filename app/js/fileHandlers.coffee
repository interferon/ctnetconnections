fs = require('fs')
pathmodule = require('path')
dataProcFn = require('./dataProcessingFunctions')

module.exports.start = (app) ->

	app.get(
		'/odfimageslist',
		(req, res) ->
			query = req.query
			fs.readdir(
				pathmodule.join(__dirname,"/../images/odfimgs/", query.foldername),
				(err, files) ->
					dataProcFn.runResponse(res, {'files' : files}, 'text/plain')
			)
	)

	app.post(
		'/uploadbillimage',
		(req, res) ->
			path = req.files.file.path
			image = path.substring(path.length, path.length-36)
			res.end(image);
	)

	app.post(
		'/uploadequipmentimage',
		(req, res) ->
			params = JSON.parse(req.body.params)
			path = req.files.file.path
			switch params.type
				when 'odf'
					targetpath = pathmodule.join(__dirname, '/../images/odfimgs/', params.targetpath)
					newfilename = pathmodule.join(__dirname, '/../images/odfimgs/', params.newfilename)
				when 'box'
					targetpath = pathmodule.join(__dirname, '/../images/boxes')
					newfilename = pathmodule.join(__dirname, '/../images/boxes', params.newfilename)
			image = path.substring(path.length, path.length-36)
			fs.exists(
				targetpath,
				(exists) ->
					if exists
						renameUploadedImage()
						res.end();
					else
						fs.mkdir(
							targetpath,
							() ->
								renameUploadedImage()
								res.end();
						)
			)
			renameUploadedImage = () ->
				fs.rename(
					path,
					newfilename,
					(err) ->
						deleteUploadedImage()
						if err
							console.log(err)
				)
			deleteUploadedImage = () ->
				fs.unlink(
					path,
					() ->
						console.log('deleted')
				)
	)

