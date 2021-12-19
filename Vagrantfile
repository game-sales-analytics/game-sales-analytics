# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative "cmd"
require_relative "vms"

def provision_dns(machine)
  dns_servers = [
    "94.140.14.14",
    "8.20.247.20",
    $dns_vm[:ip],
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
  config.vm.box_version = "20211219.7.27"
  config.vm.box_url = "https://vagrantcloud.com/xeptore/alpine315-docker"
  config.vm.box_download_checksum = "12b8e2863132c3d2b59b136836d7d88def2306c5f2fe54b56573cf41db569cb6e849ac908489dae8ea363516497783c2c48d73468d942a0287a04ebcc7ccc2e9"
  config.vm.box_download_checksum_type = "sha512"
  config.vm.box_check_update = false

  config.vm.allow_hosts_modification = true

  config.ssh.connect_timeout = 5

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.check_guest_additions = false
  end

  config.vm.define $manager_vm_name, primary: true do |manager|
    manager.vm.hostname = "#{$manager_vm_name}.internal"

    manager.vm.network "private_network", ip: $manager_vm[:ip]

    {
      8181 => 8181,
      8383 => 8383,
      8585 => 8585,
      9292 => 9292,
      3000 => 3000,
      8086 => 8086,
      8888 => 8888,
      8080 => 8080,
      9090 => 9090,
    }.each { |host, guest| manager.vm.network "forwarded_port", guest: guest, guest_ip: "127.0.0.1", host: host, host_ip: "127.0.0.1" }

    manager.vm.provision "install-apps", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
apk update
apk upgrade
apk add make
SCRIPT

    manager.vm.provision "set-env", type: "shell", run: "once", privileged: false, inline: <<-SCRIPT
set -ev
echo 'DNS_SERVER_IP=#{$dns_vm[:ip]}' > ~/.profile
SCRIPT

    provision_dns manager

    manager.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $manager_vm[:vb_name]
      vb.memory = $manager_vm[:memory]
      vb.cpus = $manager_vm[:cpus]
    end
  end

  config.vm.define $dns_vm_name do |dns|
    dns.vm.box = "generic/alpine315"
    dns.vm.box_version = "3.6.0"
    dns.vm.box_url = "https://vagrantcloud.com/generic/alpine315"
    dns.vm.box_download_checksum = "47d925219c9cde0b85930ef0558684da0bd0ebf6477fa95213117c83496c018294cdf1501c6309fd109738dd76bc66b843363d2222e8575a5d984bb92cf05805"
    dns.vm.box_download_checksum_type = "sha512"

    dns.vm.hostname = "#{$dns_vm_name}.internal"

    dns.vm.network "private_network", ip: $dns_vm[:ip]

    dns.vm.provision "install-apps", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
printf 'https://mirror.math.princeton.edu/pub/alpinelinux/v3.15/main\n' >/etc/apk/repositories
printf 'https://mirror.math.princeton.edu/pub/alpinelinux/v3.15/community\n' >>/etc/apk/repositories
apk update
apk upgrade
apk add tinydns
SCRIPT

    dns.vm.provision "configure-tinydns", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -ev
echo 'IP=#{$dns_vm[:ip]}' > /etc/conf.d/tinydns
cat > /etc/tinydns/data <<-DATA
.internal:#{$dns_vm[:ip]}:a:259200
#{$swarm_vms.map { |k, v| "=#{k}.internal:#{v[:ip]}:10800" }.join("\n")}
DATA
rc-service tinydns start
SCRIPT

    dns.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $dns_vm[:vb_name]
      vb.memory = $dns_vm[:memory]
      vb.cpus = $dns_vm[:cpus]
    end
  end

  config.vm.define $monitor_vm_name, primary: true do |monitor|
    monitor.vm.hostname = "#{$monitor_vm_name}.internal"

    monitor.vm.network "private_network", ip: $monitor_vm[:ip]

    {
      9393 => { port: 9393, id: "app-prometheus" },
    }.each { |host, guest| monitor.vm.network "forwarded_port", id: guest[:id], guest: guest[:port], guest_ip: "127.0.0.1", host: host, host_ip: "127.0.0.1" }

    provision_dns monitor

    monitor.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $monitor_vm[:vb_name]
      vb.memory = $monitor_vm[:memory]
      vb.cpus = $monitor_vm[:cpus]
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
end
