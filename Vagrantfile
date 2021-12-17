# -*- mode: ruby -*-
# vi: set ft=ruby :
require_relative "cmd"
require_relative "vms"

def provision_dns(machine)
  dns_servers = [
    "94.140.14.14",
    "8.20.247.20",
    $dnssrv_vm[:ip],
  ]

  nameservers = dns_servers.map { |s| "nameserver #{s}" }

  machine.vm.provision "set-dns", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -evx
cat > /etc/resolv.conf <<-RESOLVECONF
#{nameservers.join("\n")}
RESOLVECONF
  SCRIPT
end

Vagrant.require_version ">= 2.2.19"

Vagrant.configure("2") do |config|
  config.vm.box = "xeptore/alpine315-docker"

  config.vm.box_version = "20211215.2.55"

  config.vm.box_url = "https://vagrantcloud.com/xeptore/alpine315-docker"

  config.vm.box_download_checksum = "nafab2ecdae0c1c02f32293f36e04c84df76b84bd05b0d795e1de94a54662d8027fe6fec2741ff914f6b89b6c48af049c6c4d24fbe4c800024507843fe4389bb1"

  config.vm.box_download_checksum_type = "sha512"

  config.vm.allow_hosts_modification = true

  config.vm.box_check_update = false

  config.ssh.connect_timeout = 3

  config.ssh.shell = "sh"

  config.vm.provider "virtualbox" do |v|
    v.linked_clone = true
    v.check_guest_additions = false
  end

  config.vm.define $manager_vm_name, primary: true do |dns|
    dns.vm.hostname = $manager_vm_name

    dns.vm.network "private_network", ip: $manager_vm[:ip]

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
    }.each { |host, guest| dns.vm.network "forwarded_port", guest: guest, host: host }

    dns.vm.provision "install-apps", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -eux
apk update
apk upgrade
apk add make
    SCRIPT

    provision_dns dns

    dns.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $manager_vm[:vb_name]
      vb.memory = $manager_vm[:memory]
      vb.cpus = $manager_vm[:cpus]
    end
  end

  config.vm.define $dnssrv_vm_name do |dns|
    dns.vm.hostname = $dnssrv_vm_name

    dns.vm.network "private_network", ip: $dnssrv_vm[:ip]

    dns.vm.provision "install-apps", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -eux
apk update
apk upgrade
apk add tinydns
    SCRIPT

    dns.vm.provision "configure-tinydns", type: "shell", run: "once", privileged: true, inline: <<-SCRIPT
set -evx
echo 'IP=#{$dnssrv_vm[:ip]}' > /etc/conf.d/tinydns
cat > /etc/tinydns/data <<-DATA
.internal:#{$dnssrv_vm[:ip]}:a:259200
#{$all_vms.map { |k, v| "=#{k}.internal:#{v[:ip]}:10800" }.join("\n")}
DATA
rc-service tinydns start
    SCRIPT

    dns.vm.provider "virtualbox" do |vb|
      vb.gui = false
      vb.name = $dnssrv_vm[:vb_name]
      vb.memory = $dnssrv_vm[:memory]
      vb.cpus = $dnssrv_vm[:cpus]
    end
  end

  $worker_vms.each { |name, vm|
    config.vm.define name do |cfg|
      cfg.vm.hostname = name

      cfg.vm.network "private_network", ip: vm[:ip]

      provision_dns cfg

      cfg.vm.provider "virtualbox" do |vb|
        vb.gui = false
        vb.name = vm[:vb_name]
        vb.memory = vm[:memory]
        vb.cpus = vm[:cpus]
      end
    end
  }
end
