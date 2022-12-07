USE CP_TEST;
GO

CREATE OR ALTER PROC searchTask
	@task_name NVARCHAR(100)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF NOT EXISTS (
			SELECT * 
			FROM tasks 
			WHERE name like '%' + LTRIM(RTRIM(CAST(@task_name AS NVARCHAR(100)))) + '%')
		RAISERROR('[ERROR] searchTask: There is no suck task.', 17, 1);
		
		SELECT T.name, T.price, T.duration, P.company_name
		FROM tasks AS T JOIN providers AS P
		ON T.provider_id = P.id
		WHERE name like '%' + LTRIM(RTRIM(CAST(@task_name AS NVARCHAR(100)))) + '%';
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
EXEC @result = searchTask @task_name = '  type beat  ';
PRINT 'getOrderStatus returned: ' + CAST(@result AS VARCHAR);