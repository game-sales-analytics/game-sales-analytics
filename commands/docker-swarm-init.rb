require "vagrant"
require_relative "../vms"

module VagrantPlugins
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
          $manager_vm[:name],
          :err => "/dev/null",
          STDOUT => w,
        )
        w.close
        swarm_join_command = r.read.lines.map(&:strip).delete_if { |line| line.empty? }.at(2).strip
        r.close

        $worker_vms.each_key do |m|
          puts "Joining machine '#{m}'..."
          system(
            "vagrant",
            "ssh",
            "--command",
            swarm_join_command,
            "#{m}",
            [:out, :err] => "/dev/null",
          )
        end

        $worker_vms.each_pair do |name, vm|
          vm[:labels].each do |label|
            puts "Labeling machine '#{name}' as '#{label}'..."
            system(
              "vagrant",
              "ssh",
              "--command",
              "docker node update --label-add #{label} #{name}",
              $manager_vm[:name],
              [:out, :err] => "/dev/null",
            )
          end
        end

        system(
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
end
