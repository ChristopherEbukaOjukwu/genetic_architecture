# All of Us Height GWAS — Pipeline Progress

## 1. Analysis objective

Development GWAS of measured height in All of Us using REGENIE.

Current analysis population:

- European-ancestry participants only
- Autosomal common variants
- Quantitative phenotype: inverse-normal transformed height

Current status:

- Phenotype/covariate construction complete
- Sample QC complete
- Chromosome 22 development GWAS complete
- Genome-wide REGENIE Step 1 preparation underway

---

# 2. Base WGS cohort

Base WGS cohort:

- **535,662 participants**

Defined by:

- Short Read WGS availability

---

# 3. Height phenotype selection

Standard height concept:

- **LOINC Body height**
- `measurement_concept_id = 3036277`

All of Us staff-measured source:

- `measurement_source_concept_id = 903133`

The staff-measured PPI height source was selected because the broader Body Height concept contained heterogeneous sources, scales, units, and missing unit metadata.

Initial PPI height data:

- Records: **543,899**
- People: **528,386**
- Numeric height records: **521,509**

Raw numeric height summary:

```text
Mean:   167.96 cm
SD:       9.86 cm
Min:     90.0 cm
Median: 167.6 cm
Max:    226.1 cm
```

---

# 4. Repeated-height handling

Participants with at least one valid numeric height:

- **507,353**

Participants with exactly one valid height:

- **493,197**

Participants with multiple valid heights:

- **14,156**

Repeat-measurement rule:

- One valid height → use it.
- Multiple heights with range ≤10 cm → use the median.
- Multiple heights with range >10 cm → exclude the participant.

Participants excluded for conflicting repeated heights:

- **119**

Final height sample after repeat-resolution:

- **507,234**

---

# 5. Age calculation and age QC

Representative measurement date:

- Median measurement date per participant

Age:

```text
(measurement_date - birth_datetime).days / 365.25
```

Age range before QC:

```text
Min:   17.58
Mean:  52.02
Max:  118.94
```

Age rule:

- Include age **18–100 years**

After age QC:

- **507,047 participants**
- **187 excluded**

---

# 6. Sex-at-birth covariate

Primary binary sex-at-birth covariate:

- Female → `0`
- Male → `1`

Before filtering:

```text
Female:          306,619
Male:            195,548
Skip:              4,341
Prefer not:           399
None of these:        176
Intersex:             104
No matching:           47
```

After restricting to Female/Male:

- **501,980 participants**
- Female: **306,491**
- Male: **195,489**

This was a methodological choice for the binary covariate used in the current development GWAS.

---

# 7. Genetic ancestry and principal components

Participant ancestry file:

```text
gs://vwb-aou-datasets-controlled/v9/wgs/short_read/snpindel/aux/ancestry/ancestry_preds.tsv
```

Columns used:

- `research_id`
- `ancestry_pred`
- `pca_features`

All WGS ancestry counts:

```text
EUR  302,714
AMR  107,928
AFR  100,800
EAS   15,893
SAS    6,176
MID    2,151
```

After merging ancestry/PCA data into the phenotype-QC sample:

```text
EUR  283,720
AMR   98,876
AFR   96,720
EAS   14,796
SAS    5,834
MID    2,034
```

No ancestry/PCA data were missing.

`pca_features` contained:

- **16 PCs per participant**

Expanded to:

```text
PC1 ... PC16
```

Also created:

```text
age2 = age_at_measurement^2
```

---

# 8. European-ancestry restriction

The development GWAS was restricted to:

- `ancestry_pred == "eur"`

Initial EUR sample:

- **283,720**

This keeps the current development analysis aligned with the EUR-focused downstream workflow.

---

# 9. WGS sample QC

All of Us WGS QC files examined included:

```text
aux/qc/flagged_samples.tsv
aux/qc/wgs_sex_concordance_exception_manifest.tsv
```

Within the EUR phenotype sample:

- Flagged genomic-QC participants: **261**
- WGS sex-concordance exceptions: **175**
- Union of exclusions: **435**
- One participant appeared in both lists.

After WGS sample QC:

- **283,285 participants**

