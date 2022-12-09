CREATE OR ALTER VIEW UsersOrders
AS
	SELECT 
		U.id ID, 
		U.login �����, 
		T.name ��������_������, 
		O.order_datetime ����_�_�����, 
		(SELECT dbo.getOrderPriceByWithMargin(O.id)) ����, 
		T.duration ������������, 
		P.company_name ��������������_������, 
		S.name ������_������
	FROM 
		users AS U JOIN orders AS O 
		ON U.id = O.users_id JOIN tasks AS T
		ON T.id = O.task_id JOIN providers AS P
		ON P.id = T.provider_id JOIN status AS S
		ON S.id = O.status
	ORDER BY
		����_�_�����
WITH CHECK OPTION;