prep_base() {
    yum -y update
    yum -y install yum-utils device-mapper-persistent-data lvm2 git wget
}

install_docker() {
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y install docker-ce
    systemctl start docker
}
