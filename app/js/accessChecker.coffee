accessToResourseAllowed = (login) ->
		result = false
		if login == 'victor'
			result = true
		return result


checkAccess = (req, res, next) ->
	if !accessToResourseAllowed(req.session.login)
		res.send(JSON.stringify({result : "Ви не можете додавати дані"}))
	else
		next()

module.exports.checkAccess = checkAccess