USE CP_TEST;
GO

CREATE OR ALTER PROC addSongToAlbum 
	@album_id INT,
	@song_id  INT
AS 
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		IF (NULLIF(@album_id, '') IS NULL OR NULLIF(@song_id, '') IS NULL)
			RAISERROR('[ERROR] addSongToAlbum: Parameters cannot be null.', 17, 1);
		IF NOT EXISTS (SELECT * FROM albums WHERE id = @album_id)
			RAISERROR('[ERROR] addSongToAlbum: Incorrect album ID.', 17, 1);
		IF NOT EXISTS (SELECT * FROM songs WHERE id = @song_id)
			RAISERROR('[ERROR] addSongToAlbum: Incorrect song ID.', 17, 1);
		
		UPDATE songs
		SET album_id = @album_id
		WHERE id = @song_id;

		PRINT '[INFO] Song has been succesfully added to an album.';
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
EXEC @result = addSongToAlbum @album_id = 302, @song_id = 413
PRINT 'addSongToAlbum returned: ' + CAST(@result AS VARCHAR);