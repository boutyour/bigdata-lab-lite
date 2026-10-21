CREATE DATABASE IF NOT EXISTS tp_bigdata;
USE tp_bigdata;

DROP TABLE IF EXISTS sales_csv;
CREATE EXTERNAL TABLE sales_csv (
  id INT,
  product STRING,
  category STRING,
  amount DOUBLE
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE
LOCATION '/tp/hive/sales'
TBLPROPERTIES ('skip.header.line.count'='1');

SELECT category,
       COUNT(*) AS nb_sales,
       ROUND(SUM(amount), 2) AS revenue
FROM sales_csv
GROUP BY category
ORDER BY revenue DESC;

DROP TABLE IF EXISTS sales_parquet;
CREATE TABLE sales_parquet
STORED AS PARQUET
AS SELECT * FROM sales_csv;

SELECT COUNT(*) AS rows_in_parquet FROM sales_parquet;
