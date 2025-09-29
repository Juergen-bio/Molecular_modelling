#!/bin/bash
# Assuming your input file is named all_ligands.sdf

# Split the SDF into individual files
obabel all_ligands.sdf -O temp_ligand.sdf -m

# Loop through the split files and convert each to PDBQT
for f in temp_ligand*.sdf; do
    # Extract the base name for the output file
    base=$(basename "$f" .sdf)
    obabel -i sdf "$f" -o pdbqt -O "${base}.pdbqt" --gen3d -p
done

# Clean up temporary files
rm temp_ligand*.sdf

