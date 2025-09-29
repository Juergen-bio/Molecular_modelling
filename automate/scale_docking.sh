#!/bin/bash
# Assuming receptor file is target.pdbqt and config file is config.txt

for ligand_file in *.pdbqt; do
    # Skip the receptor file itself
    if [[ "$ligand_file" == "target.pdbqt" ]]; then
        continue
    fi
    
    # Run Vina for each ligand
    vina --receptor target.pdbqt --ligand "$ligand_file" --config config.txt --out "${ligand_file/.pdbqt/_out.pdbqt}"
done
