# UK Biobank Height GWAS Replication with REGENIE

## Purpose

I replicated a basic height GWAS workflow using participant-level UK Biobank data and REGENIE on the CU Boulder Research Computing environment.

The goal was to understand and reproduce the full path from participant phenotype extraction to chromosome-level GWAS summary statistics.

---

## Computing environment

- Cluster: CU Boulder Research Computing
- Scheduler: Blanca
- Partition/account/QoS: `blanca-ibg`
- Working directory:

```bash
/pl/active/IBG/people/choj8503/gwas_test/regenie_gwas_example
```

- Scratch directory:

```bash
/scratch/alpine/choj8503/gwas_test/regenie_gwas_example
```

- REGENIE:

```bash
/pl/active/IBG/opt/bin/regenie
```

- PLINK 2:

```bash
/pl/active/IBG/opt/bin/plink2
```

The IBG software directory was added to the batch-job path with:

```bash
export PATH=/pl/active/IBG/opt/bin:$PATH
```

---

## 1. Phenotype extraction

The UK Biobank phenotype table contained participant identifiers and multiple assessment instances of standing height.

The extraction script identified four height fields:

```text
f.50.0.0
f.50.1.0
f.50.2.0
f.50.3.0
```

These correspond to repeated height measurements from up to four UK Biobank assessment visits.

The generated phenotype file was:

```bash
/scratch/alpine/choj8503/gwas_test/regenie_gwas_example/pheno_height.txt
```

Its columns were:

```text
FID IID height height2 height3 height4
```

The file contained:

- 502,359 participant rows, excluding the header
- 499,818 nonmissing values for the first height measurement

For this replication, I used only the first height measurement:

```bash
phenos=height
```

The phenotype extraction did not itself restrict the sample to European ancestry. Participant matching and ancestry restriction occurred later through the genotype and covariate files.

---

## 2. REGENIE Step 1: background genetic prediction

### Inputs

REGENIE Step 1 used:

1. The first height measurement
2. Participant covariates
3. A cleaned European-ancestry genotype dataset
4. Approximately 125,000 QCed and LD-pruned SNPs

The genotype prefix was:

```bash
/pl/active/IBG/data/UKB/derived/common/relatedness/white/merged_QC/eur.qc
```

The PLINK files were:

```text
eur.qc.bed
eur.qc.bim
eur.qc.fam
```

Their roles were:

- `.bed`: participant genotype values
- `.bim`: SNP identifiers, chromosome positions, and allele information
- `.fam`: participant identifiers

The dataset contained:

- 436,111 participant rows in `.fam`
- 125,546 SNPs in `.bim`

These SNPs had already undergone ancestry restriction, quality control, MAF filtering, and LD pruning.

LD pruning reduced redundancy by removing highly correlated SNPs that carried similar information.

### Covariates

The covariate file was:

```bash
/pl/active/IBG/people/luke/longgwas/ukb/phenotypes/eur_covs.txt.gz
```

It contained:

```text
FID
IID
TDI
age
EPC1-EPC10
sex
Assessment_Centre
```

The covariates accounted for demographic, environmental, technical, and population-structure effects.

The genetic PCs summarized broad patterns of genetic variation across participants.

### Step 1 model

Step 1 used ridge regression to estimate each participant's polygenic background for height.

Ridge regression is useful because height is highly polygenic and the model includes many SNP predictors. It shrinks SNP-effect estimates toward zero to avoid unstable or excessively large estimates.

REGENIE tested several ridge settings:

```text
0.01  : Rsq = 0.263411, MSE = 0.741775
0.25  : Rsq = 0.263952, MSE = 0.736
0.50  : Rsq = 0.263703, MSE = 0.736281
0.75  : Rsq = 0.263330, MSE = 0.736685
0.99  : Rsq = 0.262384, MSE = 0.737708
```

The `0.25` setting was selected because it had the smallest mean squared error.

The model R-squared was approximately:

```text
Rsq = 0.264
```

This means the Step 1 SNP-based model captured about 26.4% of the variation in the adjusted height phenotype.

This does not mean that one SNP explains 26.4% of height.

### LOCO predictions

Step 1 generated leave-one-chromosome-out, or LOCO, predictions.

For each participant, REGENIE created a separate background prediction for each chromosome:

```text
row 1  = prediction excluding chromosome 1
row 2  = prediction excluding chromosome 2
...
row 22 = prediction excluding chromosome 22
```

