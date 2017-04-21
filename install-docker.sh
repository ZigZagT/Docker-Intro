#!/usr/bin/env bash

set -e
if [ -n "$(command -v yum)" ]; then
    PKG_MANAGER=yum
elif [ -n "$(command -v apt-get)" ]; then
    PKG_MANAGER=apt-get
else
    echo "no package manager found, are you a Martian?"
    exit 1
fi

case $PKG_MANAGER in
    yum)
        yum install -y yum-utils screen
        yum remove -y 	docker-ce \
				        docker \
				        docker-common \
				        container-selinux \
				        docker-selinux \
				        docker-engine || true
        rm -f 	/etc/yum.repos.d/docker-ce.repo \
		        /etc/yum.repos.d/docker-main.repo
    ;;
    apt-get)
        apt-get -y install apt-transport-https ca-certificates curl
        apt-get remove -y   docker-ce \
				            docker \
				            docker-common \
				            container-selinux \
				            docker-selinux \
				            docker-engine || true
        rm -f 	/etc/apt/sources.list.d/docker.list
        add-apt-repository -r \
               "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
               $(lsb_release -cs) \
               stable"
    ;;
esac

# install docker
offical_auto_install() {
	curl -sSL https://get.docker.com/ | sh
}
official_manual_install() {
    case $PKG_MANAGER in
        yum)
            yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
            echo verify GPG key: Docker CE	060A 61C5 1B55 8A7F 742B 77AA C52F EB6B 621E 9F35
            yum makecache fast
            yum -y install docker-ce
        ;;
        apt-get)
            curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
            sudo add-apt-repository \
               "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
               $(lsb_release -cs) \
               stable"
            apt-get -y install docker-ce
        ;;
    esac
}
aliyun_install() {
	curl -sSL http://acs-public-mirror.oss-cn-hangzhou.aliyuncs.com/docker-engine/internet | sh -
}
daocloud_install() {
	curl -sSL https://get.daocloud.io/docker | sh
}
echo "1) install docker with offical auto install script"
echo "2) install docker follow offical manual installation guide"
echo "3) install docker with aliyun auto install script"
echo "4) install docker with DaoCloud auto install script"
read -p "please select install source: " selection
case $selection in
    1) offical_auto_install;;
    2) official_manual_install;;
	3) aliyun_install;;
	4) daocloud_install;;
    *) echo "must select install source"; exit 1;;
esac

# install docker hub mirror
echo "1) install DaoCloud mirror"
echo "2) install aliyun mirror (not ready)"
echo "default) use offical mirror"
read -p "please select mirror source: " selection
case $selection in
    1)
		echo "using DaoCloud mirror"
		curl -sSL https://get.daocloud.io/daotools/set_mirror.sh | sh -s https://www.daocloud.io/mirror.html
	;;
	2)
		echo "using aliyun mirror"
		echo "not ready yet"
		echo "using official mirror"
	;;
    *) echo "using official mirror";;
esac

# install docker-compose
curl -L https://github.com/docker/compose/releases/download/1.11.1/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# enable docker service
systemctl enable docker
systemctl start docker

# run hello world
docker run hello-world
