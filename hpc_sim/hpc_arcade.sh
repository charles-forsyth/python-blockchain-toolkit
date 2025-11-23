#!/bin/bash

# --- HPC Arcade: Interactive Simulation Menu ---
# Orchestrates various scenarios using scheduler.py and blockchain.py

SCHEDULER="./scheduler.py"
BLOCKCHAIN="./blockchain.py"
CHAIN_FILE="hpc_campus.dat"
COIN_NAME="HPCCredit"
ADMIN="HPC_Core"

# Ensure we are in the hpc_sim directory or paths work
cd "$(dirname "$0")"

function header() {
    clear
    echo "======================================================="
    echo "       🌌 HPC BLOCKCHAIN SIMULATION ARCADE 🌌        "
    echo "======================================================="
    echo " Current Chain: $CHAIN_FILE"
    echo "-------------------------------------------------------"
}

function pause() {
    read -p "Press [Enter] to continue..."
}

function run_blockchain() {
    "$BLOCKCHAIN" --chain "$CHAIN_FILE" --coin-name "$COIN_NAME" "$@"
}

function check_setup() {
    if [ ! -f "$CHAIN_FILE" ]; then
        echo "⚠️  No blockchain found. Creating Genesis Mint..."
        run_blockchain mine --miner "$ADMIN" --reward 1000000 > /dev/null
    fi
}

# --- Scenarios ---

function scenario_1() {
    header
    echo "--- Scenario 1: First Day at the Lab ---"
    echo "Goal: Create a new student, fund them, and run a small job."
    
    STUDENT="New_Student_$(date +%S)"
    echo -e "\n1. Creating user '$STUDENT'வுகளை"
    echo "2. Professor sending 500 credits..."
    run_blockchain transfer --from "$ADMIN" --to "$STUDENT" --amount 500 > /dev/null
    run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
    
    echo -e "\n3. Student submitting 'hello_world.sh'வுகளை"
    "$SCHEDULER" --user "$STUDENT" --cpu-cores 1 --time 1.0 "hello_world.sh"
    pause
}

function scenario_2() {
    header
    echo "--- Scenario 2: The Heavy Lifter ---"
    echo "Goal: Submit a massive, expensive GPU job."
    
    USER="Dr_Strange"
    echo -e "\n1. Ensuring '$USER' has funds (Granting 10,000)வுகளை"
    run_blockchain transfer --from "$ADMIN" --to "$USER" --amount 10000 > /dev/null
    run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
    
    echo -e "\n2. Submitting 'multiverse_sim.py' (8 GPUs, 64 Cores, 24 Hours)வுகளை"
    # Cost: (64*10 + 8*100 + 128*2) * 24 = (640 + 800 + 256) * 24 = 1696 * 24 = 40,704
    # Wait, that's expensive. Let's tone it down so 10k covers it.
    # 4 GPUs, 10 Cores, 5 Hours.
    # (100 + 400 + 10) * 5 = 510 * 5 = 2550
    "$SCHEDULER" --user "$USER" --cpu-cores 10 --gpus 4 --mem 5 --time 5.0 "multiverse_sim.py"
    pause
}

function scenario_3() {
    header
    echo "--- Scenario 3: Insufficient Funds ---"
    echo "Goal: Attempt a job that exceeds the wallet balance."
    
    BROKE_USER="Student_Broke"
    echo -e "\n1. Creating '$BROKE_USER' with only 10 credits..."
    run_blockchain transfer --from "$ADMIN" --to "$BROKE_USER" --amount 10 > /dev/null
    run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
    
    echo -e "\n2. Attempting to run 'big_model.py' (Cost > 10)வுகளை"
    "$SCHEDULER" --user "$BROKE_USER" --cpu-cores 4 --time 2.0 "big_model.py"
    pause
}

function scenario_4() {
    header
    echo "--- Scenario 4: Emergency Funding Workflow ---"
    echo "Goal: Recover from Scenario 3 by getting a grant."
    
    BROKE_USER="Student_Broke"
    # Check if user exists (has run scenario 3), if not create them
    BAL=$(run_blockchain balance --address "$BROKE_USER" | grep "balance")
    if [ -z "$BAL" ]; then
         echo "User '$BROKE_USER' not found. Running setup from Scenario 3 first..."
         run_blockchain transfer --from "$ADMIN" --to "$BROKE_USER" --amount 10 > /dev/null
         run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
    fi

    echo -e "\n1. '$BROKE_USER' requests emergency funds..."
    echo "   -> Admin approves 500 credit grant."
    run_blockchain transfer --from "$ADMIN" --to "$BROKE_USER" --amount 500
    echo "   -> Mining block..."
    run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
    
    echo -e "\n2. Retrying job 'big_model.py'வுகளை"
    "$SCHEDULER" --user "$BROKE_USER" --cpu-cores 4 --time 2.0 "big_model.py"
    pause
}

function scenario_5() {
    header
    echo "--- Scenario 5: Grant Cycle Reset (The Purge) ---"
    echo "Goal: Admin resets the economy. (Simulated by deleting chain and minting new)"
    
    read -p "Are you sure you want to WIPE the blockchain? (y/n): " CONFIRM
    if [ "$CONFIRM" == "y" ]; then
        echo -e "\n1. Deleting $CHAIN_FILE..."
        rm -f "$CHAIN_FILE"
        echo "2. Minting new Fiscal Year Supply (1,000,000 credits)..."
        run_blockchain mine --miner "$ADMIN" --reward 1000000
        echo "✅ Economy Reset Complete."
    else
        echo "Cancelled."
    fi
    pause
}

