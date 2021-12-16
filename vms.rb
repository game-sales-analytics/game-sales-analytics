require_relative "ip_generator"

ip_generator = IPGenerator.new

$dnssrv_vm_name = "dnssrv"
$dnssrv_vm = {
  labels: ["category=dns"],
  memory: 1024,
  cpus: 1,
  ip: ip_generator.next,
  vb_name: "gsa-#{$dnssrv_vm_name}",
}

$manager_vm_name = "manager"
$manager_vm = {
  labels: [],
  memory: 4096,
  cpus: 2,
  ip: ip_generator.next,
  vb_name: "gsa-#{$manager_vm_name}",
}

$worker_vms = {
  "databases" => {
    labels: ["category=dbs"],
    memory: 8192,
    cpus: 4,
  },
  "dbadmins" => {
    labels: ["category=dba"],
    memory: 4096,
    cpus: 2,
  },
  "monitor" => {
    labels: ["category=monitor"],
    memory: 8192,
    cpus: 4,
  },
  "cache" => {
    labels: ["category=cache"],
    memory: 2048,
    cpus: 4,
  },
}
  .merge(
    (1..3).to_h { |i|
      ["app-#{i}", {
        labels: ["category=app"],
        memory: 2048,
        cpus: 2,
      }]
    }
  )
  .merge(
    (1..3).to_h { |i|
      ["dmz-#{i}", {
        labels: ["category=dmz"],
        memory: 1024,
        cpus: 2,
      }]
    }
  )
  .merge(
    (1..2).to_h { |i|
      ["gateway-#{i}", {
        labels: ["category=gateway"],
        memory: 4096,
        cpus: 2,
      }]
    }
  )
  .transform_values { |v| v.merge({ ip: ip_generator.next }) }
  .map { |k, v| [k, v.merge({ vb_name: "gsa-#{k}" })] }.to_h

$all_vms = {
  "#{$dnssrv_vm_name}" => $dnssrv_vm,
  "#{$manager_vm_name}" => $manager_vm,
}.merge($worker_vms)
