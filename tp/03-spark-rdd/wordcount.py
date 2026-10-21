from pyspark.sql import SparkSession

spark = (SparkSession.builder.appName("TP03-RDD-WordCount")
         .master("local[2]")
         .config("spark.driver.memory", "1536m")
         .config("spark.sql.shuffle.partitions", "4")
         .getOrCreate())
try:
    sc = spark.sparkContext
    lines = sc.textFile("file:///workspace/datasets/words.txt")
    counts = dict(lines.flatMap(lambda x: x.split())
                  .map(lambda w: (w, 1)).reduceByKey(lambda a, b: a + b)
                  .collect())
    print('RDD counts:', counts)
    assert counts == {'hadoop': 3, 'spark': 4, 'bigdata': 2,
                      'hdfs': 1, 'yarn': 1, 'sql': 1}
    print('PASS: Spark RDD WordCount')
finally:
    spark.stop()
