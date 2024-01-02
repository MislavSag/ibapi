# Dockerfile
FROM rocker/r-base:4.3.2

# install apps
RUN apt-get update --fix-missing \
	&& apt-get install -y \
		ca-certificates \
		build-essential \
		libprotobuf-dev \
		protobuf-compiler \
		cmake \
    libglib2.0-0 \
	 	libxext6 \
	  libsm6  \
	  libxrender1 \
	  libcurl4-gnutls-dev \
		libxml2-dev \
		libsndfile1 \
		libx11-dev \
		libatlas-base-dev \
		libgtk-3-dev \
		libboost-python-dev \
		libsodium-dev \
		ffmpeg \
		python3-audioread \
		libssl-dev \
		openssl \
		python3-openssl \
		pkg-config \
    default-jdk \
    r-cran-rjava \
    libpq-dev

# create the application folder
RUN mkdir -p ~/application

# copy everything from the current directory into the container
COPY "/" "application/"
WORKDIR "application/"

# open port 8080 to traffic
EXPOSE 8080

# install packages
RUN R -e "install.packages('plumber')"
RUN R -e "install.packages('utils')"
RUN R -e "install.packages('httr')"
RUN R -e "install.packages('jsonlite')"
RUN R -e "install.packages('rJava')"
RUN R -e "install.packages('mailR')"
RUN R -e "install.packages('DBI')"
RUN R -e "install.packages('RPostgres')"
RUN R -e "install.packages('remotes')"
RUN R -e "remotes::install_github('MislavSag/ibrest')"

# when the container starts, start the main R script
ENTRYPOINT ["Rscript", "execute_plumber.R"]
