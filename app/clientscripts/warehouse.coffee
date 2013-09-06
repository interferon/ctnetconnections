$(document).ready(
	() ->
		# set current date on all date-pickers
		$("input[type=date]").val(new Date().toISOString().slice(0,10));

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
		# method validating file pickers
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

		# html selectors with same data source
		workerSelectors = []
		workerSelectors.push($("#workerselector"))
		workerSelectors.push($("#opticaluseworkerselector"))

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


		populateSelectorsFromDB(workerSelectors, 'workers', ['name'])

		populateSelectorsFromDB([$("#boxstoreselector")],  'boxesnames', ['name'])



		isOptionSelected = (selector) ->
			return selector.find("option:selected").length > 0

		showConfirmDialog = (fn) ->
			$("#delconfirmmodal").modal('show')
			$("#deleteitemirreversibly").bind(
				'click',
				() ->
					fn()
					$("#deleteitemirreversibly").unbind('click')
					$("#delconfirmmodal").modal('hide')
			)


		$("#warehouse").bind(
			'click',
			() ->
				populateAndShowWarehouseTablesTab()
		)

		populateAndShowWarehouseTablesTab = () ->

			utils.getDataFromDB(
				{
					"parameters" : [{"param_name" : "collection", "param_value" : "copperincome"},
					{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				}
				 ,
				(tabledata) ->
						$("#copppercablewarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#copppercablewarehousetable").append(table)
			)
			utils.getDataFromDB(
				{
					"parameters" : [{"param_name" : "collection", "param_value" : "opticalincome"},
					{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				},
				(tabledata) ->
						$("#opticalcablewarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#opticalcablewarehousetable").append(table)
			)
			utils.getDataFromDB(
				{
					"parameters" : [{"param_name" : "collection", "param_value" : "boxstore"},
					{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				},
				(tabledata) ->
						$("#boxeswarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#boxeswarehousetable").append(table)
			)
			utils.getDataFromDB(
				{
					"parameters" : [{"param_name" : "collection", "param_value" : "patchpanelstore"},
					{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				},
				(tabledata) ->
						$("#patchpanelswarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#patchpanelswarehousetable").append(table)
			)
			utils.getDataFromDB(
				{
					"parameters" : [
						{"param_name" : "collection", "param_value" : "patchcordstore"},
						{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				},
				(tabledata) ->
						$("#patchcordswarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#patchcordswarehousetable").append(table)
			)
			utils.getDataFromDB(
				{
					"parameters" : [
						{"param_name" : "collection", "param_value" : "pigtailsstore"},
						{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				},
				(tabledata) ->
						$("#pigtailswarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#pigtailswarehousetable").append(table)
			)
			utils.getDataFromDB(
				{
					"parameters" : [
						{"param_name" : "collection", "param_value" : "socketsstore"},
						{"param_name" : "type", "param_value" : "warehouse"}
					],
					"path" : "getsaveditems"
				},
				(tabledata) ->
						$("#socketswarehousetable").empty()
						table = utils.createTable(tabledata)
						$("#socketswarehousetable").append(table)
			)

		$("#warehouselogs").bind(
			'click',
			() ->
				getWareHouseLogsByDate()
		)

		populateAndShowWarehouseTablesTab()


		getWareHouseLogsByDate = () ->
			start = $("#warehouselogsstart").val().split("-")
			end = $("#warehouselogsstop").val().split("-")
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "type", "param_value" : "bydate"}
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getwarehouselogs"
				},
				(tabledata) ->
					$("#warehouselogstable").empty()
					table = utils.createTable(tabledata)
					$("#warehouselogstable").append(table)
			)

		getWareHouseLogs = () ->
			utils.getDataFromDB(
				{
					"parameters" : [
						{"param_name" : "type", "param_value" : "lastlogs"}
					],
					"path" : "getwarehouselogs"
				},
				(tabledata) ->
					$("#warehouselogstable").empty()
					table = utils.createTable(tabledata)
					$("#warehouselogstable").append(table)
			)

		$("#warehouselogsstart").bind(
			'change',
			() ->
				getWareHouseLogsByDate()
		)

		$("#warehouselogsstop").bind(
			'change',
			() ->
				getWareHouseLogsByDate()
		)

		$("#warehouselogs").bind(
			'click',
			() ->
				getWareHouseLogs()
		)

		# copper

		showCopperUseDialog = (id) ->
			$("#addcopperuse").attr('value', id)
			$("#copperUseModal").modal('show')


		$("#addcopperuse").bind(
			'click',
			(e) ->
				if $("#copperuseform").valid() && isOptionSelected($("#workerselector"))
					id = e.target.getAttribute('value')
					workers = []
					$('#workerselector :selected').each(
						(i, selected) ->
							workers[i] = $(selected).text().trim()
					)
					utils.postToServer(
						'savecopperuse',
						{
							"data" : {
								"length" : +$("#copperuselength").val(),
								"contract" : $("#coppercontract").val(),
								"workers" : workers,
								"date" : new Date().toISOString()
								"user" : ""
							},
							"income_id" : id
						},
						() ->

							showCopperIncome()
							$("button.close").trigger('click')
					)

		)

		showCopperIncome = () ->
			$("#copperincometable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [{"param_name" : "collection", "param_value" :  "copperincome"},
				{"param_name" : "type", "param_value" :  "incometable"}],
				"path" : "getsaveditems"
				},
				(tableData) ->
					table = utils.createTableWithActiveElements(
						tableData,
						showCopperUseDialog,
						{selector : 'copperincome'}
					)
					$("#copperincometable").append(table)
					$("#copperincometable").show()
			)

		$("#showcopperincome").bind(
			'click',
			() ->
				showCopperIncome()
		)

		$("#showcopperuse").bind(
			'click',
			() ->
				$("#copperusetable").empty()
				utils.getDataFromDB(
					{
					"parameters" : [{"param_name" : "collection", "param_value" :  "copperuse"}],
					"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#copperusetable").append(table)
						$("#copperusetable").show()
				)

		)


		$("#showcopperbillimgs").bind(
			'click',
			() ->
				utils.getDataFromDB(
					{
						"parameters" : [
							{"param_name" : "collection", "param_value" :  "copperincome"},
							{"param_name" : "type" , "param_value" :'bills'}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#copperbillsimages").empty()
						$("#copperbillsimages").append(table)
						$("#copperbillsimages").show()
				)
		)


		$('#savecopperincome').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#copperinputform").valid()
					utils.saveImageToServer(
						$("#copperbillimage")[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
									'savecopperincome',
									{
										"type" : $("#coppercabletype option:selected").text(),
										"pairs" : $("#copperpairs option:selected").text(),
										"rope" : $("#copperrope").val(),
										"manufacturer" : $("#coppermanufacturer").val(),
										"serial" : $("#copperserial").val(),
										"length" : +$("#copperlength").val(),
										"initiallength" : +$("#copperlength").val(),
										"price" : +$("#copperprice").val(),
										"image" : image
										"date" : new Date().toISOString()
										"user" : ""
									},
									() ->
							)
					)
		)

		getCopperIncomeByDate = () ->
			start = $("#copperusestart").val().split("-")
			end = $("#copperusestop").val().split("-")
			$("#copperusetable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getcopperuse"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#copperusetable").append(table)
					$("#copperusetable").show()
			)


		$("#copperusestart").bind(
			'change',
			() ->
				getCopperIncomeByDate()
		)

		$("#copperusestop").bind(
			'change',
			() ->
				getCopperIncomeByDate()
		)

		getCopperBillsByDate = () ->
			start = $("#copperbillsstart").val().split("-")
			end = $("#copperbillsstop").val().split("-")
			$("#copperbillsimages").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getcopperbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#copperbillsimages").append(table)
					$("#copperbillsimages").show()
			)

		$("#copperbillsstart").bind(
			'change',
			() ->
				getCopperBillsByDate()
			)
		$("#copperbillsstop").bind(
			'change',
			() ->
				getCopperBillsByDate()
			)



		# end of copper statistics

		# optical fiber statistics

		showOpticalPlanDialog = (id) ->
			$("#addcableplan").attr('value', id)
			$("#opticalPlanModal").modal('show')

		showOpticalUseDialog = (id, income_id) ->
			$("#addopticalcableuse").attr('value', id)
			$("#opticalUseModal").modal('show')

		showPlan = (income_id) ->
			$("#opticalincometable tr").each(
				() ->
					$(this).attr('class', '')
			)
			$("#opticalincometable tr[value="+income_id+"]").addClass('info')
			$("#opticalplannedtable").empty()
			utils.getDataFromDB(
				{
					"parameters" : [
						{"param_name" : "collection", "param_value" :  "opticalplans"},
						{"param_name" : "income_id", "param_value" :  income_id}
					],
					"path" : "getsaveditems"
				},
				(result) ->
					table = utils.createTableWithActiveElements(
						result.planTableData,
						showOpticalUseDialog,
						{ "fn" : deletePlan, selector : 'opticalplan', "income_id" : result.income_id}
					)
					$("#opticalplannedtable").append(table)
					$("#opticalplannedtable").show()
			)

		deletePlan = (plan_id) ->
			showConfirmDialog(
				() ->
					utils.getDataFromDB(
						{
							"parameters" : [
								{"param_name" : "collection", "param_value" :  "opticalplans"},
								{"param_name" : "type" , "param_value" :'onlyitems'}
							],
							"path" : "getsaveditems"

						},
						(plans) ->
							plan = plans.filter((e) -> e._id.toString() == plan_id)[0]
							saveOpticalFiberLog(
								'Видалив заплановану подію',
								plan.length,
								plan.intensions,
								plan.income_id
							)
							utils.postToServer(
								'deleteitem',
								{
									"collection" : 'opticalplans',
									"_id" : plan_id
								}
								() ->
									showOpticalIncomeTable()
									$("#opticalplannedtable").empty()

							)
					)
			)



		$("#showopticalincome").bind(
			'click',
			() ->
				showOpticalIncomeTable()

		)

		$("#showcabelimgs").bind(
			'click',
			() ->
				$("#billsimages").empty()
				utils.getDataFromDB(
					{
						"parameters" : [
							{"param_name" : "collection", "param_value" :  "opticalincome"},
							{"param_name" : "type" , "param_value" :'bills'}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#billsimages").append(table)
						$("#billsimages").show()
				)
		)

		$("#addcableplan").bind(
			'click',
			(e) ->

				if $("#opticalplanform").valid()
					id = e.target.getAttribute('value')
					utils.postToServer(
						'savecableplan',
						{
							"length" : +$("#opticalplanlength").val(),
							"intensions" : $("#opticalintensions").val(),
							"intensionstype" : $("#cabelPlanType").val()
							"date" : new Date().toISOString()
							"user" : ""
							"income_id" : id
						},
						() ->
							showOpticalIncomeTable()
							$("#opticalplannedtable").empty()
							$("button.close").trigger('click')
					)
		)

		saveOpticalFiberLog = (action, length, intensions, income_id) ->
			utils.postToServer(
				'saveitem',
				{
					"collection" : "opticallogs",
					"data" : {
						"action" : action
						"length" : length
						"date" : new Date().toISOString()
						"intensions" : intensions
						"cable" : ""
						"user" : ""
					},
					"income_id" : income_id
				},
				() ->
			)

		showOpticalIncomeTable = () ->
			$("#opticalincometable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [{"param_name" : "collection", "param_value" :  "opticalincome"},
				{"param_name" : "type", "param_value" :  "incometable"}],
				"path" : "getsaveditems"
				},
				(tableData) ->
					table = utils.createTableWithActiveElements(
						tableData,
						showOpticalPlanDialog,
						{"fn" : showPlan, "selector" : 'opticalincome'}
					)
					$("#opticalincometable").append(table)
					$("#opticalincometable").show()
			)

		$("#addopticalcableuse").bind(
			'click',
			(e) ->
				if $("#opticaluseform").valid() && isOptionSelected($("#opticaluseworkerselector"))
					incomeid = $("#dataTable tr.info").attr('value')
					id = e.target.getAttribute('value')
					workers = []
					$('#opticaluseworkerselector :selected').each(
						(i, selected) ->
							workers[i] = $(selected).text().trim()
					)
					utils.postToServer(
						'saveopticaluse',
						{
							"data" : {
								"length" : +$("#opticaluselength").val(),
								"workers" : workers,
								"date" : new Date().toISOString()
								"user" : ""
								"intensions" : ""
							},
							"income_id" : incomeid,
							"plan_id" : id
						},
						(plan) ->
							showOpticalIncomeTable()
							$("#opticalplannedtable").empty()
							$("button.close").trigger('click')
					)
		)


		$("#showopticaluse").bind(
			'click',
			() ->
				$("#opticalusetable").empty()
				utils.getDataFromDB(
					{
					"parameters" : [{"param_name" : "collection", "param_value" :  "opticaluse"}],
					"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#opticalusetable").append(table)
						$("#opticalusetable").show()
				)

		)

		$("#showopticallogs").bind(
			'click',
			() ->
				$("#opticallogstable").empty()
				utils.getDataFromDB(
					{
					"parameters" : [{"param_name" : "collection", "param_value" :  "opticallogs"}],
					"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#opticallogstable").append(table)
						$("#opticallogstable").show()
				)

		)

		$('#saveopticalincome').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#opticalincomeform").valid()
					utils.saveImageToServer(
						$('#opticalbillimage')[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
									'saveopticalincome',
									{
										"fibers" : $("#optfibers option:selected").text(),
										"rope" : $("#optrope").val(),
										"manufacturer" : $("#optmanufacturer").val(),
										"drum" : $("#optdrum option:selected").text(),
										"length" : +$("#optlength").val(),
										"initiallength" : +$("#optlength").val(),
										"price" : +$("#optprice").val(),
										"image" : image
										"date" : new Date().toISOString()
										"user" : ""
									},
									() ->
							)
					)
		)

		getOpticalBillsByDate = () ->
			start = $("#optbillsstart").val().split("-")
			end = $("#optbillsstop").val().split("-")
			$("#billsimages").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getopticalbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#billsimages").append(table)
					$("#billsimages").show()
			)

		$("#optbillsstart").bind(
			'change',
			() ->
				getOpticalBillsByDate()
			)
		$("#optbillsstop").bind(
			'change',
			() ->
				getOpticalBillsByDate()
			)




		getOpticalUseByDate = () ->
			start = $("#optusestart").val().split("-")
			end = $("#optusestop").val().split("-")
			$("#opticalusetable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getopticaluse"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#opticalusetable").append(table)
					$("#opticalusetable").show()
			)

		$("#optusestart").bind(
			'change',
			() ->
				getOpticalUseByDate()
			)
		$("#optusestop").bind(
			'change',
			() ->
				getOpticalUseByDate()
			)
		getOpticalLogsByDate = () ->
			start = $("#optlogsstart").val().split("-")
			end = $("#optlogsstop").val().split("-")
			$("#opticallogstable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getopticallogs"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#opticallogstable").append(table)
					$("#opticallogstable").show()
			)

		$("#optlogsstart").bind(
			'change',
			() ->
				getOpticalLogsByDate()
			)
		$("#optlogsstop").bind(
			'change',
			() ->
				getOpticalLogsByDate()
			)

		getChangeLogsByDate = () ->
			start = $("#changelogstartdate").val().split("-")
			end = $("#changelogenddate").val().split("-")
			$("#changelogtable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getchangelogs"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#changelogtable").append(table)
					$("#changelogtable").show()
			)

		$("#changelogstartdate").bind(
			'change',
			() ->
				getChangeLogsByDate()
			)

		$("#changelogenddate").bind(
			'change',
			() ->
				getChangeLogsByDate()
		)


# boxes store ----------------------------
		$('#saveboxtostore').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#boxstoreform").valid()
					utils.saveImageToServer(
						$('#boxbillimage')[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
								'saveboxtostore',
								{
									"data" : {
										"box_name" : $("#boxstoreselector option:selected").text().trim(),
										"quantity" : +$("#boxquantity").val()
										"init_quantity" : +$("#boxquantity").val()
										"image" : image
										"date" : new Date().toISOString()
									}
								},
								() ->
							)
					)
		)

		getBoxBillsByDate = () ->
			start = $("#boxbillsstart").val().split("-")
			end = $("#boxbillsstop").val().split("-")
			$("#boxesbillstable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getboxesbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#boxesbillstable").append(table)
					$("#boxesbillstable").show()
			)

		$("#boxbillsstart").bind(
			'change',
			() ->
				getBoxBillsByDate()
			)

		$("#boxbillsstop").bind(
			'change',
			() ->
				getBoxBillsByDate()
		)

		updateBoxStore = (_id) ->
			id = _id
			value = +$("#"+id).val() * -1
			utils.postToServer(
				'update',
				{
					"collection" : 'boxstore',
					"_id" : id,
					"data" : {'quantity' : value},
					"update_type" : "inc"
				},
				() ->
					saveChangesToWareHouseLogs(id, "boxstore", value)
					getAndShowBoxStoreData()
			)


		getAndShowBoxStoreData = () ->
			utils.getDataFromDB(
				{
				"parameters" : [
					{
						"param_name" : "collection",
						"param_value" : 'boxstore'
					},
					{
						"param_name" : "type",
						"param_value" : 'incometable'
					}

				],
				"path" : "getsaveditems"
				},
				(tableData) ->
					$("#boxesstoretable").empty()
					tableData = utils.createTableWithActiveElements(
						tableData,
						updateBoxStore
						{selector : 'boxesstore'}
					)
					$("#boxesstoretable").append(tableData)
			)


		$("#boxtostoretabletab").bind(
			'click',
			() ->
				getAndShowBoxStoreData()
		)

		$("#boxbills").bind(
			'click',
			() ->
				$("#boxesbillstable").empty()
				utils.getDataFromDB(
					{
						"parameters" : [
							{
								"param_name" : "collection",
								"param_value" :  "boxstore"
							},
							{
								"param_name" : "type" ,
								"param_value" :'bills'
							}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#boxesbillstable").append(table)
						$("#boxesbillstable").show()
				)
		)

		# patchpaneles store ----------------------------
		$('#savepatchpaneltostore').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#patchpanelstoreform").valid()
					utils.saveImageToServer(
						$('#patchpanelbillimage')[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
								'savepatchpaneltostore',
								{
									"data" : {
										"patchpanel_name" : $("#patchpanelstoreselector option:selected").text().trim(),
										"quantity" : +$("#patchpanelquantity").val()
										"init_quantity" : +$("#patchpanelquantity").val()
										"image" : image
										"date" : new Date().toISOString()
									}
								},
								() ->
							)
					)
		)

		getpatchpanelBillsByDate = () ->
			start = $("#patchpanelbillsstart").val().split("-")
			end = $("#patchpanelbillsstop").val().split("-")
			$("#patchpanelesbillstable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getpatchpanelesbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#patchpanelesbillstable").append(table)
					$("#patchpanelesbillstable").show()
			)

		$("#patchpanelbillsstart").bind(
			'change',
			() ->
				getpatchpanelBillsByDate()
			)

		$("#patchpanelbillsstop").bind(
			'change',
			() ->
				getpatchpanelBillsByDate()
		)

		updatepatchpanelStore = (_id) ->
			id = _id
			value = +$("#"+id).val() * -1
			utils.postToServer(
				'update',
				{
					"collection" : 'patchpanelstore',
					"_id" : id,
					"data" : {'quantity' : value},
					"update_type" : "inc"
				},
				() ->
					saveChangesToWareHouseLogs(id, "patchpanelstore", value)
					getAndShowpatchpanelStoreData()
			)


		getAndShowpatchpanelStoreData = () ->
			utils.getDataFromDB(
				{
				"parameters" : [
					{
						"param_name" : "collection",
						"param_value" : 'patchpanelstore'
					},
					{
						"param_name" : "type",
						"param_value" : 'incometable'
					}
				],
				"path" : "getsaveditems"
				},
				(tableData) ->
					$("#patchpanelesstoretable").empty()
					tableData = utils.createTableWithActiveElements(
						tableData,
						updatepatchpanelStore
						{selector : 'patchpanelesstore'}
					)
					$("#patchpanelesstoretable").append(tableData)
			)


		$("#patchpaneltostoretabletab").bind(
			'click',
			() ->
				getAndShowpatchpanelStoreData()
		)

		$("#patchpanelbills").bind(
			'click',
			() ->
				$("#patchpanelesbillstable").empty()
				utils.getDataFromDB(
					{
						"parameters" : [
							{
								"param_name" : "collection",
								"param_value" :  "patchpanelstore"
							},
							{
								"param_name" : "type" ,
								"param_value" :'bills'
							}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#patchpanelesbillstable").append(table)
						$("#patchpanelesbillstable").show()
				)
		)

		# patchcordes store ----------------------------
		$('#savepatchcordtostore').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#patchcordstoreform").valid()
					utils.saveImageToServer(
						$('#patchcordbillimage')[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
								'savepatchcordtostore',
								{
									"data" : {
										"patchcord_length" : $("#patchcordlengthsselector option:selected").text().trim(),
										"patchcord_types" : $("#patchcordstypesselector option:selected").text().trim(),
										"quantity" : +$("#patchcordquantity").val()
										"init_quantity" : +$("#patchcordquantity").val()
										"image" : image
										"date" : new Date().toISOString()
									}
								},
								() ->
							)
					)
		)

		getpatchcordBillsByDate = () ->
			start = $("#patchcordbillsstart").val().split("-")
			end = $("#patchcordbillsstop").val().split("-")
			$("#patchcordesbillstable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getpatchcordesbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#patchcordesbillstable").append(table)
					$("#patchcordesbillstable").show()
			)

		$("#patchcordbillsstart").bind(
			'change',
			() ->
				getpatchcordBillsByDate()
			)

		$("#patchcordbillsstop").bind(
			'change',
			() ->
				getpatchcordBillsByDate()
		)

		updatepatchcordStore = (_id) ->
			id = _id
			value = +$("#"+id).val() * -1
			utils.postToServer(
				'update',
				{
					"collection" : 'patchcordstore',
					"_id" : id,
					"data" : {'quantity' : value},
					"update_type" : "inc"
				},
				() ->
					saveChangesToWareHouseLogs(id, "patchcordstore", value)
					getAndShowpatchcordStoreData()
			)


		getAndShowpatchcordStoreData = () ->
			utils.getDataFromDB(
				{
				"parameters" : [
					{
						"param_name" : "collection",
						"param_value" : 'patchcordstore'
					},
					{
						"param_name" : "type",
						"param_value" : 'incometable'
					}
				],
				"path" : "getsaveditems"
				},
				(tableData) ->
					$("#patchcordesstoretable").empty()
					tableData = utils.createTableWithActiveElements(
						tableData,
						updatepatchcordStore
						{selector : 'patchcordesstore'}
					)
					$("#patchcordesstoretable").append(tableData)
			)


		$("#patchcordtostoretabletab").bind(
			'click',
			() ->
				getAndShowpatchcordStoreData()
		)

		$("#patchcordbills").bind(
			'click',
			() ->
				$("#patchcordesbillstable").empty()
				utils.getDataFromDB(
					{
						"parameters" : [
							{
								"param_name" : "collection",
								"param_value" :  "patchcordstore"
							},
							{
								"param_name" : "type" ,
								"param_value" :'bills'
							}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#patchcordesbillstable").append(table)
						$("#patchcordesbillstable").show()
				)
		)

		# pigtailses store ----------------------------
		$('#savepigtailstostore').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#pigtailsstoreform").valid()
					utils.saveImageToServer(
						$('#pigtailsbillimage')[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
								'savepigtailstostore',
								{
									"data" : {
										"pigtails_length" : $("#pigtailslengthsselector option:selected").text().trim(),
										"pigtails_types" : $("#pigtailstypesselector option:selected").text().trim(),
										"quantity" : +$("#pigtailsquantity").val()
										"init_quantity" : +$("#pigtailsquantity").val()
										"image" : image
										"date" : new Date().toISOString()
									}
								},
								() ->
							)
					)
		)

		getpigtailsBillsByDate = () ->
			start = $("#pigtailsbillsstart").val().split("-")
			end = $("#pigtailsbillsstop").val().split("-")
			$("#pigtailsesbillstable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getpigtailsesbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#pigtailsesbillstable").append(table)
					$("#pigtailsesbillstable").show()
			)

		$("#pigtailsbillsstart").bind(
			'change',
			() ->
				getpigtailsBillsByDate()
			)

		$("#pigtailsbillsstop").bind(
			'change',
			() ->
				getpigtailsBillsByDate()
		)

		updatepigtailsStore = (_id) ->
			id = _id
			value = +$("#"+id).val() * -1
			utils.postToServer(
				'update',
				{
					"collection" : 'pigtailsstore',
					"_id" : id,
					"data" : {'quantity' : value},
					"update_type" : "inc"
				},
				() ->
					saveChangesToWareHouseLogs(id, "pigtailsstore", value)
					getAndShowpigtailsStoreData()
			)


		getAndShowpigtailsStoreData = () ->
			utils.getDataFromDB(
				{
				"parameters" : [
					{
						"param_name" : "collection",
						"param_value" : 'pigtailsstore'
					},
					{
						"param_name" : "type",
						"param_value" : 'incometable'
					}
				],
				"path" : "getsaveditems"
				},
				(tableData) ->
					$("#pigtailsesstoretable").empty()
					tableData = utils.createTableWithActiveElements(
						tableData,
						updatepigtailsStore
						{selector : 'pigtailsesstore'}
					)
					$("#pigtailsesstoretable").append(tableData)
			)


		$("#pigtailstostoretabletab").bind(
			'click',
			() ->
				getAndShowpigtailsStoreData()
		)

		$("#pigtailsbills").bind(
			'click',
			() ->
				$("#pigtailsesbillstable").empty()
				utils.getDataFromDB(
					{
						"parameters" : [
							{
								"param_name" : "collection",
								"param_value" :  "pigtailsstore"
							},
							{
								"param_name" : "type" ,
								"param_value" :'bills'
							}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#pigtailsesbillstable").append(table)
						$("#pigtailsesbillstable").show()
				)
		)

		# socketses store ----------------------------
		$('#savesocketstostore').bind(
			'click',
			(evt) ->
				evt.preventDefault();
				if $("#socketsstoreform").valid()
					utils.saveImageToServer(
						$('#socketsbillimage')[0].files[0],
						'/uploadbillimage',
						(image) ->
							utils.postToServer(
								'savesocketstostore',
								{
									"data" : {
										"sockets_type" : $("#socketsstoreselector option:selected").text().trim(),
										"quantity" : +$("#socketsquantity").val()
										"init_quantity" : +$("#socketsquantity").val()
										"image" : image
										"date" : new Date().toISOString()
									}
								},
								() ->
							)
					)
		)

		getsocketsBillsByDate = () ->
			start = $("#socketsbillsstart").val().split("-")
			end = $("#socketsbillsstop").val().split("-")
			$("#socketsesbillstable").empty()
			utils.getDataFromDB(
				{
				"parameters" : [
					{"param_name" : "syear", "param_value" :  start[0]},
					{"param_name" : "smonth", "param_value" :  start[1]-1},
					{"param_name" : "sday", "param_value" :  start[2]},
					{"param_name" : "eyear", "param_value" :  end[0]},
					{"param_name" : "emonth", "param_value" :  end[1]-1},
					{"param_name" : "eday", "param_value" :  end[2]}
					],
				"path" : "getsocketsesbills"
				},
				(tableData) ->
					table = utils.createTable(tableData)
					$("#socketsesbillstable").append(table)
					$("#socketsesbillstable").show()
			)

		$("#socketsbillsstart").bind(
			'change',
			() ->
				getsocketsBillsByDate()
			)

		$("#socketsbillsstop").bind(
			'change',
			() ->
				getsocketsBillsByDate()
		)

		updatesocketsStore = (_id) ->
			id = _id
			value = +$("#"+id).val() * -1
			utils.postToServer(
				'update',
				{
					"collection" : 'socketsstore',
					"_id" : id,
					"data" : {'quantity' : value},
					"update_type" : "inc"
				},
				() ->
					getAndShowsocketsStoreData()
					saveChangesToWareHouseLogs(id, "socketsstore", value)
			)

		saveChangesToWareHouseLogs = (id, collection, quantity) ->
			utils.postToServer(
				'savewarehouseuselog',
				{
					"collection" : collection,
					"id" : id,
					"quantity" : quantity*-1
				},
				() ->
			)


		getAndShowsocketsStoreData = () ->
			utils.getDataFromDB(
				{
				"parameters" : [
					{
						"param_name" : "collection",
						"param_value" : 'socketsstore'
					},
					{
						"param_name" : "type",
						"param_value" : 'incometable'
					}
				],
				"path" : "getsaveditems"
				},
				(tableData) ->
					$("#socketsesstoretable").empty()
					tableData = utils.createTableWithActiveElements(
						tableData,
						updatesocketsStore
						{selector : 'socketsesstore'}
					)
					$("#socketsesstoretable").append(tableData)
			)


		$("#socketstostoretabletab").bind(
			'click',
			() ->
				getAndShowsocketsStoreData()
		)

		$("#socketsbills").bind(
			'click',
			() ->
				$("#socketsesbillstable").empty()
				utils.getDataFromDB(
					{
						"parameters" : [
							{
								"param_name" : "collection",
								"param_value" :  "socketsstore"
							},
							{
								"param_name" : "type" ,
								"param_value" :'bills'
							}
						],
						"path" : "getsaveditems"
					},
					(tableData) ->
						table = utils.createTable(tableData)
						$("#socketsesbillstable").append(table)
						$("#socketsesbillstable").show()
				)
		)


		# workers cash ---------

		updateCashDatabase = (value) ->
			utils.postToServer(
				"deleteitem",
				{
					"collection" : "workerscash",
					"_id" : value
				},
				() ->
					getAndDisplayWorkersCashData()
			)

		getAndDisplayWorkersCashData = () ->
			$("#workerscashtables").empty()
			utils.getDataFromDB(
				{
					"parameters" : [
						{
							"param_name" : "coefficient",
							"param_value" :  1
						}
					],
					"path" : "getworkerscash"
				},
				(tableData) ->
					table = utils.createTableWithActiveElements(
						tableData,
						updateCashDatabase
						{selector : 'workerscash'}
					)
					$("#workerscashtables").append(table)
					$("#workerscashtables").show()
			)


		$("#workercablecash").bind(
			'click',
			() ->
				getAndDisplayWorkersCashData()
		)

		$("#boxstoreform").validate(
			rules : {

				boxquantity : {
					required : true,
					digits : true
					},

				boxbillimage: {
					required: true
					}
			}
		)


		$("#patchcordstoreform").validate(
			rules : {

				patchcordquantity : {
					required : true,
					digits : true
					},

				patchcordbillimage: {
					required: true
					}
			}
		)


		$("#patchpanelstoreform").validate(
			rules : {

				patchpanelquantity : {
					required : true,
					digits : true
					},

				patchpanelbillimage: {
					required: true
					}
			}
		)

		$("#pigtailsstoreform").validate(
			rules : {

				pigtailsquantity : {
					required : true,
					digits : true
					},

				pigtailsbillimage: {
					required: true
					}
			}
		)

		$("#socketsstoreform").validate(
			rules : {

				socketsquantity : {
					required : true,
					digits : true
					},

				socketsbillimage: {
					required: true
					}
			}
		)

		$("#copperuseform").validate({
			rules: {
					copperuselength : {
						required: true
						digits : true
					}
					coppercontract: {
						required: true
					}
				}
		})

		$("#opticalplanform").validate({
			rules: {
					opticalplanlength : {
						required: true
						digits : true
					}
					opticalintensions: {
						required: true
					}
				}
		})

		$("#opticaluseform").validate({
			rules: {
					opticaluselength : {
						required: true
						digits : true
					}
				}
		})

		$("#opticalincomeform" ).validate({
			rules: {
					optlength : {
						required: true,
						digits : true
					}
					optmanufacturer : {
						required: true,
					}
					optprice: {
						required: true,
						digits : true
					}
					opticalbillimage: {
						required:true
					}
				}
		})

		$("#copperinputform" ).validate({
			rules: {
					copperrope : {
						required: true,
						digits : true
					}
					coppermanufacturer : {
						required: true
					}
					copperserial : {
						required: true
					}
					copperlength : {
						required: true,
						digits : true
					}
					copperprice : {
						required: true,
						digits : true
					}
					copperbillimage: {
						required:true
					}

				}
		})
)