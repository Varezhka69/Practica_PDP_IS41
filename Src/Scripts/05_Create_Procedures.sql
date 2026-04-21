USE BankAccountingDB;
GO

CREATE PROCEDURE usp_AddClient
    @ТипКлиента NVARCHAR(20),
    @Фамилия NVARCHAR(50) = NULL,
    @Имя NVARCHAR(50) = NULL,
    @Отчество NVARCHAR(50) = NULL,
    @НаименованиеЮрЛица NVARCHAR(200) = NULL,
    @СерияПаспорта NVARCHAR(10) = NULL,
    @НомерПаспорта NVARCHAR(20) = NULL,
    @ИНН NVARCHAR(12) = NULL,
    @ДатаРождения DATE = NULL,
    @Телефон NVARCHAR(20),
    @ЭлектроннаяПочта NVARCHAR(100) = NULL,
    @АдресРегистрации NVARCHAR(500) = NULL,
    @NewClientID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ИНН IS NOT NULL AND EXISTS (SELECT 1 FROM Клиенты WHERE ИНН = @ИНН)
    BEGIN
        RAISERROR(N'Клиент с таким ИНН уже существует', 16, 1);
        RETURN;
    END
    
    INSERT INTO Клиенты (ТипКлиента, Фамилия, Имя, Отчество, НаименованиеЮрЛица,
                         СерияПаспорта, НомерПаспорта, ИНН, ДатаРождения,
                         Телефон, ЭлектроннаяПочта, АдресРегистрации)
    VALUES (@ТипКлиента, @Фамилия, @Имя, @Отчество, @НаименованиеЮрЛица,
            @СерияПаспорта, @НомерПаспорта, @ИНН, @ДатаРождения,
            @Телефон, @ЭлектроннаяПочта, @АдресРегистрации);
    
    SET @NewClientID = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE usp_CreateContract
    @НомерДоговора NVARCHAR(50),
    @IDКлиента INT,
    @IDПродукта INT,
    @IDОтделения INT,
    @IDПользователя INT,
    @Сумма DECIMAL(19,4),
    @ДатаНачала DATE,
    @ДатаОкончания DATE,
    @NewContractID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @МинСумма DECIMAL(19,4), @МаксСумма DECIMAL(19,4);
    DECLARE @МинСрок INT, @МаксСрок INT, @СрокДней INT;
    
    SELECT @МинСумма = МинимальнаяСумма, @МаксСумма = МаксимальнаяСумма,
           @МинСрок = МинимальныйСрок, @МаксСрок = МаксимальныйСрок
    FROM БанковскиеПродукты
    WHERE IDПродукта = @IDПродукта;
    
    SET @СрокДней = DATEDIFF(DAY, @ДатаНачала, @ДатаОкончания);
    
    IF @Сумма < @МинСумма OR @Сумма > @МаксСумма
    BEGIN
        RAISERROR(N'Сумма не соответствует условиям продукта', 16, 1);
        RETURN;
    END
    
    IF @СрокДней < @МинСрок OR @СрокДней > @МаксСрок
    BEGIN
        RAISERROR(N'Срок не соответствует условиям продукта', 16, 1);
        RETURN;
    END
    
    INSERT INTO Договоры (НомерДоговора, IDКлиента, IDПродукта, IDОтделения, IDПользователя,
                          Сумма, ДатаНачала, ДатаОкончания)
    VALUES (@НомерДоговора, @IDКлиента, @IDПродукта, @IDОтделения, @IDПользователя,
            @Сумма, @ДатаНачала, @ДатаОкончания);
    
    SET @NewContractID = SCOPE_IDENTITY();
END;
GO

