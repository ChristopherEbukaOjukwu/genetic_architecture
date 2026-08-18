# Network–GWAS Genetic Architecture Project

## Height Pipeline Progress Record

**Project:** Network organization of common-variant genetic associations
**Development trait:** Height
**Current status:** MAGMA and STRING network preparation complete
**Next step:** Merge MAGMA gene scores with network properties

---

## 1. Research question

> Do common-variant GWAS associations occupy non-random positions in protein–protein interaction networks?

For height, the primary analyses test whether genes with stronger common-variant association:

1. have higher network degree;
2. are non-randomly distributed across network communities;
3. lie closer to independently defined rare, large-effect height genes.

The broader objective is to evaluate network signatures consistent with modular, core–peripheral, and omnigenic models of complex-trait architecture.

---

## 2. Project environment

Project root:

```text
/pl/active/IBG/people/choj8503/genetic_architecture
```

Main directories:

```text
config/
data/
docs/
jobs/
logs/
results/
scripts/
src/
```

Heavy analyses use Slurm:

```text
partition: blanca-ibg
account: blanca-ibg
qos: blanca-ibg
```

MAGMA:

```text
/pl/active/IBG/opt/bin/magma
MAGMA v1.10
```

---

## 3. Input data

### Height GWAS

```text
data/raw/height/50_irnt.gwas.imputed_v3.both_sexes.tsv.bgz
data/raw/height/variants.tsv.bgz
```

### 1000 Genomes European LD reference

```text
data/raw/g1000_eur/g1000_eur.bed
data/raw/g1000_eur/g1000_eur.bim
data/raw/g1000_eur/g1000_eur.fam
data/raw/g1000_eur/g1000_eur.frq
data/raw/g1000_eur/g1000_eur.synonyms
```

Reference:

```text
503 European individuals
1006 autosomal chromosomes
```

### Gene annotation

```text
data/raw/NCBI37.3/NCBI37.3.gene.loc
```

Contains Entrez Gene ID, chromosome, gene coordinates, strand, and gene symbol.

### STRING physical PPI network

```text
data/raw/string/9606.protein.physical.links.v12.0.txt.gz
data/raw/string/9606.protein.info.v12.0.txt.gz
data/raw/string/9606.protein.aliases.v12.0.txt.gz
```

### Publication data

```text
data/raw/gene2pubmed/
```

### Height seed source

```text
data/raw/height/seed/Yengo_2022_supplementary_tables.xlsx
```

Seed genes will be defined independently of the common-variant GWAS.

---

## 4. Height GWAS preparation

Script:

```text
src/01_prepare_height_gwas.py
```

Sequential filters:

```text
Raw GWAS
→ join variant metadata
→ chromosomes 1–22
→ biallelic SNPs
→ valid genomic position
→ valid p-value
→ valid sample size
→ remove low-confidence variants
→ match to 1000 Genomes EUR
→ assign reference-panel MAF
→ retain MAF ≥ 0.01
```

### QC

```text
stage                         variants_retained  removed_from_previous
raw_gwas_variants             13,791,467
joined_to_variant_metadata    13,791,467         0
autosomal_variants            13,364,303         427,164
biallelic_snps                12,148,962         1,215,341
valid_genomic_position        12,148,962         0
valid_p_value                 12,147,303         1,659
valid_sample_size             12,147,303         0
passed_low_confidence_filter  11,950,766         196,537
present_in_1000g_eur          11,262,948         687,818
reference_maf_ge_0.01          8,249,300         3,013,648
final_magma_ready_variants     8,249,300         0
```

Final:

```text
8,249,300 SNPs
```

Outputs:

```text
data/processed/height_magma_input.tsv
results/01_height_gwas_qc.tsv
```

The 1000 Genomes EUR reference was used here for variant matching and standardized MAF filtering.

---

## 5. MAGMA SNP-to-gene annotation

SNPs were assigned positionally using:

```text
gene body + 35 kb upstream + 10 kb downstream
```

Inputs:

```text
data/processed/height_magma_snploc.tsv
data/raw/NCBI37.3/NCBI37.3.gene.loc
```

Command:

```bash
magma \
  --annotate window=35,10 \
  --snp-loc height_magma_snploc.tsv \
  --gene-loc NCBI37.3.gene.loc \
  --out height_magma_35up_10down
```

Output:

```text
data/processed/height_magma_35up_10down.genes.annot
```

Result:

```text
18,418 genes containing usable SNPs
```

Overlapping gene windows allow a SNP to be assigned to more than one gene.

This mapping is positional and does not imply functional regulation.

---

## 6. MAGMA gene association analysis

MAGMA combined:

```text
GWAS SNP p-values
+
SNP-to-gene assignments
+
1000 Genomes EUR LD
```

Command:

```bash
/pl/active/IBG/opt/bin/magma \
  --bfile data/raw/g1000_eur/g1000_eur \
  --gene-annot data/processed/height_magma_35up_10down.genes.annot \
  --pval data/processed/height_magma_input.tsv use=SNP,P ncol=N \
  --gene-model snp-wise=mean \
  --out results/magma/height_35up_10down
```

Analysis:

```text
8,249,300 SNPs
18,418 genes
503-person EUR LD reference
SNP-wise mean gene model
per-SNP sample size
```

Slurm:

```text
Job ID: 27278590
State: COMPLETED
Exit code: 0:0
Elapsed: 03:59:59
Maximum memory: ~2.9 GB
```

Outputs:

```text
results/magma/height_35up_10down.genes.out
results/magma/height_35up_10down.genes.raw
results/magma/height_35up_10down.log
results/magma/height_35up_10down.log.suppl
```

