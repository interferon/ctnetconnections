$(document).ready(
	() ->
		BUILDINGS_LIST = []
		selectedbuilding_id = ""
		getSelectedBuildingBoxId = ""
		getSelectedBoxCommutatorId = ""
		getSelectedBoxUpsId = ""
		getSelectedBoxOdfId = ""
		ismanageablecommutatorselected = false
		streetselectors = []
		buildingSelectors = []
		commutatorSelectors = []
		boxSelectors = []
		odfselectors = []
		upsesSelectors = []
		workerSelectors = []
		workerSelectors.push($("#workerselector_main"))
		upsesSelectors.push($("#upsselector"))
		upsesSelectors.push($("#changeupseslist"))
		odfselectors.push($("#odfselector"))
		odfselectors.push($("#changeodflist"))
		streetselectors.push($("#streetselector_building"))
		streetselectors.push($("#streetselector"))
		buildingSelectors.push($("#buildingselector_from"))
		buildingSelectors.push($("#buildingselector_to"))
		commutatorSelectors.push($("#comselector"))
		commutatorSelectors.push($("#changecommutatorlist"))
		boxSelectors.push($("#boxselector"))
		boxSelectors.push($("#addnewbuildingsboxselector"))
		boxSelectors.push($("#changebuildingsboxselector"))

		utils.setServerCommunicator(serverCommunicator.getInstance())

		$.extend($.validator.messages, {
				required: "Заповніть поле!",
				remote: "Please fix this field.",
				email: "Please enter a valid email address.",
				url: "Please enter a valid URL.",
				date: "Please enter a valid date.",
				dateISO: "Please enter a valid date (ISO).",
				number: "Please enter a valid number.",
				digits: "Тільки цифрові значення.",
				creditcard: "Please enter a valid credit card number.",
				equalTo: "Please enter the same value again.",
				accept: "Please enter a value with a valid extension.",
				maxlength: jQuery.validator.format("Please enter no more than {0} characters."),
				minlength: jQuery.validator.format("Please enter at least {0} characters."),
				rangelength: jQuery.validator.format("Please enter a value between {0} and {1} characters long."),
				range: jQuery.validator.format("Please enter a value between {0} and {1}."),
				max: jQuery.validator.format("Please enter a value less than or equal to {0}."),
				min: jQuery.validator.format("Please enter a value greater than or equal to {0}.")
		})
		# new method validating file input element
		$.validator.addMethod(
			"uploadFile",
			(val, element) ->
				ext = $(element).val().split('.')[1].toLowerCase()
				allow = ['jpeg', 'bmp', 'png', 'jpg']
				if ($.inArray(ext, allow) == -1)
					return false;
				else
					return true;
			,
			"Невірний формат файлу!"
		)

# assign listeners for ui components responsible for visibility of  miscellaneous fields
		showConfirmDialog = (fn) ->
				$("#delconfirmmodal").modal('show')
				$("#deleteitemirreversibly").bind(
					'click',
					() ->
						fn()
						$("#deleteitemirreversibly").unbind('click')
						$("#delconfirmmodal").modal('hide')
				)

		hideVisibleBlocks = () ->
			elems = [
				$("#commutatoradder"),
				$("#boxadder"),
				$("#upsadder"),
				$("#odfadder"),
				$("#personnel"),
				$("#streetadder"),
				$("#buildingadder"),
				$("#connectionsrow"),
				$("#changelogblock")
			]
			for e in elems
				if e.is(':visible')
					e.hide()

		assignEventsListeners = () ->

			$("#addnewbuildingsboxselector").bind(
				'click',
				() ->
					name = $("#addnewbuildingsboxselector option:selected").val()
					$("#imagenewbox").attr('src', '/app/images/boxes/'+name+'.jpg')
			)

			$("#changebuildingsboxselector").bind(
				'click',
				() ->
					name = $("#addnewbuildingsboxselector option:selected").val()
					$("#imagenewbox").attr('src', '/app/images/boxes/'+name+'.jpg')
			)


			$('#editcombtn').bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#commutatoradder"))
			)

			$('#editboxbtn').bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#boxadder"))
			)

			$('#editupsbtn').bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#upsadder"))
			)

			$('#editodfbtn').bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#odfadder"))
			)

			$("#editpersonnel").bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#personnel"))
			)
			$('#closeodfadder').bind('click',
				() ->
					$("#odfadder").hide()
			)

			$('#closecommutatoradder').bind('click',
				() ->
					$("#commutatoradder").hide()
			)

			$('#closeboxadder').bind('click',
				() ->
					$("#boxadder").hide()
			)

			$('#closeupsadder').bind('click',
				() ->
					$("#upsadder").hide()
			)

			$('#closestreetadder').bind('click',
				() ->
					$("#streetadder").hide()
			)

			$('#closebuildingadder').bind('click',
				() ->
					$("#buildingadder").hide()
			)
			$('#closeworkeradder').bind('click',
				() ->
					$("#personnel").hide()
			)

			$('#closequipmentchange').bind(
				'click',
				() ->
					$("#changeEquipment").hide()
			)
			$('#closeconnectionsadder').bind('click',
				() ->
					$("#connectionsrow").hide()
			)

			$("#addbuilding").bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#buildingadder"))
			)

			$("#addstreet").bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#streetadder"))
			)

			$("#connections").bind('click',
				() ->
					hideVisibleBlocks()
					utils.displayIfInvisible($("#connectionsrow"))
			)

			$("#cablereport").bind('click',
				() ->
					utils.displayIfInvisible($("#usetable"))
			)
			$("#cableincomereport").bind('click',
				() ->
					utils.displayIfInvisible($("#incometable"))
			)

			$("#changeEquipmentBtn").bind(
				'click',
				() ->
					utils.displayIfInvisible($("#changeEquipment"))
			)

			$('#manageableButtonYes').bind(
				'click',
				() ->
					if $('#manageableButtonYes').hasClass('btn-info')
						$('#manageableButtonYes').removeClass('btn-info')
					else
						$('#manageableButtonYes').addClass('btn-info')
			)

			$("#changecommutatorlist").bind('change',
				(e) ->
					utils.getDataFromDB(
						{
							"parameters" : [{"param_name" : "collection", "param_value" :  "commutatornames"}],
							"path" : "getsaveditems"
						},
						(commutatornames) ->
							id = $("#"+e.target.getAttribute('id')+" option:selected").val()
							if commutatornames.filter((elem) -> elem._id.toString() == id)[0].manageable
								$("#mancomadditionalfields").show()
								ismanageablecommutatorselected = true
							else
								$("#mancomadditionalfields").hide()

					)
			)

			$("#logout").bind(
				'click',
				() ->
					window.location.href = '/logout';
			)

			$("#changelog").bind(
				'click',
				() ->
					hideVisibleBlocks()
					showChangeLog()
					utils.displayIfInvisible($("#changelogblock"))
			)

			$("#closechangelog").bind(
				'click',
				() ->
					$("#changelogblock").hide()
			)
			$("input[type=date]").val(new Date().toISOString().slice(0,10));



