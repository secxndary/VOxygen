USE CP_TEST;
GO

CREATE OR ALTER PROC createAlbum 
	@label_id INT,
	@artist_id INT,
	@title NVARCHAR(MAX),
	@release_date DATETIME2(0)
AS 
BEGIN
	SET NOCOUNT ON;
	DECLARE @_release_date DATETIME2(0);
	BEGIN TRY
		IF (NULLIF(@artist_id, '') IS NULL OR NULLIF(@title, '') IS NULL)
			RAISERROR('[ERROR] createAlbum: Artist_id and title parameters cannot be null.', 17, 1);
		IF ((SELECT COUNT(*) FROM artists WHERE id = @artist_id) = 0)
			RAISERROR('[ERROR] createAlbum: There is no artists with this ID.', 17, 1);
		IF ((SELECT COUNT(*) FROM providers WHERE role_id = 60 AND id = @label_id) = 0)
			RAISERROR('[ERROR] createAlbum: This provider is not a label.', 17, 1);

		IF (@release_date IS NULL)
			SET @_release_date = GETDATE();

		INSERT INTO albums(title, release_date, artist_id, label_id)
		VALUES (@title, @_release_date, @artist_id, @label_id);

		PRINT 'Album has been created.';
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
EXEC @result = createAlbum @label_id = 510, @artist_id = 200, @title = 'BEER AND LAUGHS', @release_date = NULL;
PRINT 'createAlbum returned: ' + CAST(@result AS VARCHAR);