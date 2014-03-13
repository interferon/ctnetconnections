$(document).ready(
	() ->
		
		consts = {
			#free cable for client
			unpaidCable : 60
			# cable length paid with usual price 
			regularlyPaidCable : 60
			# limit of total free and usual price cable(sum of two previous)
			limitCable : 120
			pricePerMeter : 5
			pricePerMeterAsWork: 4
			work : 150
			promowork : 100
			promo : 250
		}

		opticalpayments = {
			commutator : 81
			mediaconverter : 54
			no : 0
		}

		finance = {
			getUSDAdjust : (cb) ->
				$.get(
					"/usdadjust",
					(json) ->
						cb(+json.adjust) 
				)
			used_providers : 0
			providers_url : {
				'yahoo' : "http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json",
				'rate_exchange' : "http://rate-exchange.appspot.com/currency?from=USD&to=UAH"
			}
			current_rate : null
			getUAHEchangeRate : (provider, url, adjust, cb) ->
				if finance.used_providers < 2
					$.ajax({
						url: url,
						dataType: 'jsonp', 
						success: (json)->
							uahrate = finance.extractUAHRate[provider](json);
							console.log(uahrate);
							finance.current_rate = (uahrate + adjust)
							ui.setCurrentRate(finance.current_rate.toFixed(2));
							finance.used_providers++;
							cb();
						,
						error:() ->
							finance.getUAHEchangeRate('rate_exchange', finance.providers_url.rate_exchange, adjust);

					})
			extractUAHRate :{
				yahoo : (rates) ->
					for rate in rates.list.resources
						price = rate.resource.fields.price
						symbol = rate.resource.fields.symbol
						uahrate = +price if symbol == "UAH=X"
					return +uahrate 
				rate_exchange : (rate) ->
					return rate.rate
				} 
		}
		
		

		ui = {
			setCurrentRate : (rate) -> $("#current_rate").text(rate); 
			getprepaid : () -> return $("input[name='promo']:checked").attr('value') == "yes" ? true : false
			getcablelength : () ->	return +$("#cablelength").val()
			getuserplan : () -> return +$("#userplan").val()
			getuserplanduration : () -> return +$("#userplanduration").val()
			getopticaltype : () -> return $("input[name='opticalequipment']:checked").attr('value')
			getoncashstatus : () -> return $("input[name='oncash']:checked").attr('value') == "yes" ? true : false
			setuserbill : (value) -> $("#userbill").text(value)
			setworkcost : (value) -> $("#work").text(value)
			settotalcost : (value) -> $("#total").text(value)
			setlabelstext : (text) ->
				$("#userbill").text(text.userbill)
				$("#work").text(text.work)
				$("#total").text(text.total)

			
			oncashblockhide : () -> $("#oncashblock").hide()
			oncashblockshow : () -> $("#oncashblock").show()
			promoblockhide : () -> $("#promoblock").hide()
			promoblockshow : () -> $("#promoblock").show()
			showuserplanwarning : () -> 
				$("#warninglabel").text("Заповніть поле!")
				$("#userplan").addClass('error')

			hideuserplanwarning : () -> $("#warninglabel").text("")

			nullifylabels : () ->
				$("#userbill").text("0")
				$("#work").text("0")
				$("#total").text("0")
				
			preselectRadioButtons : () -> 
				$("#promoprepaidyes").trigger('click')
				$("#opticalequipmentno").trigger('click')
				$("#oncashno").trigger('click')
				
			preFillTextFields : () ->
				$("#cablelength").val(1)
				$("#userplan").val(0)
				$("#userplanduration").val(0)
				
		} 


		formulas = {
			# plan bill  = price per month * number of monthes 
			calculateShortLengthCase : (prepaid, planbill, opticaltype) ->
				work = consts.work
				userbill = 0
				# if user pay promo price ,
				# than put promoprice to user bill,
				# and use special work price
				if prepaid
					userbill=+consts.promo
					work = consts.promowork
				# add price of optical equipment
				work += opticalpayments[opticaltype]*finance.current_rate
				total = work + userbill

				if planbill > 0
					total += planbill
					userbill+=planbill
				return {
					work : work.toFixed(0)
					userbill : userbill.toFixed(0)
					total : total.toFixed(0)
				}

			calculateMeduimLengthCase : (cablelength, prepaid, planbill, opticaltype) ->
				cableToCount = cablelength - consts.unpaidCable
				work = cableToCount * consts.pricePerMeter
				userbill = 0
				if prepaid
					userbill=+consts.promo
					work += consts.promowork
				else
					work+=consts.work
				work += opticalpayments[opticaltype] * finance.current_rate
				total = work + userbill
				if planbill > 0
					total = total + planbill
					userbill+=planbill
				return {
					work : work.toFixed(0)
					userbill : userbill.toFixed(0)
					total : total.toFixed(0)
				}

			calculateLongLengthCase : (cablelength, userplan, userplanduration, oncash, opticaltype) ->
				work = consts.regularlyPaidCable * consts.pricePerMeter + consts.promowork
				userbill = consts.promo  
				if oncash
					userbill += (cablelength - consts.limitCable)*consts.pricePerMeter
					overpay = userbill - userplan * 12
					if overpay > 0
						work = work + overpay
						userbill = userbill - overpay
				else
					work += (cablelength - consts.limitCable)*consts.pricePerMeterAsWork
				work += opticalpayments[opticaltype] * finance.current_rate
				userbill = userbill + userplan * userplanduration
				total = work + userbill
				return {
					work : work.toFixed(0)
					userbill : userbill.toFixed(0)
					total : total.toFixed(0);
				}
		}

		calculateAndshowResults = () ->
			result = calculatePayments(
				ui.getcablelength(),
				ui.getprepaid(),
				ui.getuserplan(),
				ui.getuserplanduration(),
				ui.getoncashstatus(),
				ui.getopticaltype()
			)
			ui.nullifylabels()
			ui.setlabelstext(result)
			
		calculatePayments = (cablelength, prepaid, userplan, userplanduration,  oncash, opticaltype) ->
			ui.oncashblockhide()
			ui.hideuserplanwarning()
			ui.promoblockshow()
			result = {}
			userbill = userplan * userplanduration
			if cablelength < 61
				result = formulas.calculateShortLengthCase(prepaid, userbill, opticaltype)	
			if cablelength >= 61 && cablelength <= 120
				result = formulas.calculateMeduimLengthCase(cablelength, prepaid, userbill, opticaltype)
			if cablelength > 120 
				ui.oncashblockshow()
				ui.promoblockhide()
				if ui.getuserplan() > 0
					ui.hideuserplanwarning()
					result = formulas.calculateLongLengthCase(cablelength, userplan, userplanduration,  oncash, opticaltype)
				else
					ui.showuserplanwarning()
			return result

		assignEvents = () ->
			$("input[type='text']").keyup(
				() ->
					calculateAndshowResults()
			)
			$("input[type='radio']").change(
				() ->
					calculateAndshowResults()
			)

		# program starts here
		finance.getUSDAdjust(
			(adjust) ->
				finance.getUAHEchangeRate(
					'yahoo',
					finance.providers_url.yahoo,
					adjust,
					() ->
						initUI();
				);
		)

		initUI = () ->
			assignEvents()
			ui.oncashblockhide()
			ui.preselectRadioButtons()
			ui.preFillTextFields()
)