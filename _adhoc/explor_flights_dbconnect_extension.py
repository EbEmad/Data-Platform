from pyspark.sql import SparkSession

# Create a SparkSession - not needed with latest VS Code extension
# spark = SparkSession.builder \
#     .getOrCreate()

# Connect to Unity Catalog using catalog main
spark.sql("""Select WeatherDelay, NASDelay, SecurityDelay, LateAircraftDelay, IsArrDelayed 
from main.dustinvannoy_dev.flights_raw 
where WeatherDelay != 'NA' or NASDelay != 'NA' or SecurityDelay != 'NA' or LateAircraftDelay != 'NA'
limit 20""").show()

