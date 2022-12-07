USE CP_TEST;
GO

CREATE OR ALTER PROC checkIfOrdersHasBeenCompleted
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF ((SELECT COUNT(*) FROM orders) = 0)
			RAISERROR('[ERROR] checkIfOrdersHasBeenCompleted: There is no orders.', 17, 1);

		DECLARE @user_id  INT,
				@order_id INT,
				@task_id  INT,
				@duration INT,
				@datetime DATETIME2(0),
				@status   NVARCHAR(50);
		DECLARE cursor_orders_completed CURSOR LOCAL DYNAMIC FOR 
		(
			SELECT users_id, O.id order_id, T.id task_id, order_datetime, status
			FROM orders AS O
			JOIN tasks AS T 
				ON T.id = O.task_id
		)
		OPEN  cursor_orders_completed;
		FETCH cursor_orders_completed INTO @user_id, @order_id, @task_id, @datetime, @status;
		
		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			SET @duration = (SELECT duration FROM tasks WHERE id = @task_id);
			
			IF (@status = 2 AND DATEADD(HOUR, @duration, @datetime) < GETDATE())
			BEGIN
				UPDATE orders
				SET status = 3
				WHERE id = @order_id;
				PRINT 'Order succesfully completed.';
			END;

			IF (@status < 2 AND DATEADD(HOUR, @duration, @datetime) < GETDATE())
			BEGIN
				UPDATE orders
				SET status = 4
				WHERE id = @order_id;
				PRINT 'Order has been skipped.';
			END;
			FETCH cursor_orders_completed INTO @user_id, @order_id, @task_id, @datetime, @status;
		END;

		RETURN 1;
	END TRY
	BEGIN CATCH
		DECLARE @errorMessage NVARCHAR(MAX), @errorSeverity INT, @errorState INT;
        SELECT  @errorMessage = ERROR_MESSAGE(), 
				@errorSeverity = ERROR_SEVERITY(),
				@errorState = ERROR_STATE();

		RAISERROR (@errorMessage, @errorSeverity, @errorState);
        RETURN -1;
	END CATCH;
END;
GO


DECLARE @result INT;
EXEC @result = checkIfOrdersHasBeenCompleted
PRINT 'confirmOrder returned: ' + CAST(@result AS VARCHAR);