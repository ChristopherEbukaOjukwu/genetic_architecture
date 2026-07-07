# Project scope

## Research question

Do genes prioritized from common-variant GWAS evidence occupy non-random positions in protein-protein interaction networks, and are the observed patterns consistent with proposed network signatures of complex-trait genetic architecture?

The project will examine three network patterns:

1. Gene connectivity: whether node degree is associated with gene-level GWAS evidence
2. Community organization and community-specific connectivity: whether GWAS evidence differs across network communities and whether the association between node degree and GWAS evidence differs across communities
3. Network proximity: whether GWAS-prioritized genes lie closer to independently defined trait-specific seed genes

The analyses will identify patterns consistent with particular genetic architectures: omnigenic, stratagenic, infinitesimal, oligogenic, or related models.

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

* GWAS file: `13,791,468` lines, corresponding to `13,791,467` variant records plus one header line.
* The GWAS file and variant metadata file can be joined by the `variant` column.

Height will be analyzed using:

* GRCh37/hg19 coordinates;
* GRCh37 gene annotations;
* the 1000 Genomes Phase 3 EUR GRCh37 reference panel for LD modeling and reference-panel MAF;
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
* Observed `7,659,841` total lines
* Observed `7,659,768` non-metadata lines, consisting of `7,659,767` variant records plus one column-header line.
* This is the European-ancestry autosomal public summary-statistics file from the PGC3 schizophrenia release.

Schizophrenia will be analyzed using:

* GRCh37/hg19 coordinates;
* GRCh37 gene annotations;
* a matching GRCh37 LD reference panel, 1000 Genomes Phase 3 EUR;
* autosomal variants from the European-ancestry summary-statistics file;
* biallelic SNPs only after harmonization;
* valid p-values and genomic positions;
* removal of low-imputation-quality variants by retaining only variants with IMPINFO > 0.8;
* common-variant filtering using reference-panel MAF >= 0.01 from the matched 1000 Genomes Phase 3 EUR reference panel;
* available sample-size fields, especially `NCAS`, `NCON`;
* stable gene identifiers for harmonization with the height analysis;
* the same MAGMA SNP-to-gene mapping framework used for height.

### Schizophrenia extended-MHC sensitivity analysis

The primary schizophrenia analyses will retain eligible genes in the extended MHC region because the primary analysis is intended to characterize genome-wide common-variant GWAS organization.

A schizophrenia-specific sensitivity analysis will repeat the three primary analyses after excluding genes whose GRCh37 gene-body coordinates overlap the extended MHC region on chromosome 6 from 25 Mb to 35 Mb.

The cleaned PPI network and previously calculated network metrics will remain fixed. Extended-MHC genes will be excluded from the schizophrenia gene-level analysis universe for the sensitivity analysis rather than rebuilding the network.

This sensitivity analysis will determine whether the direction and interpretation of the schizophrenia network results are primarily driven by the unusually strong and high-LD extended-MHC region.

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
* variants passing dataset-specific quality filters, including `low_confidence_variant == false` for height; and `IMPINFO > 0.8` for schizophrenia;
* variants with reference-panel MAF `>= 0.01`;
* variants present in the matched GRCh37 European LD reference panel.

Reference-panel MAF will be generated from the matched 1000 Genomes Phase 3 EUR reference panel using PLINK.

## Extra datasets

### 1000 Genomes Phase 3 EUR reference panel, GRCh37

The 1000 Genomes Phase 3 European reference panel will be used for:

* LD modeling in MAGMA;
* reference-panel MAF calculation;
* harmonization of GWAS variants to the LD reference.

The MAGMA-provided reference data uses 1000 Genomes Phase 3 variants and GRCh37/Build 37 coordinates.

Download:

```text
MAGMA source page:
https://cncr.nl/research/magma/

European reference panel:
https://vu.data.surf.nl/s/VZNByNwpD8qqINe?opendetails=
```

Primary reference files are the PLINK-format files contained in the downloaded archive.

Reference-panel MAF will be calculated using PLINK:

```bash
plink --bfile g1000_eur --freq --out g1000_eur
```

The resulting reference-panel MAF will be used to apply the primary common-variant threshold of `MAF >= 0.01` consistently to both height and schizophrenia.

### MAGMA gene annotation file, GRCh37

The MAGMA GRCh37 gene-location file will be used to map SNPs to genes.

Download:

