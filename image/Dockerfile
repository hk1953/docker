FROM python:3.6.6-slim-stretch

MAINTAINER Mohit_Sharma <mohit.sharma@nyu.edu>

ARG NB_USER=pui_user
USER root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \
    wget \
    bzip2 \
    ca-certificates \
    sudo \
    locales \
    git \
    emacs \
    python-dev \
    unzip \
    libsm6 \
    pandoc \
    texlive-latex-base \
    texlive-latex-extra \
    texlive-fonts-extra \
    texlive-fonts-recommended \
    texlive-generic-recommended \
    libxrender1 \
    fonts-dejavu \
    gfortran \
    gcc \
    libnetcdf-dev \
    libhdf5-dev \
    libproj-dev \
    libgeos++-dev \
    libgeos-dev \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen

# Install Tini
RUN wget --quiet https://github.com/krallin/tini/releases/download/v0.9.0/tini && \
    echo "faafbfb5b079303691a939a747d7f60591f2143164093727e870b289a44d9872 *tini" | sha256sum -c - && \
    mv tini /usr/local/bin/tini && \
    chmod +x /usr/local/bin/tini

# Configure environment
ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV SHELL /bin/bash
ENV NB_UID 1000
ENV HOME /home/$NB_USER
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

# Create user with UID=1000 and in the 'users' group
RUN useradd -m -s /bin/bash -N -u $NB_UID $NB_USER && \
    adduser $NB_USER sudo && \
    echo 'ALL ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
    mkdir -p $CONDA_DIR && \
    chown $NB_USER $CONDA_DIR

USER $NB_USER

# Setup home directory
RUN mkdir /home/$NB_USER/.jupyter && \
    mkdir -p -m 700 /home/$NB_USER/.local/share/jupyter && \
    echo "cacert=/etc/ssl/certs/ca-certificates.crt" > /home/$NB_USER/.curlrc

# Install conda as NB_USER
RUN cd /tmp && \
    mkdir -p $CONDA_DIR && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-4.5.11-Linux-x86_64.sh && \
    echo "ea4594241e13a2671c5b158b3b813f0794fe58d514795fbf72a1aad24db918cf  Miniconda3-4.5.11-Linux-x86_64.sh" | sha256sum -c - && \
    /bin/bash Miniconda3-4.5.11-Linux-x86_64.sh -f -b -p $CONDA_DIR && \
    rm Miniconda3-4.5.11-Linux-x86_64.sh && \
    $CONDA_DIR/bin/conda install --quiet --yes conda==4.5.11 && \
    $CONDA_DIR/bin/conda config --system --add channels conda-forge && \
    $CONDA_DIR/bin/conda update conda && \
    conda clean -tipsy

# Install JupyterHub to get the jupyterhub-singleuser startup script
RUN pip --no-cache-dir install 'jupyterhub'

# Install Python 3 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda install --quiet --yes \
    'cython' \
    'numpy' \
    'pillow' \
    'matplotlib' \
    'scipy' \
    'pandas' && \
    conda install -c conda-forge ipywidgets && \
    conda remove --quiet --yes --force qt pyqt && \
    conda clean -tipsy

# Activate ipywidgets extension in the environment that runs the notebook server
RUN jupyter nbextension enable --py widgetsnbextension --sys-prefix

# Install Python 2 packages
# Remove pyqt and qt pulled in for matplotlib since we're only ever going to
# use notebook-friendly backends in these images
RUN conda create --quiet --yes -p $CONDA_DIR/envs/python2 python=2.7 \
    'cython' \
    'numpy' \
    'pillow' \
    'matplotlib' \
    'scipy' \
    'pandas' && \
    conda install -c conda-forge -p $CONDA_DIR/envs/python2 python=2.7 ipywidgets && \
    conda remove -n python2 --quiet --yes --force qt pyqt && \
    conda clean -tipsy

# Add shortcuts to distinguish pip for python2 and python3 envs
RUN ln -s $CONDA_DIR/envs/python2/bin/pip $CONDA_DIR/bin/pip2 && \
    ln -s $CONDA_DIR/bin/pip $CONDA_DIR/bin/pip3

# Configure ipython kernel to use matplotlib inline backend by default
RUN mkdir -p $HOME/.ipython/profile_default/startup
#COPY mplimporthook.py $HOME/.ipython/profile_default/startup/

# Install Jupyter notebook as NB_USER
RUN conda install --quiet --yes \
    'notebook' \
    && conda clean -tipsy

# Install JupyterHub to get the jupyterhub-singleuser startup script
#RUN pip --no-cache-dir install 'jupyterhub'

USER root

# Install Python 2 kernel spec globally to avoid permission problems when NB_UID
# switching at runtime.
RUN $CONDA_DIR/envs/python2/bin/python -m ipykernel install

# Configure container startup as root
EXPOSE 8888
WORKDIR /home/
ENTRYPOINT ["tini", "--"]
CMD ["start-notebook.sh"]

# Add local files as late as possible to avoid cache busting
COPY start.sh /usr/local/bin/
COPY start-notebook.sh /usr/local/bin/
COPY start-singleuser.sh /usr/local/bin/
COPY jupyter_notebook_config.py /home/$NB_USER/.jupyter/
RUN chown -R $NB_USER:users /home/$NB_USER/.jupyter
RUN chmod +x /usr/local/bin/start-*

# Add any extra requirements. Done at end to avoid cache busting.
#ADD requirements.txt requirements.txt
#RUN mkdir /home/$NB_USER/work/ucsl17_notebooks
#RUN git clone https://github.com/Mohitsharma44/ucsl17 /home/$NB_USER/work/ucsl17_notebooks

USER $NB_USER
