$(document).ready(
	() ->
		consts = {
			unpaidCable : 60
			regularlyPaidCable : 60
			limitCable : 120
			pricePerMeter : 5
			pricePerMeterAsWork: 4
			work : 150
			promowork : 75
			promo : 300
		}

		opticalpayments = {
			commutator : 640
			mediaconverter : 450
			no : 0
		}

		ui = {
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
							
			calculateShortLengthCase : (prepaid, planbill, opticaltype) ->
				work = consts.work
				userbill = 0
				if prepaid
					userbill=+consts.promo
					work = consts.promowork
				work += opticalpayments[opticaltype]
				total = work + userbill
				if planbill > 0
					total += planbill
					userbill+=planbill
				return {
					work : work
					userbill : userbill
					total : total
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
				work += opticalpayments[opticaltype]
				total = work + userbill
				if planbill > 0
					total = total + planbill
					userbill+=planbill
				return {
					work : work
					userbill : userbill
					total : total
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
				work += opticalpayments[opticaltype]
				userbill = userbill + userplan * userplanduration
				total = work + userbill
				return {
					work : work
					userbill : userbill
					total : total
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

		assignEvents()
		ui.oncashblockhide()
		ui.preselectRadioButtons()
		ui.preFillTextFields()

)