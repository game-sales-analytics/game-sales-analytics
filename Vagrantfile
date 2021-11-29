# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "generic/ubuntu2110"

  config.vm.box_version = "3.5.4"

  config.vm.box_url = "https://vagrantcloud.com/generic/ubuntu2110"

  config.vm.box_download_checksum = "30fd67c1b3a6a2fba231006ee87d34f8e9ea29ff7e7d8675343fbc459058b587129ca55d1fc39e66b4104953cc08258704e80829573895ef8aea8fc766d00d88"

  config.vm.box_download_checksum_type = "sha512"

  config.vm.allow_hosts_modification = true

  config.vm.box_check_update = true

  {
    2018 => 2018,
    2019 => 2019,
    8686 => 8686,
    3000 => 3000,
    7575 => 7575,
    8080 => 8080,
    8086 => 8086,
    8888 => 8888,
    8585 => 8585,
    9090 => 9090,
    9292 => 9292,
  }.each { |host, guest| config.vm.network "forwarded_port", guest: guest, host: host, host_ip: "127.0.0.1" }

  config.vm.network "private_network", type: "dhcp"

  config.vm.synced_folder ".", "/home/vagrant/workspace", id: "host_workspace", type: "virtualbox", owner: "root", group: "root", mount_options: ["ro", "dmode=755", "fmode=644"], SharedFoldersEnableSymlinksCreate: false

  config.vm.hostname = "gsa"

  config.vm.define "gsa-machine"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.name = "gsa"
    vb.memory = 8192
    vb.cpus = 4
  end

  config.vm.provision "setup", type: "ansible_local", run: "once" do |an|
    an.verbose = false
    an.provisioning_path = "/home/vagrant/workspace"
    an.playbook = "playbook.yml"
  end

  config.vm.provision "reboot", after: "setup", type: "shell", run: "once" do |s|
    s.name = "reboot"
    s.privileged = true
    s.reboot = true
    s.inline = "echo rebooting the machine"
  end
end
