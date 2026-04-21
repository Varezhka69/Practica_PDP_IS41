USE BankAccountingDB;
GO

INSERT INTO Роли (Наименование) VALUES 
(N'Администратор'),
(N'Оператор'),
(N'Аналитик');
GO

INSERT INTO Пользователи (IDРоли, Логин, ХэшПароля, Фамилия, Имя, Отчество, ЭлектроннаяПочта, Активен, ДатаСоздания)
VALUES 
((SELECT IDРоли FROM Роли WHERE Наименование = N'Администратор'), N'admin', N'hash123', N'Иванов', N'Иван', N'Петрович', N'ivanov@bank.ru', 1, GETDATE()),
((SELECT IDРоли FROM Роли WHERE Наименование = N'Оператор'), N'operator1', N'hash456', N'Петрова', N'Мария', N'Сергеевна', N'petrova@bank.ru', 1, GETDATE()),
((SELECT IDРоли FROM Роли WHERE Наименование = N'Аналитик'), N'analyst1', N'hash789', N'Сидоров', N'Петр', N'Алексеевич', N'sidorov@bank.ru', 1, GETDATE()),
((SELECT IDРоли FROM Роли WHERE Наименование = N'Оператор'), N'operator2', N'hash012', N'Козлова', N'Елена', N'Игоревна', N'kozlova@bank.ru', 1, GETDATE()),
((SELECT IDРоли FROM Роли WHERE Наименование = N'Оператор'), N'operator3', N'hash345', N'Новиков', N'Дмитрий', N'Андреевич', N'novikov@bank.ru', 1, GETDATE());
GO

INSERT INTO Валюты (КодВалюты, Наименование, КурсКРублю) VALUES 
(N'RUB', N'Российский рубль', 1.0),
(N'USD', N'Доллар США', 92.5),
(N'EUR', N'Евро', 100.2),
(N'CNY', N'Китайский юань', 12.8);
GO

INSERT INTO ОтделенияБанка (Наименование, Адрес, Активно) VALUES 
(N'Центральный офис', N'г. Вологда, ул. Ленина, д. 1', 1),
(N'Дополнительный офис №1', N'г. Череповец, пр. Победы, д. 100', 1),
(N'Дополнительный офис №2', N'г. Вологда, ул. Мира, д. 50', 1),
(N'Операционный офис', N'г. Сокол, ул. Советская, д. 15', 1);
GO

INSERT INTO БанковскиеПродукты 
(ТипПродукта, НаименованиеПродукта, ПроцентнаяСтавка, IDВалюты,
 МинимальнаяСумма, МаксимальнаяСумма, МинимальныйСрок, МаксимальныйСрок,
 Капитализация, ПополнениеРазрешено, ЧастичноеСнятиеРазрешено, Активен)
VALUES 
(N'Кредит', N'Потребительский кредит', 18.5, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'RUB'), 50000, 3000000, 180, 1825, 0, 0, 0, 1),
(N'Кредит', N'Ипотечный кредит', 10.5, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'RUB'), 500000, 10000000, 365, 10950, 0, 0, 0, 1),
(N'Кредит', N'Автокредит', 14.0, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'RUB'), 200000, 5000000, 180, 1825, 0, 0, 0, 1),
(N'Кредит', N'Кредит в долларах', 8.5, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'USD'), 1000, 100000, 180, 1825, 0, 0, 0, 1),
(N'Вклад', N'Срочный вклад', 8.0, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'RUB'), 10000, 10000000, 30, 1095, 0, 0, 0, 1),
(N'Вклад', N'Накопительный вклад', 7.0, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'RUB'), 10000, 5000000, 90, 1095, 1, 1, 0, 1),
(N'Вклад', N'Универсальный вклад', 6.5, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'RUB'), 50000, 3000000, 180, 730, 1, 1, 1, 1),
(N'Вклад', N'Вклад в евро', 3.5, (SELECT IDВалюты FROM Валюты WHERE КодВалюты = N'EUR'), 1000, 100000, 180, 1095, 0, 0, 0, 1);
GO

