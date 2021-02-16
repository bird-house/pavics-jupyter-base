FROM continuumio/miniconda3

RUN conda update conda

# to checkout other notebooks and to run pip install
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y git mercurial gcc && \
    apt-get clean

COPY environment.yml /environment.yml

# needed for our specific jenkins
RUN groupadd --gid 1000 jenkins \
    && useradd --uid 1000 --gid jenkins --create-home jenkins

# Change these folders' permissions for jupyter-conda extension
RUN chmod -R a+rwx /opt/conda

# create env "birdy"
# use umask 0000 so that the files for the new environment are usable by user 'jenkins' for the jupyter-conda-extension
RUN umask 0000 && conda env create -f /environment.yml

# alternate way to 'source activate birdy'
ENV PATH="/opt/conda/envs/birdy/bin:$PATH"

# TODO: remove this hacked pin.  Should pin in environment.yml instead.
# Added this pin here to not have to rebuild the gigantic `conda env create`
# layer and also invalidate the layer below to force get latest ravenpy 0.2.3.
# Pins cftime >= 1.2 < 1.4. Because 1.4 breaks xarray (pydata/xarray#4853).
# https://github.com/Ouranosinc/xclim/pull/641
RUN conda install -c conda-forge -c cdat -c bokeh -c plotly -c defaults -n birdy cftime==1.3.1

# our notebooks are hardcoded to lookup for kernel named 'birdy'
# this python is from the birdy env above
# Make, g++ and libnetcdf-dev needed for ravenpy install using --install-option.
# Can move ravenpy install into environment.yml if this issue is resolved
# https://github.com/conda/conda/issues/10119#issuecomment-767697552.
RUN python -m ipykernel install --name birdy \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y make g++ libnetcdf-dev && apt-get clean \
    && pip install ravenpy --install-option="--with-binaries"

# install using same channel preferences as birdy original env to not downgrade
# anything accidentally
# this is for debug only, all dependencies should be specified in
# environment.yml above
# RUN conda install -c conda-forge -c cdat -c bokeh -c plotly -c defaults -n birdy nbdime

# build jupyterlab extensions installed by conda, see `jupyter labextension list`
RUN jupyter lab build

# for ipywidgets to work with jupyter lab (notebooks works out of the box)
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
    && jupyter serverextension enable voila --sys-prefix \
    && jupyter labextension install @jupyter-widgets/jupyterlab-manager jupyter-leaflet \
    && jupyter labextension install @bokeh/jupyter_bokeh \
    && jupyter labextension install @pyviz/jupyterlab_pyviz \
    && jupyter labextension install @jupyterlab/debugger \
    && jupyter labextension install @jupyterlab/google-drive \
    && jupyter labextension install jupyterlab-topbar-extension \
                                    jupyterlab-system-monitor \
                                    jupyterlab-topbar-text \
                                    jupyterlab-logout \
                                    jupyterlab-theme-toggle \
                                    jupyterlab_conda
#    && jupyter labextension install jupyterlab-clipboard

ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-singleuser.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/start-notebook.sh /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/fix-permissions /usr/local/bin/
ADD https://raw.githubusercontent.com/jupyter/docker-stacks/master/base-notebook/jupyter_notebook_config.py /etc/jupyter/
RUN chmod a+rx /usr/local/bin/start.sh /usr/local/bin/start-singleuser.sh /usr/local/bin/start-notebook.sh /usr/local/bin/fix-permissions; \
    chmod a+r /etc/jupyter/jupyter_notebook_config.py

# problem running start-notebook.sh when being root
# the jupyter/base-notebook image also do not default to root user so we do the same here
USER jenkins

# follow jupyter/base-notebook image so config in jupyterhub is simpler
# start notebook in conda environment to have working jupyter extensions
CMD ["conda", "run", "-n", "birdy", "/usr/local/bin/start-notebook.sh"]
