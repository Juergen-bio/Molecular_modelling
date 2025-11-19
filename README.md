##  AutoDock Vina Workflow: Receptor & Ligand Preparation (ChimeraX / Open Babel / Meeko)

This guide outlines the standard steps for preparing a single receptor and ligand for docking using **AutoDock Vina**, leveraging ChimeraX for PDB preparation and the **Meeko** (`mk_prepare_*.py`) suite for PDBQT conversion.

-----

### 1\.  Receptor Preparation using ChimeraX

These steps ensure your PDB is clean, protonated, and ready for PDBQT conversion.

  * **Load the Protein:** Load your protein structure into ChimeraX.
  * **Identify & Measure the Active Site:**
      * If you have a co-crystallized ligand:
        ```bash
        select ligand
        measure center sel # Get coordinates for config.txt
        del sel            # Delete the co-crystallized ligand
        ```
      * If the active site is unknown:
        ```bash
        # Identify pockets for blind docking center estimation
        find cavity
        ```
  * **Define Centroid (Optional):** If you are defining a docking box based on specific residues:
    ```bash
    define centroid #1.1.1 # Define a geometric center for a residue (e.g., residue 1.1.1)
    ```
  * **Clean and Protonate:**
    ```bash
    delete solvent # Remove water molecules
    addh           # Add hydrogens (ChimeraX defaults to polar-only for docking prep)
    ```
  * **Save the Cleaned Structure:**
    ```bash
    save protein.pdb #1.1 # Save the cleaned model (assuming model 1, submodel 1)
    ```

-----

### 2\.  Receptor PDBQT Conversion (Meeko)

Use `mk_prepare_receptor.py` to convert the cleaned PDB to Vina-compatible PDBQT format.

| Command | Description |
| :--- | :--- |
| `mk_prepare_receptor.py -i protein.pdb -o protein -p` | Standard, simple conversion. |
| `mk_prepare_receptor.py -i gyrase.pdb --allow_bad_res --default_altloc A -o gyrase -p` | Handles specific issues like alternate conformers (`--default_altloc A`) and non-standard residues. |
| `mk_prepare_receptor.py -i receptor.pdb -o my_receptor -p -f A:101 A:230 A:35` | **Flexible Docking:** Uses the `-f` flag to specify residues (Chain:ResNum) to be treated as flexible during docking. |

-----

### 3\.  Ligand Preparation (Open Babel & Meeko)

This involves generating 3D structures, optimizing geometry, and converting to PDBQT.

#### A. Optimization and 3D Conversion (Open Babel)

  * **Quick 3D Generation & Minimization:**
    ```bash
    obabel -i sdf ligand_2d.sdf -O ligand.sdf -h --gen3d --minimize
    ```
  * **Recommended Force Field Optimization:** For better geometric accuracy, use a force field and defined steps:
    ```bash
    obabel -i sdf quercetin_2d.sdf -O quercetin.sdf -h --gen3d --minimize --ff MMFF94 --steps 500
    ```
    > **Note:** `--minimize` in Open Babel is okay for small molecules, but running an **MMFF94 optimization** (`--ff MMFF94 --steps 500`) yields better starting geometries.

#### B. Ligand PDBQT Conversion (Meeko)

  * **Standard Conversion:**
    ```bash
    mk_prepare_ligand.py -i quercetin.sdf -o quercetin.pdbqt
    ```
  * **Generating from SMILES (Example: Phosphate Ion):**
    1.  **Generate 3D MOL2 directly from SMILES (with protonation at pH 7.4):**
        ```bash
        echo 'O=P(O)(O)[O-]' | obabel -ismi -o mol2 -O phosphate.mol2 -p 7.4 --gen3d
        ```
    2.  **Convert MOL2 to PDBQT:**
        ```bash
        mk_prepare_ligand.py -i phosphate.mol2 -o phosphate.pdbqt
        ```

#### C. Charge Validation (Optional but Recommended)

If you have a custom script (`check_charge.py`) to verify PDBQT charges:

```bash
chmod +x check_charge.py
./check_charge.py phosphate.pdbqt
```

-----

### 4\.  Docking Configuration and Execution

#### A. `config.txt` File

Create a `config.txt` file containing the grid box parameters derived from your ChimeraX measurements.

```text
# Example: Ensure all values are CLEAN (no trailing comments)

center_x = 9.92
center_y = 16.23
center_z = 8.83

size_x = 20
size_y = 20
size_z = 20

exhaustiveness = 8
cpu = 8          # Must match the number from 'nproc' run on terminal
num_modes = 9
energy_range = 3
```

#### B. Run Vina

Execute the docking run, replacing the input/output filenames as needed:

```bash
vina --receptor phytase_receptor.pdbqt \
     --ligand phosphate_ligand.pdbqt \
     --config config.txt \
     --out docking_results.pdbqt \
     --log docking_log.txt
```
