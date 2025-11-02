# This script is meant to be sourced.
# It's not for directly running.
printf "${STY_CYAN}[$0]: 1. Install dependencies\n${STY_RST}"

function outdate_detect(){
  # Shallow clone prevent latest_commit_timestamp() from working.
  x git_auto_unshallow

  local source_path="$1"
  local target_path="$2"
  local source_timestamp="$(latest_commit_timestamp $source_path 2>/dev/null)"
  local target_timestamp="$(latest_commit_timestamp $target_path 2>/dev/null)"
  local outdate_detect_mode="$(cat ${target_path}/outdate-detect-mode)"

  # outdate-detect-mode possible modes:
  # - WIP: Work in progress (should be taken as outdated)
  # - FORCE_OUTDATED: forcely taken as outdated
  # - FORCE_UPDATED: forcely taken as updated
  # - AUTO: Let the script decide automatically
  #
  # outdate status possible values:
  # - WIP,FORCE_OUTDATED,FORCE_UPDATED: Inherited directly from outdate-detect-mode
  # - EMPTY_SOURCE: source path has empty timestamp, maybe not tracked by git (should be taken as outdated)
  # - EMPTY_TARGET: target path has empty timestamp, maybe not tracked by git (should be taken as outdated)
  # - OUTDATED: target path is older than source path.
  # - UPDATED: target path is not older than source path.

  # Does target path have an outdate-detect-mode file which content is special?
  if [[ "${outdate_detect_mode}" =~ ^(WIP|FORCE_OUTDATED|FORCE_UPDATED)$ ]]; then
    echo "${outdate_detect_mode}"
  # Does source path has an empty timestamp?
  elif [ -z "$source_timestamp" ]; then
    echo "EMPTY_SOURCE"
  # Does target path has an empty timestamp?
  elif [ -z "$target_timestamp" ]; then
    echo "EMPTY_TARGET"
  # If target path is older than source path, it's outdated.
  elif [[ "$target_timestamp" -lt "$source_timestamp" ]]; then
    echo "OUTDATED"
  else
    echo "UPDATED"
  fi
}
####################
# Detect architecture
# Helpful link(s):
# http://stackoverflow.com/questions/45125516
export MACHINE_ARCH=$(uname -m)
case $MACHINE_ARCH in
  "x86_64") sleep 0;;
  *)
    printf "${STY_YELLOW}"
    printf "===WARNING===\n"
    printf "Detected machine architecture: ${MACHINE_ARCH}\n"
    printf "This script only supports x86_64.\n"
    printf "It is very likely to fail when installing dependencies on your machine.\n"
    printf "\n"
    printf "${STY_RST}"
    pause
    ;;
esac

####################
# Detect distro
# Helpful link(s):
# http://stackoverflow.com/questions/29581754
# https://github.com/which-distro/os-release
export OS_RELEASE_FILE=${OS_RELEASE_FILE:-/etc/os-release}
test -f ${OS_RELEASE_FILE} || \
  ( echo "${OS_RELEASE_FILE} does not exist. Aborting..." ; exit 1 ; )
export OS_DISTRO_ID=$(awk -F'=' '/^ID=/ { gsub("\"","",$2); print tolower($2) }' ${OS_RELEASE_FILE} 2> /dev/null)
export OS_DISTRO_ID_LIKE=$(awk -F'=' '/^ID_LIKE=/ { gsub("\"","",$2); print tolower($2) }' ${OS_RELEASE_FILE} 2> /dev/null)

if [[ "$OS_DISTRO_ID" =~ ^(arch|endeavouros)$ ]]; then

  TARGET_ID=arch
  printf "${STY_GREEN}"
  printf "===INFO===\n"
  printf "Detected distro ID: ${OS_DISTRO_ID}\n"
  printf "./sdata/dist-${TARGET_ID}/install-deps.sh will be used.\n"
  printf "\n"
  printf "${STY_RST}"
  pause
  source ./sdata/packages/install-setups.sh

elif [[ "$OS_DISTRO_ID_LIKE" == "arch" || "$OS_DISTRO_ID" == "cachyos" ]]; then

  TARGET_ID=arch
  printf "${STY_YELLOW}"
  printf "===WARNING===\n"
  printf "Detected distro ID: ${OS_DISTRO_ID}\n"
  printf "Detected distro ID_LIKE: ${OS_DISTRO_ID_LIKE}\n"
  printf "./sdata/dist-${TARGET_ID}/install-deps.sh will be used.\n"
  printf "Ideally, it should also work for your distro.\n"
  printf "Still, there is a chance that it not works as expected or even fails.\n"
  printf "Proceed only at your own risk.\n"
  printf "\n"
  printf "${STY_RST}"
  pause
  source ./sdata/packages/install-setups.sh

else
  
  TARGET_ID=non-arch
  printf "${STY_RED}${STY_BOLD}===URGENT===${STY_RST}\n"
  printf "${STY_RED}"
  printf "Detected distro ID: ${OS_DISTRO_ID}\n"
  printf "Detected distro ID_LIKE: ${OS_DISTRO_ID_LIKE}\n"
  exit 1

fi
