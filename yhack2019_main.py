import os
from dotenv import load_dotenv
from flask import Flask, request
from flask_restful import Resource, Api
import mysql.connector
from mysql.connector import MySQLConnection, Error
from python_mysql_dbconfig import read_db_config

import pyrebase

load_dotenv()

app = Flask(__name__)
api = Api(app)





class HelloWorld(Resource):
    def get(self):
        return {'about': 'Hello World!'}
    def post(self):
        some_json = request.get_json()
        if some_json['user'] == "larry":
            return {'you sent': some_json}, 201
        return jsonify({'error': 'no user found'})
        
class Video(Resource):
    def post(self):
        some_json = request.get_json()
        #HERE: Some json should contain video URL
        #Pull video from firebase
        #Run speech recogonition
        #Store in SQL
        return
    def get(self):
        return {'result': num*10}
        
class Message(Resource):
    def post(self):
        some_json = request.get_json()
        #HERE: Pull stuff from SQL, Run NLP, sentiment analysis ETC
        return jsonify({'video link': 'URL'})


def config_firebase():
    config = {
      "apiKey": os.getenv("API_KEY"),
      "authDomain": os.getenv("AUTHDOMAIN"),
      "databaseURL": os.getenv("DATABASEURL"),
      "storageBucket": os.getenv("STORAGEBUCKET"),
      "serviceAccount": os.getenv("SERVICEACCOUNT")
    }
    firebase = pyrebase.initialize_app(config)
    db = firebase.database()
    
def connect():
    """ Connect to MySQL database """
    conn = None
    try:
        conn = mysql.connector.connect(host='localhost',
                                        database='python_mysql',
                                        user='root',
                                        password=os.getenv("PASSWORD"))
        if conn.is_connected():
            print('Connected to MySQL database')
    
    except Error as e:
        print(e)
    
    finally:
        if conn is not None and conn.is_connected():
            conn.close()
            
def query_with_fetchall():
   try:
       dbconfig = read_db_config()
       conn = MySQLConnection(**dbconfig)
       cursor = conn.cursor()
       cursor.execute("SELECT * FROM books")
       rows = cursor.fetchall()

       print('Total Row(s):', cursor.rowcount)
       for row in rows:
           print(row)

   except Error as e:
       print(e)

   finally:
       cursor.close()
       conn.close()

        
api.add_resource(HelloWorld, '/')
api.add_resource(Message, '/Message/')
api.add_resource(Video, '/Video/')

if __name__ == '__main__':
    connect()
    app.run(debug=True)