INSERT INTO Клиенты 
(ТипКлиента, Фамилия, Имя, Отчество, НаименованиеЮрЛица, СерияПаспорта, НомерПаспорта, ИНН, ДатаРождения, Телефон, ЭлектроннаяПочта, АдресРегистрации, ДатаРегистрации)
VALUES 
(N'ФизЛицо', N'Смирнов', N'Алексей', N'Викторович', NULL, N'1900', N'123456', N'352801234567', '1985-06-15', N'+79111234567', N'smirnov@mail.ru', N'г. Вологда, ул. Гагарина, д. 10, кв. 25', GETDATE()),
(N'ФизЛицо', N'Кузнецова', N'Ольга', N'Сергеевна', NULL, N'1901', N'654321', N'352807654321', '1990-03-22', N'+79217654321', N'kuznetsova@mail.ru', N'г. Череповец, ул. Ленина, д. 5, кв. 78', GETDATE()),
(N'ФизЛицо', N'Морозов', N'Дмитрий', N'Александрович', NULL, N'1902', N'789012', N'352809876543', '1988-11-09', N'+79313456789', N'morozov@mail.ru', N'г. Вологда, ул. Некрасова, д. 30, кв. 12', GETDATE()),
(N'ФизЛицо', N'Волкова', N'Анна', N'Игоревна', NULL, N'1903', N'345678', N'352801112233', '1995-08-30', N'+79522345678', N'volkova@mail.ru', N'г. Сокол, ул. Пушкина, д. 8, кв. 45', GETDATE()),
(N'ФизЛицо', N'Соколов', N'Михаил', N'Петрович', NULL, N'1904', N'901234', N'352804445566', '1978-12-05', N'+79633456789', N'sokolov@mail.ru', N'г. Череповец, пр. Строителей, д. 20, кв. 90', GETDATE()),
(N'ФизЛицо', N'Орлова', N'Екатерина', N'Владимировна', NULL, N'1905', N'567890', N'352806667788', '1992-04-18', N'+79744567890', N'orlova@mail.ru', N'г. Вологда, ул. Чехова, д. 15, кв. 33', GETDATE()),
(N'ФизЛицо', N'Попов', N'Сергей', N'Николаевич', NULL, N'1906', N'234567', N'352809998877', '1982-07-25', N'+79855678901', N'popov@mail.ru', N'г. Череповец, ул. Металлургов, д. 12, кв. 56', GETDATE()),
(N'ФизЛицо', N'Лебедева', N'Татьяна', N'Андреевна', NULL, N'1907', N'890123', N'352803334455', '1993-10-12', N'+79966789012', N'lebedeva@mail.ru', N'г. Вологда, ул. Пролетарская, д. 40, кв. 8', GETDATE()),
(N'ФизЛицо', N'Зайцев', N'Андрей', N'Сергеевич', NULL, N'1908', N'456789', N'352805556677', '1980-02-28', N'+79167890123', N'zaytsev@mail.ru', N'г. Череповец, ул. Верещагина, д. 18, кв. 112', GETDATE()),
(N'ФизЛицо', N'Соловьева', N'Наталья', N'Михайловна', NULL, N'1909', N'012345', N'352807778899', '1987-09-14', N'+79278901234', N'soloveva@mail.ru', N'г. Вологда, ул. Можайского, д. 22, кв. 67', GETDATE()),

(N'ЮрЛицо', NULL, NULL, NULL, N'ООО "Северный лес"', NULL, NULL, N'352812345678', NULL, N'+78172551122', N'info@severles.ru', N'г. Вологда, ул. Промышленная, д. 5, офис 301', GETDATE()),
(N'ЮрЛицо', NULL, NULL, NULL, N'АО "Вологодский машиностроительный завод"', NULL, NULL, N'352834567890', NULL, N'+78172334455', N'office@vmz.ru', N'г. Вологда, ул. Заводская, д. 1', GETDATE()),
(N'ЮрЛицо', NULL, NULL, NULL, N'ИП Смирнов Алексей Викторович', NULL, NULL, N'352801234568', NULL, N'+79111234567', N'ip.smirnov@mail.ru', N'г. Вологда, ул. Гагарина, д. 10, кв. 25', GETDATE()),
(N'ЮрЛицо', NULL, NULL, NULL, N'ООО "Торговый дом Череповец"', NULL, NULL, N'352856789012', NULL, N'+78202556677', N'td-cher@mail.ru', N'г. Череповец, ул. Торговая, д. 15', GETDATE()),
(N'ЮрЛицо', NULL, NULL, NULL, N'ЗАО "Сокольский ЦБК"', NULL, NULL, N'352878901234', NULL, N'+78173338899', N'office@scbk.ru', N'г. Сокол, ул. Комсомольская, д. 25', GETDATE());
GO

DECLARE @Client1 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Смирнов' AND Имя = N'Алексей');
DECLARE @Client2 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Кузнецова' AND Имя = N'Ольга');
DECLARE @Client3 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Морозов' AND Имя = N'Дмитрий');
DECLARE @Client4 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Волкова' AND Имя = N'Анна');
DECLARE @Client5 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Соколов' AND Имя = N'Михаил');
DECLARE @Client7 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Попов' AND Имя = N'Сергей');
DECLARE @Client9 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Зайцев' AND Имя = N'Андрей');
DECLARE @Client11 INT = (SELECT IDКлиента FROM Клиенты WHERE НаименованиеЮрЛица = N'ООО "Северный лес"');
DECLARE @Client12 INT = (SELECT IDКлиента FROM Клиенты WHERE НаименованиеЮрЛица = N'АО "Вологодский машиностроительный завод"');

