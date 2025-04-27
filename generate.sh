#!/usr/bin/env bash
set -e

username="sw1pr0g"
in="README.tmpl.md"
out="README.md"
readme_data="data/readme.json"

if ! command -v jq &> /dev/null; then
    echo "Error: jq not installed."
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    sed_inplace() {
        sed -i '' "$@"
    }
else
    sed_inplace() {
        sed -i "$@"
    }
fi

cp "$in" "$out"

sed_inplace "s|{{USERNAME}}|$username|g" "$out"

jq -r 'to_entries[] | "\(.key)=\(.value | if type=="array" then join(", ") else tostring end)"' "$readme_data" |
while IFS="=" read -r key value; do
    placeholder="{{$(echo "$key" | awk '{print toupper($0)}')}}"
    value_escaped=$(echo "$value" | sed 's/[&/\]/\\&/g')
    sed_inplace "s|$placeholder|$value_escaped|g" "$out"
done

echo "README generated!"