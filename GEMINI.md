# MultiCoin: A Multi-Mode Educational Blockchain Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Version](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/release/python-360/)
[![GitHub release](https://img.shields.io/github/release/charles-forsyth/python-blockchain-toolkit.svg)](https://GitHub.com/charles-forsyth/python-blockchain-toolkit/releases/)

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
    Open your terminal and clone the project from GitHub.
    ```bash
    git clone https://github.com/charles-forsyth/python-blockchain-toolkit.git
    ```

2.  **Navigate to the Directory:**
    ```bash
    cd python-blockchain-toolkit
    ```

3.  **Make the Script Executable:**
    This is a one-time command that allows you to run the script directly.
    ```bash
    chmod +x blockchain.py
    ```

4.  **No Package Installation Needed:**
    This project **only uses Python's standard library**.

### Running the Tool

You can now run the tool directly. The best first step is to view the help menu:
```bash
./blockchain.py --help
```

---

## Modes of Operation

### 1. Default Mode (Simple Demo)
*   **How to Run:**
    ```bash
    ./blockchain.py
    ```
*   **What it Does:** Creates a blockchain, adds a few blocks with simple string data, and prints the final chain to the console.

### 2. Simulation Mode (Currency Simulation)
*   **How to Run:**
    ```bash
    ./blockchain.py simulate
    ```
*   **What it Does:** Runs a pre-defined scenario where users exchange coins, miners create blocks, and final balances are calculated and displayed.

### 3. CLI Tool Mode (Persistent File Notary)
*   **How to Run:** Use commands like `notarize`, `mine`, `verify`, `balance`, and `print`.
*   **What it Does:** Allows you to manage one or more persistent blockchains for practical purposes.

---

## CLI Tool Usage Guide

### Global Options
*   `--chain <filename>`: Specifies the blockchain file to use. Defaults to `geminicoin.dat`.
*   `--coin-name <name>`: Sets the name of the currency/reward unit. Defaults to "MultiCoin".

### Commands

*   **`notarize`**:
    ```bash
    ./blockchain.py notarize --owner <your_name> --file <path_to_file>
    ```

*   **`mine`**:
    ```bash
    # Reward goes to your system username by default
    ./blockchain.py mine
    ```

*   **`verify`**:
    ```bash
    ./blockchain.py verify <path_to_file>
    ```

*   **`balance`**:
    ```bash
    ./blockchain.py balance --address <address_to_check>
    ```

*   **`self-verify`**:
    ```bash
    ./blockchain.py self-verify
    ```

*   **`print`**:
    ```bash
    ./blockchain.py print
    ```

### Example Workflow: Creating a Personal Notary Chain

1.  **Create a file to notarize:**
    ```bash
    echo "My brilliant idea, recorded on this day." > my_idea.txt
    ```

2.  **Notarize it on a new, personal chain:**
    ```bash
    ./blockchain.py --chain my_chain.dat --coin-name "Tokens" notarize --owner "$USER" --file my_idea.txt
    ```

3.  **Mine the block:**
    ```bash
    ./blockchain.py --chain my_chain.dat mine
    ```

4.  **Check your balance:**
    ```bash
    ./blockchain.py --chain my_chain.dat balance --address "$USER"
    ```

5.  **Verify your file:**
    ```bash
    ./blockchain.py --chain my_chain.dat verify my_idea.txt
    ```

---

## Reusable Workflow Example Script

Included in this repository is `workflow_example.sh`, a script that demonstrates a complete, end-to-end workflow. It can be used to quickly test the tool or as a template for your own scripts.

### How to Use

Make the script executable first:
```bash
chmod +x workflow_example.sh
```

**Run with default values:**
This will create `example_chain.dat` and `example_document.txt`.
```bash
./workflow_example.sh
```

**Run with custom parameters:**
You can provide your own values for the chain file, coin name, owner, and the file to notarize.
```bash
# Usage: ./workflow_example.sh [CHAIN_FILE] [COIN_NAME] [OWNER] [FILE_TO_NOTARIZE]
./workflow_example.sh personal_stuff.dat "MyTokens" "$USER" "my_secret_notes.txt"
```