CREATE PROCEDURE usp_CreateLoanContract
    @НомерДоговора NVARCHAR(50),
    @IDКлиента INT,
    @IDПродукта INT,
    @IDОтделения INT,
    @IDПользователя INT,
    @Сумма DECIMAL(19,4),
    @ДатаНачала DATE,
    @ДатаОкончания DATE,
    @ЦельКредита NVARCHAR(200) = NULL,
    @ТипПлатежа NVARCHAR(20) = N'Аннуитетный',
    @NewLoanContractID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IDДоговора INT, @Ставка DECIMAL(5,3), @СрокМесяцев INT;
    DECLARE @Платеж DECIMAL(19,4), @Остаток DECIMAL(19,4);
    DECLARE @ДатаПлатежа DATE, @Номер INT = 1;
    DECLARE @МесячнаяСтавка DECIMAL(10,8), @Проценты DECIMAL(19,4), @Основной DECIMAL(19,4);
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        INSERT INTO Договоры (НомерДоговора, IDКлиента, IDПродукта, IDОтделения, IDПользователя,
                              Сумма, ДатаНачала, ДатаОкончания)
        VALUES (@НомерДоговора, @IDКлиента, @IDПродукта, @IDОтделения, @IDПользователя,
                @Сумма, @ДатаНачала, @ДатаОкончания);
        
        SET @IDДоговора = SCOPE_IDENTITY();
        SET @Остаток = @Сумма;
        
        SELECT @Ставка = ПроцентнаяСтавка FROM БанковскиеПродукты WHERE IDПродукта = @IDПродукта;
        SET @СрокМесяцев = DATEDIFF(MONTH, @ДатаНачала, @ДатаОкончания);
        
        INSERT INTO КредитныеДоговоры (IDКрДоговора, ЦельКредита, ТипПлатежа, ОстатокЗадолженности)
        VALUES (@IDДоговора, @ЦельКредита, @ТипПлатежа, @Сумма);
        
        SET @МесячнаяСтавка = @Ставка / 12 / 100;
        SET @ДатаПлатежа = DATEADD(MONTH, 1, @ДатаНачала);
        
        IF @ТипПлатежа = N'Аннуитетный'
        BEGIN
            SET @Платеж = dbo.ufn_CalculateAnnuityPayment(@Сумма, @Ставка, @СрокМесяцев);
            
            WHILE @Номер <= @СрокМесяцев
            BEGIN
                SET @Проценты = @Остаток * @МесячнаяСтавка;
                SET @Основной = @Платеж - @Проценты;
                
                INSERT INTO ГрафикПлатежей (IDКрДоговора, НомерПлатежа, ДатаПлатежа,
                                            СуммаОсновногоДолга, СуммаПроцентов)
                VALUES (@IDДоговора, @Номер, @ДатаПлатежа, @Основной, @Проценты);
                
                SET @Остаток = @Остаток - @Основной;
                SET @Номер = @Номер + 1;
                SET @ДатаПлатежа = DATEADD(MONTH, 1, @ДатаПлатежа);
            END
        END
        ELSE
        BEGIN
            SET @Основной = @Сумма / @СрокМесяцев;
            
            WHILE @Номер <= @СрокМесяцев
            BEGIN
                SET @Проценты = @Остаток * @МесячнаяСтавка;
                
                INSERT INTO ГрафикПлатежей (IDКрДоговора, НомерПлатежа, ДатаПлатежа,
                                            СуммаОсновногоДолга, СуммаПроцентов)
                VALUES (@IDДоговора, @Номер, @ДатаПлатежа, @Основной, @Проценты);
                
                SET @Остаток = @Остаток - @Основной;
                SET @Номер = @Номер + 1;
                SET @ДатаПлатежа = DATEADD(MONTH, 1, @ДатаПлатежа);
            END
        END
        
        UPDATE КредитныеДоговоры
        SET ДатаСледующегоПлатежа = (SELECT MIN(ДатаПлатежа) FROM ГрафикПлатежей 
                                      WHERE IDКрДоговора = @IDДоговора AND Оплачен = 0)
        WHERE IDКрДоговора = @IDДоговора;
        
        INSERT INTO Операции (IDДоговора, ТипОперации, Сумма, ОстатокПослеОперации, IDПользователя)
        VALUES (@IDДоговора, N'Выдача кредита', @Сумма, @Сумма, @IDПользователя);
        
        COMMIT TRANSACTION;
        SET @NewLoanContractID = @IDДоговора;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE usp_CreateDepositContract
    @НомерДоговора NVARCHAR(50),
    @IDКлиента INT,
    @IDПродукта INT,
    @IDОтделения INT,
    @IDПользователя INT,
    @Сумма DECIMAL(19,4),
    @ДатаНачала DATE,
    @ДатаОкончания DATE,
    @NewDepositContractID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IDДоговора INT;
    DECLARE @Капитализация BIT, @Пополнение BIT, @ЧастичноеСнятие BIT;
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        SELECT @Капитализация = Капитализация,
               @Пополнение = ПополнениеРазрешено,
               @ЧастичноеСнятие = ЧастичноеСнятиеРазрешено
        FROM БанковскиеПродукты
        WHERE IDПродукта = @IDПродукта;
        
        INSERT INTO Договоры (НомерДоговора, IDКлиента, IDПродукта, IDОтделения, IDПользователя,
                              Сумма, ДатаНачала, ДатаОкончания)
        VALUES (@НомерДоговора, @IDКлиента, @IDПродукта, @IDОтделения, @IDПользователя,
                @Сумма, @ДатаНачала, @ДатаОкончания);
        
        SET @IDДоговора = SCOPE_IDENTITY();
        
        INSERT INTO ДепозитныеДоговоры (IDДепозита, Капитализация, ПополнениеРазрешено, ЧастичноеСнятиеРазрешено)
        VALUES (@IDДоговора, @Капитализация, @Пополнение, @ЧастичноеСнятие);
        
        INSERT INTO Операции (IDДоговора, ТипОперации, Сумма, ОстатокПослеОперации, IDПользователя)
        VALUES (@IDДоговора, N'Взнос на вклад', @Сумма, @Сумма, @IDПользователя);
        
        COMMIT TRANSACTION;
        SET @NewDepositContractID = @IDДоговора;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE usp_RegisterPayment
    @IDКрДоговора INT,
    @СуммаПлатежа DECIMAL(19,4),
    @IDПользователя INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Остаток DECIMAL(19,4);
    
    SELECT @Остаток = ОстатокЗадолженности + ПросрочкаОсновнойДолг + ПросрочкаПроценты
    FROM КредитныеДоговоры
    WHERE IDКрДоговора = @IDКрДоговора;
    
    IF @СуммаПлатежа > @Остаток
    BEGIN
        RAISERROR(N'Сумма платежа превышает задолженность', 16, 1);
        RETURN;
    END
    
    BEGIN TRANSACTION;
    
    BEGIN TRY
        INSERT INTO Операции (IDДоговора, ТипОперации, Сумма, ОстатокПослеОперации, IDПользователя)
        VALUES (@IDКрДоговора, N'Погашение основного долга', @СуммаПлатежа, 0, @IDПользователя);
        
        UPDATE КредитныеДоговоры
        SET ОстатокЗадолженности = ОстатокЗадолженности - @СуммаПлатежа
        WHERE IDКрДоговора = @IDКрДоговора;
        
        UPDATE ГрафикПлатежей
        SET Оплачен = 1, ДатаОплаты = GETDATE()
        WHERE IDКрДоговора = @IDКрДоговора 
          AND Оплачен = 0 
          AND ДатаПлатежа = (SELECT MIN(ДатаПлатежа) FROM ГрафикПлатежей 
                             WHERE IDКрДоговора = @IDКрДоговора AND Оплачен = 0);
        
        UPDATE КредитныеДоговоры
        SET ДатаСледующегоПлатежа = (SELECT MIN(ДатаПлатежа) FROM ГрафикПлатежей 
                                      WHERE IDКрДоговора = @IDКрДоговора AND Оплачен = 0)
        WHERE IDКрДоговора = @IDКрДоговора;
        
        IF (SELECT ОстатокЗадолженности FROM КредитныеДоговоры WHERE IDКрДоговора = @IDКрДоговора) <= 0
        BEGIN
            UPDATE Договоры
            SET Статус = N'Закрыт', ДатаЗакрытия = GETDATE()
            WHERE IDДоговора = @IDКрДоговора;
        END
        
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

