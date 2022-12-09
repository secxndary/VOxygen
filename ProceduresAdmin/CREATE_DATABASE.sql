--CREATE DATABASE CP_TEST;
USE CP_TEST;

DROP TABLE songs;
DROP TABLE albums;
DROP TABLE sendmail;
DROP TABLE emailsenderdata;
DROP TABLE schedules;
DROP TABLE orders;
DROP TABLE tasks;
DROP TABLE artists;
DROP TABLE providers;
DROP TABLE roles;
DROP TABLE status;
DROP TABLE users;

CREATE TABLE roles
(
	id INT CONSTRAINT PK_dbo_roles PRIMARY KEY IDENTITY(10, 10),
	name NVARCHAR(50)
);

CREATE TABLE status
(
	id INT CONSTRAINT PK_dbo_status PRIMARY KEY IDENTITY(0, 1),
	name NVARCHAR(50)
);

CREATE TABLE users
(
	id INT CONSTRAINT PK_dbo_users PRIMARY KEY IDENTITY(100, 1),
	login NVARCHAR(50) CONSTRAINT UQ_dbo_users_login UNIQUE NOT NULL,
	password NVARCHAR(50) NOT NULL,
	email NVARCHAR(50) CONSTRAINT UQ_dbo_users_email UNIQUE NOT NULL,
	is_admin BIT NOT NULL
);

CREATE TABLE providers
(
	id INT CONSTRAINT PK_dbo_providers PRIMARY KEY IDENTITY(500, 1),
	login NVARCHAR(50) CONSTRAINT UQ_dbo_providers_login UNIQUE NOT NULL,
	password NVARCHAR(50) NOT NULL,
	company_name NVARCHAR(100) NOT NULL,
	role_id INT CONSTRAINT FK_dbo_providers_dbo_roles FOREIGN KEY REFERENCES roles(id) NOT NULL,
	address NVARCHAR(MAX) NULL,
	trade_margin INT CONSTRAINT CK_dbo_providers_trade_margin CHECK(trade_margin between 0 and 100) NULL
);

CREATE TABLE artists
(
	id INT CONSTRAINT PK_dbo_artists PRIMARY KEY IDENTITY(200, 1),
	nick_name NVARCHAR(MAX) NOT NULL,
	real_name NVARCHAR(MAX) NULL,
	users_id INT CONSTRAINT FK_dbo_artists_dbo_users FOREIGN KEY REFERENCES users(id) NULL
);

CREATE TABLE albums
(
	id INT CONSTRAINT PK_dbo_albums PRIMARY KEY IDENTITY(300, 1),
	title NVARCHAR(MAX) NOT NULL,
	release_date date NULL,
	artist_id INT CONSTRAINT FK_dbo_albums_dbo_artists   FOREIGN KEY REFERENCES artists(id)   NOT NULL,
	label_id  INT CONSTRAINT FK_dbo_albums_dbo_providers FOREIGN KEY REFERENCES providers(id) NULL
);

CREATE TABLE songs
(
	id INT CONSTRAINT PK_dbo_songs PRIMARY KEY IDENTITY(400, 1),
	title NVARCHAR(MAX) NULL,
	album_id  INT CONSTRAINT FK_dbo_songs_dbo_albums   FOREIGN KEY REFERENCES albums(id)  NULL,
	artist_id INT CONSTRAINT FK_dbo_songs_dbo_artists  FOREIGN KEY REFERENCES artists(id) NULL,
	audio_file VARBINARY(MAX) NULL
);

CREATE TABLE tasks
(
	id INT CONSTRAINT PK_dbo_tasks PRIMARY KEY IDENTITY(600, 1),
	name NVARCHAR(MAX) NOT NULL,
	duration INT NULL,
	price INT NOT NULL,
	provider_id INT CONSTRAINT FK_dbo_tasks_dbo_providers FOREIGN KEY REFERENCES providers(id) NOT NULL,
);

CREATE TABLE schedules
(
	id INT CONSTRAINT PK_dbo_schedules PRIMARY KEY IDENTITY(700, 1),
	opening_time time(0) NULL,
	closing_time time(0) NULL,
	provider_id INT CONSTRAINT FK_dbo_schedules_dbo_providers FOREIGN KEY REFERENCES providers(id) NOT NULL
);

CREATE TABLE orders
(
	id INT CONSTRAINT PK_dbo_orders PRIMARY KEY IDENTITY(800, 1),
	order_datetime datetime2(0) NULL,
	users_id INT CONSTRAINT FK_dbo_orders_dbo_users  FOREIGN KEY REFERENCES users(id)  NOT NULL,
	task_id  INT CONSTRAINT FK_dbo_orders_dbo_tasks  FOREIGN KEY REFERENCES tasks(id)  NOT NULL,
	status   INT CONSTRAINT FK_dbo_orders_dbo_status FOREIGN KEY REFERENCES status(id) NOT NULL
);

CREATE TABLE emailsenderdata
(
	id INT CONSTRAINT PK_dbo_emailsenderdata PRIMARY KEY IDENTITY(1000, 1),
	email NVARCHAR(100) CONSTRAINT UQ_dbo_emailsenderdata_email UNIQUE NOT NULL,
	password NVARCHAR(100) NOT NULL
);

CREATE TABLE sendmail
(
	id INT CONSTRAINT PK_dbo_sendmail PRIMARY KEY IDENTITY(900, 1),
	sender_email_id INT CONSTRAINT FK_dbo_sendmail_dbo_emailsenderdata FOREIGN KEY REFERENCES emailsenderdata(id) NOT NULL,
	receiver_email_id INT CONSTRAINT FK_dbo_sendmail_dbo_users FOREIGN KEY REFERENCES users(id) NOT NULL,
	subject NVARCHAR(MAX) NULL,
	message_text NVARCHAR(MAX) NOT NULL
);