```text
MAGMA source page:
https://cncr.nl/research/magma/

Build 37 gene locations:
https://vu.data.surf.nl/s/Pj2orwuF2JYyKxq?opendetails=
```

Primary file:

```text
NCBI37.3.gene.loc
```

The file contains gene coordinates and Entrez Gene IDs.

The gene body coordinates in this file will be extended by the prespecified MAGMA SNP-to-gene annotation window of 35 kb upstream and 10 kb downstream.

### STRING human physical PPI network

The primary protein-protein interaction network will use the STRING v12.0 human physical subnetwork.

Download:

```bash
wget https://stringdb-downloads.org/download/protein.physical.links.v12.0/9606.protein.physical.links.v12.0.txt.gz \
  -O 9606.protein.physical.links.v12.0.txt.gz
```

Primary network file:

```text
9606.protein.physical.links.v12.0.txt.gz
```

Also download the human protein information file:

```bash
wget https://stringdb-downloads.org/download/protein.info.v12.0/9606.protein.info.v12.0.txt.gz \
  -O 9606.protein.info.v12.0.txt.gz
```

Protein information file:

```text
9606.protein.info.v12.0.txt.gz
```

The primary network will be restricted to:

* Homo sapiens;
* physical protein-protein interactions;
* `combined_score >= 700`;
* protein-coding genes after protein-to-gene harmonization;
* undirected edges;
* self-loops removed;
* duplicated gene-gene edges collapsed.

STRING combined scores will be interpreted as confidence that an interaction exists, not as biological interaction strength.

### Gene ID mapping

STRING protein identifiers will be mapped directly to Entrez Gene IDs using the STRING v12.0 human protein alias file.

Download:

```bash
wget https://stringdb-downloads.org/download/protein.aliases.v12.0/9606.protein.aliases.v12.0.txt.gz \
  -O 9606.protein.aliases.v12.0.txt.gz
```

Primary mapping file:

```text
9606.protein.aliases.v12.0.txt.gz
```

The primary STRING-to-gene mapping will use aliases with:

```text
source == Ensembl_HGNC_entrez_id
```

This provides a direct mapping from STRING protein IDs to numeric Entrez Gene IDs.

Entrez Gene ID will be used as the primary gene identifier for MAGMA-to-STRING harmonization.

Gene symbols will be retained for reporting and interpretation.

### Height seed genes

The height seed set consists of all 462 autosomal genes implicated in extreme height phenotypes and skeletal growth disorders reported in Yengo et al. 2022 Supplementary Table 11.

Source:

```text
Yengo et al. 2022
Supplementary Table 11
https://www.nature.com/articles/s41586-022-05275-y
```

Download:

```bash
wget "https://static-content.springer.com/esm/art%3A10.1038%2Fs41586-022-05275-y/MediaObjects/41586_2022_5275_MOESM3_ESM.xlsx" \
  -O Yengo_2022_supplementary_tables.xlsx
```

The source seed set contains 462 autosomal genes.

All 462 genes will be retained as the source seed set before identifier harmonization and intersection with the protein-coding STRING network.

The following counts will be documented:

```text
462 source seed genes
-> N successfully mapped to Entrez Gene IDs
-> N represented in the STRING network
```

### Schizophrenia seed genes

The primary schizophrenia seed set will use the 10 exome-wide significant genes identified by the SCHEMA Consortium in Singh et al. 2022.

Source:

```text
Singh et al. 2022
Rare coding variants in ten genes confer substantial risk for schizophrenia
https://www.nature.com/articles/s41586-022-04556-w
```

The SCHEMA 2022 10-gene seed set is:

```text
SETD1A
CUL1
XPO7
TRIO
CACNA1G
SP4
GRIN2A
HERC1
RB1CC1
GRIA3
```

These genes were identified at exome-wide significance through rare coding-variant burden analyses and provide an independently defined rare-variant schizophrenia reference set.

The following counts will be documented:

```text
10 source seed genes
-> N successfully mapped to Entrez Gene IDs
-> N represented in the STRING network
```

### Publication count

Publication attention will be measured using the NCBI `gene2pubmed` gene-to-PubMed mapping file.

Download:

```bash
wget https://ftp.ncbi.nlm.nih.gov/gene/DATA/gene2pubmed.gz \
  -O gene2pubmed.gz
```

The file will be restricted to human genes:

```text
tax_id == 9606
```

For each Entrez Gene ID:

```text
publication_count = number of unique associated PubMed IDs
```

The publication-attention covariate will be:

```text
log(publication_count + 1)
```

