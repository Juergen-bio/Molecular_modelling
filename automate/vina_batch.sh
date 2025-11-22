#!/bin/bash
# ==========================================================
# AutoDock Vina Batch Docking Pipeline
# Author: Zeelot Juergen
# Description: Prepares and docks multiple ligands
#              against a single receptor using Vina.
# ==========================================================

# ======= CONFIGURABLE VARIABLES =======
RECEPTOR_PDB="protein.pdb"         # Your actual PDB file
LIGAND_DIR="ligands"            # Folder with input ligands
OUTPUT_DIR="batch_results"
CONFIG_FILE="config.txt"
SUMMARY_FILE="${OUTPUT_DIR}/vina_summary.csv"

# ======= 0. SETUP =======
mkdir -p "$OUTPUT_DIR"
echo ">>> Batch docking started on $(date)"
echo "Ligand,Best_Affinity(kcal/mol)" > "$SUMMARY_FILE"

# ======= 1. PREPARE RECEPTOR =======
echo ">>> Preparing receptor..."
if [[ ! -f "${OUTPUT_DIR}/receptor.pdbqt" ]]; then
    mk_prepare_receptor.py -i "$RECEPTOR_PDB" -o "${OUTPUT_DIR}/receptor" -p
else
    echo "Receptor already prepared. Skipping..."
fi

# Verify receptor exists before looping
if [[ ! -f "${OUTPUT_DIR}/receptor.pdbqt" ]]; then
    echo "Receptor preparation failed. Check input pdb or pdbqt."
    exit 1
fi

# ======= 2. PROCESS LIGANDS =======
for LIGAND_FILE in "$LIGAND_DIR"/*; do
    BASENAME=$(basename "$LIGAND_FILE")
    NAME="${BASENAME%.*}"
    
    echo ">>> Processing ligand: $NAME"

   #Change to SDF (not sure how many different files it can handle yet; only tried with 2d sdf files). 
    obabel "$LIGAND_FILE" -O "${OUTPUT_DIR}/${NAME}.sdf" -h --gen3d --ff MMFF94 --steps 500 --minimize 2> /dev/null

    # 2. Prepare Ligand pdbqt
    mk_prepare_ligand.py -i "${OUTPUT_DIR}/${NAME}.sdf" -o "${OUTPUT_DIR}/${NAME}.pdbqt"

    # 3. docking
    if [[ -f "${OUTPUT_DIR}/${NAME}.pdbqt" ]]; then
        vina --receptor "${OUTPUT_DIR}/receptor.pdbqt" \
             --ligand "${OUTPUT_DIR}/${NAME}.pdbqt" \
             --config "$CONFIG_FILE" \
             --out "${OUTPUT_DIR}/${NAME}_docked.pdbqt" > /dev/null 2>&1
             
        # 4. Parse Affinity
        if [[ -f "${OUTPUT_DIR}/${NAME}_docked.pdbqt" ]]; then
            BEST_AFFINITY=$(grep "REMARK VINA RESULT" "${OUTPUT_DIR}/${NAME}_docked.pdbqt" | head -n 1 | awk '{print $4}')
            echo "$NAME,$BEST_AFFINITY" >> "$SUMMARY_FILE"
            echo "   -> Result: $BEST_AFFINITY kcal/mol"
        else
            echo "$NAME,Failed" >> "$SUMMARY_FILE"
            echo "   -> Result: Docking Failed (No Output)"
        fi
    else
        echo "   -> Ligand preparation failed."
    fi
done

echo ">>> Complete. Data in $SUMMARY_FILE"

