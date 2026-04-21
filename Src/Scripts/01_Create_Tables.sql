USE BankAccountingDB;
GO

CREATE TABLE Роли
(
    IDРоли INT IDENTITY(1,1) PRIMARY KEY,
    Наименование NVARCHAR(50) NOT NULL UNIQUE
);
GO

CREATE TABLE Пользователи
(
    IDПользователя INT IDENTITY(1,1) PRIMARY KEY,
    IDРоли INT NOT NULL FOREIGN KEY REFERENCES Роли(IDРоли),
    Логин NVARCHAR(50) NOT NULL UNIQUE,
    ХэшПароля NVARCHAR(256) NOT NULL,
    Фамилия NVARCHAR(50) NOT NULL,
    Имя NVARCHAR(50) NOT NULL,
    Отчество NVARCHAR(50) NULL,
    ЭлектроннаяПочта NVARCHAR(100) NULL,
    Активен BIT NOT NULL DEFAULT 1,
    ДатаСоздания DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE TABLE Клиенты
(
    IDКлиента INT IDENTITY(1,1) PRIMARY KEY,
    ТипКлиента NVARCHAR(20) NOT NULL CHECK (ТипКлиента IN (N'ФизЛицо', N'ЮрЛицо')),
    Фамилия NVARCHAR(50) NULL,
    Имя NVARCHAR(50) NULL,
    Отчество NVARCHAR(50) NULL,
    НаименованиеЮрЛица NVARCHAR(200) NULL,
    СерияПаспорта NVARCHAR(10) NULL,
    НомерПаспорта NVARCHAR(20) NULL,
    ИНН NVARCHAR(12) NULL UNIQUE,
    ДатаРождения DATE NULL,
    Телефон NVARCHAR(20) NOT NULL,
    ЭлектроннаяПочта NVARCHAR(100) NULL,
    АдресРегистрации NVARCHAR(500) NULL,
    ДатаРегистрации DATETIME2 NOT NULL DEFAULT GETDATE(),
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.КлиентыИстория));
GO

CREATE TABLE Валюты
(
    IDВалюты INT IDENTITY(1,1) PRIMARY KEY,
    КодВалюты NVARCHAR(3) NOT NULL UNIQUE,
    Наименование NVARCHAR(50) NOT NULL,
    КурсКРублю DECIMAL(10,4) NOT NULL DEFAULT 1.0
);
GO

CREATE TABLE ОтделенияБанка
(
    IDОтделения INT IDENTITY(1,1) PRIMARY KEY,
    Наименование NVARCHAR(100) NOT NULL,
    Адрес NVARCHAR(300) NOT NULL,
    Активно BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE БанковскиеПродукты
(
    IDПродукта INT IDENTITY(1,1) PRIMARY KEY,
    ТипПродукта NVARCHAR(20) NOT NULL CHECK (ТипПродукта IN (N'Кредит', N'Вклад')),
    НаименованиеПродукта NVARCHAR(100) NOT NULL,
    ПроцентнаяСтавка DECIMAL(5,3) NOT NULL,
    IDВалюты INT NOT NULL FOREIGN KEY REFERENCES Валюты(IDВалюты),
    МинимальнаяСумма DECIMAL(19,4) NOT NULL,
    МаксимальнаяСумма DECIMAL(19,4) NOT NULL,
    МинимальныйСрок INT NOT NULL,
    МаксимальныйСрок INT NOT NULL,
    Капитализация BIT NOT NULL DEFAULT 0,
    ПополнениеРазрешено BIT NOT NULL DEFAULT 0,
    ЧастичноеСнятиеРазрешено BIT NOT NULL DEFAULT 0,
    Активен BIT NOT NULL DEFAULT 1
);
GO

CREATE TABLE Договоры
(
    IDДоговора INT IDENTITY(1,1) PRIMARY KEY,
    НомерДоговора NVARCHAR(50) NOT NULL UNIQUE,
    IDКлиента INT NOT NULL FOREIGN KEY REFERENCES Клиенты(IDКлиента),
    IDПродукта INT NOT NULL FOREIGN KEY REFERENCES БанковскиеПродукты(IDПродукта),
    IDОтделения INT NOT NULL FOREIGN KEY REFERENCES ОтделенияБанка(IDОтделения),
    IDПользователя INT NOT NULL FOREIGN KEY REFERENCES Пользователи(IDПользователя),
    Сумма DECIMAL(19,4) NOT NULL CHECK (Сумма > 0),
    ДатаЗаключения DATE NOT NULL DEFAULT GETDATE(),
    ДатаНачала DATE NOT NULL,
    ДатаОкончания DATE NOT NULL,
    ДатаЗакрытия DATE NULL,
    Статус NVARCHAR(20) NOT NULL CHECK (Статус IN (N'Активен', N'Просрочен', N'Закрыт')) DEFAULT N'Активен',
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ДоговорыИстория));
GO

