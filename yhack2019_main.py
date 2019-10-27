import os
from dotenv import load_dotenv
from flask import Flask, request
from flask_restful import Resource, Api
import mysql.connector
from mysql.connector import MySQLConnection, Error
from python_mysql_dbconfig import read_db_config
from speechRec import sample_recognize

import pyrebase

load_dotenv()

app = Flask(__name__)
api = Api(app)


"""Restful API"""
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
        # get_dict from IOS containing video URL and video name
        some_dict = request.get_json()
        #Pull video from firebase
        #storage.child(some_dict[name]).download("downloaded.jpg")
        storage.child("Sick.MOV").download("downloaded.MOV")
        #Run speech recogonition
        
        #Store in SQL
        print(some_dict)
        return
    def get(self):
        return {'result': num*10}
        
class Message(Resource):
    def post(self):
        some_json = request.get_json()
        #HERE: Pull stuff from SQL, Run NLP, sentiment analysis ETC
        return jsonify({'video link': 'URL'})


api.add_resource(HelloWorld, '/')
api.add_resource(Message, '/Message/')
api.add_resource(Video, '/Video/')
    

""" Connect to MySQL database """
def connect_sql():
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

"""Fetch all data from MySQL database"""
def query_with_fetchall():
   try:
       dbconfig = read_db_config()
       conn = MySQLConnection(**dbconfig)
       cursor = conn.cursor()
       cursor.execute("SELECT * FROM url")
       rows = cursor.fetchall()

       print('Total Row(s):', cursor.rowcount)
       for row in rows:
           print(row)

   except Error as e:
       print(e)

   finally:
       cursor.close()
       conn.close()
       
"""Insert video"""
def insert_video(title, isbn):
   query = "INSERT INTO books(title,isbn) " \
           "VALUES(%s,%s)"
   args = (title, isbn)

   try:
       db_config = read_db_config()
       conn = MySQLConnection(**db_config)

       cursor = conn.cursor()
       cursor.execute(query, args)

       if cursor.lastrowid:
           print('last insert id', cursor.lastrowid)
       else:
           print('last insert id not found')

       conn.commit()
   except Error as error:
       print(error)

   finally:
       cursor.close()
       conn.close()
       
       
"""Set up connection from python to firebase"""
def config_firebase():
    config = {
      "apiKey": os.getenv("API_KEY"),
      "authDomain": os.getenv("AUTHDOMAIN"),
      "databaseURL": os.getenv("DATABASEURL"),
      "storageBucket": os.getenv("STORAGEBUCKET"),
      "serviceAccount": os.getenv("SERVICEACCOUNT")
    }
    firebase = pyrebase.initialize_app(config)
    fdb = firebase.database()
    



if __name__ == '__main__':
    connect_sql()
    config_firebase()
    app.run(debug=True)
