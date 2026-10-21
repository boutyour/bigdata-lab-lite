"""Only PROFILE=16 or plus; requires running Hadoop and Spark services together."""
from pyspark.sql import SparkSession, functions as F

spark = (SparkSession.builder.appName("TP05-HDFS-Spark")
         .master("local[2]")
         .config("spark.driver.memory", "1536m")
         .config("spark.sql.shuffle.partitions", "4")
         .config("spark.hadoop.fs.defaultFS", "hdfs://hadoop:9000")
         .getOrCreate())
try:
    df = spark.read.option('header', True).option('inferSchema', True).csv(
        'hdfs://hadoop:9000/tp/integration/sales.csv')
    revenue = df.agg(F.sum('amount').alias('total')).first()['total']
    print('Total from HDFS:', revenue)
    assert revenue == 1830, revenue
    print('PASS: Spark reading HDFS')
finally:
    spark.stop()
