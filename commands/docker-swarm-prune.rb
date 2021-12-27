require "vagrant"
require_relative "../vms"

module VagrantPlugins
  module CommandDockerSwarmPrune
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "prunes all the swarm nodes"
      end

      def execute
        $swarm_vms.each_key do |m|
          puts "Prunning node '#{m}'..."
          system(
            "vagrant",
            "ssh",
            "--no-tty",
            "--machine-readable",
            "--no-color",
            "--command",
            "docker system prune --all --force --volumes",
            "#{m}",
            "--",
            "-T",
            [:out, :err] => "/dev/null",
          )
          puts "Node '#{m}' cleaned up ✅"
        end
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "docker-swarm-prune command"
      description <<-DESC
      The `docker-swarm-prune` command prunes all the swarm nodes.
      DESC

      command("docker-swarm-prune") do
        Command
      end
    end
  end
end
