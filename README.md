# pavics-jupyter-base
Base Jupyter docker image for PAVICS.
Specialized component images will be built from this image for both CRIM and Ouranos
organizations.

Tutorial notebooks are included with the docker image. Each specialized images provides its own custom notebooks, and
all generic notebooks of the base image are downloaded and added when starting the Docker container from JupyterHub.

Repos for the component images :
* crim-ca/pavics-jupyter-images : https://github.com/crim-ca/pavics-jupyter-images
* Ouranosinc/pavics-jupyter-images : to be created
