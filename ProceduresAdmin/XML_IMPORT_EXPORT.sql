USE CP_TEST;

GO
CREATE OR ALTER PROCEDURE exportUsersXML
    @size INT,
    @fileName VARCHAR(100)
AS
BEGIN
	EXEC MASTER.DBO.SP_CONFIGURE 'SHOW ADVANCED OPTIONS', 1
		RECONFIGURE WITH OVERRIDE
	EXEC MASTER.DBO.SP_CONFIGURE 'XP_CMDSHELL', 1
		RECONFIGURE WITH OVERRIDE;

	DECLARE @sqlString  VARCHAR(1000);
	DECLARE @sqlCommand VARCHAR(1000);

	SET @sqlString = 'USE CP_TEST; DECLARE @text VARCHAR(MAX) = (SELECT TOP ' + CONVERT(VARCHAR(10), @size) + ' * FROM users FOR XML PATH(''USER''), ' +
	              'ROOT(''USERS'')); SELECT REPLACE(@text, ''</USER>'', ''</USER>'' + CHAR(13))'
	SET @sqlCommand = 'bcp "' + @sqlString + '" queryout ' + @fileName + ' -w -T -S localhost'
	EXEC XP_CMDSHELL @sqlCommand;
END
GO

EXEC exportUsersXML @size = 100, @fileName = 'C:\test\users.xml';





GO
CREATE OR ALTER PROCEDURE importUsersXML
AS
BEGIN
    SET IDENTITY_INSERT users ON;
    INSERT INTO users (id, login, password, email, is_admin)
    SELECT
       MY_XML.USERS.query('id').value('.', 'INT'),
       MY_XML.USERS.query('login').value('.', 'NVARCHAR(100)'),
       MY_XML.USERS.query('password').value('.', 'NVARCHAR(100)'),
       MY_XML.USERS.query('email').value('.', 'NVARCHAR(100)'),
       MY_XML.USERS.query('is_admin').value('.', 'bit')
    FROM (SELECT CAST(MY_XML AS XML)
          FROM OPENROWSET(bulk 'C:/test/users.xml', single_blob ) AS T(MY_XML)) AS T(MY_XML)
          CROSS APPLY MY_XML.nodes('USERS/USER') AS MY_XML (USERS);
	SET IDENTITY_INSERT users OFF;
END
GO

EXEC importUsersXML;