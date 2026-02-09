create table zepto_raw(
sku_id SERIAL PRIMARY KEY,
category VARCHAR(120),
name VARCHAR(150) NOT NULL,
mrp NUMERIC(10,2),
discount_percent NUMERIC(5,2),
available_quantity INTEGER,
discounted_selling_price NUMERIC(10,2),
weight_in_gms INTEGER,
out_of_stock BOOLEAN,
quantity INTEGER
);

-------------------------------------------

CREATE TABLE zepto AS
SELECT *
FROM zepto_raw
WHERE mrp > 0;

--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) FROM zepto_raw;
SELECT * FROM zepto_raw LIMIT 5;



-------------------------------data exploration-------------------------------

--count of rows
SELECT COUNT(*) FROM zepto;

--null values
SELECT * FROM zepto
WHERE name IS NULL
OR
category IS NULL
OR
mrp IS NULL
OR
discountPercent IS NULL
OR
discountedSellingPrice IS NULL
OR
weightInGms IS NULL
OR
availableQuantity IS NULL
OR
outOfStock IS NULL
OR
quantity IS NULL;

--
ALTER TABLE zepto
RENAME COLUMN discountPerfect TO discountPercent;

--sample data
SELECT * FROM zepto
LIMIT 10;

--different product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

--products in stock vs out of stock
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

--product names present multiple times
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING count(sku_id) > 1
ORDER BY count(sku_id) DESC;

--------------------------------data cleaning--------------------------------

--products with price = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

--convert paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
discountedSellingPrice = discountedSellingPrice / 100.0;

SELECT mrp, discountedSellingPrice FROM zepto;


--------------------------------data analysis--------------------------------

-- Q1. Find the top 10 best-value products based on the discount percentage.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

--Q2.What are the Products with High MRP but Out of Stock

SELECT DISTINCT name,mrp
FROM zepto
WHERE outOfStock = TRUE and mrp > 300
ORDER BY mrp DESC;

--Q3.Calculate Estimated Revenue for each category
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue;

-- Q4. Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;

-- Q5. Identify the top 5 categories offering the highest average discount percentage.
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q6. Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

--Q7.Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 5000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

--Q8.What is the Total Inventory Weight Per Category 
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;



---------------------------REVENUE AND PROFITABILITY FOCUS:-------------------------------

--Q9.Which product categories contribute the highest potential revenue, and how does discounting impact that revenue?
SELECT 
    category,
    SUM(mrp * quantity) AS revenue_without_discount,
    SUM(discountedSellingPrice * quantity) AS revenue_after_discount,
    SUM((mrp - discountedSellingPrice) * quantity) AS revenue_lost_due_to_discount
FROM zepto
GROUP BY category
ORDER BY revenue_after_discount DESC;


--Q10.Identify the top 10 products generating the highest revenue after discounts. Are they concentrated in specific categories?
SELECT 
    name,
    category,
    discountedSellingPrice * quantity AS revenue
FROM zepto
ORDER BY revenue DESC
LIMIT 10;


--Q12.Compare full-price vs discounted revenue to understand how much revenue is sacrificed due to promotions.
SELECT 
    SUM(mrp * quantity) AS full_price_revenue,
    SUM(discountedSellingPrice * quantity) AS discounted_revenue,
    SUM(mrp * quantity) - SUM(discountedSellingPrice * quantity) AS total_revenue_lost
FROM zepto;



-------------------------------Inventory & Supply Chain Insights:---------------------------------

--Q13.Which categories have the highest inventory weight but low sales quantity, indicating potential overstocking?
SELECT 
    category,
    SUM(weightInGms * availableQuantity) AS total_inventory_weight,
    SUM(quantity) AS total_sales_quantity
FROM zepto
GROUP BY category
ORDER BY total_inventory_weight DESC;

--Q14.Identify products that are frequently out of stock but have high demand signals (high discount + low availability).
SELECT 
    name,
    category,
    discountPercent,
    availableQuantity
FROM zepto
WHERE outOfStock = TRUE
ORDER BY discountPercent DESC;

--Q15.Which categories have the highest risk of inventory blockage due to low turnover?
SELECT 
    category,
    SUM(quantity) / NULLIF(SUM(availableQuantity), 0) AS inventory_turnover_ratio
FROM zepto
GROUP BY category
ORDER BY inventory_turnover_ratio ASC;

--Q16.Estimate lost revenue due to out-of-stock items.
SELECT 
    category,
    SUM(discountedSellingPrice * quantity) AS estimated_lost_revenue
FROM zepto
WHERE outOfStock = TRUE
GROUP BY category
ORDER BY estimated_lost_revenue DESC;


---------------------------------Pricing & Discount Strategy:---------------------------------

--Q17.Which categories offer the highest average discount but do not translate into proportional revenue gains?
SELECT 
    category,
    AVG(discountPercent) AS avg_discount,
    SUM(discountedSellingPrice * quantity) AS revenue
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC;

--Q18.Are high-MRP products receiving excessive discounts compared to low-MRP products?
SELECT 
    CASE 
        WHEN mrp >= 500 THEN 'High MRP'
        ELSE 'Low MRP'
    END AS price_segment,
    AVG(discountPercent) AS avg_discount
