CREATE OR ALTER VIEW ProvidersTasks
AS
	SELECT 
		T.id ID_услуги,
		T.name Название_услуги, 
		T.price Стоимость_услуги, 
		T.duration Длительность, 
		P.company_name Поставщик_услуг,
		P.trade_margin Процент_наценки
	FROM 
		tasks AS T 
	JOIN providers AS P
	ON T.provider_id = P.id
WITH CHECK OPTION;