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
    Transaction for practice, and see the rollback
    keyword in action in the database.

*/

BEGIN TRANSACTION;
UPDATE products
SET unitprice = 19
WHERE productId = 1;

-- Here, I check the update transaction
SELECT productId, unitprice
FROM products;

-- COMMIT in case the save the changes
ROLLBACK TRANSACTION;
/*
    At the end, i can see that with the ROLLBACK,
    the database continue the same.
*/
SELECT productId, unitprice
FROM products;


-- FUNCTIONS

/*
    Las funciones siempre deben devolver un valor, ya sea escalar o una tabla.
    Las funciones no pueden realizar modificationes a la 
    base de datos, por lo tanto no pueden usar ciertos
    clausulas (update, delete, insert)
*/

-- Function que retorna un escalar

CREATE OR REPLACE FUNCTION Discount(
    percentage DECIMAL(5,2),
    value INT
)
RETURNS DECIMAL(10,2)
AS
$$
BEGIN
    RETURN (percentage * value);
END;
$$ LANGUAGE plpgsql;

SELECT Discount(0.50, 1000) AS TotalDiscount;

-- Function que retorna una tabla

CREATE OR REPLACE FUNCTION filterCustomerCountry(
    country_ varchar(20)
)
RETURNS TABLE(
    customerId varchar(10),
    companyname varchar(40),
    contactname varchar(30),
    contacttitle varchar(30),
    city varchar(20),
    region varchar(20),
    postalcode varchar(15),
    country varchar(20),
    phone varchar(20),
    fax varchar(20)
)
AS
$$
BEGIN
    RETURN QUERY
        SELECT *
        FROM customers
        WHERE customers.country = country_;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM filterCustomerCountry('UK');


-- Function que returna tabla

SELECT * FROM orders;
DROP FUNCTION IF EXISTS ordersSummarizeByCountry(varchar(20));
CREATE OR REPLACE FUNCTION ordersSummarizeByCountry(
    country_ varchar(20)
)
RETURNS TABLE(
    shipcountry varchar(50),
    shipcity varchar(50),
    order_qty INT
)
AS
$$
BEGIN
    RETURN QUERY
        SELECT o.shipcountry, o.shipcity, COUNT(*)::INT AS order_qty
        FROM orders o
        WHERE o.shipcountry = country_
        GROUP BY o.shipcountry, o.shipcity
        ORDER BY order_qty DESC;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM ordersSummarizeByCountry('France');


