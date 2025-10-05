FROM ghcr.io/catthehacker/ubuntu:act-latest AS builder

ARG BPK_SCM_URL=https://github.com/mendix/docker-mendix-buildpack.git

ARG BPK_SCM_REV=cb1789b71206b9e14ba16130f7ce6477339adc9e

ENV BPK_DIR=/workdir/docker-mendix-buildpack

ENV MPR_DIR=/workdir/src

ENV MDA_DIR=/workdir/mda

COPY . ${MPR_DIR}

RUN bash "${MPR_DIR}/build-scripts/100-run-docker-mendix-buildpack/100-clone-docker-mendix-buildpack.sh"
