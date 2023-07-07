# acme-cmdb instance manager

## Setup

Run `./gcp terraform apply` in project dir to create the needed infrastructure. Currently used infrastructure is:
```
Cloud Source Repository
Artifact Registry
Secret Manager
Cloud Run
```
After succesfully allocating the infrastructure either trigger a build process, by pushing to main, or run the pipe actions manually.

## Usage
The Api Service will establish two public endpoints:
+ /get_compute_instances
+ /set_state

### Get compute instances
Lists all Project related compute instances, sorted by zones. 
Example Query String: *<cloud run uri>/get_compute_engines*

### Set state
Enables the user to stop or start instances, by adressing them by their zone and name.
Example Query String: *<cloud run uri>/set_state?name=<instance name>&state=<start|stop>&zone=<zone>*

## Authentication
To authenticate to the API you must place a service account key file into the request json body. [This is subject to change]
The service account must have the *roles/compute.instanceAdmin* role associated.

## TODOS
- [x] Proper README
- [ ] Proper Auth, ditching service account key files
- [ ] Move whole CICD to GCP
- [ ] Implement more states for set state
- [ ] Implement other GCP API functions
