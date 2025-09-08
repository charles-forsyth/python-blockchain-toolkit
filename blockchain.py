# MultiCoin: A Multi-Mode Educational Blockchain Tool
#
# This script can be run in three different ways:
# 1. No arguments (`python3 blockchain.py`): Runs a simple, original demo.
# 2. `simulate` command (`python3 blockchain.py simulate`): Runs a currency simulation.
# 3. CLI commands (`notarize`, `mine`, etc.): Acts as a persistent file notary tool.

import hashlib
import time
import pickle
import argparse
import os
import sys

# --- Helper Functions ---
def hash_file(filename):
    """Calculates the SHA-256 hash of a file."""
    if not os.path.exists(filename):
        print(f"Error: File not found at '{filename}'")
        return None
    hasher = hashlib.sha256()
    try:
        with open(filename, 'rb') as f:
            chunk = f.read(4096)
            while chunk:
                hasher.update(chunk)
                chunk = f.read(4096)
        return hasher.hexdigest()
    except Exception as e:
        print(f"Error reading file: {e}")
        return None

# --- Core Classes (Block and Blockchain) ---
class Block:
    def __init__(self, index, timestamp, transactions, previous_hash, nonce=0):
        self.index = index
        self.timestamp = timestamp
        self.transactions = transactions
        self.previous_hash = previous_hash
        self.nonce = nonce
        self.hash = self.calculate_hash()

    def calculate_hash(self):
        block_string = str(self.index) + str(self.timestamp) + str(self.transactions) + str(self.previous_hash) + str(self.nonce)
        return hashlib.sha256(block_string.encode()).hexdigest()

class Blockchain:
    def __init__(self, mode='tool', coin_name='MultiCoin'):
        self.pending_transactions = []
        self.chain = []
        self.difficulty = 4
        self.mining_reward = 100
        self.coin_name = coin_name
        # The genesis block is created when the chain is initialized
        self.chain.append(self.create_genesis_block(mode))

    def create_genesis_block(self, mode):
        print(f"Initializing blockchain in '{mode}' mode with currency '{self.coin_name}'...")
        return Block(0, time.time(), f"Genesis Block ({mode} mode)", "0")

    def get_latest_block(self):
        return self.chain[-1]

    def add_transaction(self, transaction):
        self.pending_transactions.append(transaction)

    def mine_pending_transactions(self, miner_address):
        if not self.pending_transactions:
            print("No pending transactions to mine.")
            return False

        print(f"\n⛏️  Starting the miner...")
        reward_transaction = {
            'type': 'reward',
            'recipient': miner_address,
            'amount': self.mining_reward
        }
        transactions_for_new_block = self.pending_transactions + [reward_transaction]

        new_block = Block(
            index=self.get_latest_block().index + 1,
            timestamp=time.time(),
            transactions=transactions_for_new_block,
            previous_hash=self.get_latest_block().hash
        )

        self.mine_block(new_block)
        self.chain.append(new_block)
        print(f"🎉 Block #{new_block.index} successfully mined!")
        self.pending_transactions = []
        return True

    def mine_block(self, block):
        prefix = '0' * self.difficulty
        while not block.hash.startswith(prefix):
            block.nonce += 1
            block.hash = block.calculate_hash()
        print(f"Proof-of-Work successful! Nonce: {block.nonce}")

    def find_hash(self, file_hash):
        for block in self.chain:
            if isinstance(block.transactions, list):
                for tx in block.transactions:
                    if tx.get('type') == 'notarization' and tx.get('file_hash') == file_hash:
                        return block, tx
        return None, None

    def calculate_balance(self, address):
        balance = 0
        for block in self.chain:
            if not isinstance(block.transactions, list):
                continue
            for tx in block.transactions:
                if not isinstance(tx, dict):
                    continue
                if tx.get('type') == 'reward' and tx.get('recipient') == address:
                    balance += tx.get('amount', 0)
                if tx.get('sender') == address:
                    balance -= tx.get('amount', 0)
                if tx.get('recipient') == address and tx.get('type') != 'reward':
                    balance += tx.get('amount', 0)
        return balance

    def print_chain(self):
        print(f"\n--- ⛓️  {self.coin_name} Blockchain ⛓️  ---")
        for block in self.chain:
            print(f"Index: {block.index}")
            print(f"Timestamp: {time.ctime(block.timestamp)}")
            print("Transactions:")
            if isinstance(block.transactions, list):
                for tx in block.transactions:
                    if isinstance(tx, dict):
                        if tx.get('type') == 'notarization':
                            print(f"  - [Notary] Owner: {tx['owner']}, File: {tx['filename']}, Hash: {tx['file_hash'][:10]}...")
                        elif tx.get('type') == 'reward':
                            print(f"  - [Reward] To: {tx['recipient']}, Amount: {tx['amount']} {self.coin_name}")
                        else:
                            print(f"  - [Currency] From: {tx['sender']}, To: {tx['recipient']}, Amount: {tx['amount']}")
                    else:
                        print(f"  - {tx}")
            else:
                print(f"  - {block.transactions}")
            print(f"Previous Hash: {block.previous_hash}")
            print(f"Hash: {block.hash}")
            print(f"Nonce: {block.nonce}")
            print("-" * 40)

