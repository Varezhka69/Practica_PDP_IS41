USE BankAccountingDB;
GO

CREATE TRIGGER trg_Operations_CalculateBalance
ON Операции
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE o
    SET ОстатокПослеОперации = (
        SELECT ISNULL(SUM(
            CASE 
                WHEN ТипОперации IN (N'Выдача кредита', N'Взнос на вклад', N'Начисление процентов', N'Капитализация процентов') THEN Сумма
                WHEN ТипОперации IN (N'Погашение основного долга', N'Погашение процентов', N'Погашение пени', N'Снятие с вклада') THEN -Сумма
                ELSE 0
            END), 0)
        FROM Операции
        WHERE IDДоговора = i.IDДоговора AND ДатаОперации <= i.ДатаОперации AND IDОперации <= i.IDОперации
    )
    FROM Операции o
    INNER JOIN inserted i ON o.IDОперации = i.IDОперации;
END;
GO

CREATE TRIGGER trg_AfterPayment_UpdateLoanBalance
ON Операции
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @IDДоговора INT, @ТипОперации NVARCHAR(30), @Сумма DECIMAL(19,4);
    
    DECLARE cur CURSOR FOR SELECT IDДоговора, ТипОперации, Сумма FROM inserted;
    OPEN cur;
    FETCH NEXT FROM cur INTO @IDДоговора, @ТипОперации, @Сумма;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @ТипОперации IN (N'Погашение основного долга', N'Погашение процентов', N'Погашение пени')
        BEGIN
            IF EXISTS (SELECT 1 FROM КредитныеДоговоры WHERE IDКрДоговора = @IDДоговора)
            BEGIN
                IF @ТипОперации = N'Погашение основного долга'
                    UPDATE КредитныеДоговоры SET ОстатокЗадолженности = ОстатокЗадолженности - @Сумма WHERE IDКрДоговора = @IDДоговора;
                ELSE IF @ТипОперации = N'Погашение процентов'
                    UPDATE КредитныеДоговоры SET ПросрочкаПроценты = CASE WHEN ПросрочкаПроценты >= @Сумма THEN ПросрочкаПроценты - @Сумма ELSE 0 END WHERE IDКрДоговора = @IDДоговора;
                ELSE IF @ТипОперации = N'Погашение пени'
                    UPDATE КредитныеДоговоры SET НачисленоПеней = CASE WHEN НачисленоПеней >= @Сумма THEN НачисленоПеней - @Сумма ELSE 0 END WHERE IDКрДоговора = @IDДоговора;
            END
        END
        FETCH NEXT FROM cur INTO @IDДоговора, @ТипОперации, @Сумма;
    END
    CLOSE cur;
    DEALLOCATE cur;
END;
GO

CREATE TRIGGER trg_AfterContractClose
ON Договоры
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF UPDATE(Статус)
    BEGIN
        UPDATE Договоры
        SET ДатаЗакрытия = GETDATE()
        FROM Договоры д
        INNER JOIN inserted i ON д.IDДоговора = i.IDДоговора
        INNER JOIN deleted dlt ON i.IDДоговора = dlt.IDДоговора
        WHERE i.Статус = N'Закрыт' AND dlt.Статус != N'Закрыт';
    END
END;
GO
