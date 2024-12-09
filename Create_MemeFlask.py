from flask import Flask, jsonify, Response
from Gemini_GetApi_Class import GetApi  # Import your script
from Create_MemePhoto import CreateMeme

app = Flask(__name__)
gemini_api = GetApi()  # Instantiate my GetApi class
create_meme = CreateMeme()


@app.route('/create_photo', methods=['GET'])
def get_api_response():
    meme_text = gemini_api.get_meme()
    result = create_meme.create_photo({meme_text})
    



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
