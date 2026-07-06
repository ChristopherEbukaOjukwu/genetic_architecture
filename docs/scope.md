# Project scope

## Research question

Do common-variant GWAS associations occupy non-random positions in protein-protein interaction networks, and are the observed patterns consistent with proposed network signatures of complex-trait genetic architecture?

The project will examine three network properties:

1. Gene connectivity
2. Community-level concentration of GWAS evidence
3. Proximity of GWAS evidence to independently defined Mendelian or rare large-effect genes

The analyses will identify patterns consistent with particular genetic architectures: omnigenic, stratogenic, infinitesimal, oligogenic, or related models.

## Traits

### Primary and development trait

```Height```
represents a canonical highly polygenic quantitative trait.

Height will be used to construct, debug, and evaluate the analysis pipeline.

### Confirmatory trait

```Schizophrenia```
represents a highly polygenic neuropsychiatric disorder.
The schizophrenia analysis will be run after the primary analytical decisions have been finalized using height.

## GWAS datasets

### Height

Primary dataset:

Neale Lab UK Biobank Round 2 standing-height GWAS.

Primary summary-statistics file:

* Phenotype: `50_irnt`, UK Biobank standing height, inverse-rank-normal transformed.
* GWAS file: `50_irnt.gwas.imputed_v3.both_sexes.tsv.bgz`
* Download:

```bash
wget https://broad-ukb-sumstats-us-east-1.s3.amazonaws.com/round2/additive-tsvs/50_irnt.gwas.imputed_v3.both_sexes.tsv.bgz -O 50_irnt.gwas.imputed_v3.both_sexes.tsv.bgz
```

Variant metadata file:

* Metadata file: `variants.tsv.bgz`
* Download:

```bash
wget https://broad-ukb-sumstats-us-east-1.s3.amazonaws.com/round2/annotations/variants.tsv.bgz -O variants.tsv.bgz
```
File checks from local download:

* GWAS file: `13,791,468` lines, corresponding to `13,791,468` variant records.
* The GWAS file and variant metadata file can be joined by the `variant` column.

Height will be analyzed using:

* GRCh37/hg19 coordinates;
* GRCh37 gene annotations;
* a matching GRCh37 LD reference panel, likely 1000 Genomes Phase 3 EUR;
* autosomal biallelic SNPs only;
* valid p-values and genomic positions;
* common-variant filtering using reference-panel MAF from the matched 1000 Genomes Phase 3 EUR LD reference panel;
* removal of low-confidence variants using `low_confidence_variant`;
* stable gene identifiers for harmonization with the schizophrenia analysis.

### Schizophrenia

Primary dataset:

PGC 2022 schizophrenia GWAS from Trubetskoy et al.

Primary summary-statistics source:

* PGC `scz2022` summary statistics.
* Source page: `https://figshare.com/articles/dataset/scz2022/19426775`
* DOI: `https://doi.org/10.6084/m9.figshare.19426775`
* Primary file: `PGC3_SCZ_wave3.european.autosome.public.v3.vcf.tsv.gz`
* Observed 7,659,841 total lines
* Observed 7,659,768 variant rows
* This is the European-ancestry autosomal public summary-statistics file from the PGC3 schizophrenia release.

Schizophrenia will be analyzed using:

* GRCh37/hg19 coordinates;
* GRCh37 gene annotations;
* a matching GRCh37 LD reference panel, likely 1000 Genomes Phase 3 EUR;
* autosomal variants from the European-ancestry summary-statistics file;
* biallelic SNPs only after harmonization;
* valid p-values and genomic positions;
* common-variant filtering using reference-panel MAF >= 0.01 from the matched 1000 Genomes Phase 3 EUR reference panel;
* available sample-size fields, especially `NCAS`, `NCON`, and `NEFF`;
* stable gene identifiers for harmonization with the height analysis.
* generally, the same MAGMA SNP-to-gene mapping framework used for height.

## Variant set

The primary analyses will use common autosomal variants.

For both height and schizophrenia, common-variant filtering will use minor allele frequency from the 
matched European LD reference panel rather than trait-specific GWAS allele-frequency fields. Reference-panel 
allele frequencies will be computed from the 1000 Genomes Phase 3 EUR reference panel using PLINK and 
documented as reference-panel MAF.

This gives one harmonized frequency rule across both traits and avoids deriving separate MAF definitions 
from phenotype-specific summary statistics.

Primary analyses will initially be restricted to:

* autosomal variants;
* biallelic SNPs, because multi-allelic variants and indels can be harder to harmonize;
* variants with valid GRCh37/hg19 positions;
* variants with valid p-values;
* variants passing dataset-specific quality filters, including `low_confidence_variant == false` for height and acceptable `IMPINFO` for schizophrenia;
* variants with reference-panel MAF `>= 0.01`;
* variants present in the matched GRCh37 European LD reference panel.

Reference-panel MAF will be generated from the matched 1000 Genomes Phase 3 EUR reference panel using PLINK.

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
* duplicated gene-gene edges collapsed.

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
* primary source: SCHEMA (Schizophrenia Exome Sequencing Meta-Analysis consortium) rare coding-variant results;
* the initial seed set will use genes meeting the predefined strongest evidence threshold from SCHEMA;

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

### 2. Community-specific connectivity analysis

Question: 

> Does the association between node degree and MAGMA Z-score differ across network communities?

