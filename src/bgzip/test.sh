set -e

"$meta_executable" --input "$meta_resources_dir/test_data/test.vcf" --output "test.vcf.gz"

echo ">> Checking output of compressing"
[ ! -f "test.vcf.gz" ] && echo "Output file test.vcf.gz does not exist" && exit 1

"$meta_executable" --input "test.vcf.gz" --output "test.vcf" --decompress

echo ">> Checking output of decompressing"
[ ! -f "test.vcf" ] && echo "Output file test.vcf does not exist" && exit 1

echo ">> Checking original and decompressed files are the same"
set +e
cmp --silent -- "$meta_resources_dir/test_data/test.vcf" "test.vcf"
[ $? -ne 0 ] && echo "files are different" && exit 1
set -e

echo "> Test successful"