CREATE PROCEDURE usp_CalculateDailyInterest
    @ДатаРасчета DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ДатаРасчета IS NULL
        SET @ДатаРасчета = GETDATE();
    
    DECLARE @IDДоговора INT, @ТипПродукта NVARCHAR(20), @Сумма DECIMAL(19,4), @Ставка DECIMAL(5,3), @Проценты DECIMAL(19,4);
    
    DECLARE cur CURSOR FOR
        SELECT д.IDДоговора, бп.ТипПродукта, 
               CASE WHEN бп.ТипПродукта = N'Кредит' THEN кд.ОстатокЗадолженности
                    ELSE д.Сумма + дд.НачисленоПроцентов - дд.ВыплаченоПроцентов
               END AS Сумма,
               бп.ПроцентнаяСтавка
        FROM Договоры д
        JOIN БанковскиеПродукты бп ON д.IDПродукта = бп.IDПродукта
        LEFT JOIN КредитныеДоговоры кд ON д.IDДоговора = кд.IDКрДоговора
        LEFT JOIN ДепозитныеДоговоры дд ON д.IDДоговора = дд.IDДепозита
        WHERE д.Статус = N'Активен';
    
    OPEN cur;
    FETCH NEXT FROM cur INTO @IDДоговора, @ТипПродукта, @Сумма, @Ставка;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Проценты = dbo.ufn_CalculateDailyInterest(@Сумма, @Ставка);
        
        IF @ТипПродукта = N'Кредит'
            UPDATE КредитныеДоговоры SET НачисленоПроцентов = НачисленоПроцентов + @Проценты WHERE IDКрДоговора = @IDДоговора;
        ELSE
            UPDATE ДепозитныеДоговоры SET НачисленоПроцентов = НачисленоПроцентов + @Проценты WHERE IDДепозита = @IDДоговора;
        
        FETCH NEXT FROM cur INTO @IDДоговора, @ТипПродукта, @Сумма, @Ставка;
    END
    
    CLOSE cur;
    DEALLOCATE cur;
