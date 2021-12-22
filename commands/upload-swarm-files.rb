require "tempfile"
require "base64"
require "vagrant"
require_relative "../vms"

def read_monitoring_envs(filename)
  Hash[
    *File.readlines(filename, chomp: true)
      .reject { |x| x.start_with?("#") || x.strip.empty? }
      .map { |x| x.split("=", 2) }
      .flatten
  ]
end

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
        envs = read_monitoring_envs File.join(File.dirname(__FILE__), "../swarm/mon/.env.caddy")
        raw = envs["MONITORING_ADMIN_PASSWORD"]
        encoded = Base64.strict_encode64(raw)
        envs = envs.merge({ "MONITORING_ADMIN_PASSWORD" => encoded })
        new_content = envs.to_a.map { |x| x.join("=") }.join("\n")

        tempfile = Tempfile.new(".env.caddy")
        tempfile.write(new_content)
        tempfile.close

        Process.wait spawn(
          "vagrant",
          "upload",
          tempfile.path,
          "/home/vagrant/swarm/mon/.env.caddy",
          $manager_vm[:name],
          :err => "/dev/null",
          STDOUT => STDOUT,
        )

        tempfile.unlink
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
