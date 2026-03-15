from flask import Flask, jsonify, request
from blockchain import Blockchain

app = Flask(__name__)

blockchain = Blockchain()

@app.route("/blockchain", methods=["GET"])
def get_chain():
    return jsonify(blockchain.chain)

@app.route("/add_block", methods=["POST"])
def add_block():
    data = request.json["data"]

    last_block = blockchain.get_last_block()
    new_block = blockchain.create_block(data, last_block["hash"])

    return jsonify(new_block)

@app.route("/valid", methods=["GET"])
def valid():
    if blockchain.is_chain_valid():
        return jsonify({"message": "Blockchain je validní"})
    else:
        return jsonify({"message": "Blockchain není validní"})

if __name__ == "__main__":
    app.run(port=5000)