#  assign events responsible for manipulating with data and server communication

			$('#addstreetbtn').bind(
				'click',
				(e) ->
					id = e.target.id
					if $("#newstreetnameform").valid()
						saveStreetName(
							getStreetName(),
							() ->
								clearTextInput(id)
								populateStreetNamesSelectors()
						)
			)

			$("#showrenamefield").bind(
				'click',
				() ->
					utils.displayIfInvisible($("#streetrenameform"))
			)

			$("#renamestreetbtn").bind(
				'click',
				() ->
					if $("#streetrenameform").valid()
						renameStreetName(
							getStreetIdOnMainSelector(),
							() ->
								populateStreetNamesSelectors()
						)
			)


			$("#savebuildingbtn").bind(
				'click',
				(e) ->
					id = e.target.id
					if $("#buildingnumberform").valid()
						saveBuilding(
							getBuildingData(),
							(saved) ->
								getDataForBuildingsList()
						)
						clearTextInput(id)
			)


			$("#connectbuildingsbtn").bind(
				'click',
				() ->
					if isOptionSelected($("#buildingselector_from")) && isOptionSelected($("#buildingselector_to"))
						saveBuildingConnector(
							getConnectorData(),
							() ->
								populateConnectionsList()
						)
			)


			$("#delconnectionbtn").bind(
				'click',
				(e) ->
					if isOptionSelected($("#connectionslist"))
						showConfirmDialog(
							() ->
								removeBuildingConnector(
									getSelectedConnectorId(),
									() ->
										populateConnectionsList()
								)
						)
			)

			$("#buildingssearchfield").bind(
				'keydown keyup change',
				() ->
					searchInSelector(
						$("#connectionslist"),
						$("#buildingssearchfield").val()
					)
			)

			$("#changeconnectiontypebtn").bind(
				'click',
				() ->
					changeConnectionType(
						getSelectedConnectorId(),
						getNewConnectionTypeValue(),
						() ->
							populateConnectionsList()
					)
			)

			$("#addcombtn").bind(
				'click',
				(e) ->
					if $("#newcomform").valid()
						saveCommutatorName(
							getNewCommutatorNameData(),
							() ->
								populateCommutatorSelectors()
						)
						clearTextInput(e.target.id)
			)


			$("#delcombtn").bind(
				'click',
				() ->
					showConfirmDialog(
						() ->
							removeCommutatorName(
								$("#comselector").val(),
								() ->
									populateCommutatorSelectors()
							)
					)
			)

			$("#addupsbtn").bind(
				'click',
				(e) ->
					if $("#newupsnameform").valid()
						saveUpsName(
							getUpsData(),
							() ->
								populateSelectorsFromDB(upsesSelectors, 'upsnames', ['name'])
						)
						clearTextInput(e.target.id)

			)

			$("#delupsbtn").bind(
				'click',
				() ->
					showConfirmDialog(
						() ->
							removeUpsName(
								$("#upsselector").val(),
								() ->
									populateSelectorsFromDB(upsesSelectors, 'upsnames', ['name'])
							)
					)
			)

			$("#addodfbtn").bind(
				'click',
				(e) ->
					if $("#newodfnameform").valid()
						saveOdfName(
							getOdfData(),
							() ->
								populateSelectorsFromDB(odfselectors, 'odfnames', ['name'])
						)
						clearTextInput(e.target.id)
			)

			$("#delodfbtn").bind(
				'click',
				() ->
					showConfirmDialog(
						() ->
							removeOdfName(
								$("#odfselector").val(),
								() ->
									populateSelectorsFromDB(odfselectors, 'odfnames', ['name'])
								)
					)
			)

			$("#addboxbtn").bind(
				'click',
				(e) ->
					if $("#newboxnameform").valid()
						saveBoxName(
							getBoxData(),
							() ->
								populateBoxesSelectors()
						)
						clearTextInput(e.target.id)
			)

			$("#deleteboxbtn").bind(
				'click',
				() ->
					showConfirmDialog(
						() ->
							removeBoxName(
								$("#boxselector").val(),
								() ->
									populateBoxesSelectors()
							)
					)
			)

			$("#addworkerbtn").bind(
				'click',
				(e) ->
					if $("#workerform" ).valid()

						saveWorkerName(
							getWorkerName(),
							() ->
								populateWorkerSelectors()
						)
						clearTextInput(e.target.id)
			)

			$("#delworkerbtn").bind(
				'click',
				() ->
					showConfirmDialog(
						() ->
							removeWorkerName(
								$("#workerselector_main").val(),
								() ->
									populateWorkerSelectors()
							)
					)
			)


			$("#changebuildinginfo").bind(
				'click',
				() ->
					changeBuildingInfo(
						getBuildingInfo(),
						selectedbuilding_id
					)
					$("button.close").trigger('click')
			)


			$("#addnewboxtobuilding").bind(
				'click',
				() ->
					addNewBoxToBuilding(getSelectedBoxTypeId(), selectedbuilding_id)
					$("button.close").trigger('click')
			)

			$("#delbuildingsboxbtn").bind(
				'click',
				() ->
					if $("#buildingboxeslist option:selected").length > 0
						showConfirmDialog(
							() ->
								deleteBuildingsBox(getSelectedBuildingBoxId(), selectedbuilding_id)
						)
			)

			$("#changeboxtype").bind(
				'click',
				() ->
					if $("#buildingboxeslist option:selected").length > 0
						changeBoxType(
							$("#changebuildingsboxselector option:selected").text().trim()
						)
						$("#button.close").trigger('click')

			)

			$("#addcomtobox").bind(
				'click',
				() ->
					saveNewCommutator(
						getNewCommutatorData(),
						(commutator) ->
							id = getSelectedBuildingBoxId()
							utils.postToServer(
								'update',
								{
									"collection" : 'equipment',
									"_id" : id,
									"data" : {'commutators' : commutator._id},
									"update_type" : "push"
								},
								() ->
									triggerClickEventOnBuildingsListElement(selectedbuilding_id)
									$("button.close").trigger('click')
							)
					)
			)

			$("#delboxcombtn").bind(
				'click',
				() ->
					if $("#boxcommutatorlist option:selected").length > 0
						showConfirmDialog(
							() ->
								deleteBoxCommutator(getSelectedBuildingBoxId(), getSelectedBoxCommutatorId())
						)
			)

			$("#addupstobox").bind(
				'click',
				() ->
					saveNewUps(
						getNewUpsData(),
						(ups) ->
							utils.postToServer(
								'update',
								{
									"collection" : 'equipment',
									"_id" : getSelectedBuildingBoxId(),
									"data" : {'upses' : ups._id},
									"update_type" : "push"
								},
								() ->
									triggerClickEventOnBuildingsListElement(selectedbuilding_id)
									$("button.close").trigger('click')
							)
					)
			)

			$("#delboxups").bind(
				'click',
				() ->
					if $("#boxupseslist option:selected").length > 0
						showConfirmDialog(
							() ->
								deleteBoxUps(getSelectedBuildingBoxId(), getSelectedBoxUpsId())
						)
			)

			$("#addodfbutton").bind(
				'click',
				() ->
					saveNewOdf(
						getNewOdfData(),
						(odf) ->
							utils.postToServer(
								'update',
								{
									"collection" : 'equipment',
									"_id" : getSelectedBuildingBoxId(),
									"data" : {'odf' : odf._id},
									"update_type" : "push"
								},
								() ->
									triggerClickEventOnBuildingsListElement(selectedbuilding_id)
									$("button.close").trigger('click')
							)

					)
			)

			$("#delboxodf").bind(
				'click',
				() ->
					if $("#boxodflist  option:selected").length > 0
						showConfirmDialog(
							() ->
								deleteBoxOdf(getSelectedBuildingBoxId(), getSelectedBoxOdfId())
						)
			)

			$("#freeports").bind(
				'click',
				() ->
					$("#freeportsModal").modal('show')
			)

			$("#addfreeports").bind(
				'click',
				() ->
					if $("#freeportsform").valid()
						utils.postToServer(
							'update',
							{
								"collection" : 'equipment',
								"_id" : getSelectedBoxCommutatorId(),
								"data" : {'free' : $("#freeportsfield").val()},
								"update_type" : "set"
							},
							() ->
								showBuildingInfo($("#buildingslist li.active a").attr('value'))
								$("button.close").trigger('click')
						)
			)

			$("#mainbuildingssearch").bind(
				'keyup',
				() ->
					searchterm = $("#mainbuildingssearch").val()
					populateBuildingsList(BUILDINGS_LIST, searchterm)
			)


