# MultiCoin: A Multi-Mode Educational Blockchain Tool

## Project Overview

This project is an interactive, command-line tool written in Python that demonstrates the core concepts of blockchain technology. It has evolved from a simple script into a flexible, multi-purpose application that can be used as both a learning tool and a practical utility for file notarization.

The tool operates in three distinct modes, providing different levels of engagement with blockchain principles.

**Key Technologies:**
*   **Python 3:** The core programming language.
*   **`hashlib`:** For generating SHA-256 cryptographic hashes, the foundation of a block's integrity.
*   **`argparse`:** To create a robust and well-documented command-line interface (CLI).
*   **`pickle`:** For serializing and saving the blockchain's state, enabling persistence between commands.

---

## Installation and Environment Setup

To run this tool reliably, especially for verifying a blockchain, you need a consistent environment.

### Prerequisites

1.  **Python 3:** You will need Python 3 (version 3.6 or newer is recommended). To check if you have it installed, run:
    ```bash
    python3 --version
    ```
2.  **Git:** You will need Git to clone the repository. This is the recommended way to get the source code, as it allows you to verify the script's integrity against the official commit history. To check your version, run:
    ```bash
    git --version
    ```

### Installation Steps

1.  **Clone the Repository:**
    Open your terminal and clone the project from GitHub. This ensures you have the authentic source code.
    ```bash
    git clone https://github.com/charles-forsyth/python-blockchain-toolkit.git
    ```

2.  **Navigate to the Directory:**
    ```bash
    cd python-blockchain-toolkit
    ```

3.  **No Package Installation Needed:**
    This project **only uses Python's standard library**, so you do not need to `pip install` any packages. The included `requirements.txt` file is intentionally empty to make this clear.

### Running the Tool

You can now run the tool directly. The best first step is to view the help menu, which contains a full list of commands and examples:
```bash
python3 blockchain.py --help
```

---

## Modes of Operation

### 1. Default Mode (Simple Demo)
This is the most basic mode, designed to show the fundamental structure of a blockchain. It runs entirely in memory and does not save any data.

*   **How to Run:**
    ```bash
    python3 blockchain.py
    ```
*   **What it Does:** Creates a blockchain, adds a few blocks with simple string data, and prints the final chain to the console.

### 2. Simulation Mode (Currency Simulation)
This mode demonstrates a simple cryptocurrency, which we call "MultiCoin." It shows how transactions between users are collected and how "miners" are rewarded with new coins for processing them. This mode also runs entirely in memory.

*   **How to Run:**
    ```bash
    python3 blockchain.py simulate
    ```
*   **What it Does:** Runs a pre-defined scenario where users exchange coins, miners create blocks, and final balances are calculated and displayed.

### 3. CLI Tool Mode (Persistent File Notary)
This is the most advanced and practical mode. It turns the script into a command-line utility that can create a permanent, timestamped, and verifiable record of any file. The state of the blockchain in this mode is saved to a file, allowing you to build a persistent ledger over time.

*   **How to Run:** Use commands like `notarize`, `mine`, `verify`, `balance`, and `print`.
*   **What it Does:** Allows you to manage one or more persistent blockchains for practical purposes like proving the existence and integrity of your files.

---

## CLI Tool Usage Guide

This mode allows you to create and manage your own blockchains.

### Global Options
These options can be used with any CLI command to specify which blockchain you want to work with.

*   `--chain <filename>`: Specifies the blockchain file to use. If the file doesn't exist, a new one is created. Defaults to `geminicoin.dat`.
*   `--coin-name <name>`: Sets the name of the currency/reward unit (e.g., "ivxx's", "ArtCoin"). This is only applied when a **new** blockchain file is created. Defaults to "MultiCoin".

### Commands

*   **`notarize`**: Calculates a file's unique hash and adds it to the "mempool" (a waiting area for transactions).
    ```bash
    python3 blockchain.py notarize --owner <your_name> --file <path_to_file>
    ```

*   **`mine`**: Gathers all pending transactions from the mempool, bundles them into a new block, performs the "proof-of-work," and adds the block to the chain. The miner receives a reward.
    ```bash
    # Reward goes to your system username by default
    python3 blockchain.py mine

    # Specify a different miner
    python3 blockchain.py mine --miner "AnotherMiner"
    ```

*   **`verify`**: Checks if a file is on the blockchain. It re-calculates the file's hash and searches the entire chain for a match.
    ```bash
    python3 blockchain.py verify <path_to_file>
    ```

*   **`balance`**: Scans the entire blockchain to calculate the total coin balance for a specific address.
    ```bash
    python3 blockchain.py balance --address <address_to_check>
    ```

*   **`self-verify`**: Verifies the integrity of the script itself against a committed checksum.
    ```bash
    python3 blockchain.py self-verify
    ```

*   **`print`**: Displays the full contents of the blockchain, block by block.
    ```bash
    python3 blockchain.py print
    ```

### Example Workflow: Creating a Personal Notary Chain

1.  **Create a file to notarize:**
    ```bash
    echo "My brilliant idea, recorded on this day." > my_idea.txt
    ```

2.  **Notarize it on a new, personal chain called `my_chain.dat` with "Tokens" as the currency:**
    ```bash
    python3 blockchain.py --chain my_chain.dat --coin-name "Tokens" notarize --owner "$USER" --file my_idea.txt
    ```

3.  **Mine the block to make the record permanent:**
    ```bash
    python3 blockchain.py --chain my_chain.dat mine
    ```

4.  **Check your balance:**
    ```bash
    python3 blockchain.py --chain my_chain.dat balance --address "$USER"
    ```

5.  **Verify your file at any time in the future:**
    ```bash
    python3 blockchain.py --chain my_chain.dat verify my_idea.txt
    ```