#!/usr/bin/env bash

project = `terraform output project`
cicdemail = `terraform output service-account-cicd`
cmdbemail = `terraform output service-account-cmdb`

echo $project
echo $cicdemail

gcloud config set $project

gcloud init

gcloud iam service-accounts keys create cicd_key.json --iam-account=$cicdemail

gcloud iam service-accounts keys create cmdb_key.json --iam-account=$cmdbemail

[ ! -d "/keys/" ] && mkdir keys

mv cicd_key.json ./keys/cicd_key.json

mv cmdb_key.json ./keys/cmdb_key.json

git remote add google ssh://alex.stangier@cloudwuerdig.com@source.developers.google.com:2022/p/cw-academy-sandbox-repo/r/acme-cmdb

git push --all google