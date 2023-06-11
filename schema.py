# create db schema for the app
# table tag : uid | tag_type | data | description | read_count | last_read_date |
# option_new | option_sort | option_duration | option_item_length

# for mysql
import mysql.connector
import os

print("host: " + str(os.environ.get('DB_HOST')))
print("user: " + str(os.environ.get('DB_USERNAME')))
print("pass: " + str(os.environ.get('DB_PASSWORD')))
print("db: " + str(os.environ.get('DB_NAME')))

mydb = mysql.connector.connect(
  host=os.environ.get('DB_HOST'),
  user=os.environ.get('DB_USER'),
  password=os.environ.get('DB_PASS'),
  database=os.environ.get('DB_NAME')
)

mycursor = mydb.cursor()

mycursor.execute("SHOW TABLES LIKE 'tag'")

result = mycursor.fetchone()

if result:
  print("The 'tag' table already exists.")
else:
  mycursor.execute("CREATE TABLE tag (uid INT AUTO_INCREMENT PRIMARY KEY, tag_type VARCHAR(255) NOT NULL, data VARCHAR(255) NOT NULL, description TEXT, read_count INT DEFAULT 0, last_read_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, option_new BOOLEAN DEFAULT FALSE, option_sort VARCHAR(255), option_duration INT, option_item_length INT)")
  print("The 'tag' table has been created.")