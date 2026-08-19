All of Us Height GWAS — Pipeline Progress

1. Analysis objective

Development GWAS of measured height in All of Us using REGENIE.

Current analysis population:

European-ancestry participants only

Autosomal common variants

Quantitative phenotype: inverse-normal transformed height

Current status:

Phenotype/covariate construction complete

WGS and array sample QC complete

Chromosome 22 development GWAS complete

Step 1 array data localized and sample IDs harmonized

Step 1 QC strategy aligned to Luke's existing UKB REGENIE workflow

Step 1 LD-pruning pass currently running

2. Base WGS cohort

Base WGS cohort:

535,662 participants

Defined by:

Short Read WGS availability

3. Height phenotype selection

Standard height concept:

LOINC Body height

measurement_concept_id = 3036277

All of Us staff-measured source:

measurement_source_concept_id = 903133

The staff-measured PPI height source was selected because the broader Body Height concept contained heterogeneous sources, scales, units, and missing unit metadata.

Initial PPI height data:

Records: 543,899

People: 528,386

Numeric height records: 521,509

Raw numeric height summary:

Mean:   167.96 cm
SD:       9.86 cm
Min:     90.0 cm
Median: 167.6 cm
Max:    226.1 cm

4. Repeated-height handling
   
Participants with at least one valid numeric height:

507,353

Participants with exactly one valid height:

493,197

Participants with multiple valid heights:

14,156

Repeat-measurement rule:

One valid height → use it.

Multiple heights with range ≤10 cm → use the median.

Multiple heights with range >10 cm → exclude the participant.

Participants excluded for conflicting repeated heights:

119

Final height sample after repeat-resolution:

507,234

5. Age calculation and age QC

Representative measurement date:

Median measurement date per participant

Age:

(measurement_date - birth_datetime).days / 365.25

Age range before QC:

Min:   17.58
Mean:  52.02
Max:  118.94

Age rule:

Include age 18–100 years

After age QC:

507,047 participants

187 excluded

6. Sex-at-birth covariate

Primary binary sex-at-birth covariate:

Female → 0

Male → 1

Before filtering:

Female:          306,619
Male:            195,548
Skip:              4,341
Prefer not:           399
None of these:        176
Intersex:             104
No matching:           47

After restricting to Female/Male:

501,980 participants

Female: 306,491

Male: 195,489

This was a methodological choice for the binary covariate used in the current development GWAS.

7. Genetic ancestry and principal components

Participant ancestry file:

gs://vwb-aou-datasets-controlled/v9/wgs/short_read/snpindel/aux/ancestry/ancestry_preds.tsv

Columns used:

research_id

ancestry_pred

pca_features

All WGS ancestry counts:

EUR  302,714
AMR  107,928
AFR  100,800
EAS   15,893
SAS    6,176
MID    2,151

After merging ancestry/PCA data into the phenotype-QC sample:

EUR  283,720
AMR   98,876
AFR   96,720
EAS   14,796
SAS    5,834
MID    2,034

No ancestry/PCA data were missing.

pca_features contained:

16 PCs per participant

Expanded to:

PC1 ... PC16

PC1-PC16 means the first 16 principal components of genetic variation.

Each PC is a numeric variable that summarizes a major pattern of genetic similarity/difference across participants.

Also created:

age2 = age_at_measurement^2

8. European-ancestry restriction

The development GWAS was restricted to:

ancestry_pred == "eur"

Initial EUR sample:

283,720

This keeps the current development analysis aligned with the EUR-focused downstream workflow.

9. WGS sample QC

All of Us WGS QC files examined included:

aux/qc/flagged_samples.tsv
aux/qc/wgs_sex_concordance_exception_manifest.tsv

Within the EUR phenotype sample:

Flagged genomic-QC participants: 261

WGS sex-concordance exceptions: 175

Union of exclusions: 435

One participant appeared in both lists.

After WGS sample QC:

283,285 participants

10. Height inverse-normal transformation

IRNT was performed after phenotype QC, ancestry restriction, and genomic sample QC.

