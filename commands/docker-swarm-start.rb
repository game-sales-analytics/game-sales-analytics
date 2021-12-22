require "vagrant"
require_relative "../vms"

module VagrantPlugins
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
          "cd swarm && make start-all",
          $manager_vm[:name],
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
end
