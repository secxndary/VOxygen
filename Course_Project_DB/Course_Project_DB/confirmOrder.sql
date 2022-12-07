USE CP_TEST;
GO

CREATE OR ALTER PROC confirmOrder
	@order_id INT,
	@confirmOrNot BIT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @orderStatus INT = (SELECT status FROM orders WHERE id = @order_id);
	BEGIN TRY
		IF (NULLIF(@order_id, '') IS NULL)
			RAISERROR('[ERROR] confirmOrder: Parameters cannot be null.', 17, 1);
		IF ((SELECT COUNT(*) FROM orders WHERE id = @order_id) != 1)
			RAISERROR('[ERROR] confirmOrder: There is no order with this ID.', 17, 1);
		IF (@orderStatus < 1)
			RAISERROR('[ERROR] confirmOrder: This order is not paid yet.', 17, 1);
		IF (@orderStatus > 1)
			RAISERROR('[ERROR] confirmOrder: This order is already confirmed.', 17, 1);
		IF (@confirmOrNot = 0)
		BEGIN
			PRINT 'You declined this order.';
			RETURN -1;
		END

		UPDATE orders 
		SET status = 2 
		WHERE id = @order_id;
		PRINT 'You successfully confirmed this order!';
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
EXEC @result = confirmOrder @order_id = 800, @confirmOrNot = 1
PRINT 'confirmOrder returned: ' + CAST(@result AS VARCHAR);