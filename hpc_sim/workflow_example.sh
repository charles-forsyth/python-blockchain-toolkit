#!/bin/bash

# --- MultiCoin Workflow Example Script ---
# This script demonstrates a full, reusable workflow for the MultiCoin tool.
# It shows how to create a new chain, notarize a file, mine a block,
# and verify the results using parameters.

# --- Configuration ---
# Use provided arguments or set default values.
# Usage: ./workflow_example.sh [CHAIN_FILE] [COIN_NAME] [OWNER] [FILE_TO_NOTARIZE]
CHAIN_FILE=${1:-"example_chain.dat"}
COIN_NAME=${2:-"ExampleToken"}
OWNER=${3:-"$USER"}
FILE_TO_NOTARIZE=${4:-"example_document.txt"}

# --- Script Start ---
echo "### Starting MultiCoin Workflow Example ###"
echo "-------------------------------------------"
echo "CONFIG:"
echo "  Chain File:      $CHAIN_FILE"
echo "  Coin Name:       $COIN_NAME"
echo "  Owner:           $OWNER"
echo "  File to Notarize: $FILE_TO_NOTARIZE"
echo "-------------------------------------------"
echo ""

# --- Step 1: Create a sample file to notarize (if it doesn't exist) ---
if [ ! -f "$FILE_TO_NOTARIZE" ]; then
    echo "--- Step 1: Creating sample file '$FILE_TO_NOTARIZE'... ---"
    echo "This is a sample document created on $(date) for the workflow example." > "$FILE_TO_NOTARIZE"
    echo "File created."
    echo ""
else
    echo "--- Step 1: Using existing file '$FILE_TO_NOTARIZE'... ---"
    echo ""
fi

# --- Step 2: Make the main script executable ---
chmod +x blockchain.py

# --- Step 3: Notarize the file on the specified chain ---
echo "--- Step 3: Notarizing the file... ---"
./blockchain.py --chain "$CHAIN_FILE" --coin-name "$COIN_NAME" notarize --owner "$OWNER" --file "$FILE_TO_NOTARIZE"
echo ""

# --- Step 4: Mine a new block ---
echo "--- Step 4: Mining a new block... ---"
./blockchain.py --chain "$CHAIN_FILE" mine --miner "$OWNER"
echo ""

# --- Step 5: Verify the file's integrity ---
echo "--- Step 5: Verifying the file against the chain... ---"
./blockchain.py --chain "$CHAIN_FILE" verify "$FILE_TO_NOTARIZE"
echo ""

# --- Step 6: Check the owner's balance ---
echo "--- Step 6: Checking the balance for user '$OWNER'... ---"
./blockchain.py --chain "$CHAIN_FILE" balance --address "$OWNER"
echo ""

# --- Step 7: Print the entire chain ---
echo "--- Step 7: Printing the entire '$CHAIN_FILE' for final inspection... ---"
./blockchain.py --chain "$CHAIN_FILE" print
echo ""

echo "### Workflow Complete! ###"