FROM zepto
GROUP BY price_segment;

--Q19.Find products where discounts are applied but sales quantity remains low — indicating ineffective promotions.
SELECT 
    name,
    category,
    discountPercent,
    quantity
FROM zepto
WHERE discountPercent > 0
ORDER BY quantity ASC;

--Q20.What is the optimal discount range that maximizes revenue without heavy margin erosion?
SELECT 
    CASE 
        WHEN discountPercent < 10 THEN 'Low Discount'
        WHEN discountPercent BETWEEN 10 AND 20 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_range,
    SUM(discountedSellingPrice * quantity) AS revenue
FROM zepto
GROUP BY discount_range
ORDER BY revenue DESC;


-------------------------------Customer Value & Product Optimization-------------------------------

--Q21.Which products provide the best value for money based on price per gram after discount?
SELECT 
    name,
    category,
    discountedSellingPrice,
    weightInGms,
    discountedSellingPrice / weightInGms AS price_per_gram
FROM zepto
WHERE weightInGms > 0
ORDER BY price_per_gram ASC;

--Q22.Segment products into value tiers (Low, Medium, Premium) based on discounted price and analyze customer exposure.
SELECT 
    name,
    category,
    discountedSellingPrice,
    CASE 
        WHEN discountedSellingPrice < 100 THEN 'Low'
        WHEN discountedSellingPrice BETWEEN 100 AND 300 THEN 'Medium'
        ELSE 'Premium'
    END AS price_tier
FROM zepto;

--Q23.Which categories offer bulk products but fail to deliver competitive per-gram pricing?
SELECT 
    name,
    category,
    weightInGms,
    discountedSellingPrice,
    discountedSellingPrice / weightInGms AS price_per_gram
FROM zepto
WHERE weightInGms >= 1000
ORDER BY price_per_gram DESC;

--Q24.Which categories offer the best consumer value overall?
SELECT 
    category,
    AVG(discountedSellingPrice / weightInGms) AS avg_price_per_gram
FROM zepto
WHERE weightInGms > 0
GROUP BY category
ORDER BY avg_price_per_gram ASC;


---------------------------------Operational & Strategic Analysis:---------------------------------

--Q25.Which categories should be prioritized for restocking based on revenue potential and current availability?
SELECT 
    category,
    SUM(discountedSellingPrice * quantity) AS revenue,
    COUNT(*) AS available_products
FROM zepto
GROUP BY category
ORDER BY revenue DESC, available_products ASC;

--Q26.Identify underperforming categories that consume inventory space but contribute minimal revenue.
SELECT 
    category,
    COUNT(*) AS product_count,
    SUM(discountedSellingPrice * quantity) AS revenue
FROM zepto
GROUP BY category
ORDER BY revenue ASC, product_count DESC;

--Q27.Which products could be candidates for price optimization or removal from catalog based on performance metrics?
SELECT 
    name,
    category,
    mrp,
    discountPercent,
    quantity,
    (discountedSellingPrice * quantity) AS revenue
FROM zepto
ORDER BY revenue ASC;




---------------------------------Advanced Analytical Angles:---------------------------------

--Q28.Built a simple demand proxy score using stock, discount, and price.
SELECT 
    name,
    category,
    discountPercent,
    availableQuantity,
    discountedSellingPrice,
    (discountPercent * 0.4 +
     (1/NULLIF(availableQuantity,0)) * 0.3 +
     (1/discountedSellingPrice) * 0.3) AS demand_score
FROM zepto
ORDER BY demand_score DESC;

--Q29.Detect anomalies in pricing or discount patterns.
--Step 1: Calculate value:
WITH cat_avg AS (
    SELECT category, AVG(discountedSellingPrice) avg_price
    FROM zepto
    GROUP BY category
)

--Step 2: Competitiveness score:
SELECT z.*
FROM zepto z
JOIN cat_avg c ON z.category = c.category
WHERE z.discountedSellingPrice > 2 * c.avg_price
   OR z.discountedSellingPrice < 0.5 * c.avg_price;

--Q30.Create a product competitiveness index (value vs availability).
SELECT *,
discountedSellingPrice / weightInGms AS price_per_gram
FROM zepto;

SELECT *,
(1/price_per_gram)*0.5 +
(discountPercent/100)*0.3 +
(LOG(availableQuantity+1))*0.2 AS competitiveness_index
FROM your_table;

--Q31.Identify candidate products for price optimization.
WITH cat_avg AS (
    SELECT category, AVG(discountedSellingPrice) avg_price
    FROM zepto
    GROUP BY category
)

SELECT z.*
FROM zepto z
JOIN cat_avg c ON z.category = c.category
WHERE z.discountPercent < 10
AND z.discountedSellingPrice > c.avg_price
AND z.availableQuantity > 50;

--Q32.Simulate revenue impact if discounts change by ±5%.
SELECT
    name,
    discountedSellingPrice * availableQuantity AS current_revenue,

    (discountedSellingPrice * 0.95) * availableQuantity AS revenue_if_5pct_more_discount,

    (discountedSellingPrice * 1.05) * availableQuantity AS revenue_if_less_discount
FROM zepto
