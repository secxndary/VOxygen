USE CP_TEST;
GO

CREATE OR ALTER PROC RandomString
	@length			INT,
	@char_pool		NVARCHAR(MAX),
	@random_string	NVARCHAR(MAX) OUTPUT
AS
BEGIN
	DECLARE @pool_length INT,
			@i INT;
	IF (@char_pool IS NULL)
	BEGIN
		SET @char_pool = 'abcdefghijkmnopqrstuvwxyzABCDEFGHIJKLMNPQRSTUVWXYZ';
	END;

	SET @pool_length = Len(@char_pool);
	SET @random_string = '';
	SET @i = 0;

	WHILE (@i < @length) 
	BEGIN
	    SET @random_string = @random_string + SUBSTRING(@char_pool, CONVERT(INT, RAND() * @pool_length) + 1, 1);
	    SET @i += 1;
	END;
END
GO




CREATE OR ALTER PROC insertCycleStatus
(
	@limit INT
)
AS
BEGIN
	DECLARE @i INT = 0,
			@status NVARCHAR(20),
			@table_name NVARCHAR(20);

	WHILE (@i < @limit)
	BEGIN
		EXEC RandomString 20, NULL, @status OUTPUT;
		INSERT INTO status(name) VALUES (@status);
		SET @i += 1;
	END;
END

EXEC insertCycleStatus @limit = 100000;
SELECT COUNT(*) FROM status;