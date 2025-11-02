#!/usr/bin/env bash
cd "$(dirname "$0")"
# Use REPO_ROOT instead of base - when scripts are sourced they do not need export to inherit vars
REPO_ROOT="$(pwd)"
source ./sdata/lib/environment-variables.sh
source ./sdata/lib/functions.sh
source ./sdata/lib/package-installers.sh

prevent_sudo_or_root
set -e

#####################################################################################
#      Source Shellit Install and setup files
#####################################################################################
source ./sdata/install/0.install-greeting.sh
printf "${STY_CYAN}[$0]: 1. Install dependencies\n${STY_RST}"
source ./sdata/install/1.install-deps-selector.sh
printf "${STY_CYAN}[$0]: 2. Setup for permissions/services etc\n${STY_RST}"
source ./sdata/install/2.install-setups-selector.sh
printf "${STY_CYAN}[$0]: 3. Copying config files\n${STY_RST}"
source ./sdata/install/3.install-files.sh