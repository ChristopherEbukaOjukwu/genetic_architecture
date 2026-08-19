mkdir -p /tmp/height_step2_production

cat > /tmp/run_height_step2_1_21.sh <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

BILLING="wb-lukewarm-pumpkin-3556"

SOURCE="gs://vwb-aou-datasets-controlled/v9/wgs/short_read/snpindel/acaf_threshold/pgen"
DEST="gs://height-gwas-data-wb-lukewarm-pumpkin-3556/step2/production"

BASE="/tmp/height_step2_production"

KEEP_IID="/tmp/array_step1/step2_keep_iid.txt"
KEEP_FID="/tmp/array_step1/step1_keep_fid_iid.txt"
PHENO="/tmp/array_step1/height_pheno.tsv"
COVAR="/tmp/array_step1/height_covar.tsv"
PRED="/tmp/array_step1/regenie_step1/height_pred.list"
LOCO="/tmp/array_step1/regenie_step1/height_1.loco"

THREADS=15

COVARS="age_at_measurement,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16"

mkdir -p "$BASE"

# Confirm all permanent inputs exist before starting.
for f in "$KEEP_IID" "$KEEP_FID" "$PHENO" "$COVAR" "$PRED" "$LOCO"; do
    test -s "$f" || { echo "ERROR: missing $f"; exit 1; }
done

current_chr="NA"
trap 'echo "ERROR: pipeline stopped on chromosome ${current_chr} at $(date)" >&2' ERR

for chr in $(seq 1 21); do
    current_chr="$chr"

    echo
    echo "============================================================"
    echo "CHR ${chr} START: $(date)"
    echo "============================================================"
    df -h /tmp

    CHRDIR="$BASE/chr${chr}"
    RAWDIR="$CHRDIR/raw"
    QCDIR="$CHRDIR/qc"
    OUTDIR="$CHRDIR/out"

    rm -rf "$CHRDIR"
    mkdir -p "$RAWDIR" "$QCDIR" "$OUTDIR"

    RAW="$RAWDIR/acaf_threshold.chr${chr}"
    QC="$QCDIR/height_chr${chr}"
    OUT="$OUTDIR/height_chr${chr}"

    # ---------------------------------------------------------
    # 1. Download raw AoU WGS chromosome
    # ---------------------------------------------------------
    gcloud storage cp \
      --billing-project="$BILLING" \
      "$SOURCE/acaf_threshold.chr${chr}.pgen" \
      "$SOURCE/acaf_threshold.chr${chr}.pvar" \
      "$SOURCE/acaf_threshold.chr${chr}.psam" \
      "$RAWDIR/"

    # ---------------------------------------------------------
    # 2. Final production Step 2 variant QC
    #    - final EUR sample
    #    - simple biallelic SNPs
    #    - MAF >= 1%
    #    - missingness <= 1%
    #    - HWE p >= 1e-9, keep-fewhet
    # ---------------------------------------------------------
    plink2 \
      --pfile "$RAW" \
      --keep "$KEEP_IID" \
      --snps-only just-acgt \
      --max-alleles 2 \
      --maf 0.01 \
      --geno 0.01 \
      --hwe 1e-9 keep-fewhet \
      --set-all-var-ids '@:#:$r:$a' \
      --make-pgen \
      --threads "$THREADS" \
      --out "$QC"

    # ---------------------------------------------------------
    # 3. Harmonize IDs for REGENIE: FID = IID = person_id
    # ---------------------------------------------------------
    cp "$QC.psam" "$QC.psam.original"

    awk 'BEGIN{OFS="\t"}
    NR==1 {print "#FID","IID","SEX"; next}
    {print $1,$1,$2}' \
      "$QC.psam.original" > "$QC.psam"

    # ---------------------------------------------------------
    # 4. REGENIE Step 2 using Step 1 LOCO predictions
    # ---------------------------------------------------------
    regenie \
      --step 2 \
      --pgen "$QC" \
      --pred "$PRED" \
      --phenoFile "$PHENO" \
      --phenoCol height_irnt \
      --covarFile "$COVAR" \
      --covarColList "$COVARS" \
      --catCovarList sex \
      --keep "$KEEP_FID" \
      --qt \
      --chr "$chr" \
      --bsize 400 \
      --threads "$THREADS" \
      --out "$OUT" \
      > "$OUT.stdout.log" 2>&1

    RESULT="${OUT}_height_irnt.regenie"

    # Do not delete anything unless the GWAS result exists.
    test -s "$RESULT"

    # ---------------------------------------------------------
    # 5. Persist association result and QC/REGENIE logs
    # ---------------------------------------------------------
    gcloud storage cp \
      "$RESULT" \
      "$QC.log" \
      "$OUT.log" \
      "$OUT.stdout.log" \
      "$DEST/chr${chr}/"

    echo "CHR ${chr} uploaded successfully: $(date)"

    # ---------------------------------------------------------
    # 6. Free disk before downloading next chromosome
    # ---------------------------------------------------------
    rm -rf "$CHRDIR"

    echo "CHR ${chr} COMPLETE: $(date)"
    df -h /tmp
done

echo
echo "============================================================"
echo "CHROMOSOMES 1-21 COMPLETE: $(date)"
echo "============================================================"
EOF

chmod +x /tmp/run_height_step2_1_21.sh
