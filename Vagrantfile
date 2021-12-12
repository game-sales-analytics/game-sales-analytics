# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative "cmd"
require_relative "ip_generator"

ip_generator = IPGenerator.new

Vagrant.require_version ">= 2.2.19"

Vagrant.configure("2") do |config|
  config.vm.box = "xeptore/ubuntu-docker"

  config.vm.box_version = "20211212.1.45"

  config.vm.box_url = "https://vagrantcloud.com/xeptore/ubuntu-docker"

  config.vm.box_download_checksum = "d377061369758eeed23299cbb6b80737d8b8e02b0837a3f00c06e7737d19c02d73747dc3f119c2a561398fc23631077944d3882bfbf2a975523b2462a8ad4c02"

  config.vm.box_download_checksum_type = "sha512"

  config.vm.allow_hosts_modification = true

  config.vm.box_check_update = false

  config.ssh.connect_timeout = 3

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.check_guest_additions = false
  end

  config.vm.define "manager", primary: true do |manager|
    manager.vm.hostname = "manager"

    manager.vm.network "private_network", ip: ip_generator.resume

    {
      8181 => 8181,
      8383 => 8383,
      8585 => 8585,
      9292 => 9292,
    }.each { |host, guest| manager.vm.network "forwarded_port", guest: guest, host: host }

    manager.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "gsa-manager"
      vb.memory = 4096
      vb.cpus = 2
    end
  end

  config.vm.define "databases" do |cfg|
    cfg.vm.hostname = "databases"

    cfg.vm.network "private_network", ip: ip_generator.resume

    cfg.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "gsa-databases"
      vb.memory = 8192
      vb.cpus = 4
    end
  end

  config.vm.define "dbadmins" do |cfg|
    cfg.vm.hostname = "dbadmins"

    cfg.vm.network "private_network", ip: ip_generator.resume

    cfg.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "gsa-dbadmins"
      vb.memory = 4096
      vb.cpus = 2
    end
  end

  (1..3).each do |i|
    config.vm.define "app-#{i}" do |cfg|
      cfg.vm.hostname = "app-#{i}"

      cfg.vm.network "private_network", ip: ip_generator.resume

      cfg.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = "gsa-app-#{i}"
        vb.memory = 4096
        vb.cpus = 2
      end
    end
  end

  config.vm.define "cache" do |cfg|
    cfg.vm.hostname = "cache"

    cfg.vm.network "private_network", ip: ip_generator.resume

    cfg.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = "gsa-cache"
      vb.memory = 2048
      vb.cpus = 2
    end
  end

  (1..2).each do |i|
    config.vm.define "gateway-#{i}" do |cfg|
      cfg.vm.hostname = "gateway-#{i}"

      cfg.vm.network "private_network", ip: ip_generator.resume

      cfg.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = "gsa-gateway-#{i}"
        vb.memory = 8192
        vb.cpus = 4
      end
    end
  end

  (1..3).each do |i|
    config.vm.define "dmz-#{i}" do |cfg|
      cfg.vm.hostname = "dmz-#{i}"

      cfg.vm.network "private_network", ip: ip_generator.resume

      cfg.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = "gsa-dmz-#{i}"
        vb.memory = 2048
        vb.cpus = 2
      end
    end
  end
end