This measure will be interpreted as an NCBI gene-linked PubMed publication-count proxy for research attention, not as an exhaustive count of all publications that mention a gene.


## SNP-to-gene mapping

### Primary gene-level analysis

MAGMA gene-level analysis will use:

* the gene body;
* 35 kb upstream of the transcription start site;
* 10 kb downstream of the transcription end site;
* an LD reference matched to the GWAS dataset.

MAGMA will combine association evidence across variants assigned to each gene while accounting for LD.

### MAGMA sample-size input

For height, the per-variant `n_complete_samples` field will be used as the MAGMA sample-size column.

For schizophrenia, per-variant total sample size will be calculated as:

`N_SNP = NCAS + NCON`

The derived `N_SNP` field will be used as the MAGMA sample-size column.

MAGMA will therefore use per-SNP sample size for both traits rather than assuming a single constant sample size across all variants.


## GWAS outcome variables

### Primary outcome

Continuous MAGMA gene-level Z-score.

A higher Z-score represents stronger gene-level GWAS association evidence.

### Additional descriptive outcomes

* number of SNPs included in each MAGMA gene test.

## Networks

### Primary network

STRING human physical protein-protein interaction network:

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

BioGRID human physical protein-protein interaction network.

The main analyses will be repeated using BioGRID to determine whether the conclusions depend on the STRING network.

STRING and BioGRID will remain separate networks and will not be merged.

## Network universe

For each trait and network, the analysis will include only genes that:

* received a valid MAGMA gene-level association score; and
* are present as nodes in the PPI network.

Thus, the analysis universe is the intersection of the MAGMA gene set and the network gene set. More specifically, first build and analyze the cleaned PPI network. Calculate node degree, Leiden community membership, and RWR on the fixed PPI network. Then join the network results to MAGMA and restrict the regression analysis to genes with valid MAGMA scores.

Genes absent from the network will be excluded rather than assigned a degree of zero.

## Community detection

Leiden was selected because it matches the study’s definition of a community as a densely and internally connected group of proteins. Leiden is computationally efficient and designed to avoid poorly connected communities. It also keeps community detection separate from the Random Walk with Restart proximity analysis.

### Primary method

Primary method: Leiden community detection.

Leiden will divide the cleaned PPI network into densely and internally connected communities using network structure only. GWAS association scores will be added only after communities have been defined.

The primary Leiden analysis will use:

* modularity as the objective function --- because the goal is to identify groups of genes that are more densely connected to each other than expected from the broader network structure;
* an unweighted network --- because STRING `combined_score` is treated as confidence that an interaction exists rather than as biological interaction strength;
* random seed `42` --- a fixed arbitrary integer used for reproducibility;
* iterations continued until no further improvement in partition quality --- implemented using the Leiden algorithm's convergence option, which continues iterating until partition quality no longer improves.

The Leiden objective function, network weighting rule, and random seed are fixed independently of the GWAS association results and will not be tuned based on MAGMA Z-scores or community results.

## Mendelian and rare large-effect seed genes

Seed genes will be defined independently of the common-variant GWAS results.

### Height seeds

Primary seed set:

* all 462 autosomal genes implicated in extreme height phenotypes and skeletal growth disorders reported in Yengo et al. 2022 Supplementary Table 11.

These genes were curated from Mendelian and skeletal-growth disorders characterized by abnormal stature, short stature, tall stature, overgrowth, skeletal dysplasia, or related growth phenotypes.

Because the GWAS analyses are restricted to autosomes, only autosomal seed genes will be used.

### Schizophrenia seeds

Primary seed set:

* the 10 exome-wide significant schizophrenia genes identified by the SCHEMA Consortium in Singh et al. 2022:

`SETD1A`, `CUL1`, `XPO7`, `TRIO`, `CACNA1G`, `SP4`, `GRIN2A`, `HERC1`, `RB1CC1`, and `GRIA3`.

These genes were identified through rare coding-variant burden analyses and provide independently defined rare large-effect schizophrenia risk genes.

The SCHEMA seed genes are independent of the common-variant PGC schizophrenia GWAS summary statistics used for MAGMA.

### Overlap handling

Seed genes will be excluded from the tested GWAS gene set when evaluating the association between MAGMA Z-score and network proximity to the seed set. This avoids inflating proximity results by allowing seed genes to be scored as maximally close to themselves.

## Network propagation

Random Walk with Restart will be used to calculate the proximity of each network gene to the trait-specific seed genes.

