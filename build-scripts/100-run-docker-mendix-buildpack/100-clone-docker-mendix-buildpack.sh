#!/bin/bash

set -e
set -o pipefail

mkdir -p -- "${BPK_DIR:?}"
cd "${BPK_DIR:?}"

{
  # only if repo is cached: specifying --depth when repo already fetched causes redundant traffic
  git_depth_arg=""
  git rev-parse HEAD 2>/dev/null || git_depth_arg="--depth=1"

  # make a new blank repository in the current directory
  git -c init.defaultBranch=dummy init

  # add a remote
  git remote add origin "${BPK_SCM_URL:?}"

  # fetch a commit (or branch or tag) of interest
  # Note: the full history up to this commit will be retrieved unless
  #       you limit it with '--depth=...' or '--shallow-since=...'
  checkoutarg=FETCH_HEAD
  git fetch $git_depth_arg origin "${BPK_SCM_REV:?}" || {
    # not all names can be fetched, e.g. abbreviated commits can't,
    # fallback to full fetch
    git fetch origin
    checkoutarg="${BPK_SCM_REV:?}"
  }

  # checkout what we fetched
  git -c advice.detachedHead=false checkout "$checkoutarg"
}

# This must be run with docker-in-docker
# ./build.py --source "${MPR_DIR:?}" --destination "${MDA_DIR:?}" build-mda-dir
