#!bin/bash 

ORGANIZATION=DecodeDevOps
COMPONENT=cart
USERNAME=roboshop
APPDIRECTORY=/home/$USERNAME/$COMPONENT

PACKAGES=https://raw.githubusercontent.com/$ORGANIZATION/$COMPONENT/main/package.json
SERVERJS=https://raw.githubusercontent.com/$ORGANIZATION/$COMPONENT/main/server.js
SERVICE=https://raw.githubusercontent.com/$ORGANIZATION/$COMPONENT/main/$COMPONENT.service

OS=$(hostnamectl | grep 'Operating System' | tr ':', ' ' | awk '{print $3$NF}')
selinux=$(sestatus | awk '{print $NF}')

if [ $(id -u) -ne 0 ]; then
  echo -e "\e[1;33mYou need to run this as root user\e[0m"
  exit 1
fi

if [ $OS == "CentOS8" ]; then
    echo -e "\e[1;33mRunning on CentOS 8\e[0m"
    else
        echo -e "\e[1;33mOS Check not satisfied, Please user CentOS 8\e[0m"
        exit 1
fi

if [ $selinux == "disabled" ]; then
    echo -e "\e[1;33mSE Linux Disabled\e[0m"
    else
        echo -e "\e[1;33mOS Check not satisfied, Please disable SE linux\e[0m"
        exit 1
fi

hostname $COMPONENT

cat /etc/passwd | grep $USERNAME
if [ $? -ne 0 ]; then
    useradd $USERNAME
    echo -e "\e[1;33m$USERNAME user added\e[0m"
    else
    echo -e "\e[1;32m$USERNAME user exists\e[0m"
fi

if [ -d "$APPDIRECTORY" ]; then
    rm -rf $APPDIRECTORY 
    mkdir -p $APPDIRECTORY
    else
        mkdir -p $APPDIRECTORY
fi
echo -e "\e[1;33mdirecotry created $APPDIRECTORY\e[0m"

echo -e "\e[1;33mInstalling Build tools\e[0m"
rpm -qa npm | grep npm 
if [ $? -ne 0 ]; then
    yum install -y nodejs make gcc-c++ npm python36 python3-pip
    echo -e "\e[1;33mBuild tools successfully installed\e[0m"
    else
        echo -e "\e[1;33mBuild tools existing installation found\e[0m"
fi

echo -e "\e[1;33mDownloading artifacts\e[0m"
curl -L $SERVERJS -o $APPDIRECTORY/server.js
curl -L $PACKAGES -o $APPDIRECTORY/package.json

echo -e "\e[1;33mInstalling NPM packages\e[0m"
cd $APPDIRECTORY
# npm install --unsafe-perm
npm install

if [ $? -eq 0 ]; then
    echo -e "\e[1;33mNPM packages installed successfully\e[0m"
    else
        echo -e "\e[1;33mfailed to install NPM packages\e[0m"
        exit 0
fi


echo -e "\e[1;33mConfiguring and Restarting $COMPONENT service\e[0m"
curl -L $SERVICE -o /etc/systemd/system/$COMPONENT.service
sed -i -e 's/{{DOMAIN}}/'$USERNAME'.com/g' /etc/systemd/system/$COMPONENT.service

systemctl daemon-reload
systemctl enable $COMPONENT && systemctl restart $COMPONENT

if [ $? -eq 0 ]; then
    echo -e "\e[1;33m$COMPONENT configured successfully\e[0m"
    else
        echo -e "\e[1;33mfailed to configure $COMPONENT\e[0m"
        exit 0
fi