When Step 2 tests a SNP on chromosome 1, it uses a background prediction that was built without chromosome 1 SNPs.

This prevents the SNP being tested, or nearby correlated SNPs, from already contributing to the background adjustment.

### Step 1 outputs

The outputs were:

```text
height.log
height_1.loco
height_pred.list
```

Their roles were:

- `height.log`: record of the Step 1 model, sample, SNPs, ridge settings, R-squared, MSE, warnings, and runtime
- `height_1.loco`: chromosome-specific participant background predictions
- `height_pred.list`: pointer telling Step 2 where the LOCO file is stored

The prediction-list file contained:

```text
height /scratch/alpine/choj8503/gwas_test/regenie_gwas_example/step1/height_1.loco
```

Step 1 completed successfully in approximately 21 minutes and 43 seconds.

---

## 3. REGENIE Step 2: chromosome-level GWAS

Step 2 performed the actual GWAS.

A Slurm array was used:

```bash
#SBATCH --array=1-22
```

Each array task analyzed one autosomal chromosome.

For every chromosome, the script:

1. Read the chromosome-specific UK Biobank imputed genotype data
2. Selected reliably imputed variants
3. Restricted the sample to European-ancestry participants
4. Applied additional variant quality-control filters
5. Created temporary PLINK 2 files
6. Used the corresponding Step 1 LOCO prediction
7. Tested each retained SNP individually for association with height

### Initial imputation filtering

The script used:

```bash
awk '$8>0.9 && $7>=0.00001 {print $2}' \
  /pl/active/IBG/data/UKB/raw/geno/imputed/ukb_mfi_chr${cc}_v3.txt \
  > $SLURM_SCRATCH/snplist.$cc.txt
```

This retained variants with:

- imputation R-squared greater than 0.9
- an initial MAF of at least 0.00001

Imputation R-squared measures how reliably an untyped genotype was inferred from nearby observed variants and a reference panel.

It is unrelated to the Step 1 model R-squared.

### PLINK 2 quality control

PLINK 2 then applied:

```bash
--maf 0.001
--hwe 1e-9 keep-fewhet
--geno 0.05
--max-alleles 2
```

These filters mean:

- `--maf 0.001`: keep variants with MAF of at least 0.1%
- `--hwe 1e-9 keep-fewhet`: remove variants with extreme Hardy-Weinberg disequilibrium, especially excess heterozygosity
- `--geno 0.05`: remove variants missing genotype calls in more than 5% of participants
- `--max-alleles 2`: retain biallelic variants

The final MAF threshold was therefore 0.1%, not the conventional 1% threshold for common variants.

### Temporary PLINK 2 files

The command:

```bash
--make-pfile
--out $SLURM_SCRATCH/chr$cc
```

created:

```text
chrN.pgen
chrN.pvar
chrN.psam
```

REGENIE v3.2.1 reads this format using:

```bash
--pgen $SLURM_SCRATCH/chr$cc
```

The original `--pfile` option failed because REGENIE does not recognize an option with that name.

### GWAS test

For each retained SNP, Step 2 asked:

> After accounting for covariates and the participant's chromosome-specific polygenic background, is the number of copies of the tested allele associated with height?

The additive test approximately compares participants with:

```text
0 copies of the tested allele
1 copy
2 copies
```

---

## 4. Problems encountered and resolved

### REGENIE not found

`regenie` was not initially in the shell path.

Resolved by using:

```bash
/pl/active/IBG/opt/bin/regenie
```

### PLINK 2 wrapper not found

`plink2` was installed under:

```bash
/pl/active/IBG/opt/bin
```

The wrapper required the same directory to be in `PATH`.

Resolved with:

```bash
export PATH=/pl/active/IBG/opt/bin:$PATH
```

### Wrong scheduler

The Blanca partition was not visible when the Alpine Slurm module was loaded.

Resolved with:

```bash
module load slurm/blanca
```

### Incorrect REGENIE input option

The script originally used:

```bash
--pfile
```

REGENIE v3.2.1 returned:

```text
ERROR: Option 'pfile' does not exist
```

Resolved by changing it to:

```bash
--pgen
```

### Missing PLINK line continuation

The original script lacked a backslash after:

```bash
--extract $SLURM_SCRATCH/snplist.$cc.txt
```

This would have caused Bash to treat `--maf` as a separate command.

Resolved by adding:

```bash
--extract $SLURM_SCRATCH/snplist.$cc.txt \
```

### Memory failure on larger chromosomes

