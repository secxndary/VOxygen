USE CP_TEST;
GO

CREATE OR ALTER PROC signUpProvider 
	@login			NVARCHAR(50), 
	@password		NVARCHAR(50),
	@company_name	NVARCHAR(MAX),
	@address		NVARCHAR(MAX),
	@role_id		INT,
	@trade_margin	INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @countWithSameLogin INT;

	BEGIN TRY
		IF
		(	
			NULLIF(@login, '') IS NULL OR 
			NULLIF(@role_id, '') IS NULL OR
			NULLIF(@password, '') IS NULL OR 
			NULLIF(@company_name, '') IS NULL
		)
			RAISERROR('[ERROR] signUpProvider: Parameters cannot be null, besides address and trade margin.', 17, 1);
		IF EXISTS (SELECT * FROM providers WHERE login = LTRIM(RTRIM(@login)))
			RAISERROR ('[ERROR] signUpProvider: Provider with this login already exists.', 17, 1);
		IF NOT EXISTS (SELECT * FROM roles WHERE ID = @role_id)
			RAISERROR ('[ERROR] signUpProvider: Please, enter correct role ID.', 17, 1);
		IF (@trade_margin NOT BETWEEN 0 AND 100)
			RAISERROR ('[ERROR] signUpProvider: Please, enter trade margin between 0 and 100 (percents).', 17, 1);
		
		INSERT INTO providers(login, password, company_name, role_id, address, trade_margin)
		VALUES (@login, @password, @company_name, @role_id, @address, @trade_margin);

		PRINT 'You succesfully signed up! Welcome, ' + CAST(@login AS VARCHAR(50));
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
EXEC @result = signUpProvider 
					@login = 'paxorbeats', 
					@password = 'qwe', 
					@company_name = NULL, 
					@address = NULL,
					@role_id = 123,
					@trade_margin = 146
PRINT 'signUpProvider returned: ' + CAST(@result AS VARCHAR);