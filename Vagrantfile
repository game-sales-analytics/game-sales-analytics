# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative "cmd"
require_relative "vms"

def provision_dns(machine)
  dns_servers = [
    "94.140.14.14",
    "8.20.247.20",
    $worker_vms[:dns][:ip],
  ]

  nameservers = dns_servers.map { |s| "nameserver #{s}" }

  machine.vm.provision "set-dns", type: "shell", run: "always", privileged: true, inline: <<-SCRIPT
set -ev
cat > /etc/resolv.conf <<-RESOLVECONF
#{nameservers.join("\n")}
RESOLVECONF
SCRIPT
end

Vagrant.require_version ">= 2.2.19"

Vagrant.configure("2") do |config|
  config.vm.box = "xeptore/alpine315-docker"
  config.vm.box_version = "20211220.10.33"
  config.vm.box_url = "https://vagrantcloud.com/xeptore/alpine315-docker"
  config.vm.box_download_checksum = "d7ecdf1ec72bc2f3cb3b28fdfc4753a30925ae2a3c3705b2277dff440e9a20473626d339bd6a0ad1d3a3c727b98149d6a253710eaf14569e357308de01abd3a2"
  config.vm.box_download_checksum_type = "sha512"
  config.vm.box_check_update = false

  config.vm.allow_hosts_modification = true

  config.ssh.connect_timeout = 5

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.check_guest_additions = false
  end

  config.vm.define $manager_vm[:name], primary: true do |manager|
    manager.vm.hostname = "#{$manager_vm[:name]}.internal"

    manager.vm.network "private_network", ip: $manager_vm[:ip]

    {
      8181 => { port: 8181, id: "app-usersdbadmin" },
      8383 => { port: 8383, id: "app-swarmvisualizer" },
      8585 => { port: 8585, id: "app-coredbadmin" },
      9292 => { port: 9292, id: "app-gateway" },
      9090 => { port: 9090, id: "app-prometheus" },
    }.each { |host, guest| manager.vm.network "forwarded_port", id: guest[:id], guest: guest[:port], guest_ip: $manager_vm[:ip], host: host, host_ip: "127.0.0.1" }

    manager.vm.provision "install-apps", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
apk update
apk upgrade
apk add make
SCRIPT

    manager.vm.provision "set-env", type: "shell", run: "once", privileged: false, inline: <<-SCRIPT
set -ev
echo 'DNS_SERVER_IP=#{$worker_vms[:dns][:ip]}' > ~/.profile
SCRIPT

    provision_dns manager

    manager.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $manager_vm[:vb_name]
      vb.memory = $manager_vm[:memory]
      vb.cpus = $manager_vm[:cpus]
    end
  end

  config.vm.define $worker_vms[:dns][:name] do |dns|
    dns.vm.hostname = "#{$worker_vms[:dns][:name]}.internal"

    dns.vm.network "private_network", ip: $worker_vms[:dns][:ip]

    dns.vm.provision "install-apps", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
apk update
apk upgrade
apk add tinydns
SCRIPT

    dns.vm.provision "configure-tinydns", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
echo 'IP=#{$worker_vms[:dns][:ip]}' > /etc/conf.d/tinydns
cat > /etc/tinydns/data <<-DATA
.internal:#{$worker_vms[:dns][:ip]}:a:259200
#{$swarm_vms.map { |k, v| "=#{k}.internal:#{v[:ip]}:10800" }.join("\n")}
DATA
rc-update add tinydns default
rc-service tinydns start
SCRIPT

    dns.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $worker_vms[:dns][:vb_name]
      vb.memory = $worker_vms[:dns][:memory]
      vb.cpus = $worker_vms[:dns][:cpus]
    end
  end

  $worker_vms.each { |name, vm|
    config.vm.define name do |machine|
      machine.vm.hostname = "#{name}.internal"

      machine.vm.network "private_network", ip: vm[:ip]

      provision_dns machine

      machine.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = vm[:vb_name]
        vb.memory = vm[:memory]
        vb.cpus = vm[:cpus]
      end
    end
  }

  config.vm.define $worker_vms[:monitor][:name] do |monitor|
    {
      9393 => { port: 9393, id: "app-prometheus" },
      3000 => { port: 3000, id: "app-grafana" },
      8086 => { port: 8086, id: "app-influxdb" },
      8888 => { port: 8888, id: "app-chronograf" },
    }.each { |host, guest| monitor.vm.network "forwarded_port", id: guest[:id], guest: guest[:port], guest_ip: $worker_vms[:monitor][:ip], host: host, host_ip: "127.0.0.1" }
  end
end
