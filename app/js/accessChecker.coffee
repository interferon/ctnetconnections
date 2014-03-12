accessToResourseAllowed = (login) ->
	result = false
	if login == 'victor' || login == 'chovgan' || login == 'admin'
		result = true
	return result

checkAccess = (req, res, next) ->
	if !accessToResourseAllowed(req.session.login)
		res.end("Access not allowed!")
	else
		next()

module.exports.checkAccess = checkAccess