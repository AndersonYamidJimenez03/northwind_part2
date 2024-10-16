# NorthWind Database (Part 2)

Currently, our project continues with the initial purpose set out in Part 1 of the Northwind database, which aims to practice concepts and carry out multiple types of exercises. For this particular case, I will work with views, indexes, transactions, and user-defined functions (UDF).

As previously mentioned in the Northwind Project Part 1, our database structure is a snowflake type, where our fact table is the "order_details" table, and the others are dimensional tables.

### The questions I wanted to answer with SQL Queries were:

1. Present a view table, for the amount of employees by region and territory.
2. Show the quantity of products bought by product name, category and year and store it in a view table.
3. Create an index in product name column.
4. Show how to avoid unwanted changes can be managed thanks to the keyword "rollback" in the context of SQL transactions.
5. Generate a user-defined function to calculate the discount that will be applied to a product, thanks to its price and discount percentage.
6. Create a user-defined function that returns a table with customers from a given country.
7. Generate a user-defined function that returns a table grouped by country, city and number of orders requested.

# Tools I used

These are the tools were used in this analysis:

- **SQL**: It is the central tool for analysis, where DML (Data Manipulation Language) queries were used to query the database. DDL (Data Definition Language) was also generated to create the database, tables, and constraints.
- **PostgreSQL**: This was the chosen database management system for database creation, and its versatility enabled a strong connection with Visual Studio Code.
- **Visual Studio Code**: This is the most widely used code editor currently, and due to its high customizability, it was selected as the tool for writing queries.
- **Git & GitHub**: These tools were used in the project as version control applications, allowing for both local and remote storage and management of the project.

# Analysis

In this second part of the project, I will work with the other tables in the database that were not used in Part 1. I refer to the tables as region, territory, product and category. Just like other tables already used like customer, order, order_detail.

### 1. Present a view table, for the amount of employees by region and territory.

In the task, we are encouraged to create a view table that groups the total value of products sold based on the supplier's country and city.

```SQL
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
```

In the previous query, the process begins by validating the view table's name, followed by querying the database by performing joins to denormalize the tables suppliers, products, and orders_details. Finally, the data is grouped by the supplier's country and city, and the query ends with a descending sort to highlight the highest values by country and city.

### 2. Show the quantity of products bought by product name, category and year and store it in a view table.

We are tasked with creating a view table for future queries that shows the number of products sold, classified by year of sale, category, and product name. This task will require performing joins on the following tables: categories, products, orders_details, and orders.

```sql
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
```

The required query was carried out by utilizing joins and leveraging the relationships and cardinality between the dimensional tables and the fact table. This allowed us to sum the quantity of products sold in each year, category, and product. Finally, the data is ordered first by year and then by category.

### 3. Create an index in product name column.

Indexes are created to improve query efficiency for specific columns, where an index is generated to help the search engine by indicating where to find each of the searched elements. In our case, an index is created for the "productname" column belonging to the "products" table.

```sql
-- Implementation of the index in productname column
CREATE INDEX productNameIndex
ON products (productname);
```

The index is quite simple, however, its incorporation can significantly change the query response time. And although it optimizes queries, it also has a memory cost, which means it should only be used on columns that are frequently queried.

### 4. Show how to avoid unwanted changes can be managed thanks to the keyword "Rollback" in the context of SQL transactions.

In this demand, the use of the keyword "Rollback" is requested, which is used in transactions alongside keywords like: Begin, Commit, and Savepoint. These keywords implement ACID properties in a relational database system.

```sql
-- Transaction's start
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
```

In the executed transaction, an update of the product value with Id equal to 1 is performed, and the change is visualized with the first select statement. However, using the keyword "Rollback," the changes made in the database are not saved, as can be seen with the last select statement.

It is also worth clarifying that if one intends to save the changes made in the database, the keyword "Commit" should have been used to finalize the transaction.

### 5. Generate a user-defined function to calculate the discount that will be applied to a product, thanks to its price and discount percentage.

In this part, I start with user-defined functions, which are used to perform calculations and return the result of these. For this request, a function called "Discount" will be created to calculate the final value of a product after multiplying its price by the discount percentage.

```sql
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
```

The "Discount" function has as arguments a decimal value that serves as the discount percentage and an integer value that serves as the product value. The function also specifies the type of value to return, performs the calculation, and validates the function with some fictitious values, such as a percentage of 0.50 and a value of $1000, resulting in $500.

### 6. Create a user-defined function that returns a table with customers from a given country.

In this request, a function is needed that takes a text parameter representing a country, and the function should return a table with the customers for the country used as an argument.

```sql
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
```

As requested, the function "filterCustomerCountry" accepts the name of a country; in my case, I chose "UK" to obtain a table with all the customers from that country.

### 7. Generate a user-defined function that returns a table grouped by country, city and number of orders requested by country requested.

Finally, I am going to create a function that will group the number of orders sold by country and city. Additionally, the function filters by country and returns this table.

```sql
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
```

The function "ordersSummarizeByCountry" accepts a required text argument (country) and filters the database using this argument. For this particular case, the country "France" was used to obtain the quantity of products sold summarized by country and city. Finally, it is sorted by quantity from highest to lowest.

# What I learned

In this project, I learned how to create view tables, indexes, transactions, and user-defined functions using PostgreSQL. And not only how to create them, but also in what context they should be used, considering both the advantages and disadvantages of these concepts.

In future projects, I plan to combine these concepts to generate more interrelated queries. For example, a transaction that performs a commit or rollback depending on a certain result returned by a function.

Lastly, I also learned certain nomenclatures to keep in mind when using PostgreSQL in Visual Studio Code.

## Closing Thoughts
