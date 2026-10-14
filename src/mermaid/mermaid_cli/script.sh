#!/bin/bash

## VIASH START
## VIASH END

set -eo pipefail

[[ "$par_no_font_embed" == "false" ]] && unset par_no_font_embed
[[ "$par_quiet" == "false" ]] && unset par_quiet

# Use the puppeteer configuration shipped with the docker image (chromium
# without a sandbox) unless the user provided one.
if [ -z "$par_puppeteer_config_file" ] && [ -f /puppeteer-config.json ]; then
  par_puppeteer_config_file=/puppeteer-config.json
fi

cmd_args=(
  --input "$par_input"
  --output "$par_output"
  ${par_artefacts:+--artefacts "$par_artefacts"}
  ${par_config_file:+--configFile "$par_config_file"}
  ${par_css_file:+--cssFile "$par_css_file"}
  ${par_puppeteer_config_file:+--puppeteerConfigFile "$par_puppeteer_config_file"}
  ${par_output_format:+--outputFormat "$par_output_format"}
  ${par_theme:+--theme "$par_theme"}
  ${par_size:+--size "$par_size"}
  ${par_background_color:+--backgroundColor "$par_background_color"}
  ${par_svg_id:+--svgId "$par_svg_id"}
  ${par_scale:+--scale "$par_scale"}
  ${par_no_font_embed:+--no-font-embed}
  ${par_pdf_paper_format:+--pdf-paper-format "$par_pdf_paper_format"}
  ${par_quiet:+--quiet}
  ${meta_cpus:+--jobs "$meta_cpus"}
)

if [ -n "$par_icon_packs" ]; then
  IFS=";" read -ra icon_packs <<< "$par_icon_packs"
  cmd_args+=(--iconPacks "${icon_packs[@]}")
fi

if [ -n "$par_icon_packs_names_and_urls" ]; then
  IFS=";" read -ra icon_packs_names_and_urls <<< "$par_icon_packs_names_and_urls"
  cmd_args+=(--iconPacksNamesAndUrls "${icon_packs_names_and_urls[@]}")
fi

if [ -n "$par_artefacts" ]; then
  mkdir -p "$par_artefacts"
fi

mmdc "${cmd_args[@]}"