END;
GO

CREATE PROCEDURE usp_CloseContract
    @IDДоговора INT,
    @IDПользователя INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ТипПродукта NVARCHAR(20), @Остаток DECIMAL(19,4);
    
    SELECT @ТипПродукта = бп.ТипПродукта
    FROM Договоры д
    JOIN БанковскиеПродукты бп ON д.IDПродукта = бп.IDПродукта
    WHERE д.IDДоговора = @IDДоговора;
    
    IF @ТипПродукта = N'Кредит'
    BEGIN
        SELECT @Остаток = ОстатокЗадолженности + ПросрочкаОсновнойДолг + ПросрочкаПроценты
        FROM КредитныеДоговоры
        WHERE IDКрДоговора = @IDДоговора;
        
        IF @Остаток > 0
        BEGIN
            RAISERROR(N'Невозможно закрыть договор: имеется задолженность', 16, 1);
            RETURN;
        END
    END
    
    UPDATE Договоры
    SET Статус = N'Закрыт', ДатаЗакрытия = GETDATE()
    WHERE IDДоговора = @IDДоговора;
END;
GO

CREATE PROCEDURE usp_GetOverdueLoans
    @ДатаОтчета DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @ДатаОтчета IS NULL
        SET @ДатаОтчета = GETDATE();
    
    SELECT 
        д.НомерДоговора,
        CASE WHEN к.ТипКлиента = N'ФизЛицо' THEN к.Фамилия + N' ' + к.Имя + N' ' + ISNULL(к.Отчество, N'') ELSE к.НаименованиеЮрЛица END AS Клиент,
        кд.ОстатокЗадолженности, кд.ПросрочкаОсновнойДолг, кд.ПросрочкаПроценты, кд.НачисленоПеней,
        DATEDIFF(DAY, кд.ДатаСледующегоПлатежа, @ДатаОтчета) AS ДнейПросрочки,
        отд.Наименование AS Отделение
    FROM Договоры д
    JOIN Клиенты к ON д.IDКлиента = к.IDКлиента
    JOIN КредитныеДоговоры кд ON д.IDДоговора = кд.IDКрДоговора
    JOIN ОтделенияБанка отд ON д.IDОтделения = отд.IDОтделения
    WHERE д.Статус = N'Просрочен' OR кд.ПросрочкаОсновнойДолг > 0 OR кд.ПросрочкаПроценты > 0
    ORDER BY ДнейПросрочки DESC;
