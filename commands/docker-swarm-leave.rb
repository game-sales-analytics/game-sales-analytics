require "vagrant"
require_relative "../vms"

module VagrantPlugins
  module CommandDockerSwarmLeave
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "forces all the swarm nodes leave to their Docker swarm"
      end

      def execute
        threads = []

        $swarm_vms.each_key do |m|
          threads.push Thread.new {
            puts "Leaving node '#{m}'..."

            system(
              "vagrant",
              "ssh",
              "--no-tty",
              "--machine-readable",
              "--no-color",
              "--command",
              "docker swarm leave --force",
              "#{m}",
              "--",
              "-T",
              [:out, :err] => "/dev/null",
            )
            puts "Node '#{m}' left the swarm ✅"
          }
        end

        threads.each { |t| t.join }
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
