USE CP_TEST;
GO

CREATE OR ALTER PROC signUpUser 
	@login     NVARCHAR(50), 
	@password  NVARCHAR(50), 
	@email     NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @countWithSameLogin INT,
			@countWithSameEmail INT;
	BEGIN TRY
		IF (NULLIF(@login, '') IS NULL OR NULLIF(@password, '') IS NULL OR NULLIF(@email, '') IS NULL)
			RAISERROR('[ERROR] signUpUser: Parameters cannot be null.', 17, 1);
		IF EXISTS (SELECT * FROM users WHERE login = LTRIM(RTRIM(@login)))
			RAISERROR ('[ERROR] signUpUser: User with this login already exists.', 17, 1);
		IF EXISTS (SELECT * FROM users WHERE email = LTRIM(RTRIM(@email)))
			RAISERROR ('[ERROR] signUpUser: User with this email already exists.', 17, 1);

		INSERT INTO users(login, password, email, is_admin) 
		VALUES (@login, @password, @email, 0);
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
EXEC @result = signUpUser @login = 'root', @password = 'qwe', @email = 'valdaitsevv@mail.ru';
PRINT 'signUpUser returned: ' + CAST(@result AS VARCHAR);