# Python API Boilerplate
A simple Python API project boilerplate to showcase a container strategy from development to deployment and a working CICD example to deploy it to Cloud Run.

Tech stack :
* **Python 3.9**
  * fastapi
  * pytest, black, isort, mypy
* **Google Container Registry**: docker image hosting
* **Github Actions**: CI/CD pipelines
* **Google Cloud Run** : Runtime for the API

## Development
Requirements:
* Make
* Docker
For VSCode user, you can use the devcontainer with the `Remote-Container` extension and use `Remote-Container : Reopen in Container`to build and reopen VSCode in the development container.
Set the following environment variables for local development: 
* `GOOGLE_APPLICATION_CREDENTIALS` : path to a valid .json auth file for GCP
* `GCP_PROJECT` : your GCP project id

For Github Actions, add the following github secrets to your repo (Settings > Secrets):
* `GOOGLE_APPLICATION_CREDENTIALS_JSON` : The .json value of your auth file for GCP
* `GCP_PROJECT` : your GCP project id

## make commands
By default these commands are dockerized. If you run them inside the devcontainer, just set this environment variable to an empty value : `export DOCKERIZED=`
| Description               | Make Command   |
| ------------------------- | -------------- |
| Unit test                 | `make test`    |
| Format code (black/isort) | `make format`  |
| Run API                   | `make run-app` |
| Deploy to Cloud Run       | `make deploy`  |
| Destroy Cloud Run service | `make destroy` |