# --- Persistence Functions ---
def save_blockchain(blockchain, filename):
    with open(filename, 'wb') as f:
        pickle.dump(blockchain, f)
    print(f"\nBlockchain state saved to '{filename}'")

def load_blockchain(filename, coin_name):
    if os.path.exists(filename):
        with open(filename, 'rb') as f:
            return pickle.load(f)
    return Blockchain(mode='tool', coin_name=coin_name)

# --- Different Workflow Functions ---
def run_original_demo():
    print("--- Running Original Simple Demo ---")
    bc = Blockchain(mode='demo')
    print("\nMining block 1...")
    bc.add_transaction("Transaction Data 1")
    bc.mine_pending_transactions("MinerA")
    bc.print_chain()

def run_simulation_demo():
    print("--- Running MultiCoin Currency Simulation ---")
    gemini_coin = Blockchain(mode='simulate', coin_name='SimCoin')
    print("\n--- Round 1 ---")
    gemini_coin.add_transaction({'sender': 'Alice', 'recipient': 'Bob', 'amount': 50})
    gemini_coin.mine_pending_transactions(miner_address="MinerX")
    print("\n--- Final Balances ---")
    for person in ["Alice", "Bob", "MinerX"]:
        bal = gemini_coin.calculate_balance(person)
        print(f"Balance for {person}: {bal} {gemini_coin.coin_name}")

