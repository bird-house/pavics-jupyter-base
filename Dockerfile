FROM continuumio/miniconda3

RUN conda update conda

# to checkout other notebooks and to run pip install
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git mercurial gcc jq && \
    apt-get clean

# Installation of rsync used for the notebooks deployement
RUN apt-get -y install rsync

COPY environment /environment

# needed for our specific jenkins
RUN groupadd --gid 1000 jenkins \
    && useradd --uid 1000 --gid jenkins --create-home jenkins

# Change these folders' permissions for jupyter-conda extension
RUN chmod -R a+rwx /opt/conda

# create env "birdy"
# environment is split into multiple .yml files, in order to reduce the amount of RAM usage for each Dockerfile steps
# and to avoid CondaMemoryError when building the image on Docker Hub
# use umask 0000 so that the files for the new environment are usable by user 'jenkins' for the jupyter-conda-extension
RUN umask 0000 && conda env create -f /environment/environment_main.yml \
    && conda env update -f /environment/environment_test.yml \
    && conda env update -f /environment/environment_data.yml \
    && conda env update -f /environment/environment_visualization.yml \
    && conda env update -f /environment/environment_jupyter_plugins.yml \
    # The conda update for 3rd parties could potentially be moved further down in the Dockerfile,
    # depending if its dependencies change too often, in order to optimize the duration of Docker builds.
    && conda env update -f /environment/environment_pavics.yml

# alternate way to 'source activate birdy'
ENV PATH="/opt/conda/envs/birdy/bin:$PATH"

# our notebooks are hardcoded to lookup for kernel named 'birdy'
# this python is from the birdy env above
RUN python -m ipykernel install --name birdy

# build jupyterlab extensions installed by conda, see `jupyter labextension list`
RUN jupyter lab build

# for ipywidgets to work with jupyter lab (notebooks works out of the box)
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-leaflet \
    && jupyter labextension install @bokeh/jupyter_bokeh \
    && jupyter labextension install @pyviz/jupyterlab_pyviz \
    && jupyter labextension install @jupyterlab/google-drive \
    && jupyter labextension install jupyterlab_conda

ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-singleuser.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-notebook.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/fix-permissions /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/jupyter_notebook_config.py /etc/jupyter/
RUN chmod a+rx /usr/local/bin/start.sh /usr/local/bin/start-singleuser.sh /usr/local/bin/start-notebook.sh /usr/local/bin/fix-permissions; \
    chmod a+r /etc/jupyter/jupyter_notebook_config.py

# Include a copy of the script used by birdhouse-deploy to deploy the notebooks of the specific images
COPY scheduler-jobs/deploy_data_specific_image /deploy_data_specific_image

# problem running start-notebook.sh when being root
# the jupyter/base-notebook image also do not default to root user so we do the same here
USER jenkins

# follow jupyter/base-notebook image so config in jupyterhub is simpler
# start notebook in conda environment to have working jupyter extensions
CMD ["conda", "run", "-n", "birdy", "/usr/local/bin/start-notebook.sh"]