function scenario_6() {
    header
    echo "--- Scenario 6: The Priority War ---"
    echo "Goal: Two users submit jobs. We see who pays more."
    # Note: Since our scheduler is synchronous, we simulate this by just showing the costs.
    
    USER1="Alice"
    USER2="Bob"
    echo -e "\n1. Funding Alice and Bob..."
    run_blockchain transfer --from "$ADMIN" --to "$USER1" --amount 1000 > /dev/null
    run_blockchain transfer --from "$ADMIN" --to "$USER2" --amount 1000 > /dev/null
    run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
    
    echo -e "\n2. Alice submits standard job..."
    "$SCHEDULER" --user "$USER1" --cpu-cores 1 --time 1.0 "standard.sh"
    
    echo -e "\n3. Bob submits GPU job (Higher Value Transaction)..."
    "$SCHEDULER" --user "$USER2" --gpus 1 --time 1.0 "accelerated.sh"
    
    echo -e "\n(In a real mempool, Bob's transaction fee might prioritize him!)"
    pause
}

function scenario_7() {
    header
    echo "--- Scenario 7: Audit Trail & Verification ---"
    echo "Goal: Find the last notarized log file and verify it against the chain."
    
    # Find the most recent .out file
    LAST_LOG=$(ls -t *.out 2>/dev/null | head -n 1)
    
    if [ -z "$LAST_LOG" ]; then
        echo "❌ No log files (*.out) found. Run a job first!"
    else
        echo -e "\n1. Found recent job log: $LAST_LOG"
        echo "---------------------------------"
        cat "$LAST_LOG"
        echo "---------------------------------"
        
        echo -e "\n2. Verifying file against Blockchain..."
        run_blockchain verify "$LAST_LOG"
    fi
    pause
}

function scenario_8() {
    header
    echo "--- Scenario 8: Simulation Auto-Pilot ---"
    echo "Goal: Endless random activity. Press [Ctrl+C] to stop."
    echo "Starting in 3 seconds..."
    sleep 3
    
    # Pre-defined lists
    USERS=("Alice" "Bob" "Charlie" "Dave" "Eve" "Mallory" "Trent")
    SCRIPTS=("analysis.py" "train_model.sh" "render_frame.exe" "simulate_physics.bin" "grep_logs.sh")
    
    while true; do
        # 1. Pick Random User and Job
        USER=${USERS[$((RANDOM % ${#USERS[@]}))]}
        SCRIPT=${SCRIPTS[$((RANDOM % ${#SCRIPTS[@]}))]}
        
        # 2. Check Balance (Quietly)
        BAL_LINE=$(run_blockchain balance --address "$USER" | grep "balance")
        # Extract number. If empty/fail, assume 0.
        BAL=$(echo "$BAL_LINE" | awk '{print $8}') 
        if [ -z "$BAL" ]; then BAL=0; fi
        
        echo -e "\n--------------------------------------------------"
        echo "🤖 Auto-Pilot: Selected $USER (Balance: $BAL)"
        
        # 3. Top-up if poor (< 500)
        if [ "$BAL" -lt 500 ]; then
            TOPUP=$(( ( RANDOM % 10 + 1 ) * 1000 ))
            echo "   -> Balance low. Granting $TOPUP credits..."
            run_blockchain transfer --from "$ADMIN" --to "$USER" --amount "$TOPUP" > /dev/null
            run_blockchain mine --miner "$ADMIN" --reward 0 > /dev/null
        fi
        
        # 4. Run Job
        # Random specs
        CORES=$(( RANDOM % 8 + 1 ))
        TIME=$(( RANDOM % 5 + 1 )) # 1-5 hours
        
        # 10% chance of GPU job
        if [ $((RANDOM % 10)) -eq 0 ]; then
             GPUS=1
             SCRIPT="gpu_accelerated_run.sh"
        else
             GPUS=0
        fi
        
        "$SCHEDULER" --user "$USER" --cpu-cores "$CORES" --gpus "$GPUS" --time "$TIME" "$SCRIPT"
        
        # Small pause between jobs
        sleep 2
    done
}

# --- Main Menu Loop ---

check_setup

# Check for auto-start argument
if [ "$1" == "auto" ]; then
    scenario_8
    exit 0
fi

while true; do
    header
    echo "1. First Day at the Lab (New User, Small Job)"
    echo "2. The Heavy Lifter (Expensive GPU Job)"
    echo "3. Insufficient Funds (Rejection Test)"
    echo "4. Emergency Funding (Fixing Scenario 3)"
    echo "5. Grant Cycle Reset (Wipe Chain)"
    echo "6. The Priority War (Multiple Users)"
    echo "7. Audit Trail (Verify Log File)"
    echo "8. Simulation Auto-Pilot (Run Forever)"
    echo "Q. Quit"
    echo "-------------------------------------------------------"
    read -p "Select a Scenario [1-8, Q]: " CHOICE
    
        case $CHOICE in
    
            1) scenario_1 ;;
    
            2) scenario_2 ;;
    
            3) scenario_3 ;;
    
            4) scenario_4 ;;
    
            5) scenario_5 ;;
    
            6) scenario_6 ;;
    
            7) scenario_7 ;;
    
            8) scenario_8 ;;
    
            [Qq]) exit 0 ;;
    
            *) echo "Invalid option." ; sleep 1 ;;
    
        esac
    
    done
    
    