from flask import Flask, jsonify
from Mongo_Utilities_Class import Utilities
from Gemini_GetApi_Class import GetApi  # Import your script

app = Flask(__name__)
mongo_client= input("plese enter client ip: ")
Mongo_Utilities = Utilities(mongo_client) # Instantiate my Utilitites class
GeminiApi = GetApi()



@app.route('/store_meme', methods=['PUT'])
def StoreMeme():
    """Endpoint to insert a random Pokémon's details into the database."""
    meme = GeminiApi.get_meme()
    print(meme)
    if not meme:
        return jsonify({"error": "Failed to retrieve Pokémon list"}), 500


    result = Mongo_Utilities.insert_pokemon(meme)
    print
    return jsonify(meme), 200
    



if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
