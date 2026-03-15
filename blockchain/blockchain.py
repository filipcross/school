import hashlib
import datetime

class Blockchain:

    def __init__(self):
        self.chain = []
        self.create_block("Genesis block", "0")

    def create_block(self, data, previous_hash):
        block = {
            "index": len(self.chain) + 1,
            "timestamp": str(datetime.datetime.now()),
            "data": data,
            "previous_hash": previous_hash,
        }

        block["hash"] = self.hash(block)
        self.chain.append(block)

        return block

    def hash(self, block):
        block_string = str(block).encode()
        return hashlib.sha256(block_string).hexdigest()

    def get_last_block(self):
        return self.chain[-1]

    def is_chain_valid(self):
        for i in range(1, len(self.chain)):
            current = self.chain[i]
            previous = self.chain[i-1]

            if current["previous_hash"] != previous["hash"]:
                return False

        return True