Primary restart probability: `r=0.5`

Each gene will receive an RWR score. A higher raw RWR score indicates greater network proximity to the trait-specific seed genes.

Raw RWR scores will be retained for descriptive reporting.

For the primary gene-property regression analysis, RWR scores will be rank-based inverse-normal transformed (rank-INT) across the non-seed genes in the trait- and network-specific analysis universe. Higher transformed values will continue to represent greater seed proximity.

The rank-based inverse-normal transformation is prespecified to reduce the influence of the highly concentrated upper tail of the RWR score distribution and to avoid interpreting absolute differences in raw RWR probability as linearly equivalent biological differences in proximity.

The same transformation procedure will be applied to RWR scores generated from the observed seed set and from each matched random seed set before regression analysis.

## Primary analyses

### 1. Connectivity analysis

Question:

> Is gene-level GWAS evidence associated with node degree?

The primary coefficient is the association between node degree and MAGMA Z-score.


### 2. Community organization and community-specific connectivity analysis

Questions:

> Does community membership explain variation in GWAS evidence?

> Does the association between node degree and MAGMA Z-score differ across network communities?

Two related community analyses will be performed within the MAGMA generalized gene-property framework.

First, each Leiden community will be represented as a gene set and tested for differences in MAGMA gene-level association evidence relative to genes outside that community. This tests whether membership in particular network communities is associated with stronger or weaker GWAS evidence.

Second, interactions between Leiden community membership and node degree will be tested. These analyses ask whether the association between node degree and MAGMA Z-score differs for genes inside a particular community compared with genes outside that community.

False-discovery-rate correction will be applied across community-membership tests and separately across degree-by-community interaction tests within each trait.

Community-level MAGMA Z-score patterns and community-specific degree–MAGMA Z-score relationships will be reported to show where and in what direction the observed differences occur.

Together, these analyses distinguish between a community in which genes generally show elevated GWAS evidence and a community in which highly connected genes additionally tend to show stronger GWAS evidence.

### 3. Rare-seed proximity analysis

Question:

> Do genes with stronger common-variant GWAS evidence lie closer in the network to independently defined trait-specific seed genes?

A positive rank-INT RWR coefficient means that genes more strongly connected to the seed genes tend to have stronger common-variant GWAS evidence.

The observed seed result will be compared with random seed sets matched on number of genes, node degree, publication count, and network component.

The real network will remain fixed during these permutations. Only the observed and random seed labels change. For each matched random seed set, RWR scores will be recomputed, rank-INT transformed, and entered into the same MAGMA gene-property model used for the observed seed set. The observed rank-INT RWR regression coefficient will be compared with the distribution of corresponding coefficients obtained from the matched random seed sets.

This is to test whether common-variant GWAS evidence is closer to independently defined trait-specific seed genes than expected for genes with similar connectedness, publication attention, and network location.

## Research-attention adjustment

An argument is that the scientific literature partly shapes protein-interaction networks, and that genes that have been studied more extensively are more likely to have recorded protein interactions, better annotations, and higher apparent network connectivity.

This extends the argument to say that a gene may appear highly connected or close to rare large-effect seed genes partly because it is well studied, not necessarily because it is biologically more central to the trait.

To account for this, publication count will be included as a proxy for research attention. Publication count will be calculated as the number of unique PubMed records linked to each gene, using NCBI `gene2pubmed`.


## Model specification

Primary gene-level regression analyses will be performed using the MAGMA generalized gene-property analysis framework.

MAGMA's gene–gene correlation structure and automatic technical covariates will be retained in all primary models. These automatic technical adjustments include gene size measured by the number of analyzed SNPs, gene density representing within-gene LD, inverse mean minor allele count, and per-gene sample size when sample size varies across genes.

Physical gene length will additionally be included as a prespecified gene-level covariate. Gene length will be calculated from the unextended gene-body coordinates in the GRCh37 `NCBI37.3.gene.loc` file and will not include the 35 kb upstream and 10 kb downstream SNP-mapping window. Physical gene length is retained in addition to MAGMA's SNP-count-based gene-size correction because the two capture different aspects of gene size. MAGMA's automatic gene-size covariate represents the number of analyzed SNPs assigned to a gene, whereas physical gene length represents the genomic span of the gene body in base pairs.

Publication attention will be represented as:

`log(publication_count + 1)`

Each primary analysis will be reported using a base model and a publication-attention-adjusted model that additionally includes the publication-attention covariate.

