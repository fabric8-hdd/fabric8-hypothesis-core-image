#!/bin/bash

. constants.sh

run_infra_tests(){
    while [[ $# -gt 0 ]]
    do
    key="$1"

    case $key in
        -npm)
        NPM_VER="$2"
        shift # past argument
        shift # past value
        ;;
        -node)
        NODE_VER="$2"
        shift # past argument
        shift # past value
        ;;
        -port)
        PORT="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        shift
        ;;
    esac
    done

    #Running the infra tests

    node_infra_test
    npm_infra_test
    port_infra_test
    os_infra_test
}

#Running the Node infra test

node_infra_test(){
    node_ver="$(node -v)"
    if [ $(expr ${node_ver//v} \== ${NODE_VER}) == 1 ]; then
        echo "Required version of node is installed"
    else
        echo "Node version test failed"
    fi
}

#Running the NPM infra test

npm_infra_test(){
    npm_ver="$(npm -v)"
    if [ $(expr ${npm_ver} \== ${NPM_VER}) == 1 ]; then
        echo "Required version of npm is installed"
    else
        echo "Npm version test failed"
    fi
}

#Running the PORT infra test

port_infra_test(){
    if [ "${PORT}" -eq "${HDD_SUPERVISOR_PORT}" ]; then
        echo "Required PORT is configured"
    else
        echo "PORT test failed"
    fi
}

#Running the OS infra test

os_infra_test(){
    match=0
    for os in "${OS[@]}"; do
        if [[ ${os,,} = "${DEFAULT_OS,,}" ]]; then
            match=1
            os_id="$(cat /etc/*-release | grep -i "^id=" | cut -d'=' -f 2)"
            # Strip trailing inverted commas if any
            os_id="${os_id%\"}"
            # Strip leading inverted commas if any
            os_id="${os_id#\"}"
            os_ver_id="$(cat /etc/*-release | grep -i "version_id" | cut -d'=' -f 2)"
            # Strip trailing inverted commas if any
            os_ver_id="${os_ver_id%\"}"
            # Strip leading inverted commas if any
            os_ver_id="${os_ver_id#\"}"
            if [[ ($(expr ${os_id,,} \== ${DEFAULT_OS,,}) == 1) && ($(expr ${os_ver_id,,} \== ${DEFAULT_OS_VERSION,,}) == 1)  ]]; then
                echo "Required version of OS is installed"
            else
                echo "OS version test failed"
            fi
                break
        fi
    done
    if [[ $match = 0 ]]; then
        echo "OS version test failed"
    fi
}
