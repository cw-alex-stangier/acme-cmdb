#!/usr/bin/env bash

gcloud iam service-accounts keys create cicd_key.json --iam-account=as-acme-cmdb-1@cw-academy-sandbox-alex.iam.gserviceaccount.com

gcloud iam service-accounts keys create cmdb_key.json --iam-account=as-acme-cmdb-2@cw-academy-sandbox-alex.iam.gserviceaccount.com

mkdir keys

mv cicd_key.json ./keys/cicd_key.json

mv cmdb_key.json ./keys/cmdb_key.json