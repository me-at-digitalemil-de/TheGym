DCOS_URL=https://esiemes-i-elasticl-6j0jedtt5bsc-114625087.us-west-2.elb.amazonaws.com
folder=/Users/emil/tmp/TheGym
echo We are setting up Jenkins now. 
read -p "Press button when ready." -n1 -s
echo
open $DCOS_URL/service/jenkins/configure
echo Please add a global environment variable \(under Global properties\) called: DOCKERHUB_REPO and set it to your dockerhub account \(e.g. my is digitalemil\) plus: /thegym
echo Then press: Save
read -p "Press button when ready." -n1 -s
echo Now let us connect Jenkins to gitlab which runs in DC/DCOS_URL
echo First we need to create credentials for gitlab. Please use root as username and rootroot as password, id should read gitlab
open $DCOS_URL/service/jenkins/credentials/store/system/domain/_/newCredentials
read -p "Press button when ready." -n1 -s
echo We also need to provide Jenkins with your dockerhub account and password. Please fill them in:
open $DCOS_URL/service/jenkins/credentials/store/system/domain/_/newCredentials
read -p "Press button when ready." -n1 -s
echo Next step is to create the build pipleine. In the browser window please call the item TheGm and select Pipeline as type and then press OK
open $DCOS_URL/service/jenkins/view/all/newJob
read -p "Press button when ready." -n1 -s
echo Now check Poll SCM and use * * * * * as schedule. Press Apply. Scroll down to Pipeline and select "Pipeline script from SCM". Select Git as SCM
read -p "Press button when ready." -n1 -s
echo Next we need to define the repository. Please enter http://gitlab.marathon.l4lb.thisdcos.directory/root/TheGym.git as Repository URL and select root/******** as credentials. Press Apply
echo We are all set now. Thank you for your patience. You can now start build pipelines in Jenkins or call the upgrade.sh or downgrade.sh script in the folder $folder.
echo Good luck!

