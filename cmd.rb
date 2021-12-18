require "vagrant"
require_relative "vms"

module VagrantPlugins
  module CommandUploadeManagerFiles
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "uploads necessary files to manger machine"
      end

      def execute
        Process.wait spawn(
          "vagrant",
          "upload",
          "./vms/",
          "/home/vagrant/vms",
          $manager_vm_name,
          :err => "/dev/null",
          STDOUT => STDOUT,
        )
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "upload-manager-files command"
      description <<-DESC
      The `upload-manager-files` command uploads configuration and environment files to manager virtual machine.
      DESC

      command("upload-manager-files") do
        Command
      end
    end
  end

  module CommandDockerInitSwarm
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "initializes the Docker swarm in manager machine"
      end

      def execute
        r, w = IO.pipe
        Process.wait spawn(
          "vagrant",
          "ssh",
          "--command",
          "docker swarm init --advertise-addr=#{$manager_vm[:ip]} --availability=active --force-new-cluster --task-history-limit=10",
          $manager_vm_name,
          :err => "/dev/null",
          STDOUT => w,
        )
        w.close
        cmd = r.read.lines.map(&:strip).delete_if { |line| line.empty? }.at(2).strip
        r.close

        $worker_vms.each_key do |m|
          puts "Joining machine '#{m}...'"
          Process.wait spawn(
            "vagrant",
            "ssh",
            "--command",
            cmd,
            m,
            :err => "/dev/null",
            STDOUT => STDOUT,
          )
        end

        $worker_vms.each_pair do |name, vm|
          vm[:labels].each do |label|
            puts "Labeling machine '#{name}' as '#{label}'..."
            Process.wait spawn(
              "vagrant",
              "ssh",
              "--command",
              "docker node update --label-add #{label} #{name}",
              $manager_vm_name,
              :err => "/dev/null",
            )
          end
        end

        Process.wait spawn(
          "vagrant",
          "upload-manager-files",
        )

        Process.wait spawn(
          "vagrant",
          "ssh",
          "--command",
          "cd vms && make init-all",
          $manager_vm_name,
        )
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "docker-swarm-init command"
      description <<-DESC
      The `docker-swarm-init` command initializes the Docker swarm in manager machine and joins all the machines to it.
      DESC

      command("docker-swarm-init") do
        Command
      end
    end
  end

  module CommandDockerSwarmStart
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "starts the Docker swarm services in manager machine"
      end

      def execute
        Process.wait spawn(
          "vagrant",
          "ssh",
          "--command",
          "cd vms && make start-all",
          $manager_vm_name,
          STDERR => STDERR,
          STDOUT => STDOUT,
        )
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "docker-swarm-start command"
      description <<-DESC
      The `docker-swarm-start` command starts the Docker swarm services in manager machine.
      DESC

      command("docker-swarm-start") do
        Command
      end
    end
  end

  module CommandDockerNodesLeave
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "forces all the nodes leave their Docker swarm"
      end

      def execute
        $swarm_vms.each do |m|
          puts "Leaving machine '#{m}'..."
          Process.wait spawn("vagrant", "ssh", "--command", "docker swarm leave --force", m, :err => "/dev/null")
        end
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "docker-swarm-nodes-leave command"
      description <<-DESC
      The `docker-swarm-nodes-leave` command forces all the Docker swarm nodes to leave their swarm.
      DESC

      command("docker-swarm-nodes-leave") do
        Command
      end
    end
  end
end
