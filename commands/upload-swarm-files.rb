require "vagrant"
require_relative "../vms"

module VagrantPlugins
  module CommandUploadeManagerFiles
    class Command < Vagrant.plugin("2", :command)
      def self.synopsis
        "uploads swarm directory to manger machine"
      end

      def execute
        Process.wait spawn(
          "vagrant",
          "upload",
          "./swarm/",
          "/home/vagrant/swarm",
          $manager_vm[:name],
          :err => "/dev/null",
          STDOUT => STDOUT,
        )
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "upload-swarm-files command"
      description <<-DESC
      The `upload-swarm-files` command uploads configuration and environment files to manager virtual machine.
      DESC

      command("upload-swarm-files") do
        Command
      end
    end
  end
end