Chromosomes 1-13 initially failed with:

```text
OUT_OF_MEMORY
```

The failure occurred during PLINK's `.pgen` writing stage.

PLINK detected the node's full physical memory and attempted to reserve far more than the job's 50 GB Slurm allocation.

Resolved by adding:

```bash
--memory 45000
```

to the PLINK command, while retaining:

```bash
#SBATCH --mem=50G
```

Only chromosomes 1-13 were resubmitted.

At the last observed status, the rerun was pending because Blanca nodes were reserved for maintenance:

```text
ReqNodeNotAvail, Reserved for maintenance
```

---

## 5. Successfully completed chromosome results

Chromosomes 14-22 completed successfully.

The GWAS result files were:

```text
height.14_height.regenie.gz
height.15_height.regenie.gz
height.16_height.regenie.gz
height.17_height.regenie.gz
height.18_height.regenie.gz
height.19_height.regenie.gz
height.20_height.regenie.gz
height.21_height.regenie.gz
height.22_height.regenie.gz
```

The number of tested variants was:

| Chromosome | Tested variants |
|---|---:|
| 14 | 336,431 |
| 15 | 291,465 |
| 16 | 316,407 |
| 17 | 267,698 |
| 18 | 291,742 |
| 19 | 223,935 |
| 20 | 227,945 |
| 21 | 136,696 |
| 22 | 134,933 |
| **Total** | **2,227,252** |

---

## 6. GWAS output interpretation

The chromosome-level `.regenie.gz` files contain one row per tested variant.

The columns are:

```text
CHROM
GENPOS
ID
ALLELE0
ALLELE1
A1FREQ
N
TEST
BETA
SE
CHISQ
LOG10P
EXTRA
```

Their meanings are:

- `CHROM`: chromosome
- `GENPOS`: genomic position
- `ID`: variant identifier
- `ALLELE0`: other allele
- `ALLELE1`: tested or effect allele
- `A1FREQ`: frequency of the tested allele
- `N`: number of participants included for that SNP
- `TEST`: association model; here `ADD` for additive
- `BETA`: estimated effect of each additional copy of `ALLELE1`
- `SE`: standard error, or uncertainty, around the beta
- `CHISQ`: association-test statistic
- `LOG10P`: negative base-10 logarithm of the p-value
- `EXTRA`: additional test information, not used for the standard quantitative-trait test

For example:

```text
CHROM=22
GENPOS=16488635
ID=rs3949130
ALLELE0=C
ALLELE1=A
A1FREQ=0.0762
N=424966
BETA=0.0398
SE=0.0219
LOG10P=1.156
```

This means:

- the SNP is on chromosome 22
- A is the tested allele
- A has a frequency of about 7.62%
- 424,966 participants contributed to the test
- each additional A allele was associated with a small positive change in standardized adjusted height
- the corresponding p-value was approximately 0.07, so this SNP was not genome-wide significant

REGENIE reports:

```text
LOG10P = -log10(p)
```

The usual GWAS threshold:

```text
p < 5 × 10^-8
```

corresponds approximately to:

```text
LOG10P > 7.3
```

---

## 7. Final downstream use

After chromosomes 1-13 complete, the final products will be 22 chromosome-level height GWAS summary-statistics files.

These can be combined into one genome-wide file and used for:

1. Final GWAS QC and validation
2. Conversion of `LOG10P` to ordinary p-values
3. MAGMA SNP-to-gene analysis
4. Gene-level height association scores
5. Protein-protein interaction network analyses
6. Connectivity, community-enrichment, and rare-seed proximity analyses

The conversion from REGENIE's `LOG10P` field is:

```text
P = 10^(-LOG10P)
```

---

## Replication summary

I reproduced the main steps of a UK Biobank height GWAS:

```text
UK Biobank participant height measurements
                    ↓
Select the first height measurement
                    ↓
REGENIE Step 1
Estimate participant polygenic background using
QCed, MAF-filtered, LD-pruned SNPs and covariates
                    ↓
Generate chromosome-specific LOCO predictions
                    ↓
REGENIE Step 2
Filter imputed variants and test each SNP against height
                    ↓
Chromosome-level height GWAS summary statistics
                    ↓
Combine and use in the downstream MAGMA and network pipeline
```

At the last observed point:

- Step 1 was complete
- Step 2 chromosomes 14-22 were complete
- chromosomes 1-13 had been corrected for memory use and resubmitted
- the rerun was waiting for Blanca maintenance to end