DECLARE @ProductLoan1 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Потребительский кредит');
DECLARE @ProductLoan2 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Ипотечный кредит');
DECLARE @ProductLoan3 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Автокредит');
DECLARE @ProductLoan4 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Кредит в долларах');

DECLARE @Branch1 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Центральный офис');
DECLARE @Branch2 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Дополнительный офис №1');
DECLARE @Branch3 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Дополнительный офис №2');

DECLARE @User2 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator1');
DECLARE @User4 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator2');
DECLARE @User5 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator3');

EXEC usp_CreateLoanContract N'CR-2026-001', @Client1, @ProductLoan1, @Branch1, @User2, 500000, '2026-01-15', '2027-01-15', N'Потребительские нужды', N'Аннуитетный';
EXEC usp_CreateLoanContract N'CR-2026-002', @Client3, @ProductLoan1, @Branch2, @User2, 250000, '2026-02-10', '2028-02-10', N'Ремонт квартиры', N'Аннуитетный';
EXEC usp_CreateLoanContract N'CR-2026-003', @Client5, @ProductLoan2, @Branch1, @User4, 3500000, '2026-01-20', '2031-01-20', N'Приобретение жилья', N'Аннуитетный';
EXEC usp_CreateLoanContract N'CR-2026-004', @Client7, @ProductLoan3, @Branch3, @User5, 1200000, '2026-03-05', '2029-03-05', N'Покупка автомобиля', N'Дифференцированный';
EXEC usp_CreateLoanContract N'CR-2026-006', @Client2, @ProductLoan1, @Branch2, @User4, 800000, '2026-02-15', '2027-08-15', N'Обучение', N'Аннуитетный';
EXEC usp_CreateLoanContract N'CR-2026-007', @Client11, @ProductLoan2, @Branch1, @User2, 5000000, '2026-01-25', '2031-01-25', N'Расширение бизнеса', N'Дифференцированный';
EXEC usp_CreateLoanContract N'CR-2026-009', @Client12, @ProductLoan3, @Branch1, @User2, 2000000, '2026-03-20', '2028-03-20', N'Покупка спецтехники', N'Аннуитетный';
EXEC usp_CreateLoanContract N'CR-2026-010', @Client1, @ProductLoan4, @Branch1, @User2, 5000, '2026-04-01', '2027-04-01', N'Обучение за рубежом', N'Аннуитетный';
GO

DECLARE @Client9 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Зайцев' AND Имя = N'Андрей');
DECLARE @ProductLoan1 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Потребительский кредит');
DECLARE @Branch1 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Центральный офис');
DECLARE @User2 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator1');
DECLARE @Loan5 INT;

INSERT INTO Договоры (НомерДоговора, IDКлиента, IDПродукта, IDОтделения, IDПользователя, Сумма, ДатаНачала, ДатаОкончания, Статус)
VALUES (N'CR-2026-005', @Client9, @ProductLoan1, @Branch1, @User2, 150000, '2025-12-10', '2026-12-10', N'Просрочен');

SET @Loan5 = SCOPE_IDENTITY();

INSERT INTO КредитныеДоговоры (IDКрДоговора, ЦельКредита, ТипПлатежа, ОстатокЗадолженности, ПросрочкаОсновнойДолг, ПросрочкаПроценты, НачисленоПеней, ДатаСледующегоПлатежа)
VALUES (@Loan5, N'Неотложные нужды', N'Аннуитетный', 120000, 15000, 2500, 500, '2026-04-10');

INSERT INTO Операции (IDДоговора, ТипОперации, Сумма, ОстатокПослеОперации, IDПользователя)
VALUES (@Loan5, N'Выдача кредита', 150000, 150000, @User2);
GO

DECLARE @Client4 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Волкова' AND Имя = N'Анна');
DECLARE @ProductLoan1 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Потребительский кредит');
DECLARE @Branch3 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Дополнительный офис №2');
DECLARE @User5 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator3');
DECLARE @Loan8 INT;

INSERT INTO Договоры (НомерДоговора, IDКлиента, IDПродукта, IDОтделения, IDПользователя, Сумма, ДатаНачала, ДатаОкончания, ДатаЗакрытия, Статус)
VALUES (N'CR-2026-008', @Client4, @ProductLoan1, @Branch3, @User5, 300000, '2025-11-01', '2026-11-01', '2026-03-15', N'Закрыт');

SET @Loan8 = SCOPE_IDENTITY();

INSERT INTO КредитныеДоговоры (IDКрДоговора, ЦельКредита, ТипПлатежа, ОстатокЗадолженности)
VALUES (@Loan8, N'Покупка техники', N'Аннуитетный', 0);