# code affecting database

		saveStreetName = (street_name, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"name" : street_name,
					"collection" : "streetnames"
				}
				() ->
					callback()

			)

		renameStreetName = (street_name_id, callback) ->
			utils.postToServer(
				"update",
				{
					"collection" : "streetnames",
					"_id" : street_name_id,
					"data" : {'name' : $("#renamefield").val().trim()},
					"update_type" : "set"
				},
				() ->
					callback()
			)


		saveBuilding = (data, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "buildings",
					"item" : data
				},
				(saved) ->
					callback(saved)
			)

		saveBuildingConnector = (data, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "connectors",
					"item" : data
				},
				() ->
					callback()
			)

		removeBuildingConnector = (_id, callback) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "connectors"
					"_id" : _id
				},
				() ->
					callback()
			)

		saveCommutatorName = (data, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "commutatornames",
					"name" : data.name
					"manageable" : data.manageable
				},
				() ->
					callback()
			)

		saveWorkerName = (name, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "workers",
					"name" : name
				},
				() ->
					callback()
			)

		saveBoxName = (name, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "boxesnames",
					"name" : name
				},
				() ->
					callback()
			)

		saveOdfName = (name, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "odfnames",
					"name" : name
				},
				() ->
					callback()
			)

		saveUpsName = (name, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "upsnames",
					"name" : name
				},
				() ->
					callback()
			)


		removeCommutatorName = (_id, callback) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "commutatornames",
					"_id" : _id
				},
				() ->
					callback()
			)


		removeWorkerName = (_id, callback) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "workers",
					"_id" : _id
				},
				() ->
					callback()
			)

		removeBoxName = (_id, callback) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "boxesnames",
					"_id" : _id
				},
				() ->
					callback()
			)

		removeOdfName = (_id, callback) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "odfnames",
					"_id" : _id
				},
				() ->
					callback()
			)

		removeUpsName = (_id, callback) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "upsnames",
					"_id" : _id
				},
				() ->
					callback()
			)


		saveNewBox = (box_name_id, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "equipment"
					"_id" : box_name_id,
					"type" : 'box'
				},
				(box) ->
					callback(box)
			)

		saveNewCommutator = (commutator_data, callback) ->
			type = 'commutator'
			if commutator_data.manageable == true
				type = 'mancommutator'
			utils.postToServer(
				"saveitem",
				{
					"collection" : "equipment"
					"data" : commutator_data,
					"type" : type
				},
				(commutator) ->
					callback(commutator)
					saveChangeLog(
						commutator.name,
						"Додано",
						" Коробка: "+$("#buildingboxeslist option:selected").text()
					)
			)

		saveNewUps = (ups_data, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "equipment"
					"data" : ups_data,
					"type" : 'ups'
				},
				(ups) ->
					callback(ups)
					saveChangeLog(
						ups.name,
						"Додано",
						" Коробка: "+$("#buildingboxeslist option:selected").text()
					)
			)

		saveNewOdf = (odf_data, callback) ->
			utils.postToServer(
				"saveitem",
				{
					"collection" : "equipment"
					"data" : odf_data,
					"type" : 'odf'
				},
				(odf) ->
					callback(odf)
					saveChangeLog(
						odf.name,
						"Додано",
						" Коробка: "+$("#buildingboxeslist option:selected").text()
					)
			)



