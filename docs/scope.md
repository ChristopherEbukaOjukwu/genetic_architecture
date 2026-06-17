# Project scope

## Research question

Do common-variant GWAS associations occupy non-random positions in
protein–protein interaction networks, and are the observed patterns
consistent with the proposed network signatures of complex-trait genetic
architecture?

The project will examine three network properties:

1. Gene connectivity
2. Community-level concentration of GWAS evidence
3. Proximity of GWAS evidence to Mendelian genes

The analyses will identify patterns consistent with particular genetic
architectures. They will not be treated as definitive proof or refutation
of the complete omnigenic, stratagenic, infinitesimal, or oligogenic
models.

## Traits

### Primary and development trait

Height, representing a canonical highly polygenic quantitative trait.

Height will be used to construct, debug, and evaluate the analysis
pipeline.

### Confirmatory trait

Alzheimer’s disease, representing mixed genetic architecture with:

* a major common-variant effect at APOE;
* rare larger-effect variants, including variants in TREM2;
* Mendelian familial Alzheimer genes;
* a broader polygenic background.

The Alzheimer analysis will be run after the primary analytical decisions
have been finalized using height.

## GWAS datasets

### Height

Primary dataset:

Yengo et al. 2022, Nature, GIANT height GWAS.

Primary summary-statistics file:

* `GIANT_HEIGHT_YENGO_2022_GWAS_SUMMARY_STATS_EUR.gz`
* Predominantly European-ancestry analysis
* GRCh37/hg19 coordinates (each row generally represents one SNP)
* Public summary statistics exclude 23andMe data due to restrictions
* Available per-variant sample sizes will be summarized from the `N`
  column because not every SNP was tested in the same number of
  people

Height will be analyzed using:

* GRCh37 gene annotations (the SNP positions in the height
  file use the GRCh37 version of the human genome);
* a matching GRCh37 LD reference panel;
* stable gene identifiers for later harmonization with the Alzheimer's
  results.

Sensitivity datasets:

* GIANT 2018 height meta-analysis

  * tests sensitivity to GWAS vintage and sample size
  * Basically, checks whether the network result is also found in an older and smaller GWAS;
* Yengo et al. 2022 UK Biobank-excluded analysis

  * tests whether UK Biobank-specific sample structure drives the result
  * Basically asks whether the network remains when UK Biobank is removed.

### Alzheimer’s disease and related dementias

Bellenguez et al. 2026, Nature Genetics 58, 1214–1225.

DOI: `10.1038/s41588-026-02583-1`

Primary dataset:

