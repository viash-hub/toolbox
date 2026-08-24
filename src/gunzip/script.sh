#!/bin/bash

## VIASH START
## VIASH END

set -eo pipefail

[[ "$par_force" == "false" ]] && unset par_force
[[ "$par_keep" == "false" ]] && unset par_keep
[[ "$par_list" == "false" ]] && unset par_list
[[ "$par_no_name" == "false" ]] && unset par_no_name
[[ "$par_name" == "false" ]] && unset par_name
[[ "$par_quiet" == "false" ]] && unset par_quiet
[[ "$par_recursive" == "false" ]] && unset par_recursive
[[ "$par_suffix" == "false" ]] && unset par_suffix
[[ "$par_synchronous" == "false" ]] && unset par_synchronous
[[ "$par_test" == "false" ]] && unset par_test
[[ "$par_verbose" == "false" ]] && unset par_verbose

gunzip -c \
    ${par_force:+-f } \
    ${par_keep:+-k } \
    ${par_list:+-l } \
    ${par_no_name:+-n } \
    ${par_name:+-N } \
    ${par_quiet:+-q } \
    ${par_recursive:+-r } \
    ${par_suffix:+-S "${par_suffix}"} \
    ${par_synchronous:+--synchronous} \
    ${par_test:+-t } \
    ${par_verbose:+-v } \
    "$par_input" > "$par_output"