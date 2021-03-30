#!/bin/sh

# Notebook directory used by JupyterHub in birdhouse-deploy
notebook_dir="/notebook_dir/tutorial-notebooks"

# Download notebooks required for the base image and add them to the notebook directory
wget -O - https://github.com/Ouranosinc/pavics-sdi/archive/master.tar.gz | \
    tar -xz --wildcards -C $notebook_dir --strip=4 "*/docs/source/notebooks/jupyter_extensions.ipynb"

# Remove write permission on the tutorial-notebooks
chmod -R 555 $notebook_dir/*
