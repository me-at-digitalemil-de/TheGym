#!/bin/bash

export DCOS_URL=$(dcos config show core.dcos_url)
echo DCOS_URL: $DCOS_URL

#cat credentials.xml | java -jar ./jenkins-cli.jar -s $DCOS_URL/service/jenkins create-credentials-by-xml "SystemCredentialsProvider::SystemContextResolver::jenkins" GithubCredentials
#curl -X GET -k -H "Authorization: token=$(dcos config show core.dcos_acs_token)" $DCOS_URL/service/jenkins/jnlpJars/jenkins-cli.jar -o jenkins-cli.jar

dcos package install --yes marathon-lb --package-version=1.10.1
dcos package install --yes jenkins --package-version=3.2.3-2.60.2

echo Determing public node ip...
export PUBLICNODEIP=$(./findpublic_ips.sh | head -1 | sed "s/.$//" )
echo Public node ip: $PUBLICNODEIP
echo ---------------

if [ ${#PUBLICNODEIP} -le 6 ] ;
then
        echo Can not find public node ip. JQ in path?
        exit -1
fi

PRIVATENODEIP=$(./findprivate_ips.sh | tail -1)
echo Private node ip: $PRIVATENODEIP
if [ ${#PUBLICNODEIP} -le 6 ] ;
then
        echo Can not find a priavte node ip. JQ in path?
        exit -1
fi
echo ---------------
cp gitlab.json.template gitlab.json

sed -ie "s@\$PINNEDNODE@$PRIVATENODEIP@g;" gitlab.json

sed  '/gitlab/d' /etc/hosts >./hosts
echo "$PUBLICNODEIP gitlab.thegym.mesosphere.io" >>./hosts
echo We are going to add "$PUBLICNODEIP gitlab.thegym.mesosphere.io" to your /etc/host. So therefore we need your password:
sudo mv hosts /etc/hosts

dcos marathon app add gitlab.json

until $(curl --output /dev/null --silent --head --fail http://gitlab.thegym.mesosphere.io); do
    printf '.'
    sleep 5
done

echo I am going to open a browser window to gitlab. Please set the root user password there to \"rootroot\" and confirm it with \"rootroot\"
echo Afterwards please logon to gitlab \(in the browser\) as user \"root\" with password \"rootroot\"
echo When done please come back.
open http://gitlab.thegym.mesosphere.io
read -p "Press key when you set the password and are logged in as root." -n1 -s 
echo
echo On the bottom of the gitlab webpage is a green button \"New Project\". Please press it.
read -p "Press key when you are on the \"New project\" page." -n1 -s 
echo
echo Press the \"GitHub\" button.
read -p "Press a key when you are on the \"Import Projects from GitHub\" page." -n1 -s
echo
echo Here comes your \"Personal Access Token\":
echo Please copy the github token provided elsewhere and paste it into the browser form. Then press the green \"List Your GitHub Repositories\" button.
read -p "Press button when done." -n1 -s
echo
echo You can see all the existing projects now. Please look for \"digitalemil/TheGym\" and press the \"Import\" button on the right.
read -p "Press button when done." -n1 -s
echo
echo After a while the row with \"TheGym\" turns green. Please click the link \"root/TheGym\" in the "To GitLab" column.
echo Congratulations! We are done setting up gitlab.
echo We will now clone the repo to a location you specify \(./tmp is a good candidate\).
echo -n "Where shall I clone to? (When prompted for password: \"rootroot\") > "
read dir
echo Now I am going to clone the repo and install the app. This will take a couple of minutes, please come back after the browser opened a window with the running app.
mkdir -p $dir
cd $dir
git clone http://root@gitlab.thegym.mesosphere.io/root/TheGym.git
cd TheGym
echo y | ./install-thegym-1.10.sh 
echo We are setting up Jenkins now. 
read -p "Press button when ready." -n1 -s
open $DCOS_URL/service/jenkins/configure
echo Please add a global environment variable called: DOCKERHUB_REPO and set it to your dockerhub account (e.g. my is digitalemil) plus: /thegym
echo Then press: Save
echo Now let us connect Jenkins to gitlab which runs in DC/DCOS_URL
echo First we need to create credentials for gitlab. Please use root as username and rootroot as password, id should read gitlab
open $DCOS_URL/service/jenkins/credentials/store/system/domain/_/newCredentials
echo We also need to provide Jenkins with your dockerhub account and password. Please fill them in:
open $DCOS_URL/service/jenkins/credentials/store/system/domain/_/newCredentials
echo Next step is to create the build pipleine. In the browser window please call the item TheGm and select Pipeline as type and then press OK
open $DCOS_URL//service/jenkins/view/all/newJob
echo Now check Poll SCM and use * * * * * as schedule. Press Apply. Scroll down to Pipeline and select "Pipeline script from SCM". Select Git as SCM
echo Next we need to define the repository. Please enter http://gitlab.marathon.l4lb.thisdcos.directory/root/TheGym.git as Repository URL and select root/******** as credentials. Press Apply
echo We are all set now. Thank you for your patience.
