# All of Us Height GWAS — Workspace and App Setup

## 1. Goal

Set up an All of Us Controlled Tier workspace for a development GWAS of measured height, using short-read WGS participants and REGENIE.

The analysis is currently restricted to the European-ancestry subset for development so that it aligns with the existing EUR-focused downstream genetic-architecture workflow.

---

## 2. Workspace creation

Workspace created in Verily Workbench:

- **Workspace name:** `Height GWAS development`
- **Workspace ID:** `height-gwas-development`
- **Region:** `us-central1`
- **Google project:** `wb-lukewarm-pumpkin-3556`
- **Workspace UUID:** `9c2a9a43-0a82-441c-8de6-5ebccf94df34`

Workspace description:

> This project will be a genome-wide association study of measured height to identify common genetic variants associated with variation in human height.

---

## 3. Research Purpose

Primary purpose:

- **Genetic research**

Research description:

- Study how common genetic variation is associated with human height.
- Use height as a model complex trait.
- Use measured height, WGS data, and participant characteristics.
- Perform GWAS of common variants with appropriate covariate adjustment.
- Summarize results at the gene level and within protein-protein interaction networks.
- Evaluate whether genetic effects are broadly distributed or show biological/network organization.

Other declarations:

- No specific Scientific Framework category selected.
- No focus on underrepresented populations for this development analysis.
- No AI/AN-specific analyses.
- No current RAB concerns.

---

## 4. Controlled Tier resources attached

The workspace uses **All of Us Controlled Tier CDRv9** resources.

Attached references:

- BigQuery phenotype/clinical data:
  - `C2025Q4R6`
- Genomics bucket:
  - `gs://vwb-aou-datasets-controlled/v9`
- Controlled Tier bucket:
  - `vwb-aou-datasets-controlled-v9`

The source collection is:

- **All of Us Controlled Tier**
- **CDRv9**

---

## 5. Cohort setup

Created a base cohort defined only by:

- **Short Read WGS**

Cohort size:

- **535,662 participants**

Cohort description:

> Participants with short-read whole-genome sequencing data used as the base cohort for the height GWAS.

Reason for using WGS only in the cohort definition:

- Keep the cohort reusable.
- Apply phenotype inclusion/exclusion rules explicitly in the analysis pipeline rather than hiding them inside the cohort builder.

---

## 6. Dataset / notebook setup

Created a dataset from the WGS cohort.

Selected:

- Demographics
- Cohort-defining tables
- Jupyter notebook output

Generated notebook name was similar to:

`AllOfUsControlledTierDatasetv9_HeightGWAScohort_20260817_040108_Jupyter.ipynb`

Mounted workspace directory:

`~/workspace/height-gwas-data`

A direct notebook save initially produced a Jupyter **File Save Error** because of the mounted/FUSE filesystem behavior.

The notebooks were explicitly copied to persistent workspace cloud storage:

```bash
gcloud storage cp ~/workspace/height-gwas-data/*.ipynb \
  gs://height-gwas-data-wb-lukewarm-pumpkin-3556/notebooks/
```

Persistent bucket:

`gs://height-gwas-data-wb-lukewarm-pumpkin-3556/`

---

## 7. Jupyter app

Created app:

- **App name:** `AoU_Jupyter_ComputeEngine_20260817`
- **Instance:** `aoujupytercomputeengine20260817`
- **Zone:** `us-central1-a`

The original running cost was approximately:

- **$0.27/hour** while the VM was active.

After stopping:

- App status showed **Stopped**
- Active compute stopped.
- A smaller ongoing charge remained for persistent resources, approximately **$0.03/hour** at the time checked.

Important operational rule:

- **Stop the app when not actively working.**
- Stopping preserves the persistent disk and workspace state.
- Do not delete the app unless intentionally rebuilding it.

After restarting the app, `/tmp` contents from the previous session were still present.

---

## 8. Current VM resources

Current Jupyter VM:

```text
CPUs: 4
RAM: 25 GiB
Swap: 0
```

Disk check after loading chromosome 22 and microarray files:

```text
Filesystem: overlay
Size: 492G
Used: 76G
Available: 396G
```

The VM is currently sufficient for preprocessing, but REGENIE Step 1 may benefit from resizing to more CPUs before the final computational run.

---

## 9. Important storage locations

### Persistent workspace bucket

```text
gs://height-gwas-data-wb-lukewarm-pumpkin-3556/
```

Important persisted outputs include:

```text
phenotype/height_eur_phenotype_covariates.tsv
results/height_chr22_qc_test_height_irnt.regenie
notebooks/*.ipynb
```

### Controlled Tier genomics root

```text
gs://vwb-aou-datasets-controlled/v9
```

Requester-pays access requires:

```bash
--billing-project=wb-lukewarm-pumpkin-3556
```

### Local temporary working directories

```text
/tmp/chr22_test
/tmp/array_step1
```

---

## 10. Main working principle

Participant-level data remain inside the All of Us Controlled Tier environment.

Do not export participant-level phenotype/genotype files locally outside the Workbench.

Only compliant aggregate results, code, figures, and documentation should be exported according to All of Us policy.
