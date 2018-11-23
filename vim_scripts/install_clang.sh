#!/bin/bash

# EFFECTS: Install clang 6.0, with associated development tools and the LLVM
#           runtime. Crucially, installs clang-tools, with associated clangd,
#           as well as lldb-6.0.

#source `dirname $0`/global_constants.sh
INSTALLCMD="sudo apt-get install -y --fix-missing"

# Add LLVM repository
#wget -O - http://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -

sudo apt-add-repository "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-6.0 main"
sudo apt-get update
$INSTALLCMD clang*6.0 clang-tools-6.0
$INSTALLCMD clang lldb # "ordinary" clang and LLDB, for remote debugging

sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-6.0 100
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-6.0 100
sudo update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-6.0 100
