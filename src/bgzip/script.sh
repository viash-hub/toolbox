#!/bin/bash

[[ "$par_decompress" == "false" ]] && unset par_decompress
[[ "$par_rebgzip" == "false" ]] && unset par_rebgzip
[[ "$par_index" == "false" ]] && unset par_index
[[ "$par_reindex" == "false" ]] && unset par_reindex
[[ "$par_test" == "false" ]] && unset par_test
[[ "$par_binary" == "false" ]] && unset par_binary
bgzip -c \
  ${meta_cpus:+--threads "${meta_cpus}"} \
  ${par_offset:+-b "${par_offset}"} \
  ${par_decompress:+-d} \
  ${par_rebgzip:+-g} \
  ${par_index:+-i} \
  ${par_index_name:+-I "${par_index_name}"} \
  ${par_compress_level:+-l "${par_compress_level}"} \
  ${par_reindex:+-r} \
  ${par_size:+-s "${par_size}"} \
  ${par_test:+-t} \
  ${par_binary:+--binary} \
  "$par_input" > "$par_output"