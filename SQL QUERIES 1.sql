-- 	CREATE TABLE dim_product (
-- 	product_key INT AUTO_INCREMENT PRIMARY KEY,
-- 	product_name VARCHAR(100),
-- 	product_category VARCHAR(50),
-- 	unit_price DECIMAL(10,2)
-- 	);
-- INSERT INTO dim_product (product_name, product_category, unit_price)
-- SELECT DISTINCT
--     Product_Name,
--     Product_category,
--     Unit_price
-- FROM sales_raw_1500_records;

-- 	select * from dim_product;

-- CREATE TABLE dim_date (
--	date_key INT AUTO_INCREMENT PRIMARY KEY,
--	order_date DATE,
--	year INT,
--	month INT,
--	day INT,
--	quarter INT
--	);
--	INSERT INTO dim_date (order_date, year, month, day, quarter)
--	SELECT DISTINCT
--	STR_TO_DATE(Order_Date, '%d-%m-%Y') AS order_date,
--	YEAR(STR_TO_DATE(Order_Date, '%d-%m-%Y')),
--	MONTH(STR_TO_DATE(Order_Date, '%d-%m-%Y')),
--	DAY(STR_TO_DATE(Order_Date, '%d-%m-%Y')),
--	QUARTER(STR_TO_DATE(Order_Date, '%d-%m-%Y'))
--	FROM sales_raw_1500_records
--	WHERE Order_Date IS NOT NULL;

-- CREATE TABLE dim_region (
-- 	region_key INT AUTO_INCREMENT PRIMARY KEY,
-- 	region VARCHAR(50)
-- 	);
-- INSERT INTO dim_region (region)
-- SELECT DISTINCT Region
-- FROM sales_raw_1500_records;

-- CREATE TABLE dim_payment (
--	payment_key INT AUTO_INCREMENT PRIMARY KEY,
--	payment_method VARCHAR(50)
--	);
-- INSERT INTO dim_payment (payment_method)
-- SELECT DISTINCT Payment_method
-- FROM sales_raw_1500_records;

-- CREATE TABLE dim_sales_person (
--	sales_person_key INT AUTO_INCREMENT PRIMARY KEY,
--	sales_person VARCHAR(100)
--	);
-- INSERT INTO dim_sales_person (sales_person)
-- SELECT DISTINCT Sales_person
-- FROM sales_raw_1500_records;

-- CREATE TABLE fact_sales (
--     sales_key INT AUTO_INCREMENT PRIMARY KEY,
--     customer_key INT,
--     product_key INT,
--     date_key INT,
--     region_key INT,
--     payment_key INT,
--     sales_person_key INT,
--     quantity INT,
--     discount DECIMAL(5,2),
--     revenue DECIMAL(10,2),

--     FOREIGN KEY (customer_key) REFERENCES dim_customer(customer_key),
--     FOREIGN KEY (product_key) REFERENCES dim_product(product_key),
--     FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
--     FOREIGN KEY (region_key) REFERENCES dim_region(region_key),
--     FOREIGN KEY (payment_key) REFERENCES dim_payment(payment_key),
--     FOREIGN KEY (sales_person_key) REFERENCES dim_sales_person(sales_person_key)
-- );

-- INSERT INTO fact_sales (
--     customer_key,
--     product_key,
--     date_key,
--     region_key,
--     payment_key,
--     sales_person_key,
--     quantity,
--     discount,
--     revenue
-- )
-- SELECT
--     dc.customer_key,
--     dp.product_key,
--     dd.date_key,
--     dr.region_key,
--     dpay.payment_key,
--     dsp.sales_person_key,
--     s.Quantity,
--     s.Discount,
--     s.Revenue
-- FROM sales_raw_1500_records s
-- JOIN dim_customer dc 
--     ON s.Customer_name = dc.customer_name
-- JOIN dim_product dp 
--     ON s.Product_Name = dp.product_name
-- JOIN dim_date dd 
--     ON STR_TO_DATE(s.Order_Date, '%d-%m-%Y') = dd.order_date
-- JOIN dim_region dr 
--     ON s.Region = dr.region
-- JOIN dim_payment dpay 
--     ON s.Payment_method = dpay.payment_method
-- JOIN dim_sales_person dsp 
--     ON s.Sales_person = dsp.sales_person;

-- SELECT COUNT(*) FROM fact_sales;
SELECT * FROM fact_sales;

CREATE TABLE clean_sales AS
SELECT
    Order_ID,

    -- Convert date format (DD-MM-YYYY → DATE)
    STR_TO_DATE(Order_Date, '%d-%m-%Y') AS Order_Date,

    -- Standardize text
    UPPER(TRIM(Customer_name)) AS Customer_name,
    UPPER(TRIM(Region)) AS Region,
    UPPER(TRIM(Sales_person)) AS Sales_person,
    UPPER(TRIM(Product_category)) AS Product_category,
    UPPER(TRIM(Product_Name)) AS Product_Name,

    -- Handle NULLs
    IFNULL(Quantity, 0) AS Quantity,
    IFNULL(Unit_price, 0) AS Unit_price,
    IFNULL(Discount, 0) AS Discount,
    IFNULL(Revenue, 0) AS Revenue,

    UPPER(TRIM(Payment_method)) AS Payment_method,
    UPPER(TRIM(Delivery_status)) AS Delivery_status

FROM sales_raw_1500_records;



SELECT Order_ID, COUNT(*)
FROM clean_sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;
