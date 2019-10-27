import os
from dotenv import load_dotenv
from flask import Flask, request
from flask_restful import Resource, Api
import mysql.connector
from mysql.connector import MySQLConnection, Error
from python_mysql_dbconfig import read_db_config
from video_recommender import compare_keyword_similarity

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
        print("Some_dict: ", some_dict)
        #Pull video from firebase
        #storage.child(some_dict[name]).download("downloaded.jpg")
        #storage.child("Sick.MOV").download("downloaded.MOV")

        #transcript = sample_recognize("downloaded.MOV")
        #Run speech recogonition
        transcript = "Hello"
        #Store in SQL
        insert_video(some_dict['url'], some_dict['name'], transcript)
        result = query_with_fetchall()
        print(result)
        return

        
class Message(Resource):
    def post(self):
        some_json = request.get_json()
        # Pull stuff from SQL
        result_dict = query_with_fetchall()
        # Run NLP
        final_url = compare_keyword_similarity(some_json['message'], result_dict)
        #HERE: Pull stuff from SQL, Run NLP, sentiment analysis ETC
        return jsonify({'video link': final_url})


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
    
    #finally:
    #    if conn is not None and conn.is_connected():
    #        conn.close()

"""Fetch all data from MySQL database"""
def query_with_fetchall():
   result = {}
   try:
       dbconfig = read_db_config()
       conn = MySQLConnection(**dbconfig)
       cursor = conn.cursor()
       cursor.execute("SELECT * FROM video")
       rows = cursor.fetchall()

       print('Total Row(s):', cursor.rowcount)
       for row in rows:
           print(row)
       #for row_index in range(len(rows)):
        #   result[rows[row_index]['url']] = rows[row_index]['transcript']
       #print(result)
       cursor.close()
       conn.close()
       return result

   except Error as e:
       print(e)

   #finally:
       #cursor.close()
       #conn.close()
       
"""Insert video"""
def insert_video(url, name, transcript):
   query = "INSERT INTO video(url,name,transcript) " \
           "VALUES(%s,%s,%s)"
   args = (url, name, transcript)

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
       
       



if __name__ == '__main__':
    connect_sql()
    
    """Set up connection from python to firebase"""
    config = {
      "apiKey": os.getenv("API_KEY"),
      "authDomain": os.getenv("AUTHDOMAIN"),
      "databaseURL": os.getenv("DATABASEURL"),
      "storageBucket": os.getenv("STORAGEBUCKET"),
      "serviceAccount": os.getenv("SERVICEACCOUNT")
    }
    firebase = pyrebase.initialize_app(config)
    fdb = firebase.database()
    storage = firebase.storage()
    app.run(debug=True)
