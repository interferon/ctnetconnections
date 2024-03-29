module.exports =  {
	
	copper : {

		full:{
				fields : ["type", "pairs", "rope", "manufacturer", "serial", "length", "price", "user"],
				headers : ['№','Тип', 'К-сть пар', 'Трос',  'Виробник', 'Серійний №', "Довжина(м)","Ціна(грн)","Додав", 'Використати']
			},
			
		standart:{
					fields : ["type", "pairs", "rope", "manufacturer", "serial", "length", "user"],
					headers : ['№', 'Тип', 'К-сть пар', 'Трос',  'Виробник', 'Серійний №', "Довжина(м)", "Додав", 'Використати']
			}
	},

	optics: {

		full : {
			fields : ["fibers", "rope", "manufacturer", "drum", "length", "totalplan", "left", "price", "user"],
			headers : ['№','Волокон', 'Трос', 'Виробник','Барабан',  'Довжина(м)', 'Заплановано(м)', 'Вільно(м)', 'Ціна (грн)', 'Додав', 'Запланувати','Переглянути план']
		},

		standart : {
			fields : ["fibers", "rope", "manufacturer", "drum", "length", "totalplan", "left", "user"],
			headers : ['№','Волокон', 'Трос', 'Виробник','Барабан',  'Довжина(м)', 'Заплановано(м)', 'Вільно(м)', 'Додав', 'Запланувати','Переглянути план']
		}
	}
}
