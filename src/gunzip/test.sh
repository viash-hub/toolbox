set -e

## VIASH START
## VIASH END

"$meta_executable" --input "$meta_resources_dir/test_data/test.vcf.gz" --output "test.vcf"

echo ">> Checking output of decompressing"
[ ! -f "test.vcf" ] && echo "Output file test.vcf does not exist" && exit 1

echo "> Test successful"
