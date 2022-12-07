USE CP_TEST;
GO


CREATE OR ALTER PROC placeAnOrder
	@user_id	  INT,
	@task_name    NVARCHAR(100),
	@company_name NVARCHAR(50),
	@datetime datetime2(0)
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF NOT EXISTS 
		(
			SELECT * 
			FROM providers
			WHERE company_name = LTRIM(RTRIM(@company_name))
		)
		RAISERROR('[ERROR] searchTask: There is no provider with such company name.', 17, 1);

		IF NOT EXISTS 
		(
			SELECT * 
			FROM tasks 
			WHERE name = LTRIM(RTRIM(@task_name))
		)
		RAISERROR('[ERROR] searchTask: There is no suck task.', 17, 1);

		IF NOT EXISTS 
		(
			SELECT * 
			FROM tasks AS T 
			JOIN providers AS P
				ON T.provider_id = P.id
			WHERE T.name = LTRIM(RTRIM(@task_name)) 
				AND P.company_name = LTRIM(RTRIM(@company_name))
		)
		RAISERROR('[ERROR] searchTask: This provider does not have such task.', 17, 1);
		

		DECLARE @isDataInserted BIT = 0;
		DECLARE @dateAddCounter INT = 0;
		DECLARE @openTime TIME(0),
				@closeTime TIME(0),
				@duration INT,
				@order_datetime DATETIME2(0);

		WHILE (@isDataInserted != 1)
		BEGIN
			IF EXISTS
			(
				SELECT *
				FROM getProvidersOrdersOnThisDate(@company_name, DATEADD(DAY, @dateAddCounter, @datetime))
			)
			BEGIN
				DECLARE cursor_providers_orders CURSOR LOCAL DYNAMIC FOR 
				(
					SELECT * 
					FROM 
					(
						SELECT TOP(10000000)
							provider_opens, provider_closes, task_duration, order_datetime 
						FROM getProvidersOrdersOnThisDate(@company_name, DATEADD(DAY, @dateAddCounter, @datetime))
						ORDER BY order_datetime
					) AS tempTableProvidersOrdersOnThisDate
				)
				
				DECLARE @previous_task_ends DATETIME2(0);
				DECLARE @insertingTaskDuration INT = 
							(SELECT dbo.getTaskDurationByTaskNameAndCompanyName(@task_name, @company_name));
				OPEN cursor_providers_orders;
				FETCH cursor_providers_orders INTO @openTime, @closeTime, @duration, @order_datetime;

				FETCH FIRST 
				FROM cursor_providers_orders 
				INTO @openTime, @closeTime, @duration, @order_datetime;
				IF (DATEDIFF(HOUR, @order_datetime, @openTime) >= @insertingTaskDuration)
				BEGIN
					print 'first fetch insert';	--insert
					print @order_datetime;
					print @dateAddCounter;
					SET @isDataInserted = 1;
				END;

				WHILE (@@FETCH_STATUS = 0 AND @isDataInserted != 1)
				BEGIN
					SET @previous_task_ends = DATEADD(HOUR, @duration, @order_datetime);
					FETCH cursor_providers_orders INTO @openTime, @closeTime, @duration, @order_datetime;
					IF (DATEDIFF(HOUR, @previous_task_ends, @order_datetime) >= @insertingTaskDuration)
					BEGIN
						print 'fetch insert';	--insert
						print @order_datetime;
						SET @isDataInserted = 1;
						BREAK;
					END;
					IF (DATEDIFF(HOUR, @previous_task_ends, @closeTime) >= @insertingTaskDuration)
					BEGIN
						print 'last fetch insert';	--insert
						print @order_datetime;
						print @dateAddCounter;
						SET @isDataInserted = 1;
					END;
				END;

				DEALLOCATE cursor_providers_orders;
			END;
			ELSE
			BEGIN
				print 'next day insert';	--insert AND PRINT DATETIME OF ORDER
				print @dateAddCounter;
				SET @isDataInserted = 1;
				BREAK;
			END;
			SET @dateAddCounter += 1;
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
	END CATCH
END;
GO


DECLARE @result INT;
EXEC @result = placeAnOrder 
				@user_id = 100, 
				@task_name = 'Consultation', 
				@company_name = 'Roc-A-Fella Records', 
				@datetime = '2022-12-05 16:00:00';
PRINT 'getOrderStatus returned: ' + CAST(@result AS VARCHAR);