---

# 10. Height inverse-normal transformation

IRNT was performed after phenotype QC, ancestry restriction, and genomic sample QC.

Method:

```python
ranks = rankdata(height, method="average")
height_irnt = norm.ppf((ranks - 0.5) / n)
```

IRNT summary:

```text
N:       283,285
Mean:    -0.000003
SD:       0.999634
Min:     -4.637293
Median:  -0.002194
Max:      4.637293
```

---

# 11. Final phenotype/covariate dataset before array-specific QC

Columns:

```text
person_id
height_cm
height_irnt
sex
age_at_measurement
age2
PC1-PC16
```

Dimensions:

- **283,285 participants**
- **21 columns**

Persistent output:

```text
gs://height-gwas-data-wb-lukewarm-pumpkin-3556/phenotype/height_eur_phenotype_covariates.tsv
```

Local mounted copy:

```text
~/workspace/height-gwas-data/height_eur_phenotype_covariates.tsv
```

---

# 12. Chromosome 22 WGS development test

All of Us ACAF-threshold WGS PGEN source:

```text
gs://vwb-aou-datasets-controlled/v9/wgs/short_read/snpindel/acaf_threshold/
```

Chromosome 22 files:

```text
acaf_threshold.chr22.pgen
acaf_threshold.chr22.psam
acaf_threshold.chr22.pvar
```

Initial chr22 variant count:

- **895,732**

Simple biallelic A/C/G/T SNPs:

- **426,463**

EUR sample subset:

- **283,285 participants**

PLINK2 subset command:

```bash
plink2 \
  --pfile /tmp/chr22_test/acaf_threshold.chr22 \
  --keep /tmp/chr22_test/eur_keep.txt \
  --snps-only just-acgt \
  --max-alleles 2 \
  --set-all-var-ids '@:#:$r:$a' \
  --make-pgen \
  --out /tmp/chr22_test/height_eur_chr22
```

---

# 13. Common-variant filtering on chr22

Applied:

```bash
--maf 0.01
```

Result:

- Removed: **356,165**
- Retained: **70,298 common SNPs**

---

# 14. REGENIE phenotype/covariate files

Phenotype file:

```text
/tmp/chr22_test/height_pheno.tsv
```

Columns:

```text
FID
IID
height_irnt
```

Covariate file:

```text
/tmp/chr22_test/height_covar.tsv
```

Columns:

```text
FID
IID
sex
age_at_measurement
age2
PC1-PC16
```

Covariates:

- Sex
- Age
- Age²
- 16 principal components

No missing phenotype/covariate values.

Convention:

```text
FID = IID = person_id
```

---

# 15. PSAM ID correction

Original WGS `.psam` contained:

```text
#IID SEX
```

REGENIE required compatible FID/IID identifiers.

The `.psam` was rewritten to:

```text
#FID IID SEX
person_id person_id NA
```

Command:

```bash
awk 'BEGIN{OFS="\t"}
NR==1 {print "#FID","IID","SEX"; next}
{print $1,$1,$2}
' /tmp/chr22_test/height_eur_chr22.psam \
> /tmp/chr22_test/height_eur_chr22_maf01.psam
```

---

# 16. First chr22 REGENIE test

Development-only Step 2:

```bash
regenie \
  --step 2 \
  --pgen /tmp/chr22_test/height_eur_chr22_maf01 \
  --phenoFile /tmp/chr22_test/height_pheno.tsv \
  --covarFile /tmp/chr22_test/height_covar.tsv \
  --phenoCol height_irnt \
  --qt \
  --ignore-pred \
  --bsize 400 \
  --threads 4 \
  --out /tmp/chr22_test/height_chr22_test
```

This was a genuine chromosome 22 GWAS, but only a development test because:

- Only chr22 was analyzed.
- `--ignore-pred` was used.
- Genome-wide REGENIE Step 1 predictions had not yet been created.

First result:

- Tests: **69,625**
- Low-MAC variants ignored: **673**

Problem detected:

- Per-variant N ranged from **6 to 283,285**
- Some ACAF variants had extreme genotype missingness in the EUR subset.

---

