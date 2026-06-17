# Project scope

## Traits

Primary: Height, representing a canonical highly polygenic quantitative trait.

Confirmatory: Alzheimer's disease, representing mixed genetic
architecture with a major common-variant effect at APOE, rare
larger-effect variants including TREM2, Mendelian familial genes,
and a broader polygenic background.

## GWAS datasets

### Primary
#### Height

Yengo et al. 2022, Nature, GIANT height GWAS.

Primary summary-statistics file:

* `GIANT_HEIGHT_YENGO_2022_GWAS_SUMMARY_STATS_EUR.gz`
* Predominantly European-ancestry analysis
* GRCh37/hg19 coordinates
* Public summary statistics exclude 23andMe data
* Actual available per-variant sample sizes will be summarized from
  the `N` column rather than describing the file as containing the
  full 5.4-million-person study

Height will be analyzed in GRCh37 using matching GRCh37 gene
annotations and an ancestry-matched LD reference. The resulting
gene-level identifiers will later be harmonized with the Alzheimer
gene-level results.

Sensitivity:

* GIANT 2018 height meta-analysis
  * Tests robustness to GWAS vintage and sample size
* Yengo 2022 UK Biobank-excluded height analysis
  * Tests sensitivity to UK Biobank-specific sample structure

### Confirmatory
#### Alzheimer's disease and related dementias

Bellenguez et al. 2026, Nature Genetics 58, 1214–1225.
DOI: 10.1038/s41588-026-02583-1

Primary file:

* `GCST90704647`, no-proxy meta-analysis
* European-ancestry samples
* GRCh38 coordinates

Sensitivity files:

* `GCST90704646`, main meta-analysis including proxy cases
  * Tests sensitivity to proxy-related phenotype differences
* `GCST90704648`, no-biobank analysis using clinically diagnosed cases
  * Tests whether large biobank and ICD-defined samples drive the results

### APOE handling

Primary Alzheimer analysis:

* Exclude chr19:44,000,000–46,000,000 bp in GRCh38 from the
  architectural analyses

Sensitivity:

* APOE region included — tests whether APOE drives or obscures the
  broader architectural pattern

### Alzheimer Mendelian seeds

Primary seed set:

* APP
* PSEN1
* PSEN2

These are predefined as canonical genes causing autosomal-dominant
early-onset Alzheimer's disease.

Evidence sources:

* ClinGen gene–disease validity when an applicable Alzheimer
  curation exists
* GeneReviews, OMIM, and a predefined published familial-Alzheimer
  source for genes without an applicable ClinGen Alzheimer curation

Sensitivity:

* An expanded, predefined early-onset or familial Alzheimer gene set
* The source and inclusion criteria must be selected before examining
  the network-proximity results

## Variant set

Common variants with MAF ≥ 1%.

## SNP-to-gene mapping

Primary:

* MAGMA gene-level analysis
* 35 kb upstream of transcription start site, 10 kb downstream of
  transcription end site, in addition to the gene body

Sensitivity:

* Genome-wide significant, approximately independent lead SNPs
  (via LD-clumping with the matched ancestry reference panel)
  assigned to their nearest protein-coding gene

## GWAS outcomes

Primary:

* Continuous MAGMA gene-level Z-score

Secondary:

* Binary Bonferroni-significant MAGMA gene
* Threshold: 0.05 divided by the number of tested genes

## Networks

### Primary network

STRING human physical PPI network:

* Homo sapiens
* Physical subnetwork
* Combined confidence score ≥ 700
* Undirected
* Protein-coding genes only

Primary connectivity measure:

* Unweighted node degree
* Rationale: most interpretable, matches prior literature

Secondary connectivity measure:

* Confidence-weighted degree
* Uses STRING's confidence scores more fully but is harder to
  interpret biologically

STRING scores will be interpreted as interaction-confidence scores,
not biological interaction strength.

### Robustness network

BioGRID human physical PPI network.

## Network propagation

Random Walk with Restart (RWR) with restart probability r = 0.5.

Sensitivity: r ∈ {0.3, 0.7}.

## Community detection

Primary: MONET K1 (kernel clustering, propagation-aligned).

Robustness: MONET M1 (modularity).

## Primary analyses

### 1. Connectivity

