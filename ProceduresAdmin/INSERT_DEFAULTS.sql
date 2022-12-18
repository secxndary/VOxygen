USE CP_TEST;

INSERT INTO roles(name) 
VALUES 
	('Битмейкер'), ('Продюссер'), ('Сведение и мастеринг'), ('Студия звукозаписи'),
	('Запись инструментала'), ('Лейбл'), ('Гострайтинг');

INSERT INTO status(name) 
VALUES
	('Забронирован'), ('Оплачен'), ('Подтверждён'), ('Пройден'), ('Просрочен');

INSERT INTO emailsenderdata(email, password)
VALUES
	('voxygenbot@gmail.com', 'xbguckzhonlehivd');

INSERT INTO users(login, password, email, is_admin) 
VALUES
	('toxich', 'qweqwe', 'dimetranton@gmail.com', 0),
	('yedagoat', 'dabest', 'yeyeye@gmail.com', 0),
	('heroinwater', 'projectx', 'ilovecash@gmail.com', 0),
	('thrillpilldabest', 'chelsea3', 'pillthrill@mail.ru', 0),
	('scamlymilli', 'scammax', 'enterurcvv@root.com', 0),
	('budek', 'ogogog', 'budaog@work.com', 0),
	('threehunnagoat', '300300300', 'animeplatina@mail.ru', 0),
	('depoblvrd', 'depost', 'depo@info.com', 0),
	('root', 'root', 'valdaitsevv@mail.ru', 1);

INSERT INTO artists(nick_name, real_name, users_id) 
VALUES
	('SipSonic', 'Антон Димитриади', 100),
	('Kanye West', 'Ye West', 101),
	('herionwater', 'Арсений Груздев', 102),
	('Thrill Pill', 'Тимур Самедов', 103),
	('Scally Milano', NULL, 104),
	('OG Buda', 'Григорий Ляхов', 105),
	('Платина', 'Роберт Плаудис', 106),
	('Boulevard Depo', 'Артем Шатохин', 107);

INSERT INTO providers(login, password, company_name, role_id, address, trade_margin) 
VALUES
	('paxorbeats', 'ivakhilya', 'Paxor', 10 , 'Poland, Warsaw, Gregrozh st, 128-4', 20),
	('wakeupfilthy', 'wakeupwakeup', 'Filthy', 10 , 'USA, LA, Buckingham st, 12', 40),
	('wexwexwex', 'wexsex', 'Wex', 20 , 'Russia, Moscow, Tverskaya st, 87', 25),
	('prettyscrm', 'leaveurbones123', 'Pretty Scream', 20 , 'Russia, SPB, Kalinovskogo st, 93', 35),
	('donutmasterofpuppies', 'qweasd123', 'Donut Mastering', 30 , 'Russia, SPB, Bykava st, 187-4', 20),
	('streetvoicestud', 'poppins009', 'Streetvoice Mastering', 30 , 'Russia, Moscow, Pervomaiskaya st, 2', 25),
	('startstudio', 'whatisit998', 'Star Studio', 40 , 'Belarus, Minsk, Lenina st, 53', 0),
	('captainrec', 'okoknotok', 'Captain Records Studio', 40 , 'Russia, Moscow, Volgograd pr, 42-5', 0),
	('sundayye', 'godblessedeveryday', 'Sunday Service', 50 , 'USA, Washington DC, Western Union st, 12', 0),
	('defjamgoat', 'goatjayz', 'Def Jam Recordings', 60 , 'USA, New York, Machachkala st, 97', 0),
	('rocafellarecs', 'goatye', 'Roc-A-Fella Records', 60 , 'USA, LA, Bricks st, 42', 0),
	('rickyfwhoisit', 'stillgoat', 'Ricky F Writing', 70 , 'Russia, Tver, Minina st, 87-174', 40);

INSERT INTO schedules(opening_time, closing_time, provider_id) 
VALUES
	('06:00:00', '00:00:00', 500),
	('06:00:00', '23:00:00', 501),
	('08:00:00', '22:00:00', 502),
	('07:00:00', '20:30:00', 503),
	('06:00:00', '23:00:00', 504),
	('07:00:00', '23:00:00', 505),
	('08:00:00', '22:00:00', 506),
	('06:00:00', '23:30:00', 507),
	('16:00:00', '20:00:00', 508),
	('10:30:00', '21:30:00', 509),
	('10:00:00', '20:30:00', 510);

INSERT INTO tasks(name, duration, price, provider_id) 
VALUES
	('Latin Type Beat', 6, 30, 500),
	('UK Drill Type Beat', 8, 35, 500),
	('Plug Type Beat', 4, 30, 500),
	('Carti Type Beat', 8, 300, 501),
	('Plug Type Beat', 7, 200, 501),
	('Jersey Club Type Beat', 9, 150, 502),
	('Soda Luv Type Beat', 5, 100, 502),
	('Soda Luv Type Beat', 4, 180, 503),
	('Boulevard Depo Type Beat', 7, 150, 503),
	('Audio track mastering', 9, 80, 504),
	('Audio track mastering', 9, 100, 505),
	('Audio track recording', 4, 400, 506),
	('Audio track recording', 4, 350, 507),
	('Audio track publishing', 0, 50, 506),
	('Audio track publishing', 0, 40, 507),
	('Instrumentals Recording', 8, 280, 508),
	('Consultation', 3, 50, 509),
	('Label subscription', 0, 100, 509),
	('Album publishing', 2, 750, 509),
	('Consultation', 5, 100, 510),
	('Label subscription', 0, 300, 510),
	('Album publishing', 2, 900, 510),
	('Lyrics evaluation and rewriting', 4, 40, 511),
	('Lyrics full writing', 8, 240, 511);

INSERT INTO orders(order_datetime, users_id, task_id, status) 
VALUES
	('2022-12-03 12:30:00', 102, 606, 3),
	('2022-12-05 12:00:00', 100, 618, 2),
	('2022-12-05 16:00:00', 100, 618, 1),
	('2022-12-06 12:00:00', 101, 618, 0),
	('2022-12-06 16:00:00', 103, 618, 0),
	('2022-12-09 14:00:00', 107, 605, 0),
	('2022-12-10 12:00:00', 108, 610, 0),
	('2022-12-15 13:30:00', 105, 602, 0),
	('2022-12-20 12:30:00', 100, 613, 2);