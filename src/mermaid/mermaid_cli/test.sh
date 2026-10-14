#!/bin/bash

## VIASH START
## VIASH END

set -eo pipefail

TMPDIR=$(mktemp -d)
function clean_up {
  rm -rf "$TMPDIR"
}
trap clean_up EXIT

cat > "$TMPDIR/diagram.mmd" <<'EOF'
graph TD
  A[Start] --> B{Is it working?}
  B -->|Yes| C[Great]
  B -->|No| D[Debug]
  D --> B
EOF

cat > "$TMPDIR/document.md" <<'EOF'
# Test document

```mermaid
sequenceDiagram
  Alice->>Bob: Hello Bob
  Bob-->>Alice: Hi Alice
```

Some text in between.

```mermaid
pie title Pets
  "Dogs" : 40
  "Cats" : 60
```
EOF

cat > "$TMPDIR/config.json" <<'EOF'
{"theme": "forest"}
EOF

cat > "$TMPDIR/style.css" <<'EOF'
.node rect { fill: #ff0000; }
EOF

echo "> Test 1: render SVG"
"$meta_executable" \
  --input "$TMPDIR/diagram.mmd" \
  --output "$TMPDIR/out1/diagram.svg" \
  --svg_id "my_diagram"

[ ! -f "$TMPDIR/out1/diagram.svg" ] && echo "Output file diagram.svg does not exist" && exit 1
grep -q "<svg" "$TMPDIR/out1/diagram.svg" || { echo "Output is not an SVG"; exit 1; }
grep -q 'id="my_diagram"' "$TMPDIR/out1/diagram.svg" || { echo "SVG id not set"; exit 1; }
grep -q "Is it working?" "$TMPDIR/out1/diagram.svg" || { echo "SVG does not contain node label"; exit 1; }

echo "> Test 2: render PNG with theme, background color, scale and size"
"$meta_executable" \
  --input "$TMPDIR/diagram.mmd" \
  --output "$TMPDIR/out2/diagram.png" \
  --theme dark \
  --background_color transparent \
  --scale 2 \
  --size 400 \
  --quiet

[ ! -s "$TMPDIR/out2/diagram.png" ] && echo "Output file diagram.png does not exist or is empty" && exit 1
[ "$(head -c 4 "$TMPDIR/out2/diagram.png" | tail -c 3)" == "PNG" ] || { echo "Output is not a PNG"; exit 1; }

echo "> Test 3: render PDF with paper format"
"$meta_executable" \
  --input "$TMPDIR/diagram.mmd" \
  --output "$TMPDIR/out3/diagram.pdf" \
  --pdf_paper_format A4

[ ! -s "$TMPDIR/out3/diagram.pdf" ] && echo "Output file diagram.pdf does not exist or is empty" && exit 1
[ "$(head -c 4 "$TMPDIR/out3/diagram.pdf")" == "%PDF" ] || { echo "Output is not a PDF"; exit 1; }

echo "> Test 4: render with config and CSS file, without font embedding"
"$meta_executable" \
  --input "$TMPDIR/diagram.mmd" \
  --output "$TMPDIR/out4/diagram.svg" \
  --config_file "$TMPDIR/config.json" \
  --css_file "$TMPDIR/style.css" \
  --no_font_embed

[ ! -s "$TMPDIR/out4/diagram.svg" ] && echo "Output file diagram.svg does not exist or is empty" && exit 1
grep -qiE "#ff0000|rgb\(255, ?0, ?0\)" "$TMPDIR/out4/diagram.svg" || { echo "CSS was not applied"; exit 1; }

echo "> Test 5: render Markdown with artefacts directory"
"$meta_executable" \
  --input "$TMPDIR/document.md" \
  --output "$TMPDIR/out5/document.md" \
  --artefacts "$TMPDIR/out5/images" \
  --output_format png

[ ! -f "$TMPDIR/out5/document.md" ] && echo "Output file document.md does not exist" && exit 1
grep -q '```mermaid' "$TMPDIR/out5/document.md" && echo "Mermaid blocks were not replaced" && exit 1
num_images=$(find "$TMPDIR/out5/images" -name "*.png" | wc -l)
[ "$num_images" -ne 2 ] && echo "Expected 2 images, found $num_images" && exit 1
grep -q "\.png" "$TMPDIR/out5/document.md" || { echo "Markdown does not reference images"; exit 1; }

echo "> Test 6: invalid diagram should fail"
echo "this is not a mermaid diagram" > "$TMPDIR/invalid.mmd"
if "$meta_executable" --input "$TMPDIR/invalid.mmd" --output "$TMPDIR/out6/invalid.svg" 2> /dev/null; then
  echo "Expected failure on invalid diagram"
  exit 1
fi

echo "> All tests succeeded!"
