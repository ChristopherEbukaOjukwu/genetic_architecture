nohup regenie \
  --step 1 \
  --bed /tmp/array_step1/arrays_eur_step1 \
  --phenoFile /tmp/array_step1/height_pheno.tsv \
  --phenoColList height_irnt \
  --covarFile /tmp/array_step1/height_covar.tsv \
  --covarColList age_at_measurement,age2,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,PC11,PC12,PC13,PC14,PC15,PC16 \
  --catCovarList sex \
  --qt \
  --bsize 200 \
  --lowmem \
  --lowmem-prefix /tmp/array_step1/regenie_step1/height_tmp \
  --threads 15 \
  --out /tmp/array_step1/regenie_step1/height \
  > /tmp/array_step1/regenie_step1/height.nohup.log 2>&1 &

echo $!