Method:

ranks = rankdata(height, method="average")
height_irnt = norm.ppf((ranks - 0.5) / n)

IRNT summary:

N:       283,285
Mean:    -0.000003
SD:       0.999634
Min:     -4.637293
Median:  -0.002194
Max:      4.637293

11. Final phenotype/covariate dataset before array-specific QC

Columns:

person_id
height_cm
height_irnt
sex
age_at_measurement
age2
PC1-PC16

Dimensions:

283,285 participants

21 columns

Persistent output:

gs://height-gwas-data-wb-lukewarm-pumpkin-3556/phenotype/height_eur_phenotype_covariates.tsv

Local mounted copy:

~/workspace/height-gwas-data/height_eur_phenotype_covariates.tsv

12. Chromosome 22 WGS development test

All of Us ACAF-threshold WGS PGEN source:

gs://vwb-aou-datasets-controlled/v9/wgs/short_read/snpindel/acaf_threshold/

Chromosome 22 files:

acaf_threshold.chr22.pgen
acaf_threshold.chr22.psam
acaf_threshold.chr22.pvar

Initial chr22 variant count:

895,732

Simple biallelic A/C/G/T SNPs:

426,463

EUR sample subset:

283,285 participants

PLINK2 subset command:

plink2 \
  --pfile /tmp/chr22_test/acaf_threshold.chr22 \   # Input chr22 PGEN dataset
  --keep /tmp/chr22_test/eur_keep.txt \             # Keep only EUR analysis participants
  --snps-only just-acgt \                            # Keep only simple A/C/G/T SNPs
  --max-alleles 2 \                                  # Keep only biallelic variants
  --set-all-var-ids '@:#:$r:$a' \                   # Rename variants as chr:position:ref:alt
  --make-pgen \                                      # Write a new filtered PGEN dataset
  --out /tmp/chr22_test/height_eur_chr22             # Output prefix

13. Common-variant filtering on chr22

Applied:

--maf 0.01

Result:

Removed: 356,165

Retained: 70,298 common SNPs

14. REGENIE phenotype/covariate files

Phenotype file:

/tmp/chr22_test/height_pheno.tsv

Columns:

FID
IID
height_irnt

Covariate file:

/tmp/chr22_test/height_covar.tsv

Columns:

FID
IID
sex
age_at_measurement
age2
PC1-PC16

Covariates:

Sex

Age

Age² #allows for curved age relationship, not just linear

16 principal components

No missing phenotype/covariate values.

Convention:

FID = IID = person_id

15. PSAM ID correction

Original WGS .psam contained:

#IID SEX

REGENIE required compatible FID/IID identifiers.

The .psam was rewritten to:

#FID IID SEX
person_id person_id NA

Command:

awk 'BEGIN{OFS="\t"}
NR==1 {print "#FID","IID","SEX"; next}
{print $1,$1,$2}
' /tmp/chr22_test/height_eur_chr22.psam \
> /tmp/chr22_test/height_eur_chr22_maf01.psam

16. First chr22 REGENIE test

Development-only Step 2:

# Run REGENIE association testing
regenie \
  # Step 2 = test variants for association with the phenotype
  --step 2 \
  # Input filtered chr22 PGEN genotype dataset
  --pgen /tmp/chr22_test/height_eur_chr22_maf01 \
  # Phenotype file containing height_irnt
  --phenoFile /tmp/chr22_test/height_pheno.tsv \
  # Covariate file containing sex, age, age², and PCs
  --covarFile /tmp/chr22_test/height_covar.tsv \
  # Use inverse-normal transformed height as the phenotype
  --phenoCol height_irnt \
  # Specify that height is a quantitative trait
  --qt \
  # Development test only: run Step 2 without Step 1 predictions
  --ignore-pred \
  # Process variants in blocks of 400
  --bsize 400 \
  # Use 4 CPU threads
  --threads 4 \
  # Output file prefix
  --out /tmp/chr22_test/height_chr22_test
  
