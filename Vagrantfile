# -*- mode: ruby -*-
# vi: set ft=ruby :

$script = <<SCRIPT
echo "Installing Docker..."
sudo apt-get update
sudo apt-get remove docker docker-engine docker.io
echo '* libraries/restart-without-asking boolean true' | sudo debconf-set-selections
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common -y
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg |  sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
sudo apt-get update
sudo apt-get install -y docker-ce
# Restart docker to make sure we get the latest version of the daemon if there is an upgrade
sudo service docker restart
# Make sure we can actually use docker as the vagrant user
sudo usermod -aG docker vagrant
sudo docker --version

# Packages required for nomad & consul
sudo apt-get install unzip curl vim -y

echo "Installing Nomad..."
NOMAD_VERSION=1.2.2
cd /tmp/
curl -sSL https://releases.hashicorp.com/nomad/${NOMAD_VERSION}/nomad_${NOMAD_VERSION}_linux_amd64.zip -o nomad.zip
unzip nomad.zip
sudo install nomad /usr/bin/nomad
sudo mkdir -p /etc/nomad.d
sudo chmod a+w /etc/nomad.d

(
cat <<-EOF
  [Unit]
  Description=nomad
  Requires=network-online.target
  Requires=consul.service
  After=network-online.target

  [Service]
  Restart=on-failure
  ExecStart=/usr/bin/nomad agent -dev-connect -bind 0.0.0.0 -log-level INFO
  ExecReload=/bin/kill -HUP

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/nomad.service

echo "Installing Consul..."
CONSUL_VERSION=1.10.4
curl -sSL https://releases.hashicorp.com/consul/${CONSUL_VERSION}/consul_${CONSUL_VERSION}_linux_amd64.zip > consul.zip
unzip /tmp/consul.zip
sudo install consul /usr/bin/consul
(
cat <<-EOF
  [Unit]
  Description=consul agent
  Requires=network-online.target
  After=network-online.target

  [Service]
  Restart=on-failure
  ExecStart=/usr/bin/consul agent -dev -client 0.0.0.0
  ExecReload=/bin/kill -HUP $MAINPID

  [Install]
  WantedBy=multi-user.target
EOF
) | sudo tee /etc/systemd/system/consul.service

sudo systemctl enable consul.service
sudo systemctl start consul
sudo systemctl enable nomad.service
sudo systemctl start nomad

echo "Installing bridge plugin..."
BRIDGE_PLUGIN_VERSION=1.0.1
curl -sSL https://github.com/containernetworking/plugins/releases/download/v${BRIDGE_PLUGIN_VERSION}/cni-plugins-linux-amd64-v${BRIDGE_PLUGIN_VERSION}.tgz > bridge.tgz
sudo mkdir -p /opt/cni/bin
sudo tar -C /opt/cni/bin -xzf bridge.tgz

for bin in cfssl cfssl-certinfo cfssljson
do
  echo "Installing $bin..."
  curl -sSL https://pkg.cfssl.org/R1.2/${bin}_linux-amd64 > /tmp/${bin}
  sudo install /tmp/${bin} /usr/local/bin/${bin}
done
nomad -autocomplete-install
SCRIPT

Vagrant.configure("2") do |config|

  config.vm.box = "hashicorp/bionic64"
  config.vm.provision "shell", inline: $script, privileged: false
  
  config.vm.network "forwarded_port", guest: 4646, host: 4646, auto_correct: true, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8500, host: 8500, auto_correct: true, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 4000, host: 4000, auto_correct: true, host_ip: "127.0.0.1"
  
    ["vmware_fusion", "vmware_workstation"].each do |p|
    config.vm.provider p do |v|
      v.vmx["memsize"] = "1024"
    end
  end

  config.vm.synced_folder '.', '/vagrant', disabled: true
  config.vm.provider "virtualbox" do |vb|
    vb.customize [ "modifyvm", :id, "--uartmode1", "disconnected" ]
  end

end
