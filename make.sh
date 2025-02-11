#!/usr/bin/env bash
set -eu

HERE=$(dirname $(readlink -f $0))
RISCV_OPENOCD="${HERE}/riscv-openocd"

rm -rf "${RISCV_OPENOCD}"
git clone git@github.com:riscv-collab/riscv-openocd.git --recursive "${RISCV_OPENOCD}"
cd "${RISCV_OPENOCD}"
git reset --hard "$1"
git submodule update --recursive

paths="$(git config --file .gitmodules --get-regexp path | awk '{ print $2 }')"
for path in ${paths}
do
    cd "${RISCV_OPENOCD}"
    cd "${path}"
    commit="$(git rev-parse HEAD)"
    url="$(git config --get remote.origin.url)"
    cd "${RISCV_OPENOCD}"
    git submodule deinit -f "${path}"
    git rm -r "${path}"
    git commit -am "Remove submodule $(basename ${path})"

    git clone "${url}" "${path}"
    cd "${path}"
    git checkout "${commit}"
    rm -rf .git
    cd "${RISCV_OPENOCD}"
    git add "${path}"
    git commit -m "Add $(basename ${path}) as inlined submodule"
done

cd "${RISCV_OPENOCD}"
git rm .gitmodules
git commit -am "Remove .gitmodules"

git remote add martijnbastiaan git@github.com:martijnbastiaan/riscv-openocd.git
git checkout -b no-submodules-"$1"
git push -f -u martijnbastiaan no-submodules-"$1"