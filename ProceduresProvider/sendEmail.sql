USE CP_TEST;
GO

CREATE OR ALTER PROC sendEmail 
	@sender NVARCHAR(100),
	@receiver NVARCHAR(100),
	@password NVARCHAR(100),
	@subject NVARCHAR(MAX),
	@message NVARCHAR(MAX)
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF (NULLIF(@sender, '') IS NULL OR NULLIF(@receiver, '') IS NULL OR NULLIF(@password, '') IS NULL OR NULLIF(@subject, '') IS NULL)
			RAISERROR('[ERROR] sendEmail: Parameters cannot be null.', 17, 1);
		
		PRINT 'The message has been sent.';
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
EXEC @result = sendEmail 'qwe@mail.ru', 'qewqwe@mail.ru', 'fsdvsddfew', 'subj', 'mess';
PRINT 'sendEmail returned: ' + CAST(@result AS VARCHAR);