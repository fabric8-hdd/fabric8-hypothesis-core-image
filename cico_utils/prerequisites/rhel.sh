prep_base() {
    subscription-manager register --username ${SUBSCRIPTION_USERNAME} --password ${SUBSCRIPTION_PASSWORD} --auto-attach --force
    yum -y update
    yum -y install yum-utils git wget
}

install_docker() {
    subscription-manager repos --enable=rhel-7-server-rpms
    subscription-manager repos --enable=rhel-7-server-extras-rpms
    subscription-manager repos --enable=rhel-7-server-optional-rpms
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum -y install docker-ce
    systemctl start docker
}
