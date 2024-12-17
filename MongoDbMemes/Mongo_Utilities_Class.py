# pokemon_utilities.py
from pymongo import MongoClient
import os




class Utilities:
    def __init__(self):
        
        # Retrieve EC2_PUBLIC_IP from environment variables
        self.instance_ip = os.getenv('EC2_PUBLIC_IP')
        if not self.instance_ip:
            raise ValueError("Environment variable EC2_PUBLIC_IP is not set.")
        
        # Connect to MongoDB using the EC2_PUBLIC_IP
        self.client = MongoClient(f"mongodb://{self.instance_ip}:27017/")
        self.db = self.client["mydatabase"]  # Specify the database
        self.collection = self.db["Memes"]# Specify the collection

    def insert_pokemon(self, meme):
        MemeVar = {
        "Meme": meme,
        }
          

        result = self.collection.insert_one(MemeVar)
        
        
    
    def display(self, meme):
        print(f"The meme is: {meme}")
        if not meme:
            print("Error: Missing meme details.")
    
    def is_in_data_base(self, meme):
        query = {"Meme": meme}
        existing_meme = self.collection.find_one(query)

        if existing_meme:
            #print("Meme already exists:", existing_meme)    
            return True
        else:
            return False
