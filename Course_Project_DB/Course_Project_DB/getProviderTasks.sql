USE CP_TEST;
GO

CREATE OR ALTER PROC getProvidersTasks 
	@provider_id INT 
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @countOfTasksOfThisProvider INT,
			@isProviderExist BIT;
	BEGIN TRY	
		IF NOT EXISTS (SELECT * FROM providers WHERE id = @provider_id)
			RAISERROR('[ERROR] getProvidersTasks: Incorrect provider ID.', 17, 1);

		SET @countOfTasksOfThisProvider = (
			SELECT COUNT(*)
			FROM tasks AS T 
			JOIN providers AS P ON T.provider_id = P.id
			WHERE P.id = @provider_id);
		IF @countOfTasksOfThisProvider = 0
			RAISERROR('[ERROR] getProvidersTasks: This provider does not have any tasks.', 17, 1);

		SELECT T.id, T.name, T.duration, T.price, T.provider_id
		FROM tasks AS T 
			JOIN providers AS P ON T.provider_id = P.id
		WHERE P.id = @provider_id;
		RETURN 1;
	END TRY
	BEGIN CATCH
		DECLARE @errorNumber INT, @errorMessage NVARCHAR(MAX), @errorSeverity INT, @errorState INT, @xState INT;
        SELECT  @errorNumber = ERROR_NUMBER(), 
				@errorMessage = ERROR_MESSAGE(), 
				@errorSeverity = ERROR_SEVERITY(),
				@errorState = ERROR_STATE();

		RAISERROR (@errorMessage, @errorSeverity, @errorState);
        RETURN -1;
	END CATCH;
END;
GO


DECLARE @result INT;
EXEC @result = getProvidersTasks @provider_id = 500;
PRINT 'getProvidersTasks returned: ' + CAST(@result AS VARCHAR);