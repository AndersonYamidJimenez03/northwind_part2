/*
    Creation of view for the amount of employees by region
    and territory
*/

-- Check if the view already exists
DROP VIEW IF EXISTS SalesBySupplierCountry;

-- SalesBySupplierCountry view table definition
CREATE OR REPLACE VIEW SalesBySupplierCountry  AS
SELECT s.country AS Country, s.city AS City, SUM(od.unitprice * od.quantity)::money TotalSales
FROM suppliers s
JOIN products p ON s.supplierid = p.supplierid
JOIN orders_details od ON p.productid = od.productid
GROUP BY s.country, s.city
ORDER BY TotalSales DESC;

-- invoking the table view "SalesBySupplierCountry".
SELECT * FROM SalesBySupplierCountry;

/*
    Quantity of products bought by product name,
    category and year
*/
-- Check if the view already exists
DROP VIEW IF EXISTS quantityByProductCategoryYear;

-- quantityByProductCategoryYear view table definition
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

-- invoking the table view "quantityByProductCategoryYear".
SELECT * FROM quantityByProductCategoryYear;


/*
    Creation index in product name
*/

-- Implementation of the index in productname column
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
/*
 Generate a user-defined function to calculate the discount that will be applied to a product, thanks to its price and discount percentage.
*/
-- Check if the fuction already exists
DROP FUNCTION IF EXISTS Discount (percentage DECIMAL(5,2), value INT);

-- "Discount" function definition (header and body)
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

-- invoking the function "Discount".
SELECT Discount(0.50, 1000) AS TotalDiscount;

/*
    Create a user-defined function that returns a table with customers from a given country.
*/
-- Check if the fuction already exists
DROP FUNCTION IF EXISTS filterCustomerCountry(
    country_ varchar(20)
)

-- "filterCustomerCountry" function definition (header and body)
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

-- invoking the function "filterCustomerCountry".
SELECT * FROM filterCustomerCountry('UK');


/*
    Generate a user-defined function that returns a table grouped by country, city and number of orders requested by country requested.
*/


-- Check if the fuction already exists
DROP FUNCTION IF EXISTS ordersSummarizeByCountry(varchar(20));

-- "ordersSummarizeByCountry" function definition (header and body)
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

-- invoking the function "ordersSummarizeByCountry".
SELECT * FROM ordersSummarizeByCountry('France');