This was a genuine chromosome 22 GWAS, but only a development test because:

Only chr22 was analyzed.

--ignore-pred was used.

Genome-wide REGENIE Step 1 predictions had not yet been created.

First result:

Tests: 69,625

Low-MAC variants ignored: 673

Problem detected:

Per-variant N ranged from 6 to 283,285

Some ACAF variants had extreme genotype missingness in the EUR subset.

17. Variant missingness diagnosis

Variant missingness was calculated:
for each chr22 variant, how many participants were missing a genotype call.

plink2 \
  --pfile /tmp/chr22_test/height_eur_chr22_maf01 \
  --missing variant-only \
  --out /tmp/chr22_test/chr22_missing

MISSING_CT   = number of participants missing that genotype
OBS_CT       = number of participants considered
F_MISS       = fraction missing

Among 70,298 variants:

Mean F_MISS:    0.02047
Median:         0.000113
90th percentile 0.002694
95th percentile 0.022709
99th percentile 0.999813
Max             1.0

Counts:

>1% missing:   4,509
>5% missing:   2,749
>10% missing:  2,200
>20% missing:  1,742
>50% missing:  1,162

Decision:

Require genotype missingness ≤1%

PLINK option: --geno 0.01

18. Final chr22 QC test

Applied:

plink2 \
  --pfile /tmp/chr22_test/height_eur_chr22_maf01 \
  --geno 0.01 \
  --make-pgen \
  --out /tmp/chr22_test/height_eur_chr22_maf01_geno01

Removed:

4,509 variants

Retained:

65,789 variants

Re-ran REGENIE Step 2:

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

Final chr22 test:

Variants tested: 65,789

Low-MAC variants ignored: 0

Per-variant N:

Min:     280,456
Median:  283,255
Max:     283,285

This confirmed that the --geno 0.01 filter solved the severe missingness problem.

19. Example chr22 association

Strongest observed signal included:

Variant: 22:32662616:G:A
A1FREQ:  0.151872
N:       283,238
BETA:   -0.023652
SE:      0.002635
LOG10P: 18.5506

Several nearby variants around ~32.65–32.70 Mb also showed strong association, consistent with an LD cluster.

Result persisted to:

gs://height-gwas-data-wb-lukewarm-pumpkin-3556/results/height_chr22_qc_test_height_irnt.regenie

20. Transition to genome-wide REGENIE

The full GWAS will use:

REGENIE Step 1 → genome-wide prediction model
REGENIE Step 2 → chromosome-by-chromosome WGS association testing

The chromosome 22 run used --ignore-pred only as a development test.

The final genome-wide Step 2 must use predictions from Step 1.

21. Microarray data selected for REGENIE Step 1

All of Us microarray PLINK files:

gs://vwb-aou-datasets-controlled/v9/microarray/plink/arrays.bed
gs://vwb-aou-datasets-controlled/v9/microarray/plink/arrays.bim
gs://vwb-aou-datasets-controlled/v9/microarray/plink/arrays.fam

Sizes:

arrays.bed  ~215.19 GiB
arrays.bim  ~69 MB
arrays.fam  ~10.5 MB

Array dataset:

553,949 participants

1,667,823 variants

Simple autosomal A/C/G/T SNPs:

1,583,622

Chromosome coverage includes all autosomes 1–22.

All 283,285 original EUR height participants were present in the array dataset.

22. Array-specific sex-concordance QC

Array QC file:

gs://vwb-aou-datasets-controlled/v9/microarray/aux/qc/array_sex_concordance_exception_manifest.tsv

Overlap with the 283,285-person EUR height sample:

1 participant

That participant was excluded.

Current genome-wide Step 1 sample:

283,284 participants

Updated Step 1 phenotype/covariate files:

/tmp/array_step1/height_pheno.tsv
/tmp/array_step1/height_covar.tsv

Each file has:

283,284 participant rows

1 header row

Total lines: 283,285

23. FID/IID harmonization for array data

Original array .fam:

FID = 0
IID = person_id

