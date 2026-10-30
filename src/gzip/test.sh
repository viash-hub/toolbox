#!/bin/bash

## VIASH START
## VIASH END

set -eo pipefail

test_data_dir="$meta_temp_dir/test_data"
test_output_dir="$meta_temp_dir/test_output"
mkdir -p "$test_data_dir" "$test_output_dir"

echo "> Create test data"
# Test data was obtained from https://github.com/snakemake/snakemake-wrappers/tree/master/bio/bgzip/test.
cat > "$test_data_dir/test.vcf" <<'EOF'
##fileformat=VCFv4.0
##fileDate=20090805
##source=https://www.internationalgenome.org/wiki/Analysis/vcf4.0/
##reference=1000GenomesPilot-NCBI36
##phasing=partial
##INFO=<ID=NS,Number=1,Type=Integer,Description="Number of Samples With Data">
##INFO=<ID=DP,Number=1,Type=Integer,Description="Total Depth">
##INFO=<ID=AF,Number=.,Type=Float,Description="Allele Frequency">
##INFO=<ID=AA,Number=1,Type=String,Description="Ancestral Allele">
##INFO=<ID=DB,Number=0,Type=Flag,Description="dbSNP membership, build 129">
##INFO=<ID=H2,Number=0,Type=Flag,Description="HapMap2 membership">
##FILTER=<ID=q10,Description="Quality below 10">
##FILTER=<ID=s50,Description="Less than 50% of samples have data">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Read Depth">
##FORMAT=<ID=HQ,Number=2,Type=Integer,Description="Haplotype Quality">
#CHROM POS     ID        REF ALT    QUAL FILTER INFO                              FORMAT      NA00001        NA00002        NA00003
20     14370   rs6054257 G      A       29   PASS   NS=3;DP=14;AF=0.5;DB;H2           GT:GQ:DP:HQ 0|0:48:1:51,51 1|0:48:8:51,51 1/1:43:5:.,.
20     17330   .         T      A       3    q10    NS=3;DP=11;AF=0.017               GT:GQ:DP:HQ 0|0:49:3:58,50 0|1:3:5:65,3   0/0:41:3
20     1110696 rs6040355 A      G,T     67   PASS   NS=2;DP=10;AF=0.333,0.667;AA=T;DB GT:GQ:DP:HQ 1|2:21:6:23,27 2|1:2:0:18,2   2/2:35:4
20     1230237 .         T      .       47   PASS   NS=3;DP=13;AA=T                   GT:GQ:DP:HQ 0|0:54:7:56,60 0|0:48:4:51,51 0/0:61:2
20     1234567 microsat1 GTCT   G,GTACT 50   PASS   NS=3;DP=9;AA=G                    GT:GQ:DP    0/1:35:4       0/2:17:2       1/1:40:3
EOF
input="$test_data_dir/test.vcf"
[ ! -s "$input" ] && echo "Test data $input was not created" && exit 1

# FLG byte (offset 3) of a gzip header; bit 3 (value 8) is set when the original file name is stored
has_stored_name() {
  local flg
  flg=$(od -An -tu1 -j3 -N1 "$1" | tr -d ' ')
  [ $(( flg & 8 )) -ne 0 ]
}

echo "> TEST 1: Compress with default settings"
"$meta_executable" \
  --input "$input" \
  --output "$test_output_dir/compressed.vcf.gz"

echo ">> Checking output"
[ ! -s "$test_output_dir/compressed.vcf.gz" ] && echo "Output file compressed.vcf.gz does not exist or is empty" && exit 1
gzip -t "$test_output_dir/compressed.vcf.gz" || { echo "Output file compressed.vcf.gz is not a valid gzip file"; exit 1; }
has_stored_name "$test_output_dir/compressed.vcf.gz" || { echo "Original file name should be stored by default"; exit 1; }

echo "> TEST 2: Decompress the compressed file"
"$meta_executable" \
  --input "$test_output_dir/compressed.vcf.gz" \
  --output "$test_output_dir/decompressed.vcf" \
  --decompress

echo ">> Checking original and decompressed files are the same"
[ ! -f "$test_output_dir/decompressed.vcf" ] && echo "Output file decompressed.vcf does not exist" && exit 1
cmp -s -- "$input" "$test_output_dir/decompressed.vcf" || { echo "Files are different"; exit 1; }

echo "> TEST 3: Compress with --compress_level 9 and --no_name"
"$meta_executable" \
  --input "$input" \
  --output "$test_output_dir/best.vcf.gz" \
  --compress_level 9 \
  --no_name

echo ">> Checking output"
[ ! -s "$test_output_dir/best.vcf.gz" ] && echo "Output file best.vcf.gz does not exist or is empty" && exit 1
gzip -dc "$test_output_dir/best.vcf.gz" | cmp -s -- "$input" - || { echo "Files are different"; exit 1; }
has_stored_name "$test_output_dir/best.vcf.gz" && { echo "Original file name should not be stored with --no_name"; exit 1; }

echo ">> Checking output of --no_name is reproducible"
"$meta_executable" \
  --input "$input" \
  --output "$test_output_dir/best_again.vcf.gz" \
  --compress_level 9 \
  --no_name
cmp -s -- "$test_output_dir/best.vcf.gz" "$test_output_dir/best_again.vcf.gz" || { echo "Outputs with --no_name are not identical"; exit 1; }

echo "> TEST 4: Compress a symlinked input (as staged by Nextflow)"
ln -s "$input" "$test_data_dir/linked.vcf"
"$meta_executable" \
  --input "$test_data_dir/linked.vcf" \
  --output "$test_output_dir/linked.vcf.gz"

echo ">> Checking output"
gzip -dc "$test_output_dir/linked.vcf.gz" | cmp -s -- "$input" - || { echo "Files are different"; exit 1; }

echo "> TEST 5: Compress and decompress an empty file"
touch "$test_data_dir/empty.txt"
"$meta_executable" \
  --input "$test_data_dir/empty.txt" \
  --output "$test_output_dir/empty.txt.gz"
"$meta_executable" \
  --input "$test_output_dir/empty.txt.gz" \
  --output "$test_output_dir/empty.txt" \
  --decompress

echo ">> Checking output"
gzip -t "$test_output_dir/empty.txt.gz" || { echo "Output file empty.txt.gz is not a valid gzip file"; exit 1; }
[ ! -f "$test_output_dir/empty.txt" ] && echo "Output file empty.txt does not exist" && exit 1
[ -s "$test_output_dir/empty.txt" ] && echo "Output file empty.txt should be empty" && exit 1

echo "> TEST 6: Decompress uncompressed input"
echo ">> Without --force, decompressing should fail"
if "$meta_executable" \
  --input "$input" \
  --output "$test_output_dir/not_gzip.vcf" \
  --decompress 2>/dev/null; then
  echo "Decompressing uncompressed input should have failed"
  exit 1
fi

echo ">> With --force, the input should be copied through unchanged"
"$meta_executable" \
  --input "$input" \
  --output "$test_output_dir/forced.vcf" \
  --decompress \
  --force
cmp -s -- "$input" "$test_output_dir/forced.vcf" || { echo "Files are different"; exit 1; }

echo "> TEST 7: Non-existent input file"
if "$meta_executable" \
  --input "$test_data_dir/does_not_exist.txt" \
  --output "$test_output_dir/does_not_exist.txt.gz" 2>/dev/null; then
  echo "Compressing a non-existent input file should have failed"
  exit 1
fi

echo "> All tests succeeded"
