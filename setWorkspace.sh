# Version 1.0.0
# Dirs mgmt
scriptDir=$PWD
scriptUser=$LOGNAME
logDir="/tmp/installer/logs"
if [ ! -d $logDir ]; then
   mkdir -p $logDir
fi
cd /tmp/installer
 
echo " ##### Starting installation, this could take a while... #####"
sleep 2
# sudo apt-get -y install \
#  tzdata \
#  libicu66:amd64 \
#  libxml2:amd64 \
#  libsoup2.4-1:amd64 \
#  libappstream4:amd64 \
#  shared-mime-info \
#  packagekit \
#  packagekit-tools \
#  software-properties-common \
#  gnupg2
 
# Install git and other tools dependencies
echo " ### Installing basic and required tools ###"
sudo apt-key add --keyserver keyserver.ubuntu.com --recv-keys CC86BB64 >>$logDir/toolsInstall 2>&1 && \
sudo add-apt-repository -y ppa:rmescandon/yq >>$logDir/toolsInstall 2>&1 && \
sudo apt-get update >>$logDir/toolsInstall 2>&1 && sudo apt-get -y install \
git virtualenv npm nodejs \
python python3 python3-pip golang \
ca-certificates curl gnupg-agent software-properties-common \
apt-transport-https gnupg2 curl \
zip unzip jq wget tldr \
>>$logDir/toolsInstall 2>&1 && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"

# OH-MY-ZSH - with bash-like theme and plugins
echo " ### Installing Oh-my-zsh ###"
sudo apt-get -y install zsh >>$logDir/zshInstall 2>&1 && \
chsh -s $(which zsh)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >>$logDir/zshInstall 2>&1 && \
sed -i 's/ZSH_THEME="/ZSH_THEME="essembeh" #"/g' ~/.zshrc && \
sed -i 's/plugins=(/plugins=(themes colored-man-pages colorize docker helm kubectl terraform vscode npm sudo /g' ~/.zshrc
>>$logDir/zshInstall 2>&1 && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"
 
# AWSCLI
echo " ### Installing Aws-CLI v2 ###"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" >>$logDir/awscliInstall 2>&1 && \
unzip awscliv2.zip >>$logDir/awscliInstall 2>&1 && \
sudo ./aws/install >>$logDir/awscliInstall 2>&1 && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"
 
# Docker
echo " ### Installing Docker && Docker-Compose ###"
sudo apt-get remove -y docker docker-engine docker.io containerd runc >>$logDir/dockerInstall 2>&1
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - >>$logDir/dockerInstall 2>&1 && \
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" >>$logDir/dockerInstall 2>&1 && \
sudo apt-get update >>$logDir/dockerInstall 2>&1 && sudo apt-get -y install docker-ce docker-ce-cli containerd.io >>$logDir/dockerInstall 2>&1 && \
sudo usermod -aG docker $scriptUser >>$logDir/dockerInstall 2>&1
sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >>$logDir/dockerInstall 2>&1 && \
sudo chmod +x /usr/local/bin/docker-compose >>$logDir/dockerInstall 2>&1 && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"
 
# Terraform + tfenv
echo " ### Installing Terraform + tfenv ###"
git clone https://github.com/tfutils/tfenv.git ~/.tfenv >>$logDir/terraformInstall 2>&1 && \
sudo ln -s ~/.tfenv/bin/* /usr/local/bin >>$logDir/terraformInstall 2>&1 && \
tfenv install latest:^0.14 >>$logDir/terraformInstall 2>&1 && \
tfenv use >>$logDir/terraformInstall 2>&1 &&
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"
 
# Helm + helmenv
echo " ### Installing Helm + helmenv ###"
git clone https://github.com/alexppg/helmenv.git ~/.helm >>$logDir/helmInstall 2>&1 && \
echo 'export PATH="$HOME/.helm:$PATH"' >> ~/.zshrc && \
echo 'source $HOME/.helm/helmenv.sh' >> ~/.zshrc && \
source "$HOME/.helm/helmenv.sh" && \
helmenv install $(helmenv list-remote | tail -n 1) >>$logDir/helmInstall 2>&1 && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"

#  Helmfile + helm-diff
echo " ### Installing Helmf-diff + Helmfile ###"
helm plugin install https://github.com/databus23/helm-diff --version master >>$logDir/helmdiffInstall 2>&1 && \
wget https://github.com/roboll/helmfile/releases/download/v0.119.0/helmfile_linux_amd64 >>$logDir/helmfileInstall 2>&1 && \
sudo mv helmfile_linux_amd64 /usr/local/bin/helmfile >>$logDir/helmfileInstall 2>&1 && \
sudo chmod +x /usr/local/bin/helmfile >>$logDir/helmfileInstall 2>&1 && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"
 
# SAML2AWS
echo " ### Installing SAML2AWS ###"
wget https://github.com/Versent/saml2aws/releases/download/v2.26.1/saml2aws_2.26.1_linux_amd64.tar.gz >>$logDir/saml2awsInstall 2>&1 && \
if [ ! -d ~/.local/bin/ ]; then mkdir -p ~/.local/bin/; fi
tar -xzvf saml2aws_2.26.1_linux_amd64.tar.gz -C ~/.local/bin >>$logDir/saml2awsInstall 2>&1 && \
sudo chmod u+x ~/.local/bin/saml2aws && \
sudo ln -s ~/.local/bin/saml2aws /usr/local/bin/saml2aws && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"
 
# Kubectl
echo " ### Installing Kubectl ###"
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - >>$logDir/kubectlInstall 2>&1 && \
echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee -a /etc/apt/sources.list.d/kubernetes.list >>$logDir/kubectlInstall 2>&1 && \
sudo apt-get update >>$logDir/kubectlInstall 2>&1 && sudo apt-get -y install kubectl >>$logDir/kubectlInstall 2>&1 && \
echo 'source <(kubectl completion zsh)' >>~/.zshrc && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"

#SSHM
echo " ### Installing SSHM ###" 
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb" >>$logDir/sshmInstall 2>&1 && \
sudo dpkg -i session-manager-plugin.deb >>$logDir/sshmInstall 2>&1 && \
git clone https://github.com/claranet/sshm.git ~/.sshm >>$logDir/sshmInstall 2>&1 && \
cd ~/.sshm && go build >>$logDir/sshmInstall 2>&1 && \
sudo ln -s $PWD/sshm /usr/local/bin/sshm >>$logDir/sshmInstall 2>&1 && \
cd /tmp/installer && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"

echo " ### Setting tools up, just gonna need some info from you ###"
echo " # What is your full name?"
read fullname
echo " # Your work email?"
read email
git config --global user.name "$fullname" >>$logDir/toolSetUp 2>&1 && \
git config --global user.email "$email" >>$logDir/toolSetUp 2>&1 && \
saml2aws configure -p default -r us-east-1 --idp-provider=GoogleApps --url="https://accounts.google.com/o/saml2/initsso?idpid=C03e4ydj1&spid=517610764354&forceauthn=false" --role="arn:aws:iam::477575873490:role/GoogleRemediationTeam" --username="$email" --mfa=Auto --skip-prompt && \
echo "  -- Done -- " || echo "  -- There's been an issue, you should check the logs on $logDir --"

sleep 1
echo " ### That's it, have a great day! ###"
