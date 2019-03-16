#!/bin/bash
set -e

trap "trap_ctrlc" 2


ROOT_DIR=$(pwd)
logDir="$ROOT_DIR/predix-scripts/log"
BUILD_APP=false
SKIP_PREDIX_SERVICES=false
function local_read_args() {
  while (( "$#" )); do
  opt="$1"
  case $opt in
    -h|-\?|--\?--help)
      PRINT_USAGE=1
      QUICKSTART_ARGS="$SCRIPT $1"
      break
    ;;
    -b|--branch)
      BRANCH="$2"
      QUICKSTART_ARGS+=" $1 $2"
      shift
    ;;
    --build-app)
      BUILD_APP="true"
    ;;
    --skip-predix-services)
      SKIP_PREDIX_SERVICES=true
    ;;
    -o|--override)
      QUICKSTART_ARGS=" $SCRIPT"
    ;;
    --skip-setup)
      SKIP_SETUP=true
    ;;
    *)
      QUICKSTART_ARGS+=" $1"
      #echo $1
    ;;
  esac
  shift
  done

  if [[ -z $BRANCH ]]; then
    echo "Usage: $0 -b/--branch <branch> [--skip-setup]"
    exit 1
  fi
}

BRANCH="master"
PRINT_USAGE=0
SKIP_SETUP=false
PREDIX_SCRIPTS_ORG="PredixDev"
PREDIX_SCRIPTS="predix-scripts"
VERSION_JSON="version.json"
GITHUB_RAW="https://raw.githubusercontent.com"
IZON_SH="https://raw.githubusercontent.com/PredixDev/izon/1.5.0/izon2.sh"

GITHUB_ORG="PredixDev"
REPO_NAME="predix-edge-sample-scaler-nodejs"
DOCKER_STACK_NAME="predix-edge-sample-scaler-nodejs"
SCRIPT="-script edge-starter-deploy.sh -script-readargs edge-starter-deploy-readargs.sh "
APP_DIR="edge-nodejs-scaler"
APP_NAME="Edge Node.js Scaler"
TOOLS="Cloud Foundry CLI, Docker, Git, jq, Predix CLI, yq"
TOOLS_SWITCHES="--cf --docker --git --jq --predixcli --yq"

# Process switches
local_read_args $@

VERSION_JSON_URL="$GITHUB_RAW/$GITHUB_ORG/$REPO_NAME/$BRANCH/version.json"

if [[ "$SKIP_PREDIX_SERVICES" == "true" ]]; then
  QUICKSTART_ARGS="$QUICKSTART_ARGS $SCRIPT --run-edge-app -repo-name $REPO_NAME -app-name $DOCKER_STACK_NAME"
else
  PS_MODEL="sample-data/predix-asset/Compressor-CMMS-Compressor-2018-Scaled.json"
  QUICKSTART_ARGS="$QUICKSTART_ARGS $SCRIPT -uaa -ts -psts -psmodel $PS_MODEL --run-edge-app -repo-name $REPO_NAME -app-name $DOCKER_STACK_NAME"
fi

function check_internet() {
  set +e
  echo ""
  echo "Checking internet connection..."
  curl "http://google.com" > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    echo "Unable to connect to internet, make sure you are connected to a network and check your proxy settings if behind a corporate proxy"
    echo "If you are behind a corporate proxy, set the 'http_proxy' and 'https_proxy' environment variables."
    exit 1
  fi
  echo "OK"
  echo ""
  set -e
}

function init() {
  currentDir=$(pwd)
  if [[ $currentDir == *"scripts" ]]; then
    echo 'Please launch the script from the root dir of the project'
    exit 1
  fi
  if [[ ! $currentDir == *"$REPO_NAME" ]]; then
    mkdir -p $APP_DIR
    cd $APP_DIR
  fi

  check_internet

  #get the script that reads version.json
  eval "$(curl -s -L $IZON_SH)"

  getVersionFile
  getLocalSetupFuncs $GITHUB_RAW $PREDIX_SCRIPTS_ORG
}

if [[ $PRINT_USAGE == 1 ]]; then
  init
  __print_out_standard_usage
else
  if $SKIP_SETUP; then
    init
  else
    init
    __standard_mac_initialization
  fi
fi

getPredixScripts
#clone the repo itself if running from oneclick script
#if [[ ! -d "$PREDIX_SCRIPTS/$REPO_NAME" ]]; then
#  echo "repo not present"
getCurrentRepo
#fi

echo "pwd after copy -> $(pwd)"
echo "quickstart_args=$QUICKSTART_ARGS"
cd $PREDIX_SCRIPTS/$REPO_NAME
dockerVersion=$(grep version Dockerfile | awk -F"=" '{print $2}' | tr -d "\"")
echo "$dockerVersion"
if [[ "$BUILD_APP" == "true" ]]; then
  docker build  --no-cache -t "predixedge/$DOCKER_STACK_NAME:$dockerVersion" -t "predixedge/$DOCKER_STACK_NAME:latest" -f ./Dockerfile . --build-arg http_proxy --build-arg https_proxy --build-arg no_proxy
fi
cd ../..

export TIMESERIES_CHART_ONLY="true"

source $PREDIX_SCRIPTS/bash/quickstart.sh $QUICKSTART_ARGS

########### custom logic starts here ###########
if ! [ -d "$logDir" ]; then
  mkdir "$logDir"
  chmod 744 "$logDir"
fi

########### custom logic ends here ###########
docker service ls
echo ""
echo ""
docker network ls

echo "" >> $SUMMARY_TEXTFILE
echo "$APP_NAME App quickstart complete " >> $SUMMARY_TEXTFILE
echo "" >> $SUMMARY_TEXTFILE

cat $SUMMARY_TEXTFILE
echo "......................................Done......................................"
