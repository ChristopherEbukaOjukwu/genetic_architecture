# Project scope

## Research question

Do common-variant GWAS associations occupy non-random positions in protein-protein interaction networks, and are the observed patterns consistent with proposed network signatures of complex-trait genetic architecture?

The project will examine three network properties:

1. Gene connectivity
2. Community-level concentration of GWAS evidence
3. Proximity of GWAS evidence to independently defined Mendelian or rare large-effect genes

The analyses will identify patterns consistent with particular genetic architectures: omnigenic, stratagenic, infinitesimal, oligogenic, or related models.

## Traits

### Primary and development trait

Height, representing a canonical highly polygenic quantitative trait.

Height will be used to construct, debug, and evaluate the analysis pipeline.

### Confirmatory trait

Schizophrenia, representing a highly polygenic neuropsychiatric disorder with:

* substantial common-variant GWAS signal;
* rare larger-effect coding variants identified independently of common-variant GWAS;
* broader evidence of convergence on neuronal and synaptic biology;
* no single APOE-like locus expected to dominate the analysis.

The schizophrenia analysis will be run after the primary analytical decisions have been finalized using height.

## GWAS datasets

### Height

Primary dataset:

Yengo et al. 2022, Nature, GIANT height GWAS.

Primary summary-statistics file:

* `GIANT_HEIGHT_YENGO_2022_GWAS_SUMMARY_STATS_EUR.gz`
* Predominantly European-ancestry analysis
* GRCh37/hg19 coordinates
* Public summary statistics exclude 23andMe data due to restrictions
* Available per-variant sample sizes will be summarized from the `N` column because not every SNP was tested in the same number of people

Height will be analyzed using:

* GRCh37 gene annotations;
* a matching GRCh37 LD reference panel: 1000 Genomes Phase 3 EUR, GRCh37;
* stable gene identifiers for later harmonization with the schizophrenia results.

### Schizophrenia

Primary dataset:

PGC 2022 schizophrenia GWAS from Trubetskoy et al.

Primary summary-statistics source:

* PGC `scz2022` summary statistics;
* preferably European-ancestry or European-compatible summary statistics where available;
* genome build will be confirmed from the downloaded file README before analysis;
* all downstream analyses will be harmonized to GRCh37.

Schizophrenia will be analyzed using:

* GRCh37 gene annotations;
* a matching GRCh37 LD reference panel: 1000 Genomes Phase 3 EUR, GRCh37;
* the same MAGMA SNP-to-gene mapping framework used for height.

If the downloaded schizophrenia summary statistics are not already in GRCh37, they will be lifted to GRCh37 before SNP filtering, LD matching, and gene-level analysis. Variant counts will be recorded before and after build harmonization.

## Locus handling

No primary locus will be excluded from the schizophrenia analysis.

Unlike Alzheimer’s disease, schizophrenia does not have a single APOE-like common-variant locus that must be removed in the primary analysis. However, the MHC region on chromosome 6 will be monitored descriptively because it is a known strong and complex schizophrenia-associated region.

If the MHC region dominates the results, an MHC-excluded analysis may be reported as exploratory rather than as part of the confirmatory primary plan.

## Variant set

The primary analyses will use common variants.

When frequency is unavailable in the GWAS file, frequency from the matched LD reference panel will be used and documented as reference-panel MAF.

Primary analyses will initially be restricted to:

* autosomal variants;
* biallelic SNPs, because multi-allelic variants can be harder to harmonize;
* variants with valid positions and p-values;
* variants present in the matched LD reference panel.

## SNP-to-gene mapping

### Primary gene-level analysis

MAGMA gene-level analysis will use:

* the gene body;
* 35 kb upstream of the transcription start site;
* 10 kb downstream of the transcription end site;
* an LD reference matched to the GWAS dataset.

MAGMA will combine association evidence across variants assigned to each gene while accounting for LD.

## GWAS outcome variables

### Primary outcome

Continuous MAGMA gene-level Z-score.

A higher Z-score represents stronger gene-level GWAS association evidence.

### Additional descriptive outcomes

* number of SNPs included in each MAGMA gene test.

## Networks

### Primary network

STRING human physical protein–protein interaction network:

* species: Homo sapiens;
* physical subnetwork;
* combined confidence score >= 700;
* undirected;
* protein-coding genes only;
* self-loops removed;
* duplicated gene–gene edges collapsed.

STRING scores will be interpreted as confidence that an interaction exists, not as biological interaction strength.

### Primary connectivity measure

Unweighted node degree: number of direct network connections of a gene.

This is the most interpretable connectivity measure.

### Robustness network

BioGRID human physical protein–protein interaction network.

The main analyses will be repeated using BioGRID to determine whether the conclusions depend on the STRING network.

STRING and BioGRID will remain separate networks and will not be merged.

## Network universe

For each trait and network, the analysis will include only genes that:

* received a valid MAGMA gene-level association score; and
* are present as nodes in the PPI network.

Thus, the analysis universe is the intersection of the MAGMA gene set and the network gene set.

Genes absent from the network will be excluded rather than assigned a degree of zero.

## Community detection

Leiden was selected because it matches the study’s definition of a community as a densely and internally connected group of proteins. Leiden is computationally efficient and designed to avoid poorly connected communities. It also keeps community detection separate from the Random Walk with Restart proximity analysis.

### Primary method

Primary method: Leiden community detection.

Leiden will divide the cleaned PPI network into densely and internally connected communities using network structure only. GWAS association scores will be added after communities have been defined.

