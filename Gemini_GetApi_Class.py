# pokemon_api.s
import google.generativeai as genai
from textblob import TextBlob
import re
from PIL import Image, ImageDraw, ImageFont
import os

class GetApi:

    def __init__(self):
        # Set your API key
        #api_key = os.getenv("GEMINI_API_KEY")
        genai.configure(api_key="AIzaSyBab5VArMDK59FsdW9hNgR3_5ASaV_tpJU")
        #if not api_key:
            #raise ValueError("GEMINI_API_KEY environment variable not set.")
            # Create a model instance
        self.model = genai.GenerativeModel("gemini-pro")

    def get_meme(self):

        # Send a request to the model
        flag = 1
        while flag == 1:
            response = self.model.generate_content("give me a positive joke about peace")
            cleaned_text = self.clean_text(response.text) #using the clean_text function for clean text 
            blob = TextBlob(cleaned_text) #creating blob object of the text to analayze 
            sentiment = blob.sentiment.polarity #score of -1 to 1 by how negetive to positive
            print(sentiment) #print -1 to 1 score of sentiment
            if sentiment >= 0:  
                flag = 0      
                return cleaned_text
               
    
    #removing non relevant charecters form the text
    def clean_text(self,response):
        text = re.sub(r'[^a-zA-Z0-9\s\n]', '', response)
        return text

