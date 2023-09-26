#!/bin/bash

# Validate the input argument
if [[ -z "$1" ]]; then
    echo "Usage: $0 <path-to-directory>"
    exit 1
fi

DIRECTORY="$1"

# Define a function for each renaming pattern
# util function to rename adapters
transform_adapter_field() {
    local file="$1"
    local fromField="$2"
    local toField="$3"

    local len_adapters=$(yq eval '.adapters | length' "$file")
    
    for (( i=0; i<$len_adapters; i++ )); do
        yq eval -i ".adapters[$i].$toField = .adapters[$i].$fromField | del(.adapters[$i].$fromField)" "$file"
    done
}

# util function to rename step fields
transform_steps_field() {
    local file="$1"
    local fromField="$2"
    local toField="$3"

    local len_adapters=$(yq eval '.adapters | length' "$file")
    
    for (( i=0; i<$len_adapters; i++ )); do
        local len_steps=$(yq eval ".adapters[$i].steps | length" "$file")
        for (( j=0; j<$len_steps; j++ )); do
            yq eval -i ".adapters[$i].steps[$j].$toField = .adapters[$i].steps[$j].$fromField | del(.adapters[$i].steps[$j].$fromField)" "$file"
        done
    done
}

rename_ingressAdapters() {
    yq eval -i '.adapters = .ingressAdapters | del(.ingressAdapters)' "$1"
}

rename_broker() {
    transform_adapter_field "$1" "broker" "consumer"
}

rename_stateless() {
    transform_adapter_field "$1" "stateless" "server"
}

rename_stateful() {
    transform_adapter_field "$1" "stateful" "repository"
}

# Rename egress
rename_egressAdapters() {
    transform_steps_field "$1" "egressAdapter" "adapter"
}

rename_steps_stateless() {
    transform_steps_field "$1" "adapter.stateless" "adapter.invocation"
}

rename_steps_stateful() {
    transform_steps_field "$1" "adapter.stateful" "adapter.repository"
}

rename_steps_broker() {
    transform_steps_field "$1" "adapter.broker" "adapter.producer"
}

remove_nulls() {
    yq eval -i 'del(.. | select(. == null))' "$1"
}

move_gateway() {
    yq eval -i '.deployment.gateway = .gateway | del(.gateway)' "$1"
}

update_version() {
    yq eval -i '.version = "v0.1.0"' "$1"
}

# Process each file with the renaming functions in order
process_file() {
    local file="$1"
    echo "Processing: $file"
    rename_ingressAdapters "$file"
    rename_broker "$file"
    rename_stateless "$file"
    rename_stateful "$file"
    rename_egressAdapters "$file"
    rename_steps_broker "$file"
    rename_steps_stateless "$file"
    rename_steps_stateful "$file"
    update_version "$file"
    move_gateway "$file"

    remove_nulls "$file"
}

# Find all YAML files recursively and apply renaming
find "$DIRECTORY" -type f \( -name "*.yaml" -o -name "*.yml" \) -print | while read -r file; do
    process_file "$file"
done

echo "All files processed."

