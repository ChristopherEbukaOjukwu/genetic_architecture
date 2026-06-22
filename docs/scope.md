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

The primary analyses will use common variants.
Or if absent, derived from effect-allele frequency if available.

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


## Mendelian and rare large-effect seed genes

Seed genes will be defined independently of the common-variant GWAS
results.

### Height seeds

Primary seed set:

* the curated abnormal-skeletal-growth gene set reported by
  Yengo et al. 2022;
* because the GWAS analyses are restricted to autosomes,
  only autosomal seed genes will be used.

This set includes genes involved in Mendelian disorders characterized
by abnormal stature, skeletal growth, short stature, tall stature,
overgrowth, skeletal dysplasia, or related growth phenotypes.

### Alzheimer seeds

Primary seed set examples:

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

### Overlap handling

Seed genes will be excluded from the tested GWAS gene set when evaluating
the association between MAGMA Z-score and network proximity to the seed
set. This avoids inflating proximity results by allowing seed genes to be
scored as maximally close to themselves.

## Network propagation

Random Walk with Restart will be used to calculate the proximity of each
network gene to the trait-specific seed genes.

Primary restart probability:

[
r=0.5
]

Each gene will receive an RWR score. A higher score means the gene is
more strongly connected to the seed genes through the network.

## Primary analyses

### 1. Connectivity analysis

Question:

> Is gene-level GWAS evidence associated with node degree?

The primary coefficient is the association between node degree and
MAGMA Z-score.

### 2. Community enrichment analysis

Questions:

> Are some network communities more enriched for GWAS evidence than
> others?

> Does community membership explain variation in GWAS evidence beyond
> individual gene characteristics?

The primary analysis will compare continuous MAGMA gene-level Z-scores
across Leiden communities.

Community membership will be tested as a predictor of MAGMA Z-score,
while adjusting for relevant gene-level covariates such as degree,
gene length, number of SNPs included in the MAGMA gene test, and
publication count. We adjust because a community may look important 
just because its genes are long, contain more SNPs, are highly 
connected, or are better studied.

False-discovery-rate correction will be applied across community-level
tests within each trait.

### 3. Mendelian-seed proximity analysis

Question:

> Do genes with stronger common-variant GWAS evidence lie closer in the
> network to independently defined Mendelian or rare large-effect genes?

A positive RWR coefficient means that genes more strongly connected to
the seed genes tend to have stronger GWAS evidence.

The observed seed result will be compared with random seed sets matched
on number of genes, node degree, publication count, network component.

The real network will remain fixed during these permutations.
Only the observed and random seed labels change.

This is to confirm that GWAS genes are closer to observed seed genes
than expected for genes with similar connectedness, publication 
attention, and network location.

## Research-attention adjustment

An argument is that the scientific literature partly shapes protein-interaction networks, 
and that genes that have been studied more extensively are more likely to have recorded 
protein interactions, better annotations, and higher apparent network connectivity.

This extends the argument to say that a gene may appear highly connected or close to 
Mendelian seed genes, partly because it is well studied, not necessarily because it 
is biologically more central to the trait.

To account for this, publication count will be included as a proxy for research attention. 
Publication count will be calculated as the number of unique PubMed records linked to each gene,
using NCBI `gene2pubmed` or an equivalent gene-publication mapping source.

## Required covariates

Connectivity and proximity models will account for:

* gene length;
* number of SNPs included in the MAGMA gene test;
* publication count
* network community.

Models will be reported both with and without publication-count
adjustment.

## Architectural interpretation

The three primary analyses will be interpreted jointly.

### Pattern consistent with an omnigenic-like signature

* GWAS evidence is broadly distributed;
* higher RWR proximity to Mendelian seeds predicts stronger GWAS
  evidence;
* the pattern is not confined to only one or two communities;
* the result is directionally consistent across STRING and BioGRID.

### Pattern consistent with a stratagenic-like signature

* GWAS evidence differs substantially across communities;
* a restricted collection of communities contains disproportionately
  strong association evidence;
* enriched communities represent distinct biological processes.

### Pattern consistent with an oligogenic-like signature

* a small number of loci, genes, or communities dominate the results;
* removal of the dominant region substantially weakens the pattern.

For Alzheimer’s disease, this will be examined by comparing the
APOE-excluded and APOE-included analyses.

### Pattern consistent with a polygenic signature

* GWAS evidence is broadly distributed;
* degree is not reproducibly associated with GWAS signal;
* community enrichment is weak;
* Mendelian-seed proximity does not predict GWAS evidence.

These interpretations describe consistency with model predictions.
They will not be used to claim definitive proof or refutation of an
entire genetic-architecture model.

## Development and preregistration plan

Height will be used to:

* build the data-processing pipeline;
* select workable software parameters;
* identify data-quality problems;
* test the implementation of MAGMA, Leiden, and RWR;
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

These may be considered after the primary PPI-based project is
completed.