Phenotype/covariate convention:

FID = person_id
IID = person_id

To prevent REGENIE sample-matching problems, the array .fam was rewritten.

Original saved as:

/tmp/array_step1/arrays.fam.original

Corrected .fam:

awk 'BEGIN{OFS="\t"} {print $2,$2,$3,$4,$5,$6}' \
  /tmp/array_step1/arrays.fam.original \
  > /tmp/array_step1/arrays.fam

Current array convention:

FID = IID = person_id

Example:

1000000 1000000 0 0 0 NA
1000004 1000004 0 0 0 NA

This now matches both:

REGENIE phenotype/covariate files

WGS Step 2 PSAM convention

24. Correct Step 1 keep file

A one-column IID keep file was initially created.

After rewriting the .fam, a correct two-column keep file was created:

tail -n +2 /tmp/array_step1/height_pheno.tsv \
  | cut -f1,2 \
  > /tmp/array_step1/step1_keep_fid_iid.txt

Format:

FID IID

without a header.

Rows:

283,284

25. Current array file status

The full array .bed has been copied locally:

/tmp/array_step1/arrays.bed

Copy completed successfully:

215.1 GiB

Current array working set:

/tmp/array_step1/arrays.bed
/tmp/array_step1/arrays.bim
/tmp/array_step1/arrays.fam
/tmp/array_step1/arrays.fam.original

26. Step 1 array QC development

Two array-QC specifications were evaluated before freezing the Step 1 workflow.

Initial conservative QC

plink2 \
  --bfile /tmp/array_step1/arrays \                         # Raw All of Us microarray genotype data
  --keep /tmp/array_step1/step1_keep_fid_iid.txt \          # Keep final EUR analysis participants
  --autosome \                                               # Autosomes 1–22 only
  --snps-only just-acgt \                                    # Simple A/C/G/T SNPs only
  --max-alleles 2 \                                          # Biallelic variants only
  --maf 0.01 \                                               # Minor allele frequency ≥ 1%
  --mac 100 \                                                # At least 100 minor-allele copies
  --geno 0.01 \                                              # ≤1% genotype missingness
  --hwe 1e-15 \                                              # Hardy-Weinberg QC threshold
  --make-pgen \                                              # Create filtered PGEN dataset
  --out /tmp/array_step1/arrays_eur_qc                       # Output prefix

Result:

Samples: 283,284

Variants retained: 721,253

Luke-style broad QC test

A second QC pass used thresholds visible in Luke's REGENIE Step 2 preprocessing:

plink2 \
  --bfile /tmp/array_step1/arrays \
  --keep /tmp/array_step1/step1_keep_fid_iid.txt \
  --autosome \
  --snps-only just-acgt \
  --max-alleles 2 \
  --maf 0.001 \
  --geno 0.05 \
  --hwe 1e-9 keep-fewhet \
  --make-pgen \
  --threads 4 \
  --out /tmp/array_step1/arrays_eur_qc_luke

Result:

Samples: 283,284

Variants retained: 871,490

This run was useful for understanding Luke's QC conventions, but it is not the final Step 1 marker definition.

27. Luke's actual REGENIE Step 1 reference

Luke's Step 1 script uses an already:

EUR-restricted

MAF-filtered

QC-filtered

LD-pruned

genotype set:

/pl/active/IBG/data/UKB/derived/common/relatedness/white/merged_QC/eur.qc

Tracing the upstream UKB files showed that this dataset was built chromosome-by-chromosome from pruned marker lists and then merged.

For chromosome 1, the pruning log showed:

--geno 0.05
--hwe 1e-8
--maf 0.05
--indep-pairwise 50 5 0.2

Luke's Step 1 preparation used:

MAF ≥ 5%

genotype missingness ≤ 5%

HWE p ≥ 1e-8

LD pruning with --indep-pairwise 50 5 0.2

Luke's REGENIE Step 1 settings:

12 threads
20 GB RAM
--bsize 200
--lowmem

28. Current Step 1 pruning pass

