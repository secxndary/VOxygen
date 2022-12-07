USE CP_TEST;
GO


CREATE OR ALTER FUNCTION getProvidersOrdersOnThisDate
(
	@company_name NVARCHAR(50),
	@datetime DATETIME2(0)
)
RETURNS TABLE
AS
RETURN
	SELECT 
		company_name provider, opening_time provider_opens, closing_time provider_closes, 
		task_id, name task_name, duration task_duration, O.id order_id, order_datetime
	FROM orders AS O 
	JOIN tasks AS T 
		ON O.task_id = T.id 
	JOIN providers AS P
		ON T.provider_id = P.id 
	JOIN schedules AS S
		ON S.provider_id = P.id
	WHERE P.company_name = @company_name 
		AND CAST(O.order_datetime AS DATE) = CAST(@datetime AS DATE)
GO

SELECT * FROM getProvidersOrdersOnThisDate('Roc-A-Fella Records', '2022-12-05 12:00:00');




GO
CREATE OR ALTER FUNCTION getProvidersOpeningTime
(
	@company_name NVARCHAR(50)
)
RETURNS TABLE
AS
RETURN
	SELECT DISTINCT opening_time
	FROM tasks AS T 
	JOIN providers AS P
		ON T.provider_id = P.id 
	JOIN schedules AS S
		ON S.provider_id = P.id
	WHERE P.company_name = @company_name 
GO

SELECT * FROM getProvidersOpeningTime('Roc-A-Fella Records');






GO
CREATE OR ALTER FUNCTION getOrdersOnThisDate
(
	@datetime DATETIME2(0)
)
RETURNS TABLE
AS
RETURN
	SELECT
		company_name provider, opening_time provider_opens, closing_time provider_closes, 
		task_id, name task_name, duration task_duration, O.id order_id, order_datetime
	FROM orders AS O 
	JOIN tasks AS T 
		ON O.task_id = T.id 
	JOIN providers AS P
		ON T.provider_id = P.id 
	JOIN schedules AS S
		ON S.provider_id = P.id
	WHERE CAST(O.order_datetime AS DATE) = CAST(@datetime AS DATE)
GO

SELECT * FROM getOrdersOnThisDate('2022-12-05 12:00:00');




GO
CREATE OR ALTER FUNCTION getTaskDurationByTaskNameAndCompanyName
(
	@task_name NVARCHAR(MAX),
	@company_name NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @task_duration INT;
	SET @task_duration = 
	(
		SELECT T.duration
		FROM tasks AS T 
		JOIN providers AS P
			ON P.id = T.provider_id
		WHERE T.name = @task_name 
			AND P.company_name = @company_name
	);
	RETURN @task_duration;
END
GO

SELECT dbo.getTaskDurationByTaskNameAndCompanyName('Consultation', 'Roc-A-Fella Records');




GO
CREATE OR ALTER FUNCTION getTaskIdByTaskNameAndCompanyName
(
	@task_name NVARCHAR(MAX),
	@company_name NVARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @task_id INT;
	SET @task_id = 
	(
		SELECT T.id
		FROM tasks AS T 
		JOIN providers AS P
			ON P.id = T.provider_id
		WHERE T.name = @task_name 
			AND P.company_name = @company_name
	);
	RETURN @task_id;
END
GO

SELECT dbo.getTaskIdByTaskNameAndCompanyName('Consultation', 'Roc-A-Fella Records');





GO 
CREATE OR ALTER FUNCTION getOrderPriceByOrderId
(
	@order_id INT
)
RETURNS INT
AS
BEGIN
	DECLARE @order_price INT;
	SET @order_price = 
	(
		SELECT T.price
		FROM orders AS O 
		JOIN tasks AS T 
			ON O.task_id = T.id 
		WHERE O.id = @order_id
	);
	RETURN @order_price;
END
GO

SELECT dbo.getOrderPriceByOrderId(806);




GO 
CREATE OR ALTER FUNCTION getOrderPriceByWithMargin
(
	@order_id INT
)
RETURNS INT
AS
BEGIN
	DECLARE @order_price INT;
	SET @order_price = 
	(
		SELECT T.price
		FROM orders AS O 
		JOIN tasks AS T 
			ON O.task_id = T.id 
		WHERE O.id = @order_id
	);
	DECLARE @provMargin INT = 
	(
		SELECT P.trade_margin
		FROM orders AS O 
		JOIN tasks AS T 
			ON O.task_id = T.id 
		JOIN providers AS P
			ON P.id = T.provider_id
		WHERE O.id = @order_id
	);
	DECLARE @provMarginInPercents FLOAT = CAST(@provMargin AS FLOAT) / 100;
	DECLARE @orderPriceWithMargin INT = @order_price + @order_price * @provMarginInPercents;
	RETURN @orderPriceWithMargin;
END
GO

SELECT dbo.getOrderPriceByWithMargin(806);




GO 
CREATE OR ALTER FUNCTION getArtistIdByOrderId
(
	@order_id INT
)
RETURNS INT
AS
BEGIN
	DECLARE @artist_id INT = 
	(
		SELECT A.id
		FROM orders AS O
		JOIN users AS U 
			ON U.id = O.users_id
		JOIN artists AS A
			ON A.users_id = U.id
		WHERE O.id = @order_id
	);
	RETURN @artist_id;
END;
GO

SELECT dbo.getArtistIdByOrderId(808);
