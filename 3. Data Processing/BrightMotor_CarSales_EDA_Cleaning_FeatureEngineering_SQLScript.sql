-- Databricks notebook source
-------------------------------------------------------------------------
---1. DATA EXPLORATION
-------------------------------------------------------------------------
--- SNAPSHOT OF DATA
SELECT * 
FROM `workspace`.`default`.`car_sales_data` 
LIMIT 100;

--- HOW BIG IS MY DATASET
SELECT COUNT(*) AS total_rows
FROM `workspace`.`default`.`car_sales_data`;
---# rows: 558811

--- CHECKING FOR DUPLICATES (BASED ON VIN)
SELECT vin, COUNT(*) AS duplicate_count
FROM `workspace`.`default`.`car_sales_data`
GROUP BY vin
HAVING duplicate_count > 1;
--- over 1000 vin duplicates 

--- CHECKING FOR NULL VALUES
SELECT COUNT(*) - COUNT(year) AS missing_year,
       COUNT(*) - COUNT(make) AS missing_make,
       COUNT(*) - COUNT(model) AS missing_model,
       COUNT(*) - COUNT(trim) AS missing_trim,
       COUNT(*) - COUNT(body) AS missing_body,
       COUNT(*) - COUNT(transmission) AS missing_transmission,
       COUNT(*) - COUNT(vin) AS missing_vin,
       COUNT(*) - COUNT(state) AS missing_state,
       COUNT(*) - COUNT(condition) AS missing_condition,
       COUNT(*) - COUNT(odometer) AS missing_odometer,
       COUNT(*) - COUNT(color) AS missing_color,
       COUNT(*) - COUNT(interior) AS missing_interior,
       COUNT(*) - COUNT(seller) AS missing_seller,
       COUNT(*) - COUNT(mmr) AS missing_mmr,
       COUNT(*) - COUNT(sellingprice) AS missing_sellingprice,
       COUNT(*) - COUNT(saledate) AS missing_saledate
FROM `workspace`.`default`.`car_sales_data`;
--- make: 10301; model:10399; trim: 10651; body: 13195; transmission: 65352; condition: 11794; odometer: 94; color: 749; interior: 749; mmr: 12; sellingprice: 12; saledate: 12

--- EXPLORE RANGE OF SELLING PRICE
SELECT 
    MIN(sellingprice) AS min_price,
    MAX(sellingprice) AS max_price,
    AVG(sellingprice) AS avg_price
FROM `workspace`.`default`.`car_sales_data`;
--- min_price: 1; max_price: 230000; avg_price:13611.3562

--- EXPLORE RANGE OF ODOMETER VALUES
SELECT 
    MIN(odometer) AS min_odometer,
    MAX(odometer) AS max_odometer,
    AVG(odometer) AS avg_odometer
FROM `workspace`.`default`.`car_sales_data`;
--- min_odometer: 1; max_odometer: 999999; avg_odometer: 68323.19579679874


--- DISTRIBUTION BY MAKE
SELECT make, 
       COUNT(*) AS total_sales
FROM `workspace`.`default`.`car_sales_data`
GROUP BY make
ORDER BY total_sales DESC;

--- DISTRIBUTION BY STATE (REGION)
SELECT state, 
       COUNT(*) AS total_sales
FROM `workspace`.`default`.`car_sales_data`
GROUP BY state
ORDER BY total_sales DESC;

--- DISTINCT BODY (FOR FUEL TYPE DETERMINATION)
SELECT DISTINCT body, 
       COUNT(*) AS total_sales
FROM `workspace`.`default`.`car_sales_data`
GROUP BY body
ORDER BY total_sales DESC;


-------------------------------------------------------------------------
---2. DATA CLEANING
-------------------------------------------------------------------------
SELECT DISTINCT
        CAST(year AS INT) AS year, --- CAST converts string into integer
        COALESCE(INITCAP(TRIM(make)), 'unknown') AS make, --- "TRIM" removes any extra spaces at the beginning and end of the string; "INITCAP" converts the first letter of each word to uppercase and the rest to lowercase; COALESCE is used to replace NULL values with 'Unknown

        COALESCE(INITCAP(TRIM(model)), 'unknown') AS model,

        COALESCE(INITCAP(TRIM(trim)), 'unknown') AS trim,

        COALESCE(INITCAP(TRIM(body)), 'unknown') AS body,

        COALESCE(LOWER(TRIM(transmission)), 'unknown') AS transmission,

        TRIM(vin) AS vin,

        UPPER(TRIM(state)) AS region, --- "UPPER" converts the string to uppercase

        COALESCE( 
            CAST(condition AS INT),
            (SELECT percentile_approx(condition, 0.5)  
                 FROM workspace.default.car_sales_data
                 WHERE condition IS NOT NULL     --- replaces the NULL values with the median of the non-NULL values | calculated median value in a sub-query
            )
                ) AS condition,


        COALESCE(
            CAST(odometer AS INT),
            (
                SELECT CAST(AVG(odometer) AS INT)
                FROM workspace.default.car_sales_data
                WHERE odometer IS NOT NULL
            )
        ) AS odometer,
        
        CASE 
            WHEN TRIM(color) IS NULL OR TRIM(color) = '-' THEN 'unknown'
            ELSE TRIM(color)
        END AS color,

        CASE 
            WHEN TRIM(interior) IS NULL OR TRIM(interior) = '-' THEN 'unknown'
            ELSE TRIM(interior)
        END AS interior,

        TRIM(seller) AS seller,

        CAST(mmr AS DOUBLE) AS mmr,

        CAST(sellingprice AS DOUBLE) AS sellingprice,

        saledate