The Leiden resolution parameter and random seed will be fixed before testing community enrichment.

## Mendelian and rare large-effect seed genes

Seed genes will be defined independently of the common-variant GWAS results.

### Height seeds

Primary seed set:

* the curated abnormal-skeletal-growth gene set reported by Yengo et al. 2022;
* because the GWAS analyses are restricted to autosomes, only autosomal seed genes will be used.

This set includes genes involved in Mendelian disorders characterized by abnormal stature, skeletal growth, short stature, tall stature, overgrowth, skeletal dysplasia, or related growth phenotypes.

### Schizophrenia seeds

Primary seed set:

* rare large-effect schizophrenia genes identified independently of common-variant GWAS;
* primary source: SCHEMA rare coding-variant results;
* the initial seed set will use genes meeting the predefined strongest evidence threshold from SCHEMA;
* an expanded seed set may use SCHEMA genes meeting FDR < 5%, if prespecified before the schizophrenia analysis.

These seed genes represent rare coding-variant evidence for schizophrenia risk and are independent of the common-variant GWAS summary statistics used for MAGMA.

### Overlap handling

Seed genes will be excluded from the tested GWAS gene set when evaluating the association between MAGMA Z-score and network proximity to the seed set. This avoids inflating proximity results by allowing seed genes to be scored as maximally close to themselves.

## Network propagation

Random Walk with Restart will be used to calculate the proximity of each network gene to the trait-specific seed genes.

Primary restart probability:

[
r=0.5
]

Each gene will receive an RWR score. A higher score means the gene is more strongly connected to the seed genes through the network.

## Primary analyses

### 1. Connectivity analysis

Question:

> Is gene-level GWAS evidence associated with node degree?

The primary coefficient is the association between node degree and MAGMA Z-score.

### 2. Community enrichment analysis

Questions:

> Are some network communities more enriched for GWAS evidence than others?

> Does community membership explain variation in GWAS evidence beyond individual gene characteristics?

The primary analysis will compare continuous MAGMA gene-level Z-scores across Leiden communities.

Community membership will be tested as a predictor of MAGMA Z-score while adjusting for relevant gene-level covariates such as degree, gene length, number of SNPs included in the MAGMA gene test, and publication count. We adjust because a community may look important just because its genes are long, contain more SNPs, are highly connected, or are better studied.

False-discovery-rate correction will be applied across community-level tests within each trait.

### 3. Rare-seed proximity analysis

Question:

> Do genes with stronger common-variant GWAS evidence lie closer in the network to independently defined rare large-effect schizophrenia genes?

A positive RWR coefficient means that genes more strongly connected to the seed genes tend to have stronger common-variant GWAS evidence.

The observed seed result will be compared with random seed sets matched on number of genes, node degree, publication count, and network component.

The real network will remain fixed during these permutations. Only the observed and random seed labels change.

This is to test whether common-variant GWAS evidence is closer to independently defined rare large-effect schizophrenia genes than expected for genes with similar connectedness, publication attention, and network location.

## Research-attention adjustment

An argument is that the scientific literature partly shapes protein-interaction networks, and that genes that have been studied more extensively are more likely to have recorded protein interactions, better annotations, and higher apparent network connectivity.

This extends the argument to say that a gene may appear highly connected or close to rare large-effect seed genes partly because it is well studied, not necessarily because it is biologically more central to the trait.

To account for this, publication count will be included as a proxy for research attention. Publication count will be calculated as the number of unique PubMed records linked to each gene, using NCBI `gene2pubmed` or an equivalent gene-publication mapping source.

## Required covariates

Connectivity and proximity models will account for:

* gene length;
* number of SNPs included in the MAGMA gene test;
* publication count;
* network community.

Models will be reported both with and without publication-count adjustment.

## Architectural interpretation

The three primary analyses will be interpreted jointly.

### Pattern consistent with an omnigenic-like signature

* GWAS evidence is broadly distributed;
* higher RWR proximity to rare large-effect seed genes predicts stronger GWAS evidence;
* the pattern is not confined to only one or two communities;
* the result is directionally consistent across STRING and BioGRID.

### Pattern consistent with a stratogenic-like signature

* GWAS evidence differs substantially across communities;
* a restricted collection of communities contains disproportionately strong association evidence;
* enriched communities represent distinct biological processes.

### Pattern consistent with an oligogenic-like signature

* a small number of loci, genes, or communities dominate the results;
* the overall signal is strongly shaped by a limited number of regions rather than broadly distributed evidence.

For schizophrenia, this will be evaluated descriptively by checking whether results are dominated by a small number of known regions, including the MHC region. Any MHC-excluded analysis will be labeled exploratory unless prespecified before the confirmatory run.

### Pattern consistent with a polygenic signature

* GWAS evidence is broadly distributed;
* degree is not reproducibly associated with GWAS signal;
* community enrichment is weak;
* rare-seed proximity does not predict GWAS evidence.

These interpretations describe consistency with model predictions. They will not be used to claim definitive proof or refutation of an entire genetic-architecture model.

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
3. preregister the schizophrenia confirmatory analysis;
4. run the schizophrenia analysis without changing the primary methods based on its results.

Additional analyses may still be performed, but analyses not specified in the confirmatory plan will be labeled exploratory.

## Out of scope

The following are not part of the initial project:

* tissue-specific co-expression networks;
* gene-regulatory networks;
* rare-variant burden testing;
* multi-ancestry comparisons;
* extra sensitivity analysis.

These may be considered after the primary PPI-based project is completed.