# 17. Variant missingness diagnosis

Variant missingness was calculated:

```bash
plink2 \
  --pfile /tmp/chr22_test/height_eur_chr22_maf01 \
  --missing variant-only \
  --out /tmp/chr22_test/chr22_missing
```

Among 70,298 variants:

```text
Mean F_MISS:    0.02047
Median:         0.000113
90th percentile 0.002694
95th percentile 0.022709
99th percentile 0.999813
Max             1.0
```

Counts:

```text
>1% missing:   4,509
>5% missing:   2,749
>10% missing:  2,200
>20% missing:  1,742
>50% missing:  1,162
```

Decision:

- Require genotype missingness ≤1%
- PLINK option: `--geno 0.01`

---

# 18. Final chr22 QC test

Applied:

```bash
plink2 \
  --pfile /tmp/chr22_test/height_eur_chr22_maf01 \
  --geno 0.01 \
  --make-pgen \
  --out /tmp/chr22_test/height_eur_chr22_maf01_geno01
```

Removed:

- **4,509 variants**

Retained:

- **65,789 variants**

Re-ran REGENIE Step 2:

```bash
regenie \
  --step 2 \
  --pgen /tmp/chr22_test/height_eur_chr22_maf01_geno01 \
  --phenoFile /tmp/chr22_test/height_pheno.tsv \
  --covarFile /tmp/chr22_test/height_covar.tsv \
  --phenoCol height_irnt \
  --qt \
  --ignore-pred \
  --bsize 400 \
  --threads 4 \
  --out /tmp/chr22_test/height_chr22_qc_test
```

Final chr22 test:

- Variants tested: **65,789**
- Low-MAC variants ignored: **0**

Per-variant N:

```text
Min:     280,456
Median:  283,255
Max:     283,285
```

This confirmed that the `--geno 0.01` filter solved the severe missingness problem.

---

# 19. Example chr22 association

Strongest observed signal included:

```text
Variant: 22:32662616:G:A
A1FREQ:  0.151872
N:       283,238
BETA:   -0.023652
SE:      0.002635
LOG10P: 18.5506
```

Several nearby variants around ~32.65–32.70 Mb also showed strong association, consistent with an LD cluster.

Result persisted to:

```text
gs://height-gwas-data-wb-lukewarm-pumpkin-3556/results/height_chr22_qc_test_height_irnt.regenie
```

---

# 20. Transition to genome-wide REGENIE

The full GWAS will use:

```text
REGENIE Step 1 → genome-wide prediction model
REGENIE Step 2 → chromosome-by-chromosome WGS association testing
```

The chromosome 22 run used `--ignore-pred` only as a development test.

The final genome-wide Step 2 must use predictions from Step 1.

---

# 21. Microarray data selected for REGENIE Step 1

All of Us microarray PLINK files:

```text
gs://vwb-aou-datasets-controlled/v9/microarray/plink/arrays.bed
gs://vwb-aou-datasets-controlled/v9/microarray/plink/arrays.bim
gs://vwb-aou-datasets-controlled/v9/microarray/plink/arrays.fam
```

Sizes:

```text
arrays.bed  ~215.19 GiB
arrays.bim  ~69 MB
arrays.fam  ~10.5 MB
```

Array dataset:

- **553,949 participants**
- **1,667,823 variants**

Simple autosomal A/C/G/T SNPs:

- **1,583,622**

Chromosome coverage includes all autosomes 1–22.

All **283,285** original EUR height participants were present in the array dataset.

---

# 22. Array-specific sex-concordance QC

Array QC file:

```text
gs://vwb-aou-datasets-controlled/v9/microarray/aux/qc/array_sex_concordance_exception_manifest.tsv
```

Overlap with the 283,285-person EUR height sample:

- **1 participant**

That participant was excluded.

Current genome-wide Step 1 sample:

- **283,284 participants**

Updated Step 1 phenotype/covariate files:

```text
/tmp/array_step1/height_pheno.tsv
/tmp/array_step1/height_covar.tsv
```

Each file has:

- 283,284 participant rows
- 1 header row
- Total lines: **283,285**

---