FROM workspace.default.car_sales_data

--- dropping the below NULL values; there's only 12 rows (which is less than 1% of the total dataset), replacing them might skew or inflate the figures
WHERE mmr IS NOT NULL --- this is an estimated value on a specific make and model, can't use average mmr as a replacement
      AND sellingprice IS NOT NULL --- replacing it could distort total revenue, profit, price distributions (have different makes and models, can't use average price as a replacement)
      AND saledate IS NOT NULL
      AND vin IS NOT NULL; --- vin is a unique identifier, replacing it would make it harder to detect duplicated


-------------------------------------------------------------------------
---3. FEATURE ENGINEERING 
-------------------------------------------------------------------------
SELECT
    -- REVENUE
    sellingprice AS total_revenue, --- there's no "number of units" columns, assumes each row = 1 car sold so revenue = selling price

    -- PROFIT
    (sellingprice - mmr) AS profit, --- mmr is the market value of the car, assuming it approx cost of the car

    ROUND(                                               --- round() specifies number of decimal places
        ((sellingprice - mmr) / sellingprice) * 100,
        2
    ) AS profit_margin,

    -- MARGIN TIERS
    CASE
        WHEN ((sellingprice - mmr) / sellingprice) * 100 > 20 THEN 'High Margin'
        WHEN ((sellingprice - mmr) / sellingprice) * 100 BETWEEN 10 AND 20 THEN 'Medium Margin'
        ELSE 'Low Margin'
    END AS profit_tier,

    -- CAR AGE
    YEAR(CURRENT_DATE()) - year AS car_age, 

    -- MILEAGE CATEGORY
    CASE
        WHEN odometer < 30000 THEN 'Low Mileage'
        WHEN odometer BETWEEN 30000 AND 80000 THEN 'Medium Mileage'
        WHEN odometer BETWEEN 80001 AND 150000 THEN 'High Mileage'
        ELSE 'Very High Mileage'
    END AS mileage_category,

    -- PRICE BANDS
    CASE
        WHEN sellingprice < 10000 THEN 'Budget'
        WHEN sellingprice BETWEEN 10000 AND 25000 THEN 'Mid Range'
        WHEN sellingprice BETWEEN 25001 AND 50000 THEN 'Premium'
        ELSE 'Luxury'
    END AS price_band,

    -- TIME FEATURE
    -- SALE YEAR
    YEAR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) AS sale_year, ---without "substring" get error; substring starts reading the string from the 5th character; "TO_TIMESTAMP" converts the string to a timestamp

    -- SALE MONTH (NUMBER)
    MONTH(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) AS sale_month_number,

    -- SALE MONTH NAME
    DATE_FORMAT(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss'),'MMMM') AS sale_month_name,

    -- SALE QUARTER
    QUARTER(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) AS sale_quarter,

    -- DAY NAME
    DATE_FORMAT(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss'),'EEEE') AS day_name,

    -- TIME OF SALE
    DATE_FORMAT(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss'),'HH:mm:ss') AS time_of_sale,

    -- TIME BUCKET
    CASE
        WHEN HOUR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) BETWEEN 0 AND 5 THEN 'Morning'
        WHEN HOUR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_bucket,

    -- DAY CLASSIFICATION
    CASE
        WHEN DATE_FORMAT(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss'),'E') IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_classification,

    -- VEHICAL TYPE SEGMENTATION --- not given fuel type, however the type of vehicle can be used to proxy fuel type (i.e. passenger car tend to skew towards petrol)
    CASE
        WHEN LOWER(body) IN (
            'sedan','coupe','convertible','hatchback','wagon',
            'g sedan','g coupe','g convertible',
            'genesis coupe','koup','cts coupe',
            'elantra coupe','tsx sport wagon',
            'cts-v coupe','g37 coupe','g37 convertible',
            'q60 coupe','q60 convertible',
            'granturismo convertible','beetle convertible',
            'cts wagon','cts-v wagon'
        ) THEN 'Passenger'

        WHEN LOWER(body) IN (
            'suv','minivan','van','e-series van',
            'transit van','ram van','promaster cargo van'
        ) THEN 'Utility'

        WHEN LOWER(body) IN (
            'crew cab','supercrew','supercab','regular cab',
            'extended cab','quad cab','double cab',
            'crewmax cab','king cab','mega cab',
            'access cab','club cab','xtracab',
            'cab plus','cab plus 4','regular-cab'
        ) THEN 'Truck'

        ELSE 'Other'
    END AS vehicle_segment


FROM workspace.default.car_sales_data;
