-- Databricks notebook source
SELECT
    year AS manufacturing_year,
    make,
    model,
    trim,
    body,
    transmission,
    vin,
    region,
    condition,
    odometer,
    color,
    interior,
    seller,
    mmr,
    sellingprice,
    saledate,

    -- REVENUE
    sellingprice AS total_revenue,

    -- PROFIT
    (sellingprice - mmr) AS profit, 

    ROUND(((sellingprice - mmr) / sellingprice) * 100, 2) AS profit_margin,

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
    YEAR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) AS sale_year, 

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
        WHEN HOUR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) BETWEEN 0 AND 5 THEN 'Early Morning'
        WHEN HOUR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) BETWEEN 6 AND 11 THEN 'Morning'
        WHEN HOUR(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS time_bucket,

    -- DAY CLASSIFICATION
    CASE
        WHEN DATE_FORMAT(TO_TIMESTAMP(substring(saledate,5), 'MMM dd yyyy HH:mm:ss'),'E') IN ('Sat', 'Sun') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_classification,

    -- VEHICAL TYPE SEGMENTATION 
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

FROM
(
  SELECT DISTINCT
        CAST(year AS INT) AS year, 
        COALESCE(INITCAP(TRIM(make)), 'unknown') AS make,

        COALESCE(INITCAP(TRIM(model)), 'unknown') AS model,

        COALESCE(INITCAP(TRIM(trim)), 'unknown') AS trim,

        COALESCE(INITCAP(TRIM(body)), 'unknown') AS body,

        COALESCE(LOWER(TRIM(transmission)), 'unknown') AS transmission,

        TRIM(vin) AS vin,

        UPPER(TRIM(state)) AS region, 

        COALESCE( 
            CAST(condition AS INT),
            (SELECT percentile_approx(condition, 0.5)  
                 FROM workspace.default.car_sales_data
                 WHERE condition IS NOT NULL  
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
            WHEN TRIM(color) IS NULL OR TRIM(color) = '—' THEN 'unknown'
            ELSE TRIM(color)
        END AS color,

        CASE 
            WHEN TRIM(interior) IS NULL OR TRIM(interior) = '—' THEN 'unknown'
            ELSE TRIM(interior)
        END AS interior,

        TRIM(seller) AS seller,

        CAST(mmr AS DOUBLE) AS mmr,

        CAST(sellingprice AS DOUBLE) AS sellingprice,

        saledate

FROM workspace.default.car_sales_data


WHERE mmr IS NOT NULL 
      AND sellingprice IS NOT NULL 
      AND saledate IS NOT NULL
      AND vin IS NOT NULL
) cleaned_data;

