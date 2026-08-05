# Network–GWAS Genetic Architecture Project

## Height Pipeline Progress Record

**Project:** Network organization of common-variant genetic associations
**Development trait:** Height
**Current status:** Height MAGMA gene analysis completed successfully
**Last completed stage:** MAGMA gene-level association analysis

---

## 1. Research question

The project asks:

> Do common-variant GWAS associations occupy non-random positions in protein–protein interaction networks?

The broader goal is to determine whether common genetic effects are biologically organized rather than randomly scattered across genes.

For height, the planned analyses will test whether genes with stronger MAGMA association scores:

1. have higher network degree;
2. are concentrated in particular network communities;
3. are closer in the protein interaction network to rare, large-effect height genes.

The analysis is intended to evaluate whether common-variant architecture displays network signatures consistent with core–peripheral, modular, or omnigenic models.

---

## 2. Computing environment

The project is stored at:

```text
/pl/active/IBG/people/choj8503/genetic_architecture
```

Repository structure:

```text
config/
data/
docs/
jobs/
logs/
results/
src/
```

Heavy analyses are submitted through Slurm to:

```text
partition: blanca-ibg
account: blanca-ibg
qos: blanca-ibg
```

The login node is used only for file inspection, editing, and job submission.

MAGMA is available at:

```text
/pl/active/IBG/opt/bin/magma
```

Version:

```text
MAGMA v1.10
```

---

## 3. Raw input data

### Height GWAS

```text
data/raw/height/50_irnt.gwas.imputed_v3.both_sexes.tsv.bgz
data/raw/height/variants.tsv.bgz
```

The GWAS file contains the height association statistics, including:

```text
variant
pval
beta
se
n_complete_samples
low_confidence_variant
```

The accompanying `variants.tsv` file contains variant metadata, including:

```text
variant
chr
pos
ref
alt
rsid
consequence
info
call_rate
allele frequency
```

### 1000 Genomes EUR reference

```text
data/raw/g1000_eur/g1000_eur.bed
data/raw/g1000_eur/g1000_eur.bim
data/raw/g1000_eur/g1000_eur.fam
data/raw/g1000_eur/g1000_eur.frq
data/raw/g1000_eur/g1000_eur.synonyms
```

Reference sample size:

```text
503 European individuals
1006 observed autosomal chromosomes
```

### Gene annotation

```text
data/raw/NCBI37.3/NCBI37.3.gene.loc
```

The annotation contains:

```text
Entrez Gene ID
chromosome
gene start
gene stop
strand
gene symbol
```

### STRING network

```text
data/raw/string/9606.protein.physical.links.v12.0.txt.gz
data/raw/string/9606.protein.info.v12.0.txt.gz
data/raw/string/9606.protein.aliases.v12.0.txt.gz
```

### Publication attention

```text
data/raw/gene2pubmed/
```

### Height seed genes

```text
data/raw/height/seed/Yengo_2022_supplementary_tables.xlsx
```

---

## 4. Step 01: Prepare the height GWAS

Script:

```text
src/01_prepare_height_gwas.py
```

The script reads the GWAS file and `variants.tsv` together and verifies that the variant identifiers match on every row.

The following filters were applied sequentially:

```text
Raw height GWAS
Join to variants.tsv
Retain chromosomes 1–22
Retain biallelic SNPs
Require valid genomic position
Require valid p-value
Require valid sample size
Remove low-confidence variants
Match to 1000 Genomes EUR by chromosome, position, and alleles
Add reference-panel MAF
Retain reference MAF ≥ 0.01
```

The 1000 Genomes reference was used at this stage to:

1. confirm that the SNP was represented in the European reference panel;
2. obtain a standardized reference-panel MAF;
3. retain common variants with MAF of at least 1%.

### Final QC counts

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

Approximately 59.8% of the original variants remained.

Output files:

```text
data/processed/height_magma_input.tsv
results/01_height_gwas_qc.tsv
```

The final SNP-level file contains:

```text
SNP
CHR
BP
REF
ALT
P
N
REF_MAF
HEIGHT_VARIANT
```

Validation checks confirmed:

* 8,249,300 variant rows plus one header;
* consistent tab-separated column counts;
* no duplicate SNP identifiers;
* data begin on chromosome 1 and end on chromosome 22.

---

## 5. Step 02: MAGMA SNP-to-gene annotation

MAGMA assigned SNPs to genes using:

```text
gene body
+ 35 kb upstream
+ 10 kb downstream
```

Input files:

```text
data/processed/height_magma_snploc.tsv
data/raw/NCBI37.3/NCBI37.3.gene.loc
```

MAGMA command conceptually used:

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

MAGMA identified:

```text
18,418 gene definitions containing usable SNPs
```

The assignment is positional.

For example:

```text
Entrez ID: 148398
Gene symbol: SAMD11
Original interval: chr1:859,993–879,961
Extended interval: chr1:824,993–889,961
```

The SNP:

```text
rs4475692
chr1:825,069
```

was assigned to SAMD11 because it fell inside the extended interval.

A SNP may be assigned to multiple nearby genes when gene windows overlap.

This step does not claim that the SNP functionally regulates the gene. It creates a consistent positional mapping for the MAGMA analysis.

---

## 6. Step 03: MAGMA gene analysis

The gene analysis combined:

```text
height SNP p-values
+
SNP-to-gene annotation
+
1000 Genomes EUR LD structure
```

The 1000 Genomes reference was used again here for a different reason than in Step 01.

In Step 01, it was used for variant matching and MAF filtering.

In the MAGMA gene analysis, the `.bed`, `.bim`, and `.fam` files were used to estimate linkage disequilibrium among SNPs. This prevents correlated SNPs from being counted as independent evidence.

MAGMA command:

```bash
/pl/active/IBG/opt/bin/magma \
  --bfile data/raw/g1000_eur/g1000_eur \
  --gene-annot data/processed/height_magma_35up_10down.genes.annot \
  --pval data/processed/height_magma_input.tsv use=SNP,P ncol=N \
  --gene-model snp-wise=mean \
  --out results/magma/height_35up_10down
```

The analysis used:

```text
503 European reference individuals
8,249,300 valid height SNPs
18,418 genes
SNPwise-mean gene model
per-SNP sample-size column N
```

Slurm job:

```text
Job ID: 27278590
State: COMPLETED
Exit code: 0:0
Elapsed time: 03:59:59
Maximum memory: approximately 2.9 GB
```

Outputs:

```text
results/magma/height_35up_10down.genes.out
results/magma/height_35up_10down.genes.raw
results/magma/height_35up_10down.log
results/magma/height_35up_10down.log.suppl
```

The readable `.genes.out` file contains:

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

Interpretation:

```text
GENE     Entrez Gene ID
NSNPS    number of SNPs assigned to the gene
NPARAM   effective number of statistical parameters after accounting for LD
N        GWAS sample size
ZSTAT    MAGMA gene-level association Z-score
P        gene-level association p-value
```

The primary outcome for the network analyses is:

```text
MAGMA ZSTAT
```

The analysis will retain all eligible genes and use the continuous Z-score rather than analyzing only statistically significant genes.

---

## 7. Current interpretation

The pipeline has transformed:

```text
13.8 million raw height variants
```

into:

```text
8.25 million cleaned common SNPs
```

and then into:

```text
18,418 gene-level height association scores
```

---

## 8. Next steps

### Immediate next step

Create:

```text
data/processed/height_magma_genes.tsv
```

This table should join the MAGMA results back to `NCBI37.3.gene.loc` and contain:

```text
Entrez Gene ID
gene symbol
chromosome
gene start
gene stop
number of SNPs
effective parameters
sample size
MAGMA Z-score
gene p-value
```

### STRING network construction

Create:

```text
src/02_build_string_network.py
```

Apply:

```text
Homo sapiens
physical interactions
combined_score ≥ 700
map STRING proteins to Entrez Gene IDs
protein-coding genes only
undirected edges
remove self-loops
collapse duplicate edges
```

Outputs:

```text
data/processed/string_physical_700_edges.tsv
data/processed/string_network_genes.tsv
```

### Network properties

Calculate:

```text
node degree
Leiden community membership
```

Leiden settings:

```text
objective: modularity
network: unweighted
random seed: 42
iterations: until convergence
```

### Later analyses

1. Connectivity:

```text
MAGMA Z-score ~ network degree + covariates
```

2. Community enrichment:

```text
Are particular network communities enriched for height association?
```

3. Seed proximity:

```text
Are common-variant height signals closer than expected to rare,
large-effect height seed genes?
```

RWR, matched-seed permutations, and gene-property models will be implemented only after the MAGMA and STRING gene tables are finalized.
