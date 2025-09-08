# Project Overview

This project, named "MultiCoin," is a command-line tool written in Python that serves as an educational platform and practical utility for blockchain technology. It demonstrates core concepts like blocks, chains, proof-of-work mining, and transactions. The tool is designed to be flexible, operating in several distinct modes: a simple in-memory demo, a cryptocurrency simulation, and a persistent file notarization service.

The architecture is centered around two main classes: `Block` and `Blockchain`. The `Block` class defines the structure of each element in the chain, including its index, timestamp, transactions, and cryptographic hashes. The `Blockchain` class manages the chain itself, handling the addition of new blocks, the "mempool" of pending transactions, and the mining process. The tool uses Python's standard libraries, notably `hashlib` for SHA-256 hashing, `argparse` for the command-line interface, and `pickle` for saving the blockchain state to a file.

A key feature is its ability to manage multiple, independent blockchains, each with a custom "currency" name (e.g., "VeriTokens"). It also includes a self-verification mechanism, where the integrity of the main script can be checked against a trusted hash stored in the repository.

# Building and Running

The tool is designed to be run directly from the command line and has no external dependencies.

### Prerequisites
*   **Python 3.6+**
*   **Git** (for cloning the repository)

### Setup and Execution

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/charles-forsyth/python-blockchain-toolkit.git
    ```
2.  **Navigate to the project directory:**
    ```bash
    cd python-blockchain-toolkit
    ```
3.  **Make the script executable (one-time setup):**
    ```bash
    chmod +x blockchain.py
    ```
4.  **Run the tool:**
    The script can be run in several modes. The most common is the CLI tool mode for file notarization.

    *   **View all commands:**
        ```bash
        ./blockchain.py --help
        ```
    *   **Notarize a file:**
        ```bash
        ./blockchain.py notarize --owner "MyName" --file "my_document.txt"
        ```
    *   **Mine a new block:**
        ```bash
        ./blockchain.py mine
        ```
    *   **Check a balance:**
        ```bash
        ./blockchain.py balance --address "MyName"
        ```

A comprehensive, reusable example is also provided in the `workflow_example.sh` script.

# Development Conventions

*   **No External Dependencies:** The project intentionally relies only on the Python Standard Library to ensure maximum portability and ease of setup. This is documented in the `requirements.txt` file.
*   **Persistence:** In the CLI tool mode, the state of each blockchain is saved to a `.dat` file (e.g., `geminicoin.dat`) using Python's `pickle` module. These data files are explicitly ignored by Git.
*   **Self-Verification:** The integrity of the `blockchain.py` script is maintained via a `trusted_hash.txt` file. This file contains the SHA-256 hash of the trusted version of the script and should be updated whenever the script is changed. The `self-verify` command automates this check.
*   **Git Provenance:** When a new blockchain is created, the Genesis Block is embedded with the Git remote URL and the specific commit hash of the tool's version that created it, ensuring a permanent and verifiable link between the data and the software.
*   **Code Style:** The code is written to be clear and educational, with comments explaining key blockchain concepts.
