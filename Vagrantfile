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
  config.vm.box_version = "20220201.14.35"
  config.vm.box_url = "https://vagrantcloud.com/xeptore/alpine315-docker"
  config.vm.box_download_checksum = "334815f9a4a67f0875156b57d916b9905a99d732c63b219a6bd0c42057cdd0f64963c113dfe09c72c34c4abe2908bd67f351"
  config.vm.box_download_checksum_type = "sha512"

  config.vm.allow_hosts_modification = true

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.check_guest_additions = false
  end

  config.trigger.after [:up, :reload] do |trg|
    trg.info = "Restarting eth1 internal network interface"
    trg.name = "eth1 internal network restart"
    trg.run_remote = {
      privileged: true,
      inline: "ifdown eth1 && ifup eth1",
    }
  end

  config.vm.define $manager_vm[:name], primary: true do |manager|
    manager.vm.hostname = "#{$manager_vm[:name]}.internal"

    manager.vm.network "private_network", ip: $manager_vm[:ip], virtualbox__intnet: "gsa-net"

    {
      8181 => { port: 8181, id: "app-usersdbadmin" },
      8585 => { port: 8585, id: "app-coredbadmin" },
      9292 => { port: 9292, id: "app-gateway" },
    }.each { |host, guest| manager.vm.network "forwarded_port", id: guest[:id], guest: guest[:port], guest_ip: $manager_vm[:ip], host: host, host_ip: "127.0.0.1" }

    manager.vm.provision "set-env", type: "shell", run: "once", privileged: false, inline: <<-SCRIPT
set -ev
echo 'export DNS_SERVER_IP=#{$worker_vms[:dns][:ip]}' > ~/.profile
echo 'export HISTCONTROL=ignoreboth,erasedups' > ~/.bashrc
SCRIPT

    manager.trigger.after [:up] do |trg|
      trg.info = "Running Docker service restart trigger"
      trg.name = "Docker service restart"
      trg.run_remote = {
        privileged: true,
        inline: "rc-service docker restart",
      }
    end

    provision_dns manager

    manager.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $manager_vm[:vb_name]
      vb.memory = $manager_vm[:memory]
      vb.cpus = $manager_vm[:cpus]
    end
  end

  $worker_vms.each { |name, vm|
    config.vm.define name do |machine|
      machine.vm.hostname = "#{name}.internal"

      machine.vm.network "private_network", ip: vm[:ip], virtualbox__intnet: "gsa-net"

      provision_dns machine

      machine.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = vm[:vb_name]
        vb.memory = vm[:memory]
        vb.cpus = vm[:cpus]
      end
    end
  }

  config.vm.define $worker_vms[:dns][:name] do |dns|
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
  end

  config.vm.define $worker_vms[:monitor][:name] do |monitor|
    {
      3000 => { port: 3000, id: "app-grafana" },
      8086 => { port: 8086, id: "app-influxdb" },
      8383 => { port: 8383, id: "app-swarmvisualizer" },
      8888 => { port: 8888, id: "app-chronograf" },
      9393 => { port: 9393, id: "app-prometheus" },
    }.each { |host, guest| monitor.vm.network "forwarded_port", id: guest[:id], guest: guest[:port], guest_ip: $worker_vms[:monitor][:ip], host: host, host_ip: "127.0.0.1" }
  end

  config.vm.define $worker_vms[:sentry][:name] do |sentry|
    sentry.vm.provision "install-pkgs", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
apk update
apk upgrade
apk add docker-compose bash
rm -rf /var/cache/apk/*
SCRIPT

    sentry.vm.provision "download-sentry", type: "shell", run: "once", privileged: false, inline: <<-SCRIPT
set -ev
wget -nv https://github.com/getsentry/self-hosted/archive/refs/tags/22.1.0.tar.gz
tar -xzf 22.1.0.tar.gz
rm 22.1.0.tar.gz
SCRIPT

    {
      9000 => { port: 9000, id: "app-sentry" },
    }.each { |host, guest| sentry.vm.network "forwarded_port", id: guest[:id], guest: guest[:port], guest_ip: $worker_vms[:sentry][:ip], host: host, host_ip: "127.0.0.1" }
  end
end