* `GCST90704647` (the main Alzheimer dataset to analyze);
* no-proxy meta-analysis (does not count for Alzheimer's cases reported in relatives);
* European-ancestry samples;
* GRCh38 coordinates.

## APOE handling

Primary Alzheimer analysis:

* exclude chr19:44,000,000–46,000,000 bp in GRCh38 from the GWAS
  data before the gene-level architectural analyses.

Sensitivity analysis:

* repeat the analysis with the APOE region included;
* report how strongly APOE changes the connectivity, community, and
  proximity results.

## Variant set

The primary analyses will use common variants:

[
\mathrm{MAF} \geq 1%
]

When effect-allele frequency is available:

[
\mathrm{MAF}=\min(\mathrm{EAF},1-\mathrm{EAF})
]

When frequency is unavailable in the GWAS file, frequency from the
matched LD reference panel will be used and documented as
reference-panel MAF.

Primary analyses will initially be restricted to:

* autosomal variants;
* biallelic SNPs;
* variants with valid positions and p-values;
* variants present in the matched LD reference panel.

## SNP-to-gene mapping

### Primary gene-level analysis

MAGMA gene-level analysis using:

* the gene body (all SNPs inside the gene itself);
* 35 kb upstream of the transcription start site (SNPs up to 35 kb before the gene starts);
* 10 kb downstream of the transcription end site (SNPs up to 10 kb after the gene ends);
* an LD reference matched to the GWAS dataset (tells MAGMA which SNPs are correlated).

MAGMA will combine association evidence across variants assigned to
each gene while accounting for LD.

### MAGMA mapping sensitivity

Repeat MAGMA using:

* gene body only.

This tests whether the main findings depend on the selected gene window.

## GWAS outcome variables

### Primary outcome

Continuous MAGMA gene-level Z-score.

A higher Z-score represents stronger gene-level GWAS association
evidence.

### Additional descriptive outcomes

* number of SNPs included in each MAGMA gene test;

## Networks

### Primary network

STRING human physical protein–protein interaction network:

* species: Homo sapiens;
* physical subnetwork (using actual PPI rather than all STRING functional relationships, such as co-expression, text mining, or shared pathway membership) ;
* combined confidence score >= 700 (high confidence indicates that an interaction exists);
* undirected (for interactions between two proteins);
* protein-coding genes only;
* self-loops removed (does not help measure connections between different genes);
* duplicated gene–gene edges collapsed.

STRING scores will be interpreted as confidence that an interaction
exists, not as biological interaction strength.

### Primary connectivity measure

Unweighted node degree:

[
k_g = \text{number of direct network connections of gene }g
]

This is the most interpretable connectivity measure.

### Robustness network

BioGRID human physical protein–protein interaction network.

The main analyses will be repeated using BioGRID to determine whether
the conclusions depend on the STRING network.

STRING and BioGRID will remain separate networks and will not be merged.

## Network universe

For each trait and network, the analysis will include only genes that:

* received a valid MAGMA gene-level association score; and
* are present as nodes in the PPI network.

Thus, the analysis universe is the intersection of the MAGMA gene set and the network gene set.

Genes absent from the network will be excluded rather than assigned a degree of zero.

## Community detection

Leiden was selected over K1 and M1 because it better matches the study’s definition of 
a community as a densely and internally connected group of proteins. K1 groups genes by 
similarity in their diffusion patterns, which overlaps conceptually with our separate 
Random Walk with Restart analysis. M1 also uses modularity, but Leiden is easier to implement, 
computationally efficient, and specifically designed to avoid poorly connected communities. 
Leiden therefore provides the clearest and simplest method for the primary community analysis.

### Primary method

Primary method: Leiden community detection.

Leiden will divide the cleaned PPI network into densely and internally
connected communities using network structure only. GWAS association
scores will be added after communities have been defined.

The Leiden resolution parameter and random seed will be fixed before
testing community enrichment.


--------------Begin Editing-------------------
## Mendelian and rare large-effect seed genes

Seed genes will be defined independently of the common-variant GWAS
results.

### Height seeds

Primary seed set:

* the curated abnormal-skeletal-growth gene set reported by
  Yengo et al. 2022;
* use the autosomal subset when the GWAS analysis is restricted to
  autosomes.

This set includes genes involved in Mendelian disorders characterized
by abnormal stature, skeletal growth, short stature, tall stature,
overgrowth, skeletal dysplasia, or related growth phenotypes.

Sensitivity seed set:

* genes with ClinGen Definitive or Strong gene–disease evidence for
  disorders in which abnormal linear or skeletal growth is a central
  phenotype.

### Alzheimer seeds

Primary seed set:

* APP
* PSEN1
* PSEN2

These are predefined canonical genes causing autosomal-dominant
early-onset Alzheimer’s disease.

Evidence sources may include:

* ClinGen, when an applicable Alzheimer gene–disease curation exists;
* GeneReviews;
* OMIM;
* a predefined published familial-Alzheimer review.

Sensitivity seed set:

* an expanded early-onset or familial Alzheimer gene set;
* its source and inclusion criteria must be finalized before examining
  the Alzheimer proximity results.

### Overlap handling

Some seed genes may also have common-variant GWAS evidence.

Proximity analyses will therefore be run:

1. including overlapping seed and GWAS genes;
2. excluding overlapping genes.

## Network propagation

Random Walk with Restart will be used to calculate the proximity of each
network gene to the trait-specific seed genes.

Primary restart probability:

[
r=0.5
]

Sensitivity values:

[
r\in{0.3,0.7}
]

Each gene will receive an RWR score. A higher score means the gene is
more strongly connected to the seed genes through the network.

Shortest-path distance to the nearest seed gene will be reported as a
secondary descriptive measure.

## Primary analyses

### 1. Connectivity analysis

Question:

> Is gene-level GWAS evidence associated with node degree?

Primary model:

[
\text{MAGMA Z-score}
\sim
\log(1+\text{degree})
+
\text{covariates}
+
\text{community}
]

The primary coefficient is the association between node degree and
MAGMA Z-score.

Secondary analysis:

* binary Bonferroni-significant MAGMA gene as the outcome.

### 2. Community enrichment analysis

Questions:

> Are some network communities more enriched for GWAS evidence than
> others?

> Does community membership explain variation in GWAS evidence beyond
> individual gene characteristics?

Two complementary analyses will be used:

1. binary enrichment of significant GWAS genes in each community;
2. continuous comparison of MAGMA Z-scores across communities.

False-discovery-rate correction will be applied across community tests
within each trait.

### 3. Mendelian-seed proximity analysis

Question:

> Do genes with stronger common-variant GWAS evidence lie closer in the
> network to independently defined Mendelian or rare large-effect genes?

Primary model:

[
\text{MAGMA Z-score}
\sim
\text{RWR score}
+
\text{covariates}
]

A positive RWR coefficient means that genes more strongly connected to
the seed genes tend to have stronger GWAS evidence.

The observed seed result will be compared with random seed sets matched
on:

* number of genes;
* node degree;
* publication count;
* network component.

The real network will remain fixed during these permutations.

## Required covariates

Connectivity and proximity models will account for:

* gene length;
* number of SNPs included in the MAGMA gene test;
* (\log(\text{publication count}+1));
* network community.

The precise treatment of community as a fixed or random effect will be
selected based on the number and size of the detected communities and
will be documented before the confirmatory Alzheimer analysis.

Models will be reported both with and without publication-count
adjustment.

## Architectural interpretation

The three primary analyses will be interpreted jointly.

### Pattern consistent with a core–peripheral or omnigenic-like signature

* GWAS evidence is broadly distributed;
* higher RWR proximity to Mendelian seeds predicts stronger GWAS
  evidence;
* the pattern is not confined to only one or two communities;
* the result is directionally consistent across STRING and BioGRID.

This would support a PPI-based core–peripheral signature. It would not
prove the complete omnigenic model.

### Pattern consistent with a modular or stratagenic-like signature

* GWAS evidence differs substantially across communities;
* a restricted collection of communities contains disproportionately
  strong association evidence;
* enriched communities represent distinct biological processes.

### Pattern consistent with an oligogenic-like signature

* a small number of loci, genes, or communities dominate the results;
* removal of the dominant region substantially weakens the pattern.

For Alzheimer’s disease, this will be examined by comparing the
APOE-excluded and APOE-included analyses.

### Pattern consistent with a network-unstructured polygenic signature

* GWAS evidence is broadly distributed;
* degree is not reproducibly associated with GWAS signal;
* community enrichment is weak;
* Mendelian-seed proximity does not predict GWAS evidence.

These interpretations describe consistency with model predictions.
They will not be used to claim definitive proof or refutation of an
entire genetic-architecture model.

## Planned sensitivity analyses

| Decision                | Primary                                     | Sensitivity                                  |
| ----------------------- | ------------------------------------------- | -------------------------------------------- |
| Network                 | STRING physical, score ≥700                 | BioGRID physical                             |
| Community detection     | MONET K1                                    | MONET M1                                     |
| RWR restart probability | (r=0.5)                                     | (r=0.3,\ 0.7)                                |
| MAGMA mapping window    | Gene body +35 kb upstream/+10 kb downstream | Gene body only                               |
| GWAS representation     | Continuous MAGMA Z-score                    | Binary significant gene                      |
| Locus-level mapping     | Not primary                                 | Independent lead SNPs mapped to nearest gene |
| Connectivity measure    | Unweighted degree                           | Confidence-weighted degree                   |
| Publication adjustment  | Included                                    | Excluded                                     |
| Alzheimer phenotype     | No-proxy                                    | Main; no-biobank                             |
| Alzheimer APOE handling | APOE excluded                               | APOE included                                |
| Alzheimer seed genes    | APP, PSEN1, PSEN2                           | Expanded familial-AD set                     |
| Height GWAS             | Yengo et al. 2022                           | GIANT 2018; UKBB-excluded                    |
| Height seed genes       | Yengo abnormal-growth set                   | ClinGen Strong/Definitive set                |

A sensitivity analysis will not be considered an automatic failure
merely because its p-value crosses 0.05. Effect direction, magnitude,
confidence interval, dataset coverage, and evidence of effect reversal
will all be reported.

## Multiple testing

Within each trait:

* one primary connectivity test will be identified;
* one primary RWR proximity test will be identified;
* community enrichment p-values will be corrected using
  Benjamini–Hochberg false-discovery-rate correction.

Height and Alzheimer’s disease will be interpreted as separate trait
analyses.

A formal claim that the traits differ will require a direct statistical
test of the difference. Otherwise, cross-trait differences will be
reported descriptively.

## Development and preregistration plan

Height will be used to:

* build the data-processing pipeline;
* select workable software parameters;
* identify data-quality problems;
* test the implementation of MAGMA, MONET, and RWR;
* finalize the regression and permutation procedures.

After the height pipeline is stable:

1. freeze the primary analysis decisions;
2. record the code version and configuration;
3. preregister the Alzheimer confirmatory analysis;
4. run the Alzheimer analysis without changing the primary methods
   based on its results.

Additional analyses may still be performed, but analyses not specified
in the confirmatory plan will be labeled exploratory.

## Out of scope

The following are not part of the initial project:

* tissue-specific co-expression networks;
* gene-regulatory networks;
* rare-variant burden testing;
* multi-ancestry comparisons;
* polygenic-score analysis;
* formal individual-level tests of stratagenic architecture;
* simulation-based classification of genetic architectures.

These may be considered after the primary PPI-based project is
completed.
