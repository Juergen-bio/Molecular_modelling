Computational Drug Discovery Workflow
This repository provides a step-by-step guide and automation scripts for a basic virtual screening workflow. It demonstrates the process of preparing a protein and a ligand, performing molecular docking, and analyzing the results, a fundamental skill set in modern drug discovery.

1. Preparation
This section covers the download and preparation of the protein and ligand files for docking.
    • Protein Acquisition: Download the protein structure for HIV-1 Protease (PDB ID: 1HPV) from the `Protein Data Bank (PDB).` It is recommended to download the file in the modern PDBx/mmCIF format.
    • Ligand Acquisition: Download the `Darunavir` ligand in SDF format form `pubchem.`
    • Protein Preparation:
        ◦ Open the protein file in a molecular visualization tool like ChimeraX. `chimerax protein_name`
        ◦ Delete the co-crystallized ligand from the active site. `delete sel`
        ◦ Find the active site coordinates for docking. Two methods are outlined:
            1. Ligand-Based (Recommended): Use the original ligand's position to define the center.
                • In ChimeraX, type define `centroid sel` after selecting the ligand.
                • Copy the XYZ coordinates from the log.
            2. Cavity-Based: Use ChimeraX's built-in tool to find the largest cavity.
                • Use the Tools > General > Find Cavities menu.
                • Type define `centroid #1.1.1` in the command line (#1.1.1 is the largest cavity).
    • File Conversion: Use the Open Babel command-line tool to prepare the files for AutoDock Vina. This converts them to the PDBQT format, adds hydrogens, and removes heteroatoms.
        ◦ Protein: obabel -i cif 1HPV.cif -o pdbqt -O 1hpv.pdbqt -xr
        ◦ Ligand: obabel -i sdf darunavir.sdf -o pdbqt -O darunavir.pdbqt --gen3d -p

2. Molecular Docking
This section covers the actual docking simulation using AutoDock Vina.
    • Configuration: Create a config.txt file to specify the docking box.
receptor = 1hpv.pdbqt
ligand = darunavir.pdbqt

center_x = [your x coordinate]
center_y = [your y coordinate]
center_z = [your z coordinate]

size_x = 20
size_y = 20
size_z = 20
    • Run Docking: Execute the docking simulation from the terminal.
    • Vina -receptor 1hpv.pdbqt --ligand darunavir.pdbqt --config config.txt
        ◦ If your ligand file contains multiple models, use vina_split first: vina_split --input darunavir.pdbqt
        ◦ Then, run the docking command: vina --receptor 1hpv.pdbqt --ligand darunavir_ligand_1.pdbqt --config config.txt

3. Analysis
The final step is to analyze the results to understand the protein-ligand interactions.
    • Visualize Poses: Open the prepared protein (the one without the original ligand) and the Vina output file in ChimeraX.
        ◦ chimerax 1hpv.pdb darunavir_ligand_1_out.pdbqt
    • Select Poses: The output file contains multiple poses. You can select them for visualization using the Model Panel or command line.
        ◦ To select the best pose (usually the first one): select #2.1
        ◦ To show only the selected pose: hide #2.2-
    • Analyze Interactions: Use ChimeraX to identify key interactions like hydrogen bonds.
        ◦ To select residues within 5 Å of the ligand: sel zone #2.1&protein distance 5
        ◦ To find hydrogen bonds within the selection: hbonds sel
        ◦ To refine the H-bond visualization: hbonds #2.1 #1 color yellow intermodel true
