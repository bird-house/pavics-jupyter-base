Changes
=======

Unreleased (latest)
===================

Changes:
--------
- ...

Fixes:
------
- ...

0.4.0 (2022-12-23)
===================

Changes:
--------
- Install requirements with `mamba` instead of `conda`, which greatly speeds up the installation steps and which avoids
  lots of resolution conflicts.

Fixes:
------
- Pin `packaging` version to avoid a package installation error when using the `jupyterlab_conda` extension to install
  packages from JupyterLab.
- Pin `jupyterlab-git` version to avoid newer versions which are only compatible with JupyterLab v3.
- Pin some other requirements to avoid errors while installing environment during image build.

0.3.0 (2022-12-13)
===================

Changes:
--------
- Add a JupyterLab extension to display a message on the top bar, along with the file `plugin.json` to customize the 
  extension display.

Fixes:
------
- Fix bug while building JupyterLab (see [issue](https://github.com/jupyterlab/jupyterlab/issues/11248)).
- Fix notebook scripts to use a specific commit id.

0.2.2 (2021-09-10)
===================

Changes:
--------
- Add rsync installation, used for the deployment of notebooks in jupyterhub.

Fixes:
------
- The `deploy_data_specific_image` script now mirrors the git repository. Fixes problem with renamed or deleted files not being updated.
  

0.2.1 (2021-06-01)
===================

Changes:
--------
- Bumped version to test renovate-bot flow with component images

Fixes:
------
- na

0.2.0 (2021-05-11)
===================

Changes:
--------
- Add the jq/yq installations, which are required for the deploy scripts for the notebooks in JupyterHub.
- Add a deploy script and related env file used to download notebooks for specific images

Fixes:
------
- na

0.1.0 (2021-02-19)
===================

Changes:
--------
- Added Dockerfile and environment files, inspired by the corresponding files from PAVICS-e2e-workflow-tests project

Fixes:
------
- na

0.0.2 (2020-12-09)
===================

Changes:
--------
- Updated tag, only for cascading build test purposes

Fixes:
------
- na

0.0.1 (2020-12-04)
===================

Changes:
--------
- Added dummy `Dockerfile`

Fixes:
------
- na