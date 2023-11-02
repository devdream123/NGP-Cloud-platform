#!/usr/bin/env bash

echo "Starting create-pubsub-topic-schema.sh"

set -o errexit   # abort on nonzero exitstatus
set -o pipefail  # don't hide errors within pipes
set -o nounset   # abort on unbound variable

protobuf_schema_filename=$1
protobuf_schema_file_path=$2
topic_schema_name=$3
topic_full_id=$4
project_id=$5
topic_schema_full_id="projects/${project_id}/schemas/${topic_schema_name}"
MAX_N_REVISIONS=20

if [[ ! $(gcloud pubsub topics describe "${topic_full_id}") ]]; then
  echo "Topic ${topic_full_id} not found."
  exit 1
fi

echo "Validating schema definition for ${topic_schema_name}..."

if [[ $(gcloud pubsub schemas validate-schema \
          --type="protocol-buffer" \
          --definition-file="${protobuf_schema_file_path}/${protobuf_schema_filename}") -ne 0
    ]]; then
  echo "Definition file ${protobuf_schema_filename} contains invalid protobuf schema definition"
  exit 1
fi

echo "Checking schema ${topic_schema_full_id} exists..."

if [[ ! $(gcloud pubsub schemas describe "${topic_schema_name}" --project="${project_id}") ]]; then
  echo "Schema not found. Creating new schema..."
  gcloud pubsub schemas create \
         "${topic_schema_full_id}" \
         --type="protocol-buffer" \
         --definition-file="${protobuf_schema_file_path}/${protobuf_schema_filename}" \
         --format=yaml | yq '.name'

  create_schema=$?

  if [[ "${create_schema}" -ne 0 ]]; then
      echo "Failed to create schema with ID ${topic_schema_full_id} using definition file ${protobuf_schema_filename}"
      exit 1
  fi

else

  n_revisions=$(gcloud pubsub schemas list-revisions \
                "${topic_schema_full_id}" \
               --format=yaml \
               --sort-by=revisionCreateTime \
               | yq '{.revisionId: .name}' | yq 'length')

  if [[ "${n_revisions}" == "${MAX_N_REVISIONS}" ]]; then

    echo "The maximum number of revisions exist. Deleting the oldest revision..."
    oldest_revision_id=$(gcloud pubsub schemas list-revisions "${topic_schema_full_id}" \
                          --format=yaml \
                          --sort-by=revisionCreateTime \
                          | yq 'select(document_index == 0)' \
                          | yq '.revisionId')
    gcloud pubsub schemas delete-revision "${topic_schema_full_id}@${oldest_revision_id}"

  fi

  echo "Creating new revision for ${topic_schema_full_id}..."
  gcloud pubsub schemas commit \
         "${topic_schema_full_id}" \
         --type=protocol-buffer \
        --definition-file="${protobuf_schema_file_path}/${protobuf_schema_filename}" 

  create_schema=$?
  
  if [[ "${create_schema}" -ne 0 ]]; then
    echo "Failed to commit schema revision for schema ${topic_schema_full_id} using definition file ${protobuf_schema_filename}".
    exit 1
  fi

fi

most_recent_revision=$(gcloud pubsub schemas describe "${topic_schema_full_id}" --format=yaml | yq .revisionId)
echo "Update topic ${topic_full_id} to only use latest schema revision ${most_recent_revision}..."
gcloud pubsub topics update \
       "${topic_full_id}" \
       --schema="${topic_schema_full_id}" \
       --message-encoding=binary \
       --first-revision-id="${most_recent_revision}" \
       --last-revision-id="${most_recent_revision}"

update_schema=$?

if [[ "${update_schema}" -ne 0 ]]; then
  echo "Failed to update the schema of ${topic_full_id}"
  exit 1
fi