To match the structure of Luke's Step 1 preparation cleanly, the pruning pass is being run directly from the raw All of Us array dataset, not from an intermediate differently filtered PGEN.

Current command:

plink2 \
  --bfile /tmp/array_step1/arrays \                         # Raw All of Us microarray genotype data
  --keep /tmp/array_step1/step1_keep_fid_iid.txt \          # Keep final 283,284 EUR analysis participants
  --autosome \                                               # Autosomes 1–22 only
  --snps-only just-acgt \                                    # Simple A/C/G/T SNPs only
  --max-alleles 2 \                                          # Biallelic variants only
  --maf 0.05 \                                               # Keep variants with MAF ≥ 5%
  --geno 0.05 \                                              # Remove variants missing in >5% of participants
  --hwe 1e-8 \                                               # Hardy-Weinberg QC threshold
  --indep-pairwise 50 5 0.2 \                                # LD-prune: 50-SNP window, shift 5 SNPs, r² threshold 0.2
  --threads 4 \                                               # Use 4 CPU threads
  --out /tmp/array_step1/step1_prune                         # Output pruning files
  
Purpose:

Restrict to the final 283,284-person EUR analysis sample.

Restrict to autosomal biallelic A/C/G/T SNPs.

Keep common array markers with MAF ≥5%.

Remove variants with >5% missingness.

Remove strong HWE departures.

LD-prune correlated markers using Luke's 50 5 0.2 specification.

Expected primary output:

/tmp/array_step1/step1_prune.prune.in

This marker list will define the genotype set used for REGENIE Step 1.

Status:

LD-pruning pass currently running.

29. REGENIE Step 1 / Step 2 distinction

The current architecture is:

Raw array genotypes
→ Step 1-specific QC
→ LD pruning
→ REGENIE Step 1
→ prediction list
→ chromosome-by-chromosome WGS QC
→ REGENIE Step 2

Step 1 markers are used only to fit the genome-wide prediction model.

Step 2 variants are the actual GWAS-tested variants.

The Step 1 MAF threshold therefore does not define the final scientific variant set.

30. Planned Step 2 variant definition

The project focuses on common-variant genetic architecture.

The current intended Step 2 WGS rules remain:

autosomal

simple A/C/G/T SNPs

biallelic

EUR MAF ≥ 1%

genotype missingness ≤ 1%

The 1% MAF threshold defines the tested common-variant set for the scientific analysis.

Luke's UKB Step 2 script used a broader MAF ≥0.1% threshold, but that is not being adopted automatically because it would include low-frequency variants outside the project's original common-variant definition.

31. Current primary covariates

The current GWAS adjustment set is:

sex
age_at_measurement
age2
PC1-PC16

The 16 PCs come from the All of Us participant ancestry/PCA file, not the ancestry-specific PCA training files.

32. Current storage state

Large local files include:

/tmp/array_step1/arrays.bed                  ~216 GB
/tmp/array_step1/arrays_eur_qc_luke.pgen    ~32 GB

The raw array dataset must be retained until the final Step 1 marker/genotype set is created and persisted.

The older conservative QC dataset can be deleted if additional disk space is needed.

33. Next steps

After the LD-pruning command finishes:

Record the number of retained Step 1 markers.

Build the final Step 1 genotype dataset using step1_prune.prune.in.

Persist the final Step 1 dataset and logs to the workspace bucket.

Remove unnecessary large intermediate files.

Resize the VM if needed for REGENIE Step 1.

Run one EUR REGENIE Step 1.

Use the resulting predictions for chromosome-by-chromosome WGS Step 2.

34. Methodological items still to freeze

Before treating the full GWAS pipeline as final:

Confirm the final Step 1 marker count after pruning.

Confirm final VM resources for REGENIE Step 1.

Confirm whether the 16 projected PCs remain the final PC specification.

Freeze the Step 2 WGS QC thresholds.

Preserve exact PLINK/REGENIE commands and logs.

Handle All of Us GRCh38 coordinates explicitly in downstream MAGMA/network integration.