CREATE TABLE КредитныеДоговоры
(
    IDКрДоговора INT PRIMARY KEY FOREIGN KEY REFERENCES Договоры(IDДоговора),
    ЦельКредита NVARCHAR(200) NULL,
    ТипПлатежа NVARCHAR(20) NOT NULL CHECK (ТипПлатежа IN (N'Аннуитетный', N'Дифференцированный')),
    ОстатокЗадолженности DECIMAL(19,4) NOT NULL,
    ПросрочкаОсновнойДолг DECIMAL(19,4) NOT NULL DEFAULT 0,
    ПросрочкаПроценты DECIMAL(19,4) NOT NULL DEFAULT 0,
    НачисленоПроцентов DECIMAL(19,4) NOT NULL DEFAULT 0,
    НачисленоПеней DECIMAL(19,4) NOT NULL DEFAULT 0,
    ДатаСледующегоПлатежа DATE NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.КредитныеДоговорыИстория));
GO

CREATE TABLE ДепозитныеДоговоры
(
    IDДепозита INT PRIMARY KEY FOREIGN KEY REFERENCES Договоры(IDДоговора),
    Капитализация BIT NOT NULL DEFAULT 0,
    ПополнениеРазрешено BIT NOT NULL DEFAULT 0,
    ЧастичноеСнятиеРазрешено BIT NOT NULL DEFAULT 0,
    НачисленоПроцентов DECIMAL(19,4) NOT NULL DEFAULT 0,
    ВыплаченоПроцентов DECIMAL(19,4) NOT NULL DEFAULT 0,
    ДатаПоследнейКапитализации DATE NULL,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ДепозитныеДоговорыИстория));
GO

CREATE TABLE ГрафикПлатежей
(
    IDГрафика INT IDENTITY(1,1) PRIMARY KEY,
    IDКрДоговора INT NOT NULL FOREIGN KEY REFERENCES КредитныеДоговоры(IDКрДоговора),
    НомерПлатежа INT NOT NULL,
    ДатаПлатежа DATE NOT NULL,
    СуммаОсновногоДолга DECIMAL(19,4) NOT NULL,
    СуммаПроцентов DECIMAL(19,4) NOT NULL,
    Оплачен BIT NOT NULL DEFAULT 0,
    ДатаОплаты DATE NULL
);
GO

CREATE TABLE Операции
(
    IDОперации INT IDENTITY(1,1) PRIMARY KEY,
    IDДоговора INT NOT NULL FOREIGN KEY REFERENCES Договоры(IDДоговора),
    ДатаОперации DATETIME2 NOT NULL DEFAULT GETDATE(),
    ТипОперации NVARCHAR(30) NOT NULL CHECK (ТипОперации IN 
        (N'Выдача кредита', N'Погашение основного долга', N'Погашение процентов', 
         N'Погашение пени', N'Взнос на вклад', N'Снятие с вклада', 
         N'Начисление процентов', N'Капитализация процентов')),
    Сумма DECIMAL(19,4) NOT NULL CHECK (Сумма > 0),
    ОстатокПослеОперации DECIMAL(19,4) NOT NULL,
    IDПользователя INT NOT NULL FOREIGN KEY REFERENCES Пользователи(IDПользователя)
);
GO
