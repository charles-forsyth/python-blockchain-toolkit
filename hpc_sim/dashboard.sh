#!/bin/bash

# --- HPC Live Dashboard ---
# Runs the simulation in the background and displays real-time stats.

SIM_SCRIPT="./hpc_arcade.sh"
BLOCKCHAIN="./blockchain.py"
CHAIN_FILE="hpc_campus.dat"
COIN_NAME="HPCCredit"
LOG_FILE="sim_output.log"

# Ensure we are in the right directory
cd "$(dirname "$0")"

# Cleanup
rm -f "$LOG_FILE"
touch "$LOG_FILE"

# Trap Ctrl+C to kill the background simulation
trap "kill $SIM_PID 2>/dev/null; exit" SIGINT SIGTERM

echo "🚀 Starting Simulation Backend..."
"$SIM_SCRIPT" auto > "$LOG_FILE" 2>&1 &
SIM_PID=$!

function draw_dashboard() {
    clear
    echo "==============================================================================="
    echo "                   🖥️   HPC BLOCKCHAIN LIVE DASHBOARD   🖥️                     "
    echo "==============================================================================="
    
    # 1. Fetch Blockchain Stats
    # Output format: {"height": 12, "tx_count": 45, "last_hash": "abc..."}
    STATS=$("$BLOCKCHAIN" --chain "$CHAIN_FILE" --coin-name "$COIN_NAME" stats 2>/dev/null)
    
    # Simple JSON parsing with awk/sed (since we can't assume jq is installed)
    HEIGHT=$(echo "$STATS" | sed -n 's/.*"height": \([0-9]*\).*/\1/p')
    TX_COUNT=$(echo "$STATS" | sed -n 's/.*"tx_count": \([0-9]*\).*/\1/p')
    HASH=$(echo "$STATS" | sed -n 's/.*"last_hash": "\([^"]*\)".*/\1/p' | cut -c 1-20)...
    
    # 2. Simulation Health
    if ps -p $SIM_PID > /dev/null; then
        STATUS="🟢 RUNNING (PID $SIM_PID)"
    else
        STATUS="🔴 STOPPED"
    fi

    echo " STATUS: $STATUS"
    echo "-------------------------------------------------------------------------------"
    echo " ⛓️  BLOCKCHAIN STATE"
    echo "    Block Height:      $HEIGHT"
    echo "    Total Tx:          $TX_COUNT"
    echo "    Latest Hash:       $HASH"
    echo "-------------------------------------------------------------------------------"
    echo " 📊 HPC ECONOMY"
    # Estimate jobs by looking for "Job completed" in the log
    JOBS_RUN=$(grep -c "Job completed" "$LOG_FILE")
    # Estimate spent credits by grepping "TOTAL COST" lines and summing
    CREDITS_SPENT=$(grep "TOTAL COST" "$LOG_FILE" | awk '{sum+=$4} END {print sum}')
    if [ -z "$CREDITS_SPENT" ]; then CREDITS_SPENT=0; fi
    
    echo "    Jobs Completed:    $JOBS_RUN"
    echo "    Credits Spent:     $CREDITS_SPENT $COIN_NAME"
    echo "-------------------------------------------------------------------------------"
    echo " 📝 LIVE LOG (Last 10 Lines)"
    echo "-------------------------------------------------------------------------------"
    tail -n 12 "$LOG_FILE" | fold -w 80
    echo "==============================================================================="
    echo " Press [Ctrl+C] to Stop Simulation"
}

# Main Loop
while true; do
    draw_dashboard
    sleep 1
done
