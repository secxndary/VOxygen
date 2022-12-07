USE CP_TEST;
GO

CREATE OR ALTER PROC getOrderStatus
	@user_id INT,
	@order_id INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @countOfOrders INT, @isUserHaveThisOrder INT;
	BEGIN TRY
		IF NOT EXISTS (SELECT * FROM users WHERE id = @user_id)
			RAISERROR('[ERROR] getOrderStatus: There is no user with this ID.', 17, 1);
		IF NOT EXISTS (SELECT * FROM orders WHERE id = @order_id)
			RAISERROR('[ERROR] getOrderStatus: There is no orders with this ID.', 17, 1);
		SET @countOfOrders = (
			SELECT COUNT(*) FROM users AS U JOIN orders AS O 
			ON U.id = O.users_id
			WHERE U.id = @user_id);
		IF @countOfOrders = 0
			RAISERROR('[ERROR] getOrderStatus: User does not have any orders.', 17, 1);
		IF NOT EXISTS (
			SELECT * FROM users AS U JOIN orders AS O 
			ON U.id = O.users_id
			WHERE U.id = @user_id AND O.id = @order_id)
		RAISERROR('[ERROR] getOrderStatus: User does not have order with this ID.', 17, 1);

		SELECT T.name Название_услуги, O.order_datetime Дата_и_время, 
			   T.price Цена, T.duration Длительность, S.name Статус_заказа
		FROM users AS U JOIN orders AS O 
			ON U.id = O.users_id JOIN tasks AS T
			ON T.id = O.task_id JOIN providers AS P
			ON P.id = T.provider_id JOIN status AS S
			ON S.id = O.status
		WHERE U.id = @user_id AND O.id = @order_id;
		RETURN 1;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(MAX), @errorSeverity INT, @errorState INT;
        SELECT  @errorMessage = ERROR_MESSAGE(), 
				@errorSeverity = ERROR_SEVERITY(),
				@errorState = ERROR_STATE();

		RAISERROR (@errorMessage, @errorSeverity, @errorState);
        RETURN -1;
	END CATCH
END;
GO


DECLARE @result INT;
EXEC @result = getOrderStatus @user_id = 100, @order_id = 800;
PRINT 'getOrderStatus returned: ' + CAST(@result AS VARCHAR);