END;
GO

CREATE PROCEDURE usp_GetDepositPortfolio
    @IDОтделения INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        д.НомерДоговора,
        CASE WHEN к.ТипКлиента = N'ФизЛицо' THEN к.Фамилия + N' ' + к.Имя + N' ' + ISNULL(к.Отчество, N'') ELSE к.НаименованиеЮрЛица END AS Клиент,
        д.Сумма AS СуммаВклада, бп.ПроцентнаяСтавка, в.КодВалюты AS Валюта,
        дд.НачисленоПроцентов, дд.ВыплаченоПроцентов, д.ДатаОкончания, отд.Наименование AS Отделение
    FROM Договоры д
    JOIN Клиенты к ON д.IDКлиента = к.IDКлиента
    JOIN ДепозитныеДоговоры дд ON д.IDДоговора = дд.IDДепозита
    JOIN БанковскиеПродукты бп ON д.IDПродукта = бп.IDПродукта
    JOIN Валюты в ON бп.IDВалюты = в.IDВалюты
    JOIN ОтделенияБанка отд ON д.IDОтделения = отд.IDОтделения
    WHERE д.Статус = N'Активен' AND (@IDОтделения IS NULL OR д.IDОтделения = @IDОтделения)
    ORDER BY д.ДатаОкончания;
END;
GO

CREATE PROCEDURE usp_GeneratePaymentSchedule
    @IDКрДоговора INT,
    @Сумма DECIMAL(19,4),
    @Ставка DECIMAL(5,3),
    @СрокМесяцев INT,
    @ТипПлатежа NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;
    
    DELETE FROM ГрафикПлатежей WHERE IDКрДоговора = @IDКрДоговора;
    
    DECLARE @МесячнаяСтавка DECIMAL(10,8) = @Ставка / 12 / 100;
    DECLARE @ДатаПлатежа DATE = DATEADD(MONTH, 1, GETDATE());
    DECLARE @Остаток DECIMAL(19,4) = @Сумма;
    DECLARE @Номер INT = 1;
    DECLARE @Платеж DECIMAL(19,4), @Проценты DECIMAL(19,4), @Основной DECIMAL(19,4);
    
    IF @ТипПлатежа = N'Аннуитетный'
    BEGIN
        SET @Платеж = dbo.ufn_CalculateAnnuityPayment(@Сумма, @Ставка, @СрокМесяцев);
        
        WHILE @Номер <= @СрокМесяцев
        BEGIN
            SET @Проценты = @Остаток * @МесячнаяСтавка;
            SET @Основной = @Платеж - @Проценты;
            
            INSERT INTO ГрафикПлатежей (IDКрДоговора, НомерПлатежа, ДатаПлатежа, СуммаОсновногоДолга, СуммаПроцентов)
            VALUES (@IDКрДоговора, @Номер, @ДатаПлатежа, @Основной, @Проценты);
            
            SET @Остаток = @Остаток - @Основной;
            SET @Номер = @Номер + 1;
            SET @ДатаПлатежа = DATEADD(MONTH, 1, @ДатаПлатежа);
        END
    END
    ELSE
    BEGIN
        SET @Основной = @Сумма / @СрокМесяцев;
        
        WHILE @Номер <= @СрокМесяцев
        BEGIN
            SET @Проценты = @Остаток * @МесячнаяСтавка;
            
            INSERT INTO ГрафикПлатежей (IDКрДоговора, НомерПлатежа, ДатаПлатежа, СуммаОсновногоДолга, СуммаПроцентов)
            VALUES (@IDКрДоговора, @Номер, @ДатаПлатежа, @Основной, @Проценты);
            
            SET @Остаток = @Остаток - @Основной;
            SET @Номер = @Номер + 1;
            SET @ДатаПлатежа = DATEADD(MONTH, 1, @ДатаПлатежа);
        END
    END
END;
GO
