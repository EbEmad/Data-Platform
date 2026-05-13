from databricks.connect import DatabricksSession
import sys

try:
    my_profile = sys.argv[1]
except IndexError as e:
    print("Trying DEFAULT profile, add profile name as argument to use different profile")
    my_profile = "DEFAULT"

# Create a SparkSession
spark = DatabricksSession.builder.profile(my_profile).getOrCreate()

table = "samples.nyctaxi.trips"

df = spark.read.table(table)
df.select("tpep_pickup_datetime", "tpep_dropoff_datetime", 
"trip_distance", "fare_amount", "pickup_zip", "dropoff_zip").limit(100).show()

