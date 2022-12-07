USE CP_TEST;
GO

CREATE OR ALTER PROC payForAnOrder
	@order_id	 INT, 
	@payment_sum INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @orderPrice  INT = (SELECT dbo.getOrderPriceByOrderId(@order_id)),
			@orderStatus INT = (SELECT status FROM orders WHERE id = @order_id),
			@orderPriceWithMargin INT = (SELECT dbo.getOrderPriceByWithMargin(@order_id));

	BEGIN TRY
		IF (NULLIF(@payment_sum, '') IS NULL OR NULLIF(@order_id, '') IS NULL)
			RAISERROR('[ERROR] payForAnOrder: Parameters cannot be null.', 17, 1);
		IF NOT EXISTS (SELECT * FROM orders WHERE id = @order_id)
			RAISERROR('[ERROR] payForAnOrder: There is no order with this ID.', 17, 1);
		IF (@orderStatus > 0)
			RAISERROR('[ERROR] payForAnOrder: This order is already paid.', 17, 1);
		IF (@payment_sum < @orderPriceWithMargin)
			RAISERROR('[ERROR] payForAnOrder: You paid too little money broke boi.', 17, 1);
	
		UPDATE orders 
		SET status = 1 
		WHERE id = @order_id;

		PRINT 'You successfully paid for your order!';
		PRINT 'Providers tip: ' + CAST((@payment_sum - @orderPriceWithMargin) AS VARCHAR) + '$.';
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
EXEC @result = payForAnOrder @order_id = 805, @payment_sum = 100
PRINT 'payForAnOrder returned: ' + CAST(@result AS VARCHAR);