The primary analysis tests whether highly connected genes show stronger GWAS evidence in all communities, or whether the relationship between node degree and MAGMA Z-score is concentrated in particular communities.

Community membership will be tested as a modifier of the association between node degree and MAGMA Z-score using a degree-by-community interaction.

Conceptually, this asks whether being a highly connected gene is informative by itself, or whether connectivity is associated with stronger GWAS evidence only within particular network communities.

For example, node degree may be strongly associated with MAGMA Z-score within a trait-relevant community but show little or no association within other communities.

Community-specific degree–MAGMA Z-score associations will be summarized, and false-discovery-rate correction will be applied across community-level interaction or slope tests within each trait.

### 3. Community enrichment analysis

Questions:

> Are some network communities more enriched for GWAS evidence than others?

> Does community membership explain variation in GWAS evidence beyond individual gene characteristics?

The primary analysis will compare continuous MAGMA gene-level Z-scores across Leiden communities.

Community membership will be tested as a predictor of MAGMA Z-score while adjusting for relevant gene-level covariates such as degree, gene length, number of SNPs included in the MAGMA gene test, and publication count. We adjust because a community may look important just because its genes are long, contain more SNPs, are highly connected, or are better studied.

False-discovery-rate correction will be applied across community-level tests within each trait.

### 4. Rare-seed proximity analysis

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

The four primary analyses will be interpreted jointly.

The analyses are not intended to assign a trait to a mutually exclusive genetic-architecture category or to define a numerical threshold at which a trait is classified as omnigenic, stratagenic, oligogenic, polygenic, or infinitesimal.

Instead, the observed combination of network signatures will be compared with qualitative predictions from proposed models of complex-trait genetic architecture.

Architecture interpretation will therefore be comparative and signature-based rather than a binary classification exercise.

### Evidence more consistent with an omnigenic-like organization

A broadly distributed common-variant GWAS signal, together with evidence of convergence toward independently defined trait-relevant seed genes, would strengthen an omnigenic-like interpretation.

Relevant network signatures include:

* GWAS evidence distributed across many genes and multiple communities;
* stronger GWAS evidence among genes with greater network proximity to rare large-effect or otherwise independently defined seed genes;
* network proximity that is not explained solely by a small number of communities;
* evidence that connectivity is informative within multiple parts of the network rather than being restricted to one isolated module;

These patterns would be interpreted as more consistent with widespread peripheral genetic effects that remain connected to a smaller set of trait-relevant biological genes.

### Evidence more consistent with a stratagenic-like organization

A stratagenic-like interpretation would be strengthened by evidence that GWAS associations are unevenly organized across network communities and that connectivity is informative primarily within particular network contexts.

Relevant network signatures include:

* substantial variation in MAGMA Z-score across communities;
* a restricted collection of communities carrying disproportionately strong GWAS evidence;
* substantial variation in the degree-MAGMA Z-score relationship across communities;
* stronger degree-GWAS associations within particular communities and weak or absent relationships elsewhere;
* trait-associated communities representing distinguishable biological processes.

These patterns would be interpreted as more consistent with genetic evidence being stratified across functionally relevant network layers or modules.

### Evidence more consistent with a polygenic-like organization
A polygenic-like interpretation would be strengthened by evidence that GWAS association is distributed across many genes rather than dominated by a small number of genes, loci, or network regions.

Relevant network signatures include:

* GWAS evidence distributed across many genes;
* no small set of genes or communities dominating the overall pattern;
* broad persistence of GWAS evidence after removing the strongest individual loci or genes;
* network degree, community membership, or seed proximity may explain some variation in GWAS evidence, but no single network feature is required * to account for the broad distribution of association signal.

These patterns would be interpreted as more consistent with many genetic contributors influencing the trait.

### Evidence more consistent with an oligogenic-like organization

An oligogenic-like interpretation would be strengthened by a strong concentration of the observed signal in a limited number of genes, loci, or network regions.

Relevant network signatures include:

* a small number of genes or loci accounting for a disproportionate share of strong GWAS evidence;
* network results strongly influenced by a limited number of genes or communities;
* substantial attenuation of connectivity, community, or proximity results after removing the strongest signals;
* limited evidence of broadly distributed network organization.

These patterns would be interpreted as more consistent with an architecture dominated by a relatively small set of influential genetic signals.

### Evidence more consistent with an infinitesimal-like organization

An infinitesimal-like interpretation would be strengthened by broadly distributed GWAS evidence with little reproducible organization of GWAS evidence across network communities or proximity patterns.

Relevant network signatures include:

* broadly distributed gene-level GWAS evidence;
* little or no reproducible association between node degree and MAGMA Z-score;
* little evidence that the degree-GWAS relationship varies meaningfully across communities;
* weak community-level differences in GWAS evidence;
* little or no association between GWAS evidence and network proximity to independently defined seed genes.

These patterns would be interpreted as more consistent with highly diffuse genetic effects that are not strongly organized according to the tested PPI network features.

## Interpretive principle

No individual analysis will be treated as sufficient evidence for a specific genetic-architecture model.

Interpretation will be based on the joint direction, magnitude, robustness, and consistency of results across connectivity, community-specific connectivity, community enrichment, and rare-seed proximity analyses. And directionally consistent results across STRING and BioGRID sensitivity analyses.

The final conclusions will use language such as more consistent with, less consistent with, or shows network signatures predicted by a proposed architecture. The analyses will not claim to prove that a trait follows a specific architecture.

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
