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
        puts "Initializing swarm in manager vm..."
        Process.wait spawn(
          "vagrant",
          "ssh",
          "--command",
          "docker swarm init --advertise-addr=#{$manager_vm[:ip]} --listen-addr=#{$manager_vm[:ip]}:2377 --availability=active --force-new-cluster --task-history-limit=10",
          $manager_vm[:name],
          "--",
          "-T",
          :err => "/dev/null",
          STDOUT => w,
        )
        w.close
        swarm_join_command = r.read.lines.map(&:strip).delete_if { |line| line.empty? }.at(2).strip
        r.close
        puts "Swarm initialized ✅"

        threads = []

        $worker_vms.each_pair do |name, vm|
          threads.push Thread.new {
            puts "Joining node '#{name}'..."
            system(
              "vagrant",
              "ssh",
              "--command",
              swarm_join_command,
              "#{name}",
              "--",
              "-T",
              [:out, :err] => "/dev/null",
            )
            puts "Node '#{name}' joined the swarm ✅"
          }
        end

        threads.each { |t| t.join }

        label_command = $worker_vms
          .map { |name, vm| vm[:labels].map { |l| { name: name, label: l } } }
          .flatten(1)
          .map { |set| "docker node update --label-add #{set[:label]} #{set[:name]}" }
          .join("; ")

        puts "Labeling nodes..."
        system(
          "vagrant",
          "ssh",
          "--command",
          label_command,
          $manager_vm[:name],
          "--",
          "-T",
          [:out, :err] => "/dev/null",
        )
        puts "ٔNodes labeled ✅"

        system(
          "vagrant",
          "upload-swarm-files",
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
