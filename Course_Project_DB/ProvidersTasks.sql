CREATE OR ALTER VIEW ProvidersTasks
AS
	SELECT 
		T.id ID_������,
		T.name ��������_������, 
		T.price ���������_������, 
		T.duration ������������, 
		P.company_name ���������_�����,
		P.trade_margin �������_�������
	FROM 
		tasks AS T 
	JOIN providers AS P
	ON T.provider_id = P.id
WITH CHECK OPTION;