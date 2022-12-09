USE CP_TEST;
GO


CREATE OR ALTER PROC placeAnOrder
	@user_id	  INT,
	@task_name    NVARCHAR(100),
	@company_name NVARCHAR(50),
	@datetime	  DATETIME2(0)
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
			FROM  ProvidersTasks
			WHERE Название_услуги = LTRIM(RTRIM(@task_name)) 
			AND	  Поставщик_услуг = LTRIM(RTRIM(@company_name))
		)
		RAISERROR('[ERROR] searchTask: This provider does not have such task.', 17, 1);
		

		DECLARE @isDataInserted BIT = 0,
				@dateAddCounter INT = 0,
				@openTime		TIME(0),
				@closeTime		TIME(0),
				@duration		INT,
				@order_datetime DATETIME2(0),
				@provOpenTime	TIME(0) = (SELECT * FROM dbo.getProvidersOpeningTime(@company_name)),
				@task_id		INT = (SELECT dbo.getTaskIdByTaskNameAndCompanyName(@task_name, @company_name));
		WHILE (@isDataInserted != 1)
		BEGIN
			IF EXISTS
			(
				SELECT *
				FROM getOrdersOnThisDate(DATEADD(DAY, @dateAddCounter, @datetime))
			)
			BEGIN
				DECLARE cursor_providers_orders CURSOR LOCAL DYNAMIC FOR 
				(
					SELECT * 
					FROM 
					(
						SELECT TOP(10000000)
							provider_opens, provider_closes, task_duration, order_datetime 
						FROM getOrdersOnThisDate(DATEADD(DAY, @dateAddCounter, @datetime))
						ORDER BY order_datetime
					) AS tempTableOrdersOnThisDate
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
					DECLARE @dateToChange2		 DATETIME2(0),
							@orderFinalDateTime2 DATETIME2(0);
					SET @dateToChange2 = CONVERT(DATE, DATEADD(DAY, @dateAddCounter, @datetime));
					SET @orderFinalDateTime2 = (DATEADD(MINUTE, DATEPART(MINUTE, @provOpenTime), DATEADD(HH, DATEPART(HOUR, @provOpenTime), @dateToChange2)));
					INSERT INTO orders(order_datetime, users_id, task_id, status)
					VALUES (@orderFinalDateTime2, @user_id, @task_id, 0);
					--print 'first fetch insert';	
					--print @order_datetime;
					--print @dateAddCounter;
					SET @isDataInserted = 1;
				END;


				WHILE (@@FETCH_STATUS = 0 AND @isDataInserted != 1)
				BEGIN
					SET @previous_task_ends = DATEADD(HOUR, @duration, @order_datetime);
					FETCH cursor_providers_orders INTO @openTime, @closeTime, @duration, @order_datetime;
					IF (DATEDIFF(HOUR, @previous_task_ends, @order_datetime) >= @insertingTaskDuration)
					BEGIN
						INSERT INTO orders(order_datetime, users_id, task_id, status)
						VALUES (@previous_task_ends, @user_id, @task_id, 0);
						PRINT 'Your order has been placed on ' + CAST(@previous_task_ends AS VARCHAR(50)) + '.';
						--print 'fetch insert';	
						--print @order_datetime;
						SET @isDataInserted = 1;
						BREAK;
					END;

					IF (DATEDIFF(HOUR, @previous_task_ends, @closeTime) >= @insertingTaskDuration)
					BEGIN
						INSERT INTO orders(order_datetime, users_id, task_id, status)
						VALUES (@previous_task_ends, @user_id, @task_id, 0);
						PRINT 'Your order has been placed on ' + CAST(@previous_task_ends AS VARCHAR(50)) + '.';
						--print 'last fetch insert';
						--print @order_datetime;
						--print @dateAddCounter;
						SET @isDataInserted = 1;
					END;
				END;

				DEALLOCATE cursor_providers_orders;
			END;

			ELSE
			BEGIN
				DECLARE @dateToChange		DATETIME2(0),
						@orderFinalDateTime DATETIME2(0);
				SET @dateToChange = CONVERT(DATE, DATEADD(DAY, @dateAddCounter, @datetime));
				SET @orderFinalDateTime = (DATEADD(MINUTE, DATEPART(MINUTE, @provOpenTime), DATEADD(HH, DATEPART(HOUR, @provOpenTime), @dateToChange)));

				INSERT INTO orders(order_datetime, users_id, task_id, status)
				VALUES (@orderFinalDateTime, @user_id, @task_id, 0);
				--print 'next day insert';
				--print @dateAddCounter;
				PRINT 'Your order has been placed on ' + CAST(@orderFinalDateTime AS VARCHAR(50)) + '.';
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