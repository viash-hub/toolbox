#!/bin/bash

## VIASH START
## VIASH END

set -eo pipefail

# unset flags
unset_if_false=(
  par_decompress
  par_no_name
  par_name
  par_rsyncable
  par_force
  par_quiet
  par_verbose
)

for par in "${unset_if_false[@]}"; do
  test_val="${!par}"
  [[ "$test_val" == "false" ]] && unset $par
done

# Build command arguments array
cmd_args=(
  --stdout
  ${par_decompress:+--decompress}
  ${par_compress_level:+-"$par_compress_level"}
  ${par_no_name:+--no-name}
  ${par_name:+--name}
  ${par_rsyncable:+--rsyncable}
  ${par_force:+--force}
  ${par_quiet:+--quiet}
  ${par_verbose:+--verbose}
  "$par_input"
)

# Execute command
gzip "${cmd_args[@]}" > "$par_output"
