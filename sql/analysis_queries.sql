-- Kategori ve Alt Kategori Bazında Toplam Satış ve Kâr
SELECT 
    Category,
	Sub_Category,
	Sum(Sales) AS Total_Sales_Amount,
	SUM(Profit) AS Total_Profit
FROM superstore_sales 
GROUP BY Category, Sub_Category 
ORDER BY Sum(Sales) DESC


-- Aylık Satış Trendi

SELECT 
    YEAR(Order_Date) AS Order_Year,
	MONTH(Order_Date) AS Order_Month,
	SUM(Sales) AS Total_Sales_Amount,
	COUNT(Order_ID) AS Total_Orders

FROM superstore_sales 
GROUP BY YEAR(Order_Date),MONTH(Order_Date)
ORDER BY Order_Year,Order_Month


-- En Çok Kâr Getiren İlk 10 Şehir

SELECT TOP 10
    City,
	State,
	Sum(Profit) AS Total_Profit
FROM superstore_sales 
GROUP BY City, State
ORDER BY Sum(Profit) DESC


-- En Çok Satılan Ürünler

SELECT TOP 5
    Product_Name,
	Sum(Quantity) AS Total_Quantity,
	SUM(Sales) AS Total_Sales_Amount
FROM superstore_sales
GROUP BY Product_Name
ORDER BY Sum(Quantity) DESC


-- Bu sorgu, müşterilerin toplam alışveriş tutarlarını hesaplayarak en yüksek harcamayı yapan VIP müşteriyi tespit eder.

SELECT TOP 10
    Customer_ID,
	Customer_Name,
	COUNT(Order_ID) AS Total_Orders,
	SUM(Sales) AS Total_Sales_Amount
FROM superstore_sales 
GROUP BY Customer_ID, Customer_Name
ORDER BY SUM(Sales) DESC


--Bu sorgu, uygulanan indirim oranlarının satış ve kârlılık üzerindeki etkisini analiz etmek amacıyla hazırlanmıştır.

SELECT 
    Discount,
	COUNT(Order_ID) AS Total_Orders,
	SUM(Sales) AS Total_Sales_Amount,
	SUM(Profit) AS Total_Profit
FROM superstore_sales
GROUP BY Discount
ORDER BY Discount
    


--Bu sorgu, farklı kargo türlerinin teslimat performansını analiz ederek ortalama teslimat sürelerini 
--ve sipariş yoğunluklarını ölçmektedir.

SELECT
    Ship_Mode,
	COUNT(Order_ID) AS Total_Orders,
	AVG(DATEDIFF(DAY,Order_Date,Ship_Date)) AS Avg_Delivery_Days
FROM superstore_sales
GROUP BY Ship_Mode



--Bu sorgu, oluşturulan fonksiyon yardımıyla siparişlerin teslimat durumunu hesaplayıp müşteri bilgileriyle birlikte gösterir.
SELECT 
    Order_ID,
	Customer_Name,
	DBO.FN_Get_Shipping_Status(Order_Date,Ship_Date) AS Ship_Status
FROM superstore_sales






