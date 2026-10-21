from pyspark.sql import SparkSession, functions as F

spark = (SparkSession.builder.appName("TP04-Spark-SQL")
         .master("local[2]")
         .config("spark.driver.memory", "1536m")
         .config("spark.sql.shuffle.partitions", "4")
         .getOrCreate())
try:
    df = spark.read.option("header", True).option("inferSchema", True).csv(
        "/workspace/datasets/sales.csv")
    result = df.groupBy('city').agg(F.sum('amount').alias('total')).orderBy('city')
    result.show(truncate=False)
    actual = {r['city']: r['total'] for r in result.collect()}
    assert actual == {'Casablanca': 530, 'Fes': 820, 'Rabat': 480}, actual
    print('PASS: Spark SQL aggregations')
finally:
    spark.stop()
