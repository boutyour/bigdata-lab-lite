from pyspark.sql import SparkSession
from pyspark.sql import functions as F

spark = (
    SparkSession.builder
    .appName("TP07-Hive-Spark-Parquet")
    .master("local[2]")
    .config("spark.driver.memory", "1g")
    .config("spark.sql.shuffle.partitions", "4")
    .getOrCreate()
)

path = "hdfs://hadoop:9000/user/hive/warehouse/tp_bigdata.db/sales_parquet"
df = spark.read.parquet(path)

print("Schema lu depuis le Parquet produit par Hive:")
df.printSchema()

result = (
    df.groupBy("category")
      .agg(F.count("*").alias("n"), F.round(F.sum("amount"), 2).alias("revenue"))
      .orderBy(F.desc("revenue"))
)
result.show(truncate=False)

assert df.count() > 0, "Le jeu de données Hive/Parquet est vide"
spark.stop()
