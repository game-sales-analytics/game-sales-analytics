require "vagrant"

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
          "gsa-manager",
          STDERR => STDERR,
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
end