Main gene-level fields:

```text
GENE
CHR
START
STOP
NSNPS
NPARAM
N
ZSTAT
P
```

Primary downstream outcome:

```text
MAGMA ZSTAT
```

All eligible genes are retained; analyses are not restricted to genome-wide significant genes.

---

## 7. MAGMA gene table

Entrez Gene IDs were mapped to gene symbols using:

```text
data/raw/NCBI37.3/NCBI37.3.gene.loc
```

Output:

```text
results/gene_tables/height_35up_10down_genes.tsv
```

Columns:

```text
GENE
SYMBOL
CHR
START
STOP
NSNPS
NPARAM
N
ZSTAT
P
```

QC:

```text
MAGMA genes:          18,418
Mapped gene symbols:  18,418
Missing symbols:           0
```

---

## 8. STRING physical network construction

Script:

```text
scripts/build_string_physical_network.py
```

Inputs:

```text
data/raw/string/9606.protein.physical.links.v12.0.txt.gz
data/raw/string/9606.protein.info.v12.0.txt.gz
```

Network rules:

```text
Homo sapiens
physical interactions
combined_score ≥ 700
map STRING protein IDs to preferred gene names
undirected network
remove self-loops
collapse duplicate gene pairs
```

When multiple protein-level records mapped to the same gene pair, the maximum STRING confidence score was retained.

The primary topology analyses treat the thresholded network as unweighted.

### QC

```text
STRING protein mappings:             19,699
Raw physical interaction rows:    1,477,610
Rows with score ≥ 700:              173,038
Missing mappings:                         0
Self-loops removed:                       0
Duplicate directions collapsed:      86,519

Final genes:                        10,746
Final unique edges:                 86,519
```

Output:

```text
results/network/string_physical_700_edges.tsv
```

---

## 9. MAGMA–STRING overlap

Comparison of the MAGMA and STRING gene sets produced:

```text
MAGMA genes:                 18,418
STRING genes:                10,746
Overlap:                      9,734

MAGMA genes represented
in STRING:                    52.9%

STRING genes with
MAGMA scores:                 90.6%
```

The 9,734 overlapping genes have both common-variant association information and STRING network information.

Network topology is calculated on the full STRING network, not only the MAGMA-overlapping genes.

---

## 10. Network degree and connected components

Script:

```text
scripts/calculate_network_properties.py
```

For each STRING gene, the analysis calculated:

```text
degree
connected component
component size
largest-component membership
```

Network:

```text
Genes:                  10,746
Edges:                  86,519
Connected components:      344
```

Largest connected component:

```text
Genes:                    9,830
Fraction of network:      91.5%
```

Genes outside the largest component:

```text
916
```

Degree is defined using the full 10,746-gene STRING network.

---

## 11. Leiden communities

Leiden community detection used:

```text
objective: modularity
network: unweighted
random seed: 42
```

An initial partition of the complete network produced:

```text
394 communities
modularity = 0.801593
```

Inspection showed that:

```text
51 communities occurred in the giant component
343 corresponded to the 343 smaller disconnected components
```

The final primary community partition was therefore calculated explicitly within the giant connected component.

Script:

```text
scripts/calculate_giant_leiden.py
```

Final giant-component network:

```text
Genes:        9,830
Edges:       85,576
Communities:     51
Modularity: 0.798286
```

Final network-property table:

```text
results/network/string_physical_700_gene_properties_final.tsv
```

Primary definitions:

```text
Degree:
full 10,746-gene STRING network

Community:
9,830-gene giant connected component

Seed proximity:
giant connected component
```

---

## 12. Current pipeline status

```text
Raw height GWAS                           Done
Clean and match common SNPs               Done
Assign SNPs to genes                      Done
Calculate MAGMA gene scores               Done
Add gene symbols / prepare gene table     Done
Build cleaned STRING physical network     Done
Check MAGMA–STRING overlap                Done
Calculate network degree                  Done
Identify connected components             Done
Calculate final Leiden communities        Done
Merge MAGMA + network properties          NEXT
Connectivity analysis                     later
Community analysis                        later
Prepare independent height seed genes     later
Seed-proximity / RWR analysis             later
```

---

## 13. Next step: MAGMA–network merge

Merge:

```text
results/gene_tables/height_35up_10down_genes.tsv
```

with:

```text
results/network/string_physical_700_gene_properties_final.tsv
```

by:

```text
SYMBOL
```

Expected initial overlap:

```text
9,734 genes
```

The merged analysis table should include:

```text
GENE
SYMBOL
CHR
START
STOP
NSNPS
NPARAM
N
ZSTAT
P
degree
component
component_size
in_largest_component
leiden_community_giant
```

---

## 14. Planned analyses

### Connectivity

Test whether stronger common-variant association is related to network connectivity.

```text
MAGMA ZSTAT ~ degree + covariates
```

### Community organization

Test whether height-associated signal is distributed non-randomly across the 51 communities of the giant STRING component.

### Seed proximity

Test whether common-variant height association is concentrated near independently defined rare, large-effect height genes.

Workflow:

```text
independent seed genes
→ map seeds to STRING
→ calculate network proximity / RWR
→ exclude seed genes from the tested gene set
→ relate MAGMA signal to seed proximity
→ compare with matched random seed sets
```

Seed genes remain in the network when proximity is calculated but are excluded from the downstream MAGMA–proximity association test.

RWR, matched-seed permutations, publication-attention adjustment, and final gene-property models will be implemented after the MAGMA–network merge is finalized.