Degree vs. GWAS signal: test whether MAGMA gene-level association
scores are related to node degree.

### 2. Community enrichment

GWAS signal concentration by community: test whether some MONET
communities contain stronger or more frequent GWAS associations
than expected, and whether community membership accounts for
gene-level GWAS signal beyond individual gene properties.

### 3. Proximity to Mendelian genes

RWR from Mendelian seeds vs. GWAS signal: test whether common-variant
GWAS evidence is unusually close to the Mendelian or rare large-effect
seed genes, using Random Walk with Restart as the primary proximity
measure. Shortest-path distance may be reported as a secondary
descriptive comparison but is not a primary inferential measure.

## Required covariates

Connectivity and proximity models will account for:

* gene length
* number of SNPs included in the MAGMA gene test
* log(publication count + 1) per gene
* network community

## Pre-registered architectural predictions

Height: smooth attenuation of GWAS signal with network distance
from Mendelian seeds (omnigenic-flavored prediction).

AD (APOE-excluded): two possibilities, both informative:

* If AD is genuinely oligogenic/stratogenic with tiers organized
  around TREM2, ABCA7, and similar large-effect signals, we expect
  stepped attenuation.
* If AD is omnigenic on the non-APOE polygenic background, we expect
  smooth attenuation.

The trait contrast itself is a pre-registered finding: a difference
in attenuation shape between height (smooth) and AD (stepped) would
support trait-dependent architecture rather than a universal
architectural model.

## Falsifiable positive criterion (omnigenic)

The omnigenic prediction will be considered supported in a trait if
all of the following hold:

(a) The RWR-from-Mendelian coefficient in the MAGMA Z-score regression
    is positive and significant under degree-preserving permutation
    (p < 0.05) in the primary trait, with directionally consistent
    result in the confirmatory trait.
(b) The RWR-vs-MAGMA relationship is monotonic and better fit by a
    smooth attenuation (isotonic regression) than a step function
    (K = 2, 3, 4 tiers), as judged by BIC.
(c) Result holds under publication-count adjustment.
(d) Result holds in both primary network (STRING) and robustness
    network (BioGRID).

Omnigenic will be considered NOT supported if (a) fails.

Stratogenic will be considered preferred over omnigenic if (a) holds
but (b) prefers a step-function fit.

## Multiple-testing approach across traits

Height and AD will be analyzed independently. No across-trait
multiple-testing correction will be applied, because the two traits
serve as conceptually separate tests with different a priori
architectural predictions (smooth vs. stepped). The trait contrast
is the unit of interpretation, not a single pooled significance test.

## Planned sensitivity analyses

For each primary finding, robustness will be assessed across the
following variants. A finding will be reported as robust if direction
and significance are preserved across all variants; otherwise, the
variants in which it fails will be reported explicitly.

| Decision               | Primary                          | Sensitivity                                    |
|------------------------|----------------------------------|------------------------------------------------|
| Network                | STRING physical, score ≥ 700     | BioGRID physical                               |
| Community detection    | MONET K1                         | MONET M1                                       |
| RWR restart probability| r = 0.5                          | r = 0.3, r = 0.7                               |
| SNP-to-gene mapping    | MAGMA (35 kb / 10 kb)            | Nearest-gene via LD-clumping                   |
| Connectivity measure   | Unweighted degree                | Confidence-weighted degree                     |
| Confounder adjustment  | With log(publication count + 1)  | Without publication-count adjustment           |
| AD phenotype           | No-proxy (GCST90704647)          | Main (GCST90704646); no-biobank (GCST90704648) |
| AD APOE handling       | APOE excluded                    | APOE included                                  |
| AD Mendelian seeds     | APP, PSEN1, PSEN2                | Expanded EOAD/familial AD set                  |
| Height GWAS            | Yengo et al. 2022                | GIANT 2018; UKBB-excluded version              |

## Future / out-of-scope analyses

Tissue-specific co-expression networks (e.g., GTEx-derived networks
for trait-relevant vs. control tissues) are not included in the primary
scope but represent the strongest single test of the *specifically*
omnigenic prediction (cell-type-specific propagation). These analyses
are planned as future work and will not be reported as part of the
current pre-registered project unless the scope is formally amended.
