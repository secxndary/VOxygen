CREATE OR ALTER VIEW UsersOrders
AS
	SELECT 
		U.id ID, 
		U.login Логин, 
		T.name Название_услуги, 
		O.order_datetime Дата_и_время, 
		(SELECT dbo.getOrderPriceByWithMargin(O.id)) Цена, 
		T.duration Длительность, 
		P.company_name Предоставитель_услуги, 
		S.name Статус_заказа
	FROM 
		users AS U JOIN orders AS O 
		ON U.id = O.users_id JOIN tasks AS T
		ON T.id = O.task_id JOIN providers AS P
		ON P.id = T.provider_id JOIN status AS S
		ON S.id = O.status
	ORDER BY
		Дата_и_время
WITH CHECK OPTION;