# getters ---------------------------------------------------------


		getNewConnectionTypeValue = () ->
			return $("#connectiontype_change").val()

		getSelectedConnectorId = () ->
			return $("#connectionslist").val()

		getStreetIdOnMainSelector = () ->
			return $("#streetselector").val()

		getStreetIdOnBuildingAdderSelector = () ->
			return $("#streetselector_building").val()

		getStreetName = () ->
			return $('#newstreetnamefield').val()

		getWorkerName = () ->
			return  $("#newworkernamefield").val()


		getNewCommutatorData = () ->
			commutatordata = {
				"_id" : $("#changecommutatorlist option:selected").val()
				"manageable" : false
			}

			if ismanageablecommutatorselected
				commutatordata["ip"] = $("#mancomip").val()
				commutatordata["login"] = $("#mancomlogin").val()
				commutatordata["pass"] = $("#mancompass").val()
				commutatordata.manageable = true
			return commutatordata


		getNewUpsData = () ->
			return {
				"_id" : $("#changeupseslist option:selected").val()
			}

		getNewOdfData = () ->
			return {
				"_id" : $("#changeodflist option:selected").val()
			}

		getNewCommutatorNameData = () ->
			return {
				"name" : $("#newcomname").val()
				"manageable" : $("#manageableButtonYes").hasClass("active")
			}

		getUpsData = () ->
			return $("#newupsname").val()

		getOdfData = () ->
			return $("#newodfname").val()

		getBoxData = () ->
			return $("#newboxname").val()


		getBuildingInfo = () ->
			return {
				entrance : $("#newentranceinfo").val()
				flat : $("#newkeyinfo").val()
				info : $("#newadditionalinfo").val()
				ladder : $("#newladderinfo").val()
			}


		getBuildingData = () ->
			return {
				street : getStreetIdOnBuildingAdderSelector()
				type : $("#buildingtypeselector").val()
				number : $("#streetnumber").val()
			}



		getConnectorData = () ->
			return  {
				type : $("#connectiontype").val()
				parent : $("#buildingselector_from").val()
				out : $("#buildingselector_to").val()
			}

		getSelectedBuildingBoxId = () ->
			return $("#buildingboxeslist option:selected").val()

		getSelectedBoxTypeId = () ->
			return $("#addnewbuildingsboxselector").val()

		getSelectedBoxOdfId = () ->
			return $("#boxodflist option:selected").val()

		getSelectedBoxUpsId = () ->
			return $("#boxupseslist option:selected").val()

		getSelectedBoxCommutatorId = () ->
			return $("#boxcommutatorlist option:selected").val()

		getSelectedBuildingFrom = () ->
			return $("#buildingselector_from option:selected")

		getSelectedBuildingTo = () ->
			return $("#buildingselector_to option:selected")


