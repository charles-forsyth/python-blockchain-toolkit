#!/bin/bash

# --- HPC Credit Simulation: Full Campus Scale ---
# Simulates a closed-loop economy with 10 Labs, 30 Students, and mixed workloads.

# --- Configuration ---
CHAIN_FILE="hpc_campus.dat"
COIN_NAME="HPCCredit"
ADMIN="HPC_Core"
BLOCKCHAIN_TOOL="$(dirname "$0")/blockchain.py"

# Job Types and Costs
declare -A JOB_COSTS
JOB_COSTS=(
    ["Quick_Debug"]=10
    ["Standard_CPU"]=50
    ["BigMem_Analysis"]=200
    ["GPU_Training"]=500
    ["Hero_Run"]=2000
)
JOB_TYPES=("Quick_Debug" "Standard_CPU" "BigMem_Analysis" "GPU_Training" "Hero_Run")

# --- Helper Functions ---
function run_cmd() {
    "$BLOCKCHAIN_TOOL" --chain "$CHAIN_FILE" --coin-name "$COIN_NAME" "$@"
}

function mine_block() {
    echo "  ⛏️  Mining block to confirm transactions..."
    run_cmd mine --miner "$ADMIN" --reward 0 > /dev/null
}

# --- Simulation Start ---
echo "### Starting Campus-Scale HPC Simulation ###"
echo "--------------------------------------------"

# 1. Clean Start
rm -f "$CHAIN_FILE"
echo "--- Step 1: HPC_Core Minting Initial Supply ---"
# Mint 10,000,000 credits
run_cmd mine --miner "$ADMIN" --reward 10000000 > /dev/null
echo "✅ HPC_Core minted 10,000,000 $COIN_NAME"

# 2. Grant Cycle (Allocating to PIs)
echo -e "\n--- Step 2: Annual Grant Allocations (Admin -> 10 Professors) ---"
PI_LIST=()
for i in {1..10}; do
    PI_NAME="Prof_Lab$i"
    PI_LIST+=("$PI_NAME")
    # Random Grant between 50,000 and 100,000
    GRANT_AMOUNT=$(( ( RANDOM % 50 + 50 ) * 1000 ))
    
    echo "  -> Allocation: $PI_NAME receives $GRANT_AMOUNT"
    run_cmd transfer --from "$ADMIN" --to "$PI_NAME" --amount "$GRANT_AMOUNT" > /dev/null
done
mine_block

# 3. Lab Onboarding (PIs -> Students)
echo -e "\n--- Step 3: Lab Onboarding (Professors -> 30 Students) ---"
STUDENT_LIST=()
for PI in "${PI_LIST[@]}"; do
    # Each PI has 3 students
    for j in {1..3}; do
        STUDENT_NAME="${PI}_Student$j"
        STUDENT_LIST+=("$STUDENT_NAME")
        # Allocation between 5,000 and 15,000
        STIPEND=$(( ( RANDOM % 10 + 5 ) * 1000 ))
        
        # echo "  -> Stipend: $PI sends $STIPEND to $STUDENT_NAME"
        run_cmd transfer --from "$PI" --to "$STUDENT_NAME" --amount "$STIPEND" > /dev/null
    done
done
echo "✅ All 30 students funded. Mining batch..."
mine_block

# 4. The Work Cycle (Students -> Admin)
echo -e "\n--- Step 4: Simulating Workload (Students running jobs) ---"
echo "Queueing jobs..."

JOB_COUNT=0
TOTAL_REVENUE=0

for STUDENT in "${STUDENT_LIST[@]}"; do
    # Each student runs 1 random job
    # Pick random job type index
    RAND_IDX=$(( RANDOM % 5 ))
    JOB_NAME=${JOB_TYPES[$RAND_IDX]}
    COST=${JOB_COSTS[$JOB_NAME]}
    
    echo "  💻 $STUDENT submits '$JOB_NAME' (Cost: $COST)"
    run_cmd transfer --from "$STUDENT" --to "$ADMIN" --amount "$COST" > /dev/null
    
    TOTAL_REVENUE=$((TOTAL_REVENUE + COST))
    JOB_COUNT=$((JOB_COUNT + 1))
done

echo -e "\nProcessing $JOB_COUNT jobs worth $TOTAL_REVENUE credits..."
mine_block

# 5. Insufficient Funds Scenario (Cascading Requests)
echo -e "\n--- Step 5: Handling Insufficient Funds (The 'Broke Lab' Scenario) ---"
BROKE_STUDENT="${PI_LIST[0]}_Student1"
RICH_PROF="${PI_LIST[0]}"
HUGE_JOB_COST=25000
EMERGENCY_GRANT=50000

echo "Scenario: $BROKE_STUDENT wants to run a 'Planetary_Sim' costing $HUGE_JOB_COST credits."
echo "  👉 Attempt 1: Submitting Job..."
run_cmd transfer --from "$BROKE_STUDENT" --to "$ADMIN" --amount "$HUGE_JOB_COST"

echo -e "\n  📝 Student requests budget increase from $RICH_PROF..."
echo "  👉 Attempt 2: Professor tries to fund Student..."
# This is expected to fail if Prof is low on funds
run_cmd transfer --from "$RICH_PROF" --to "$BROKE_STUDENT" --amount "$HUGE_JOB_COST"

echo -e "\n  🚨 Professor also lacks funds! Requesting Emergency Grant from HPC_Core..."
echo "  -> HPC_Core sends $EMERGENCY_GRANT to $RICH_PROF."
run_cmd transfer --from "$ADMIN" --to "$RICH_PROF" --amount "$EMERGENCY_GRANT"
mine_block

echo -e "\n  👉 Attempt 3: Professor retries funding Student..."
run_cmd transfer --from "$RICH_PROF" --to "$BROKE_STUDENT" --amount "$HUGE_JOB_COST"
mine_block

echo -e "\n  👉 Attempt 4: Student retries Job..."
run_cmd transfer --from "$BROKE_STUDENT" --to "$ADMIN" --amount "$HUGE_JOB_COST"
mine_block

# 6. Final Report
echo -e "\n### Simulation Report ###"
echo "-------------------------"
ADMIN_BAL=$(run_cmd balance --address "$ADMIN" | grep "balance" |    awk '{print $8}')
echo "🏦 HPC_Core Final Balance: $ADMIN_BAL (Recycled Revenue: $TOTAL_REVENUE)"

echo -e "\n--- Sample Researcher Status ---"
# Pick 3 random PIs to show
for i in {1..3}; do
    RAND_PI=${PI_LIST[$(( RANDOM % 10 ))]}
    PI_BAL=$(run_cmd balance --address "$RAND_PI" | grep "balance" |    awk '{print $8}')
    echo "👨‍🔬 $RAND_PI Balance: $PI_BAL"
done

echo -e "\n--- Sample Student Status ---"
# Pick 3 random Students to show
for i in {1..3}; do
    RAND_STU=${STUDENT_LIST[$(( RANDOM % 30 ))]}
    STU_BAL=$(run_cmd balance --address "$RAND_STU" | grep "balance" |    awk '{print $8}')
    echo "🎓 $RAND_STU Balance: $STU_BAL"
done

echo -e "\n### Simulation Complete ###"