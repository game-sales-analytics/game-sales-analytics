require "vagrant"
require_relative "../vms"

module VagrantPlugins
  module CommandDockerSwarmLeave
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "forces all the swarm nodes leave to their Docker swarm"
      end

      def execute
        $swarm_vms.each_key do |m|
          puts "Leaving machine '#{m}'..."
          system(
            "vagrant",
            "ssh",
            "--command",
            "docker swarm leave --force",
            "#{m}",
            [:out, :err] => "/dev/null",
          )
        end
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "docker-swarm-leave command"
      description <<-DESC
      The `docker-swarm-leave` command forces all the Docker swarm nodes to leave their swarm.
      DESC

      command("docker-swarm-leave") do
        Command
      end
    end
  end
end
