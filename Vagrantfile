# -*- mode: ruby -*-
# vi: set ft=ruby :

require "./env.rb"


Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2110"

  config.vm.box_version = "3.5.2"

  config.vm.box_url = "https://vagrantcloud.com/generic/ubuntu2110"

  config.vm.box_download_checksum = "30fd67c1b3a6a2fba231006ee87d34f8e9ea29ff7e7d8675343fbc459058b587129ca55d1fc39e66b4104953cc08258704e80829573895ef8aea8fc766d00d88"

  config.vm.box_download_checksum_type = "sha512"

  config.vm.allow_hosts_modification = true

  config.vm.box_check_update = true

  config.vm.network "forwarded_port", guest: 9090, host: 9090, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8888, host: 8888, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 8585, host: 8585, host_ip: "127.0.0.1"
  config.vm.network "forwarded_port", guest: 7575, host: 7575, host_ip: "127.0.0.1"

  config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder ".", "/home/vagrant/workspace", type: "virtualbox", SharedFoldersEnableSymlinksCreate: false

  config.vm.hostname = "gsa"

  config.vm.define "gsa-machine"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.name = "gsa"
    vb.memory = 8192
    vb.cpus = 4
  end

  config.vm.provision "setup", type: "ansible", run: "once" do |an|
    an.verbose = "vvv"
    an.playbook = "playbook.yml"
  end

  config.vm.provision "bootstrap", after: "setup", type: "shell", run: "always" do |s|
    s.env = { "DOCKER_BUILDKIT" => "1" }.merge(EnvReader.read())
    s.inline = "docker-compose --project-name gsa --file /home/vagrant/compose.yml up --detach"
  end
end