#  utils ------------------------------------------------utils

		populateBuildingsList = (buildings, filter) ->

			filterAndDisplayBuildingListData = (buildings, filter) ->
				buildings.sort(utils.compareBuildings)
				populateBuildingsSelectors(buildings)
				if filter.length > 0
					filtered = buildings.filter((elem) -> elem.street.toLowerCase().indexOf(filter) != -1)
					displayBuildingsList(filtered)
				else
					displayBuildingsList(buildings)

			displayBuildingsList = (buildings) ->
				for b in buildings
					# create list element for every building
					elem = $("<li><a value="+b._id+">"+b.street+", "+b.number+"</a></li>")
					# bind click event to every element
					elem.bind(
						'click',
						(e) ->
							# remove class active from selected list element
							$("#buildingslist li.active").attr('class', '')
							# add class active to selected list element
							e.target.parentNode.className = 'active'
							# extract selected building id
							selectedbuilding_id = e.target.getAttribute('value').toString()
							# show building info
							showBuildingInfo(selectedbuilding_id)
					)
					$("#buildingslist").append(elem)
				# when yandex maps is redy assign events showing building representation on map
				ymaps.ready( () -> initYandexMaps())
				# trigger click on 2-nd list element
				$("#buildingslist li:nth-child(2) a").trigger('click')

			$("#buildingslist").empty()
			$("#buildingslist").append("<li class='nav-header'>АДРЕСИ</li>")
			filterAndDisplayBuildingListData(buildings, filter)

		getDataForBuildingsList = () ->
			utils.getDataFromDB(
				{
					"parameters" : [{"param_name" : "collection", "param_value" : "buildings"}],
					"path" : "getsaveditems"
				}
				 ,
				(buildings) ->
					BUILDINGS_LIST = buildings
					populateBuildingsList(BUILDINGS_LIST, "")
			)

		showChangeLog = () ->
			utils.getDataFromDB(
				{
					"path" : "getsaveditems",
					"parameters" : [{"param_name" : "collection", "param_value" : "logs"}]
				},
				(loginfo) ->
					table = utils.createTable(loginfo)
					$("#changelogtable").empty()
					$("#changelogtable").append(table)
			)

		showBuildingInfo = (building_id) ->
			utils.getDataFromDB(
				{
					"parameters" : [
						{"param_name" : "collection", "param_value" :  "buildings"},
						{"param_name" : "building_id", "param_value" : building_id.toString()}
					],
					"path" : "getsaveditems"
				},
				(buildinginfo) ->
					fillGeneralBuildingInfo(buildinginfo.general)
					fillConnectionsInfo(buildinginfo.connections)
					fillEquipmentInfo(buildinginfo.equipment)
			)
			fillGeneralBuildingInfo = (info) ->

				$("#buildingnameinfo").text(info.name)
				$("#entranceinfo").text(info.entrance)
				$("#typeinfo").text(info.type)
				$("#keyinfo").text(info.flat)
				$("#additionalinfo").text(info.info)
				$("#ladderinfo").text(info.ladder)
				$('#newentranceinfo').val(info.entrance)
				$('#newkeyinfo').val(info.flat)
				$('#newadditionalinfo').val(info.info)
				$('#newladderinfo').val(info.ladder)

			fillConnectionsInfo = (info) ->

				showConnections = (elem, connectors) ->
					elem.empty()
					for connector in connectors
						infoelem = createElementAndBindEvent(connector)
						elem.append(infoelem)

				createElementAndBindEvent = (connector) ->
					elem = $('<div style="margin-top : 7px" class="btn" value='+connector.building_id+'>'+connector.building_name+' Тип: '+connector.type+'</div>')
					elem.bind(
						'click',
						(e) ->
							triggerClickEventOnBuildingsListElement(e.target.getAttribute('value'))
					)
					return elem

				showConnections($("#linkfrominfo"), info.incoming_connections)
				showConnections($("#linkoutinfo"), info.outgoing_connections)

			fillEquipmentInfo = (info) ->
				# info - jsons array
				populateinfoblock = (elem, text, style, value) ->
					elem.append($("<div><label value='"+value+"' class='label "+style+"'>"+text+"</label></div>"))

				populateBoxSelector = (info) ->
					$("#buildingboxeslist").empty()
					value_to_preselect = null
					for i in info
						if value_to_preselect == null
							value_to_preselect = i.box._id
						elem = $("<option value="+i.box._id+">"+i.box.name+"</option>")
						elem.bind(
							'click',
							(e) ->
								id = e.target.getAttribute('value')
								popualateRelatedEquipmentSelectors(id, info)
						)
						$("#buildingboxeslist").append(elem)
					$("#buildingboxeslist").val(value_to_preselect)
					$("#buildingboxeslist option:selected").trigger('click')

				populateEquipmentSelector = (selector, data, fn) ->
					selector.empty()
					value_to_preselect = null
					for d in data
						if value_to_preselect == null
							value_to_preselect = d._id
						elem = $("<option value="+d._id+">"+d.name+"</option>")
						elem.bind(
							'click',
							(e) ->
								id = e.target.getAttribute('value')
								fn(id)
						)
						selector.append(elem)
						selector.val(value_to_preselect)

				popualateRelatedEquipmentSelectors = (box_id, info) ->
					info = info.filter((elem) -> elem.box._id.toString() == box_id)[0]

					populateEquipmentSelector(
						$("#boxcommutatorlist"),
						info.commutators,
						(id) ->

					)

					populateEquipmentSelector(
						$("#boxupseslist"),
						info.upses,
						(id) ->

					)

					populateEquipmentSelector(
						$("#boxodflist"),
						info.odf,
						(id) ->

					)

				populateBoxSelector(info)
				$("#equipmentinfo").empty()
				for elem in info
					div = $('<div>')
					populateinfoblock(div, elem.box.name, "label-important", elem.box._id)
					populateinfoblock(div, "Комутатори", "label-inverse equipmentinfolabel", "")
					for commutator in elem.commutators
						populateinfoblock(
							div,
							commutator.name+" Вільно: "+commutator.free,
							"equipmentinfolabel",
							commutator._id
						)
					populateinfoblock(div, "Блоки живлення", "label-inverse equipmentinfolabel")
					for ups in elem.upses
						populateinfoblock(
							div,
							ups.name,
							"equipmentinfolabel",
							ups._id
						)
					populateinfoblock(div, "ODF", "label-inverse equipmentinfolabel")
					for odf in elem.odf
						anchor = $("<a href='#savedodfimagesModal' value='"+odf._id+"'role='button' class='label equipmentinfolabel' data-toggle='modal'>"+odf.name+"</a>")
						anchor.bind(
							'click',
							(e) ->
								value = e.target.getAttribute('value')
								utils.getFilesList(
									{
										"path" : 'odfimageslist',
										"value" : value
									},
									(data) ->
										$("#odfimagescontainer").empty()
										count = 0
										for file in data.files
											path = "/app/images/odfimgs/"+value+"/"+file
											date = file.split('.')[0]
											image = $(
												"<div class='controls controls-row'>
													<label class='label label-important span'>"+date+"</label>
													<a class='span' href="+path+"><img class='img-rounded' src='"+path+"' style='width: 100px; height:70px;'></a>
												</div>"
											)
											$("#odfimagescontainer").append(image)
											count++
								)
						)
						div.append(anchor)
					$("#equipmentinfo").append(div)


		populateBuildingsSelectors = (data) ->
			utils.fillselectors(data, buildingSelectors, ['street', 'number'])


		populateConnectionsList = () ->
			$("#connectionslist").empty()
			utils.getDataFromDB(
					{
					"parameters" : [{"param_name" : "collection", "param_value" :  "connectors"}],
					"path" : "getsaveditems"
					},
					(data) ->
						data.sort(utils.compareConnections)
						for i in data
							$("#connectionslist")
							.append("<option value="+i._id+">"+i.parent.street+" "+i.parent.number+" --> "+i.out.street+" "+i.out.number+" "+"("+ i.type+")"+"</option>")
			)


		populateSelectorsFromDB = (selectors, collection, params) ->
			utils.getDataFromDB(
				{
					"parameters" : [{"param_name" : "collection", "param_value" :  collection}],
					"path" : "getsaveditems"
				},
				(data) ->
					data.sort(utils.compare)
					utils.fillselectors(data, selectors, params)
			)

		addNewBoxToBuilding = (box_name_id, building_id) ->
			saveNewBox(
				box_name_id,
				(box) ->
					utils.postToServer(
						'update',
						{
							"collection" : 'buildings'
							"_id" : selectedbuilding_id,
							"data" : {'boxes' : box._id},
							"update_type" : "push"
						}
						() ->
							triggerClickEventOnBuildingsListElement(selectedbuilding_id)
							saveChangeLog($("#addnewbuildingsboxselector option:selected").text(), "Додано" ,"")
					)

			)

		deleteBuildingsBox = (box_id, building_id) ->
			utils.postToServer(
				'update',
				{
					"collection" : 'buildings'
					"_id" : building_id,
					"data" : {'boxes' : box_id},
					"update_type" : "pull"
				}
				() ->
					triggerClickEventOnBuildingsListElement(building_id)
					saveChangeLog($("#addnewbuildingsboxselector option:selected").text(), "Видалено" ,"")

			)
			utils.postToServer(
				'deleteboxequipment',
				{
					"box_id" : box_id
				},
				() ->
					utils.postToServer(
						'deleteitem',
						{
							"collection" : 'equipment'
							"_id" : box_id,
						}
						() ->
					)
			)



		deleteBoxCommutator = (box_id, comm_id) ->
			utils.postToServer(
				'deleteitem',
				{
					"collection" : 'equipment',
					"_id" : comm_id
				},
				() ->
			)
			utils.postToServer(
				'update',
				{
					"collection" : 'equipment'
					"_id" : box_id,
					"data" : {'commutators' : comm_id},
					"update_type" : "pull"
				}
				() ->
					triggerClickEventOnBuildingsListElement(selectedbuilding_id)
					triggerClickEventOnBoxesListElement(box_id)
					saveChangeLog(
						$("#boxcommutatorlist option:selected").text(),
						"Видалено",
						" Коробка: "+$("#buildingboxeslist option:selected").text()
					)
			)



		deleteBoxUps = (box_id, ups_id) ->
			utils.postToServer(
				'deleteitem',
				{
					"collection" : 'equipment',
					"_id" : ups_id
				}
				() ->
			)

			utils.postToServer(
				'update',
				{
					"collection" : 'equipment'
					"_id" : box_id,
					"data" : {'upses' : ups_id},
					"update_type" : "pull"
				}
				() ->
					triggerClickEventOnBuildingsListElement(selectedbuilding_id)
					triggerClickEventOnBoxesListElement(box_id)
					saveChangeLog(
						$("#boxupseslist option:selected").text(),
						"Видалено",
						" Коробка: "+$("#buildingboxeslist option:selected").text()
					)
			)

		deleteBoxOdf = (box_id, odf_id) ->
			utils.postToServer(
				'update',
				{
					"collection" : 'equipment'
					"_id" : getSelectedBuildingBoxId(),
					"data" : {'odf' : odf_id},
					"update_type" : "pull"
				}
				() ->
					triggerClickEventOnBuildingsListElement(selectedbuilding_id)
					triggerClickEventOnBoxesListElement(box_id)
					saveChangeLog(
						$("#boxodflist option:selected").text(),
						"Видалено",
						" Коробка: "+$("#buildingboxeslist option:selected").text()
					)

			)
			utils.postToServer(
				'deleteitem',
				{
					"collection" : 'equipment',
					"_id" : odf_id
				}
				() ->
			)


		changeBoxType = (value) ->
			utils.postToServer(
				'update',
				{
					"collection" : 'equipment'
					"_id" : getSelectedBuildingBoxId(),
					"data" : {'name' : value},
					"update_type" : "set"
				}
				() ->
					triggerClickEventOnBuildingsListElement(selectedbuilding_id)
			)


		clearTextInput = (id) ->
			$('#'+id+'').closest('div').find('input[type=text]').val("")

		searchInSelector = (selector, phrase) ->
			values = $("#connectionslist>option").map(
				() ->
					data = {}
					data.value = $(this).val()
					data.text = $(this)[0].innerText
					return data
			)
			for v in values
				sub = v.text.substring(0, phrase.length)
				value = v.value
				if sub.toLowerCase() == phrase.toLowerCase()
					$("option[value='"+value+"']").prop('selected', true);

		changeConnectionType = (connector_id, type, callback) ->
			utils.postToServer(
				'update',
				{
					"collection" : 'connectors'
					"_id" : connector_id,
					"data" : {'type' : type},
					"update_type" : "set"
				}
				() ->
					callback()
			)

		changeBuildingInfo = (data, building_id) ->
			utils.postToServer(
				'update',
				{
					"_id" : building_id,
					"collection" : "buildings",
					"data" : data,
					"update_type" : "set"
				},
				() ->
					triggerClickEventOnBuildingsListElement(building_id)
			)

		saveChangeLog = (item, action, adress) ->
			utils.postToServer(
				'saveitem',
				{
					"collection" : "logs",
					"data" : {
						"item" : item.trim()
						"action" : action
						"adress" : $("#buildingslist li.active a").text()+adress
						"date" : new Date().toISOString()
						"user" : ""
					},
					"type" : 'logs'
				},
				() ->
					showChangeLog()
			)

		triggerClickEventOnBuildingsListElement = (value) ->
			$("#buildingslist li a[value="+value+"]").trigger('click')

		triggerClickEventOnBoxesListElement = (value) ->
			$("#buildingboxeslist option[value="+value+"]").trigger('click')


		populateStreetNamesSelectors = () ->
			populateSelectorsFromDB(streetselectors, 'streetnames', ['name'])

		populateCommutatorSelectors = () ->
			populateSelectorsFromDB(commutatorSelectors, 'commutatornames', ['name'])

		populateWorkerSelectors = () ->
			populateSelectorsFromDB(workerSelectors, 'workers', ['name'])

		populateBoxesSelectors = () ->
			populateSelectorsFromDB(boxSelectors, 'boxesnames', ['name'])

		populateODFSelectors = () ->
			populateSelectorsFromDB(odfselectors, 'odfnames', ['name'])

		popualteUpsesSelectors = () ->
			populateSelectorsFromDB(upsesSelectors, 'upsnames', ['name'])


		sendSelectedFileViaXMLHttpReq = (file, path, params) ->
			$('div.progress').show();
			formData = new FormData();
			formData.append('file', file)
			formData.append('params', JSON.stringify(params))
			xmlhttpreq = new XMLHttpRequest();
			xmlhttpreq.open('post', path, true);
			xmlhttpreq.upload.onprogress = (e) ->
				if (e.lengthComputable)
					percentage = (e.loaded / e.total) * 100;
					$('div.progress div.bar').css('width', percentage + '%');
			xmlhttpreq.onerror = (e) ->
				showProgressInfo('An error occurred while submitting the form. Maybe your file is too big');
			xmlhttpreq.onload = () ->
				showProgressInfo(this.statusText);
			xmlhttpreq.onreadystatechange = () ->
				$("#serverMessages").addClass('alert-success')
				$("#serverMessages").text("Фото збережено!")
				$("#serverMessages").show()
				setTimeout(
					() ->
						$("#serverMessages").fadeOut('slow')
					, 3000
				)
			xmlhttpreq.send(formData)
			$("button.close").trigger('click')

		$('#saveodfimage').bind(
			'click',
			(evt) ->
				foldername = $("#boxodflist option:selected").val()
				date = utils.getCurrentDateInMyFormat()
				params = {
							targetpath : foldername
							newfilename : foldername+"/"+date+".jpg"
							type: "odf"
						}
				evt.preventDefault();
				if $("#odfimageform").valid() && isOptionSelected($("#boxodflist"))
					sendSelectedFileViaXMLHttpReq($('#odfimage')[0].files[0],"/uploadequipmentimage", params)
		)

		$('#saveboximage').bind(
			'click',
			(evt) ->
				name = $("#boxselector option:selected").val()
				params = {
							newfilename : name+".jpg"
							type : "box"
						}
				evt.preventDefault();
				if $("#boximageform").valid()
					sendSelectedFileViaXMLHttpReq($('#boximage')[0].files[0],"/uploadequipmentimage", params)
		)

		showProgressInfo = (message) ->
			$('div.progress').hide()
			$('strong.message').text(message)
			$('div.alert').show()


		isOptionSelected = (selector) ->
			return selector.find("option:selected").length > 0

		# validation
		$("#boximageform").validate(
			rules : {
				boximage : {
					required : true

				}
			}
		)

		$("#odfimageform").validate(
			rules : {
				odfimage : {
					required : true

				}
			}
		)

		$("#freeportsform").validate(
			rules : {

				freeportsfield : {
					required : true,
					digits : true
					}
			}
		)

		$("#workerform" ).validate({
			rules: {
					newworkernamefield : {
						required: true
					}

				}
		})

		$("#streetrenameform").validate({
			rules: {
					renamefield : {
						required: true
					}
				}
		})

		$("#newstreetnameform").validate({
			rules: {
					newstreetnamefield : {
						required: true
					}
				}
		})

		$("#buildingnumberform").validate({
			rules: {
					streetnumber : {
						required: true
					}
				}
		})

		$("#newcomform").validate({
			rules: {
					newcomname : {
						required: true
					}
				}
		})

		$("#newboxnameform").validate({
			rules: {
					newboxname : {
						required: true
					}
				}
		})

		$("#newupsnameform").validate({
			rules: {
					newupsname : {
						required: true
					}
				}
		})

		$("#newodfnameform").validate({
			rules: {
					newodfname : {
						required: true
					}
				}
		})

		populateStreetNamesSelectors()
		getDataForBuildingsList()
		populateConnectionsList()
		populateCommutatorSelectors()
		populateWorkerSelectors()
		popualteUpsesSelectors()
		populateBoxesSelectors()
		populateODFSelectors()
		assignEventsListeners()
)
