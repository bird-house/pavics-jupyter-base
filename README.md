# pavics-jupyter-base
Base Jupyter docker image for PAVICS.
Specialized component images will be built from this image for both CRIM and Ouranos
organizations.

Repos for the component images :
* crim-ca/pavics-jupyter-images : https://github.com/crim-ca/pavics-jupyter-images
* Ouranosinc/pavics-jupyter-images : to be created

This repo includes a script (deploy_data_specific_image) and its related env file. These files are used in the context
of a cronjob started by the scheduler from the birdhouse-deploy repo. They are used to download and update the 
different notebooks for each specific image, which are available to the users on JupyterHub.
