#!/usr/bin/env bash

gcloud auth login

gcloud iam service-accounts keys create cicd_key.json --iam-account=as-acme-cmdb-1@cw-academy-sandbox-alex.iam.gserviceaccount.com

gcloud iam service-accounts keys create cmdb_key.json --iam-account=as-acme-cmdb-2@cw-academy-sandbox-alex.iam.gserviceaccount.com

[ ! -d "/keys/" ] && mkdir keys

mv cicd_key.json ./keys/cicd_key.json

mv cmdb_key.json ./keys/cmdb_key.json

git remote add google ssh://alex.stangier@cloudwuerdig.com@source.developers.google.com:2022/p/cw-academy-sandbox-repo/r/acme-cmdb

git push --all google