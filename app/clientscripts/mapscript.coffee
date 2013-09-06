$(document).ready(
	() ->
		window.initYandexMaps = () ->
			getBuildingsCoordinates = (buildings, callback) ->
				coords = []
				count = 0
				for c in buildings
					street = c.building_name.replace('є', 'е')
					myGeocoder = ymaps.geocode("Україна місто Чернівці "+street)
					myGeocoder.then(
						(res) ->
							coordinates = res.geoObjects.get(0).geometry.getCoordinates()
							coords.push(coordinates)
							count++
							if count == buildings.length
								callback(coords)
						,
						(err) ->
					)

			createPolylineCoordinates = (startcoordinate, endcoordinates) ->
				connectionscoordinates = []
				for coords in endcoordinates
					connectionscoordinates.push(startcoordinate)
					connectionscoordinates.push(coords)
				return connectionscoordinates

			displayConnections = (map,startcoordinates, endcoordinates, color) ->
				polylinecoordinates = createPolylineCoordinates(startcoordinates, endcoordinates)
				myPolyline = new ymaps.Polyline(
					polylinecoordinates,
					{# // Описываем свойства геообъекта.
						balloonContent: ""  # Содержимое балуна.
					},
					{ # // Задаем опции геообъекта.
						balloonHasCloseButton:false,# // Отключаем кнопку закрытия балуна.
						strokeColor: color,# // Цвет линии.
						strokeWidth: 2,# // Ширина линии.
						strokeOpacity: 0.7# // Коэффициент прозрачности.
					}
				)
				map.geoObjects.add(myPolyline)

			getBuildingInfoById = (building_id, callback) ->
				utils.getDataFromDB(
					{
						"parameters" : [
							{"param_name" : "collection", "param_value" :  "buildings"},
							{"param_name" : "building_id", "param_value" : building_id}
						],
						"path" : "getsaveditems"
					},
					(buildinginfo) ->
						callback(buildinginfo)
				)

			createMap = () ->
				$('#map').empty()
				return new ymaps.Map("map", {center : [26, 48], zoom: 5})

			markSelectedBuildingOnMapWithCircle = (map, diameter, coordinates,centermap, street_name ) ->
				map.setCenter(coordinates, 17) if centermap
				circle = new ymaps.Circle(
					[coordinates, diameter],
					{content : street_name, balloonContent: street_name},
					{ geodesic: true}
				)
				map.geoObjects.add(circle)

			displayInfoOnMap = (street_name, building_id) ->
				in_line_color = "F20A0A"
				out_line_color = "1A0AC9"
				map = createMap()
				getBuildingsCoordinates(
					[{building_name : street_name}],
					(buildings_coords) ->
						markSelectedBuildingOnMapWithCircle(map, 12, buildings_coords[0],true, street_name)
						getBuildingInfoById(
							building_id,
							(buildinginfo) ->
								getBuildingsCoordinates(
									buildinginfo.connections.incoming_connections,
									(connected_buildings_coords) ->
										for coords in connected_buildings_coords
											markSelectedBuildingOnMapWithCircle(map, 7, coords,false, "")
										displayConnections(map, buildings_coords[0], connected_buildings_coords, in_line_color)			
								)
								getBuildingsCoordinates(
									buildinginfo.connections.outgoing_connections,
									(connected_buildings_coords) ->
										for coords in connected_buildings_coords
											markSelectedBuildingOnMapWithCircle(map, 7, coords,false, "")
										displayConnections(map, buildings_coords[0], connected_buildings_coords, out_line_color)	
								)
						)
				)
			
			assignEventsToBuildingsList = () ->
				$("#buildingslist li a").bind(
					'click',
					(e) ->
						buildings_street_name = e.target.innerText
						building_id = e.target.attributes.value.nodeValue
						displayInfoOnMap(buildings_street_name, building_id)
				)
			
			assignEventsToBuildingsList()
			$("#buildingslist li:nth-child(2) a").trigger('click')

)