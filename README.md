# NorthWind Database (Part 2)

Actualmente nuestro projecto sigue con el proposito inicialdo en la parte 1 de la base de datos NorthWind, el cual busca practicar conceptos y llevar a cabo multiples tipos de ejercicios. Para este caso particular, trabajare con views, index, transactions y user-defined funcitions (UDF).

Y como se hablo anteriormente en el projecto NorthWind Part 1, nuestra estructura de base de datos es tipy snowflake, donde nuestra fact table es "order_details" table y las demas son dimensional tables.

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

En la solitud se nos anima a realizar una view table, la cual agrupa el numero de empleados basado en las regiones y territorios comprendidos en la