INSERT INTO Операции (IDДоговора, ТипОперации, Сумма, ОстатокПослеОперации, IDПользователя)
VALUES 
(@Loan8, N'Выдача кредита', 300000, 300000, @User5),
(@Loan8, N'Погашение основного долга', 300000, 0, @User5);
GO

DECLARE @Client2 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Кузнецова' AND Имя = N'Ольга');
DECLARE @Client3 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Морозов' AND Имя = N'Дмитрий');
DECLARE @Client6 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Орлова' AND Имя = N'Екатерина');
DECLARE @Client8 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Лебедева' AND Имя = N'Татьяна');
DECLARE @Client10 INT = (SELECT IDКлиента FROM Клиенты WHERE Фамилия = N'Соловьева' AND Имя = N'Наталья');
DECLARE @Client14 INT = (SELECT IDКлиента FROM Клиенты WHERE НаименованиеЮрЛица = N'ООО "Торговый дом Череповец"');
DECLARE @Client15 INT = (SELECT IDКлиента FROM Клиенты WHERE НаименованиеЮрЛица = N'ЗАО "Сокольский ЦБК"');

DECLARE @ProductDep1 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Срочный вклад');
DECLARE @ProductDep2 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Накопительный вклад');
DECLARE @ProductDep3 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Универсальный вклад');
DECLARE @ProductDep4 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Вклад в евро');

DECLARE @Branch1 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Центральный офис');
DECLARE @Branch2 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Дополнительный офис №1');
DECLARE @Branch3 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Дополнительный офис №2');

DECLARE @User2 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator1');
DECLARE @User4 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator2');
DECLARE @User5 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator3');

EXEC usp_CreateDepositContract N'DEP-2026-001', @Client2, @ProductDep1, @Branch2, @User4, 100000, '2026-02-01', '2027-02-01';
EXEC usp_CreateDepositContract N'DEP-2026-002', @Client6, @ProductDep2, @Branch1, @User2, 250000, '2026-01-10', '2027-07-10';
EXEC usp_CreateDepositContract N'DEP-2026-003', @Client8, @ProductDep1, @Branch3, @User5, 50000, '2026-03-15', '2026-09-15';
EXEC usp_CreateDepositContract N'DEP-2026-004', @Client10, @ProductDep3, @Branch1, @User2, 150000, '2026-02-20', '2026-08-20';
EXEC usp_CreateDepositContract N'DEP-2026-005', @Client14, @ProductDep2, @Branch2, @User4, 1000000, '2026-01-05', '2028-01-05';
EXEC usp_CreateDepositContract N'DEP-2026-007', @Client15, @ProductDep4, @Branch1, @User2, 10000, '2026-04-10', '2027-04-10';
EXEC usp_CreateDepositContract N'DEP-2026-008', @Client3, @ProductDep3, @Branch2, @User4, 300000, '2026-03-01', '2027-03-01';
GO

DECLARE @Client13 INT = (SELECT IDКлиента FROM Клиенты WHERE НаименованиеЮрЛица = N'ИП Смирнов Алексей Викторович');
DECLARE @ProductDep1 INT = (SELECT IDПродукта FROM БанковскиеПродукты WHERE НаименованиеПродукта = N'Срочный вклад');
DECLARE @Branch1 INT = (SELECT IDОтделения FROM ОтделенияБанка WHERE Наименование = N'Центральный офис');
DECLARE @User2 INT = (SELECT IDПользователя FROM Пользователи WHERE Логин = N'operator1');
DECLARE @Dep6 INT;

INSERT INTO Договоры (НомерДоговора, IDКлиента, IDПродукта, IDОтделения, IDПользователя, Сумма, ДатаНачала, ДатаОкончания, ДатаЗакрытия, Статус)
VALUES (N'DEP-2026-006', @Client13, @ProductDep1, @Branch1, @User2, 200000, '2025-10-01', '2026-04-01', '2026-04-01', N'Закрыт');

SET @Dep6 = SCOPE_IDENTITY();

INSERT INTO ДепозитныеДоговоры (IDДепозита, Капитализация, ПополнениеРазрешено, ЧастичноеСнятиеРазрешено, НачисленоПроцентов, ВыплаченоПроцентов)
VALUES (@Dep6, 0, 0, 0, 8000, 8000);

INSERT INTO Операции (IDДоговора, ТипОперации, Сумма, ОстатокПослеОперации, IDПользователя)
VALUES 
(@Dep6, N'Взнос на вклад', 200000, 200000, @User2),
(@Dep6, N'Начисление процентов', 8000, 208000, @User2),
(@Dep6, N'Снятие с вклада', 208000, 0, @User2);
GO