In the primary proximity models, `rank-INT RWR score` refers to the prespecified rank-based inverse-normal transformation of the raw RWR score.

### Connectivity analysis

Base model of interest:

`MAGMA Z ~ degree + gene length`

Publication-attention-adjusted model of interest:

`MAGMA Z ~ degree + gene length + log(publication_count + 1)`

The MAGMA automatic technical covariates will be retained in both models.

Community membership will not be included because this analysis tests the overall association between node degree and GWAS evidence across the network.

### Community organization and community-specific connectivity analysis

Leiden communities will be represented as gene sets in MAGMA. Node degree, physical gene length, and publication attention will be supplied as continuous gene properties.

Community organization will be evaluated by testing each Leiden community for differences in gene-level GWAS evidence relative to genes outside that community. For degree-by-community interaction analyses, only Leiden communities satisfying MAGMA's default gene-set-by-continuous-property interaction size criterion will be tested. The tested community must contain at least 100 genes in the trait- and network-specific analysis universe and no more than the total number of analyzed genes minus 100.

Base model of interest:

`MAGMA Z ~ community membership + gene length`

Publication-attention-adjusted model of interest:

`MAGMA Z ~ community membership + gene length + log(publication_count + 1)`

Community-specific connectivity will be evaluated using MAGMA's native gene-set-by-continuous-gene-property interaction framework, with Leiden community membership represented as the gene set and node degree represented as the continuous gene property.

Conceptual interaction model:

`MAGMA Z ~ degree + community membership + degree × community membership + gene length`

Publication-attention-adjusted conceptual interaction model:

`MAGMA Z ~ degree + community membership + degree × community membership + gene length + log(publication_count + 1)`

MAGMA internally centers the continuous gene property on its mean within the tested gene set when defining the interaction term. Degree-by-community interaction terms will therefore be generated using MAGMA's native interaction analysis rather than manually constructed interaction columns.

Gene length and publication attention will be included as conditioning gene properties in the applicable models.

The MAGMA automatic technical covariates will be retained in all models.

False-discovery-rate correction will be applied separately across community-membership tests and degree-by-community interaction tests within each trait.

### Rare-seed proximity analysis

Base model of interest:

`MAGMA Z ~ rank-INT RWR score + degree + gene length`

Publication-attention-adjusted model of interest:

`MAGMA Z ~ rank-INT RWR score + degree + gene length + log(publication_count + 1)`

The MAGMA automatic technical covariates will be retained in both models.

Node degree will be included to distinguish seed proximity from general network connectedness. Community membership will not be included in the primary proximity model because the primary question concerns overall convergence toward independently defined seed genes.

The same primary model specifications will be used for height and schizophrenia and for the corresponding STRING and BioGRID analyses.

## Architectural interpretation

The three primary analyses will be interpreted jointly.

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
* network degree, community membership, or seed proximity may explain some variation in GWAS evidence, but no single network feature is required to account for the broad distribution of association signal.

These patterns would be interpreted as more consistent with many genetic contributors influencing the trait.

### Evidence more consistent with an oligogenic-like organization

An oligogenic-like interpretation would be strengthened by a strong concentration of the observed signal in a limited number of genes, loci, or network regions.

Relevant network signatures include:

* a small number of genes or loci accounting for a disproportionate share of strong GWAS evidence;
* network results strongly influenced by a limited number of genes or communities;
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


Note: polygenic-like differs from infinitesimal-like in that some network features remain informative, whereas infinitesimal-like shows no reproducible network organization.

## Interpretive principle

No individual analysis will be treated as sufficient evidence for a specific genetic-architecture model.

Interpretation will be based on the joint direction, magnitude, robustness, and consistency of results across connectivity, community organization and community-specific connectivity, and rare-seed proximity analyses, including the directional consistency of results across STRING and BioGRID sensitivity analyses.

The final conclusions will use language such as more consistent with, less consistent with, or shows network signatures predicted by a proposed architecture. The analyses will not claim to prove that a trait follows a specific architecture.

## Development and preregistration plan

Height will be used to:

* build the data-processing pipeline;
* select workable software parameters;
* identify data-quality problems;
* test the implementation of MAGMA, Leiden, and RWR;
* verify implementation of the prespecified regression models and finalize the matched-seed permutation procedure.

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
* additional sensitivity analyses beyond the prespecified BioGRID robustness and schizophrenia extended-MHC sensitivity analyses.

These may be considered after the primary PPI-based project is completed.