# --- Main CLI Function ---
def main():
    if len(sys.argv) == 1:
        run_original_demo()
        return

    parser = argparse.ArgumentParser(
        description='''MultiCoin: A Multi-Mode Educational Blockchain Tool.
This tool demonstrates blockchain concepts through three distinct modes of operation.''',
        formatter_class=argparse.RawTextHelpFormatter,
        epilog='''
--- EXAMPLES ---

**1. Default Mode (Simple Demo):**
   Shows the most basic blockchain concepts. Runs in-memory and does not save data.
   $ python3 blockchain.py

**2. Simulation Mode (Currency Simulation):**
   Demonstrates a simple cryptocurrency with multiple users and miners. Also runs in-memory.
   $ python3 blockchain.py simulate

**3. CLI Tool Mode (A Practical Workflow):**
   Use the tool as a persistent file notary. This mode saves its data.

   # Notarize a file on the default chain (geminicoin.dat)
   $ python3 blockchain.py notarize --owner "$USER" --file my_art.txt

   # Mine a block to add the notarization to the chain
   $ python3 blockchain.py mine

   # Check your balance (you just got a mining reward!)
   $ python3 blockchain.py balance --address "$USER"

**Advanced CLI Usage (Working with Multiple Chains):**

   # Create and use a NEW chain for your personal files with a custom currency
   $ python3 blockchain.py --chain ivxx_chain.dat --coin-name "ivxx's" notarize --owner "ivxx" --file "my_notes.txt"

   # Mine the first block on your new chain
   $ python3 blockchain.py --chain ivxx_chain.dat mine --miner "ivxx"

   # Check your balance on your new chain
   $ python3 blockchain.py --chain ivxx_chain.dat balance --address "ivxx"

   # Verify the file on your new chain
   $ python3 blockchain.py --chain ivxx_chain.dat verify "my_notes.txt"

   # Print the contents of your new chain
   $ python3 blockchain.py --chain ivxx_chain.dat print
'''
    )
    
    # Global arguments that apply to the CLI Tool Mode
    parser.add_argument('--chain', type=str, default='geminicoin.dat', 
                        help='The file name for the blockchain. Allows you to maintain multiple, separate chains. Defaults to geminicoin.dat.')
    parser.add_argument('--coin-name', type=str, default='MultiCoin', 
                        help='The name for the currency/reward unit. This is only applied when a new blockchain file is created.')

    subparsers = parser.add_subparsers(dest='command', help='Choose a mode of operation or a command for the CLI tool.')

    # --- Mode Commands ---
    subparsers.add_parser('simulate', help='Run the non-persistent MultiCoin currency simulation.')

    # --- CLI Tool Commands ---
    parser_notarize = subparsers.add_parser('notarize', help='(CLI Tool) Add a file to the mempool for notarization.')
    parser_notarize.add_argument('--owner', type=str, required=True, help='The name of the file owner.')
    parser_notarize.add_argument('--file', type=str, required=True, dest='filepath', help='The path to the file to notarize.')
    
    parser_mine = subparsers.add_parser('mine', help='(CLI Tool) Mine a new block with all pending transactions.')
    parser_mine.add_argument('--miner', type=str, dest='address', default=os.environ.get('USER', 'local_miner'), 
                             help='The address to receive the mining reward (defaults to your system username).')
    
    parser_verify = subparsers.add_parser('verify', help='(CLI Tool) Verify a file by checking its hash against the blockchain.')
    parser_verify.add_argument('filepath', type=str, help='The path to the file to verify.')
    
    parser_print = subparsers.add_parser('print', help='(CLI Tool) Print the entire blockchain.')
    
    parser_balance = subparsers.add_parser('balance', help='(CLI Tool) Calculate and show the balance of an address.')
    parser_balance.add_argument('--address', type=str, required=True, help='The address to check the balance for.')

    # Manually handle parsing to allow global args before commands
    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return

    if args.command == 'simulate':
        run_simulation_demo()
        return
    
    # For CLI tool commands, load the specified chain
    gemini_coin = load_blockchain(args.chain, args.coin_name)

    if args.command == 'notarize':
        file_hash = hash_file(args.filepath)
        if file_hash:
            gemini_coin.add_transaction({
                'type': 'notarization', 'owner': args.owner, 'file_hash': file_hash,
                'filename': os.path.basename(args.filepath), 'timestamp': time.time()
            })
            print(f"✅ Notarization for '{args.filepath}' added to the mempool.")
    elif args.command == 'mine':
        gemini_coin.mine_pending_transactions(args.address)
    elif args.command == 'verify':
        file_hash = hash_file(args.filepath)
        if file_hash:
            block, tx = gemini_coin.find_hash(file_hash)
            if block:
                print(f"\n--- Verification Successful!---\n✅ File hash found on the blockchain in Block #{block.index}.")
            else:
                print(f"\n--- Verification Failed---\n❌ File hash not found in the blockchain.")
    elif args.command == 'print':
        gemini_coin.print_chain()
    elif args.command == 'balance':
        balance = gemini_coin.calculate_balance(args.address)
        print(f"\n💰 The balance for address '{args.address}' is: {balance} {gemini_coin.coin_name}")

    save_blockchain(gemini_coin, args.chain)


if __name__ == "__main__":
    main()