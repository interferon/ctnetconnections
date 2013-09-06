createBuilding = (params) ->
	building = {}
	building.type = params.type
	building.street = params.street
	building.number = params.number
	building.entrance = params.entrance
	building.flat = params.flat
	building.ladder = params.ladder
	building.info = params.info
	building.boxes = params.boxes
	return building

createODF = (params) ->
	odf = {}
	odf.name = params.name
	return odf


createStreet = (params) ->
	street = {}
	street.name = params.name
	return street

createBox = (params) ->
	box = {}
	box.name= params.name
	box.commutators = params.commutators
	box.upses = params.upses
	box.odf = params.odf
	return box

createUps = (params) ->
	ups = {}
	ups.name = params.name
	return ups

createBuildingsConnector = (params) ->
	connector = {}
	connector.parent = params.parent
	connector.out = params.out
	connector.type = params.type
	return connector

createLogObject = (params) ->
	logObject = {}
	logObject.item = params.item
	logObject.action = params.action
	logObject.date = params.date
	logObject.user = params.user
	return logObject


createCommutator = (params) ->
	commutator = {}
	commutator.name = params.name
	commutator.free = params.free
	commutator.manageable = params.manageable
	return commutator

createManageableCommutator = (params) ->
	commutator = {}
	commutator.name = params.name
	commutator.ip = params.ip
	commutator.login = params.login
	commutator.pass = params.pass
	commutator.free = params.free
	commutator.manageable = params.manageable
	return commutator


module.exports.createLogObject = createLogObject
module.exports.createBuildingsConnector = createBuildingsConnector
module.exports.createUps = createUps
module.exports.createBuilding = createBuilding
module.exports.createBox = createBox
module.exports.createManageableCommutator = createManageableCommutator
module.exports.createCommutator = createCommutator
module.exports.createStreet = createStreet
module.exports.createODF = createODF
