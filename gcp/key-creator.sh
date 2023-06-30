#!/usr/bin/env bash

#Create Dir for keystorage
mkdir keys

accounts =`terraform output -json service-accounts`

print $accounts
