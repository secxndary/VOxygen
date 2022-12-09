USE CP_TEST;
GO

CREATE OR ALTER PROC getUserOrdersFromCart
	@user_id INT
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF (NULLIF(@user_id, '') IS NULL)
			RAISERROR('[ERROR] getUserOrdersFromCart: Parameters cannot be null.', 17, 1);
		IF NOT EXISTS (SELECT * FROM users WHERE id = @user_id)
			RAISERROR('[ERROR] getUserOrdersFromCart: There is no user with this ID.', 17, 1);
		IF NOT EXISTS (SELECT * FROM UsersOrders WHERE ID = @user_id)
			RAISERROR('[ERROR] getUserOrdersFromCart: User does not have any orders.', 17, 1);

		SELECT * FROM UsersOrders WHERE ID = @user_id;
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
EXEC @result = getUserOrdersFromCart @user_id = 100;
PRINT 'getUserOrdersFromCart returned: ' + CAST(@result AS VARCHAR);