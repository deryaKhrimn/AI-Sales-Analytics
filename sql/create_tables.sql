-- 1. Asıl Tablonun Oluşturulması
CREATE TABLE superstore_sales (
    Row_ID INT PRIMARY KEY,
    Order_ID VARCHAR(50),
    Order_Date DATE,
    Ship_Date DATE,
    Ship_Mode VARCHAR(50),
    Customer_ID VARCHAR(50),
    Customer_Name VARCHAR(100),
    Segment VARCHAR(50),
    Country VARCHAR(50),
    City VARCHAR(50),
    State VARCHAR(50),
    Postal_Code VARCHAR(20),
    Region VARCHAR(50),
    Product_ID VARCHAR(50),
    Category VARCHAR(50),
    Sub_Category VARCHAR(50),
    Product_Name VARCHAR(500),
    Sales DECIMAL(10, 2),
    Quantity INT,
    Discount DECIMAL(4, 2),
    Profit DECIMAL(10, 2)
);

-- NOT: 'staging_sales' geçici tablosu, CSV dosyasındaki tüm veriler 
-- VARCHAR olarak kabul edilerek SSMS Import Wizard ile içeri alınmıştır.

-- 2. Veri Tiplerinin Dönüştürülerek (Casting) Asıl Tabloya Aktarılması
INSERT INTO superstore_sales
SELECT 
    CAST(Row_ID AS INT),
    Order_ID,
    CONVERT(DATE, Order_Date, 101),
    CONVERT(DATE, Ship_Date, 101),
    Ship_Mode,
    Customer_ID,
    Customer_Name,
    Segment,
    Country,
    City,
    State,
    Postal_Code,
    Region,
    Product_ID,
    Category,
    Sub_Category, 
    Product_Name,
    CAST(Sales AS DECIMAL(10,2)),
    CAST(Quantity AS INT),
    CAST(Discount AS DECIMAL(4,2)),
    CAST(Profit AS DECIMAL(10,2))
FROM staging_sales;

-- 3. İşlem Sonrası Geçici Tablonun Silinmesi (Temizlik)
DROP TABLE staging_sales;

GO

CREATE FUNCTION FN_Get_Shipping_Status(@OrderDate AS DATE,@ShipDate AS DATE)
RETURNS VARCHAR(20)
AS
BEGIN
DECLARE @DayDiff AS INT=DATEDIFF(DAY,@OrderDate,@ShipDate)
DECLARE @Ship_Status AS VARCHAR(20)
IF @DayDiff <3
BEGIN
SET @Ship_Status='FAST'
END
ELSE IF @DayDiff BETWEEN 3 AND 5
BEGIN
SET @Ship_Status = 'NORMAL'
END
ELSE IF @DayDiff>5
BEGIN
SET @Ship_Status = 'DELAYED'
END
RETURN @Ship_Status
END 

GO