require "vagrant"

$manager_vm = "manager"

$worker_vms = {
  "databases" => {
    labels: ["category=dbs"],
  },
  "dbadmins" => {
    labels: ["category=dba"],
  },
  "app-1" => {
    labels: ["category=app"],
  },
  "app-2" => {
    labels: ["category=app"],
  },
  "app-3" => {
    labels: ["category=app"],
  },
  "cache" => {
    labels: ["category=cache"],
  },
  "gateway-1" => {
    labels: ["category=gateway"],
  },
  "gateway-2" => {
    labels: ["category=gateway"],
  },
  "dmz-1" => {
    labels: ["category=dmz"],
  },
  "dmz-2" => {
    labels: ["category=dmz"],
  },
  "dmz-3" => {
    labels: ["category=dmz"],
  },
}

$all_vms = [$manager_vm].concat($worker_vms.keys)

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
          $manager_vm,
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
          "docker swarm init --advertise-addr=enp0s8 --availability=drain --force-new-cluster --task-history-limit=10",
          $manager_vm,
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
              $manager_vm,
              :err => "/dev/null",
            )
          end
        end

        Process.wait spawn(
          "vagrant",
          "upload-manager-files",
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

  module CommandDockerNodesLeave
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "forces all the nodes leave their Docker swarm"
      end

      def execute
        $all_vms.each do |m|
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
