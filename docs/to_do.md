# Initial Development Steps

## Objective

The immediate goal is to build the height analysis pipeline from raw GWAS data 
through a clean MAGMA-ready input and initial network preparation.

Height is the development trait and will be used to construct, debug, and validate 
the full analysis pipeline before the schizophrenia confirmatory analysis.

## Step 1: Create the project structure

Create the initial repository structure:

```text
data/
├── raw/
└── processed/

src/

results/

logs/

config/

docs/
```

The project scope should remain is in:

```text
docs/scope.md
```

## Step 2: Inventory the required raw data

### Height GWAS

```text
50_irnt.gwas.imputed_v3.both_sexes.tsv.bgz
variants.tsv.bgz
```

### 1000 Genomes EUR reference panel

```text
g1000_eur.bed
g1000_eur.bim
g1000_eur.fam
```

The reference-panel MAF file will also be generated using PLINK:
For every variant in the 1000 Genomes European reference panel,
its allele frequency is calculated. 

```bash
plink \
  --bfile g1000_eur \
  --freq \
  --out g1000_eur
```

Expected output:

```text
g1000_eur.frq
```

### MAGMA gene annotation

```text
NCBI37.3.gene.loc
```

### STRING network

```text
9606.protein.physical.links.v12.0.txt.gz
9606.protein.info.v12.0.txt.gz
9606.protein.aliases.v12.0.txt.gz
```

### Publication attention

```text
gene2pubmed.gz
```

### Height seed genes

```text
Yengo_2022_supplementary_tables.xlsx
```

## Step 3: Prepare the height GWAS

Create:

```text
src/01_prepare_height_gwas.py
```

The purpose of this script is to convert the raw Neale Lab height GWAS 
into a harmonized MAGMA-ready variant dataset.

The pipeline should perform the following operations:

```text
Height GWAS
    +
variants.tsv
    |
    v
Join on variant
    |
    v
Restrict to autosomes
    |
    v
Retain biallelic SNPs
    |
    v
Remove invalid genomic positions
    |
    v
Remove invalid p-values
    |
    v
Remove low-confidence variants
    |
    v
Match variants to the 1000 Genomes EUR reference panel
    |
    v
Add reference-panel MAF
    |
    v
Retain MAF >= 0.01
    |
    v
Create MAGMA-ready height GWAS file
```

### Primary filters

The script should retain variants satisfying:

```text
chromosome in 1-22
biallelic SNP
valid GRCh37 genomic position
valid p-value
low_confidence_variant == false
present in 1000 Genomes Phase 3 EUR
reference-panel MAF >= 0.01
```

The per-variant sample-size field should be:

```text
n_complete_samples
```

### QC reporting

The script should record the number of variants remaining after each processing step.

Example:

```text
Raw GWAS variants:                    N
Joined to variant metadata:           N
Autosomal variants:                   N
Biallelic SNPs:                       N
Valid position and p-value:           N
Passed low-confidence filter:         N
Present in 1000G EUR:                 N
Reference-panel MAF >= 0.01:          N
Final MAGMA-ready variants:           N
```

The QC counts should be written to:

```text
results/01_height_gwas_qc.tsv
```

The final MAGMA-ready GWAS file should be written to:

```text
data/processed/height_magma_input.tsv
```

## Step 4: Run the height MAGMA gene analysis

After the height GWAS preparation pipeline is stable, run MAGMA.

### SNP-to-gene annotation

Use:

```text
NCBI37.3.gene.loc
```

with the prespecified mapping window:

```text
35 kb upstream
10 kb downstream
```

### Gene analysis

Use:

```text
1000 Genomes Phase 3 EUR
```

as the LD reference.

Use the per-SNP sample-size field:

```text
n_complete_samples
```

The primary gene-level outcome is:

```text
MAGMA gene Z-score
```

Also retain:

```text
Entrez Gene ID
MAGMA Z-score
gene p-value
number of SNPs included in the gene test
```

The processed gene-level output should be written to:

```text
data/processed/height_magma_genes.tsv
```

## Step 5: Build the STRING network

Create:

```text
src/02_build_string_network.py
```

The STRING network should be constructed independently of the GWAS results.

Apply the following rules:

```text
Homo sapiens
physical PPI network
combined_score >= 700
map STRING proteins to Entrez Gene IDs
protein-coding genes only
undirected edges
remove self-loops
collapse duplicate gene-gene edges
```

STRING protein identifiers should be mapped to Entrez Gene IDs using:

```text
9606.protein.aliases.v12.0.txt.gz
```

and aliases with:

```text
source == Ensembl_HGNC_entrez_id
```

The cleaned network edge list should be written to:

```text
data/processed/string_physical_700_edges.tsv
```

## Step 6: Calculate initial network properties

Using the fixed cleaned STRING network, calculate:

```text
node degree
Leiden community membership
```

The Leiden analysis should use:

```text
objective: modularity
network: unweighted
random seed: 42
iterations: until convergence
```

The resulting node-level network table should contain:

```text
Entrez Gene ID
degree
Leiden community
```

Write the output to:

```text
data/processed/string_network_genes.tsv
```

Do not use MAGMA Z-scores when constructing the network or detecting communities.

## Immediate development target

The first development milestone is:

> Produce a clean MAGMA-ready height GWAS file and a QC report showing the number of variants retained after every filtering step.

The immediate files to create are:

```text
src/01_prepare_height_gwas.py
results/01_height_gwas_qc.tsv
data/processed/height_magma_input.tsv
```

RWR, matched-seed permutations, and the primary gene-property regressions should be implemented only after the height GWAS preparation, MAGMA gene analysis, and STRING network construction are working correctly.
