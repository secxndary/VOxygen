USE CP_TEST;
GO

CREATE OR ALTER PROC searchTask
	@task_name NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF NOT EXISTS 
		(
			SELECT *
			FROM ProvidersTasks
			WHERE Название_услуги like '%' + LTRIM(RTRIM(@task_name)) + '%'
		)
			RAISERROR('[ERROR] searchTask: There is no suck task.', 17, 1);
		
		SELECT *
		FROM ProvidersTasks
		WHERE Название_услуги like '%' + LTRIM(RTRIM(@task_name)) + '%';

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
EXEC @result = searchTask @task_name = '  trype beat  ';
PRINT 'searchTask returned: ' + CAST(@result AS VARCHAR);