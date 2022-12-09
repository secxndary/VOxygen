USE CP_TEST;
GO

CREATE OR ALTER PROC signInProvider
	@login     NVARCHAR(50), 
	@password  NVARCHAR(50) 
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @countWithThisLogin INT, 
			@countWithThisLoginAndPassword INT;
	BEGIN TRY
		IF (@login IS NULL AND @password IS NULL)
			RAISERROR('[ERROR] signInProvider: Parameters can not be null.', 17, 1);
				
		BEGIN
			SET @countWithThisLogin = (SELECT COUNT(*) FROM providers WHERE login = @login);
			IF (@countWithThisLogin = 0)
				RAISERROR('[ERROR] signInProvider: Incorrect login.', 17, 1);

			SET @countWithThisLoginAndPassword = 
			(
				SELECT COUNT(*) 
				FROM providers 
				WHERE login = @login 
					AND password = @password
			);
			IF (@countWithThisLoginAndPassword = 0)
				RAISERROR('[ERROR] signInProvider: Incorrect password.', 17, 1);
			ELSE
				PRINT 'You successfully signed in! Hello, ' + LTRIM(RTRIM(@login));
			RETURN 1;
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
EXEC @result = signInProvider @login = 'paxorbeats', @password = 'ivakhilya';
PRINT 'signInProvider returned: ' + CAST(@result AS VARCHAR);