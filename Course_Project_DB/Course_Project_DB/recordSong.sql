USE CP_TEST;
GO

CREATE OR ALTER PROC recordSong 
	@order_id INT,
	@song_name NVARCHAR(MAX),
	@audio_file_path NVARCHAR(MAX)
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @last_song_id INT,
			@artist_id INT =
	(
		SELECT A.id
		FROM orders AS O
		JOIN users AS U 
			ON U.id = O.users_id
		JOIN artists AS A
			ON A.users_id = U.id
		WHERE O.id = @order_id
	);
	BEGIN TRY
		IF (NULLIF(@artist_id, '') IS NULL OR NULLIF(@order_id, '') IS NULL)
			RAISERROR('[ERROR] recordSong: Parameters cannot be null.', 17, 1);
		IF NOT EXISTS (SELECT * FROM orders WHERE id = @order_id)
			RAISERROR('[ERROR] recordSong: Incorrect order ID.', 17, 1);
		
		DECLARE @insertFileCommand NVARCHAR(MAX) =
			'INSERT INTO songs(audio_file) ' + 
			'SELECT BulkColumn ' +
			'FROM OPENROWSET(BULK ''' + LTRIM(RTRIM(@audio_file_path)) + ''', SINGLE_BLOB) AS audio_file';

		IF (@audio_file_path IS NULL)
		BEGIN
			INSERT INTO songs(title, album_id, artist_id, audio_file)
			VALUES (LTRIM(RTRIM(@song_name)), NULL, @artist_id, NULL);
			PRINT 'Song succesfully published (without file).';
			RETURN 1;
		END;

		ELSE IF (@audio_file_path IS NOT NULL)
		BEGIN
			EXECUTE sp_executesql @insertFileCommand;
			SET @last_song_id = (SELECT TOP(1) id HUI FROM songs ORDER BY id DESC);
			UPDATE songs SET title = @song_name, artist_id = @artist_id;
			PRINT 'Song succesfully published (with file).';
			RETURN 1;
		END;

		RAISERROR('[ERROR] recordSong: Some error occured.', 17, 1);
		RETURN -1;
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
EXEC @result = recordSong @order_id = 808, @song_name = 'Secxndary Diss', @audio_file_path = 'C:\song.mp3';
PRINT 'recordSong returned: ' + CAST(@result AS VARCHAR);