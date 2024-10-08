/*
    Creation of view for the amount of employees by region
    and territory
*/


CREATE VIEW employeeByRegionTerritory AS
SELECT r.regiondescription, t.territorydescription, COUNT(*)
FROM regions r
JOIN territories t ON r.regionid = t.regionid
GROUP BY r.regiondescription, t.territorydescription
ORDER BY r.regiondescription, t.territorydescription


/*
    Quantity of products bought by product name,
    category and year
*/

CREATE OR REPLACE VIEW quantityByProductCategoryYear AS
SELECT 
    Extract(YEAR FROM o.orderdate) AS Year_of_order, 
    c.categoryname AS Category_Name, 
    p.productname AS Product_Name,
    SUM(od.quantity) AS Quantity
FROM orders o
JOIN orders_details od ON o.orderId = od.orderId
JOIN products p ON od.productId = p.productId
JOIN categories c ON p.categoryId = c.categoryId
GROUP BY Year_of_order, c.categoryname, p.productname
ORDER BY Year_of_order, Category_Name;

SELECT * FROM quantityByProductCategoryYear;


/*
    Creation index in product name
*/

CREATE INDEX productNameIndex
ON products (productname);

/*
    Transactions
*/

SELECT * FROM products;

BEGIN TRANSACTION;
UPDATE products
SET unitprice = 19
WHERE productId = 1;

SELECT productId, unitprice
FROM products;

-- COMMIT in case the save the changes
ROLLBACK TRANSACTION;


SELECT productId, unitprice
FROM products;