# 23. FID/IID harmonization for array data

Original array `.fam`:

```text
FID = 0
IID = person_id
```

Phenotype/covariate convention:

```text
FID = person_id
IID = person_id
```

To prevent REGENIE sample-matching problems, the array `.fam` was rewritten.

Original saved as:

```text
/tmp/array_step1/arrays.fam.original
```

Corrected `.fam`:

```bash
awk 'BEGIN{OFS="\t"} {print $2,$2,$3,$4,$5,$6}' \
  /tmp/array_step1/arrays.fam.original \
  > /tmp/array_step1/arrays.fam
```

Current array convention:

```text
FID = IID = person_id
```

Example:

```text
1000000 1000000 0 0 0 NA
1000004 1000004 0 0 0 NA
```

This now matches both:

- REGENIE phenotype/covariate files
- WGS Step 2 PSAM convention

---

# 24. Correct Step 1 keep file

A one-column IID keep file was initially created.

After rewriting the `.fam`, a correct two-column keep file was created:

```bash
tail -n +2 /tmp/array_step1/height_pheno.tsv \
  | cut -f1,2 \
  > /tmp/array_step1/step1_keep_fid_iid.txt
```

Format:

```text
FID IID
```

without a header.

Rows:

- **283,284**

---

# 25. Current array file status

The full array `.bed` has been copied locally:

```text
/tmp/array_step1/arrays.bed
```

Copy completed successfully:

```text
215.1 GiB
```

Current array working set:

```text
/tmp/array_step1/arrays.bed
/tmp/array_step1/arrays.bim
/tmp/array_step1/arrays.fam
/tmp/array_step1/arrays.fam.original
```

---

# 26. Current step — Step 1 genotype QC

We are **not yet running REGENIE Step 1**.

Current stage:

```text
Array genotype QC → LD pruning → REGENIE Step 1 → REGENIE Step 2
```

The current QC command is:

```bash
plink2 \
  --bfile /tmp/array_step1/arrays \
  --keep /tmp/array_step1/step1_keep_fid_iid.txt \
  --autosome \
  --snps-only just-acgt \
  --max-alleles 2 \
  --maf 0.01 \
  --mac 100 \
  --geno 0.01 \
  --hwe 1e-15 \
  --make-pgen \
  --out /tmp/array_step1/arrays_eur_qc
```

Purpose:

- Restrict to the 283,284 final participants.
- Restrict to autosomes.
- Keep simple A/C/G/T SNPs.
- Keep biallelic variants.
- MAF ≥1%.
- MAC ≥100.
- Genotype missingness ≤1%.
- HWE p ≥1e-15.
- Write a smaller filtered PGEN dataset.

Status at the time of this document:

- **Command currently running / awaiting completion.**

---

# 27. Next planned steps

After the current array QC finishes:

1. Inspect retained sample and variant counts.
2. LD-prune the QC-passing microarray variants.
3. Preserve the reduced Step 1 genotype dataset.
4. Consider resizing the VM before the expensive REGENIE Step 1 run.
5. Run one genome-wide REGENIE Step 1 for the EUR sample.
6. Use Step 1 predictions for chromosome-by-chromosome WGS Step 2.
7. Apply the validated WGS variant rules genome-wide:
   - autosomal
   - simple A/C/G/T SNP
   - biallelic
   - EUR MAF ≥1%
   - genotype missingness ≤1%

---

# 28. Current primary covariates

The current GWAS adjustment set is:

```text
sex
age_at_measurement
age2
PC1-PC16
```

The 16 PCs come from the All of Us participant ancestry/PCA file, not the ancestry-specific PCA training files.

---

# 29. Important methodological notes still to resolve/document

Before the final GWAS is treated as frozen:

- Confirm the final REGENIE Step 1 LD-pruning settings.
- Confirm whether the current 16 global/projected PCs remain the final PC specification.
- Document the `--geno 0.01` WGS missingness threshold.
- Decide final VM resources for Step 1.
- Preserve QC logs and exact commands.
- The All of Us genotype coordinates are GRCh38; downstream MAGMA/network integration must explicitly handle genome-build compatibility.
