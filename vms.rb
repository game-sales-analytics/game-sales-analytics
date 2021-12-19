require_relative "ip_generator"

$dns_vm_name = "dns"
$dns_vm = {
  labels: ["category=dns"],
  memory: 256,
  cpus: 1,
  ip: "192.168.56.32",
  vb_name: "gsa-#{$dns_vm_name}",
}

$manager_vm_name = "manager"
$manager_vm = {
  labels: [],
  memory: 4096,
  cpus: 2,
  ip: "192.168.56.33",
  vb_name: "gsa-#{$manager_vm_name}",
}

$worker_vms = {
  "databases" => {
    labels: ["category=dbs"],
    memory: 8192,
    cpus: 4,
    ip: "192.168.56.34",
  },
  "dbadmins" => {
    labels: ["category=dba"],
    memory: 4096,
    cpus: 2,
    ip: "192.168.56.35",
  },
  "monitor" => {
    labels: ["category=monitor"],
    memory: 8192,
    cpus: 4,
    ip: "192.168.56.36",
  },
  "cache" => {
    labels: ["category=cache"],
    memory: 2048,
    cpus: 4,
    ip: "192.168.56.37",
  },
  "app-1" => {
    labels: ["category=app"],
    memory: 2048,
    cpus: 2,
    ip: "192.168.56.38",
  },
  "app-2" => {
    labels: ["category=app"],
    memory: 2048,
    cpus: 2,
    ip: "192.168.56.39",
  },
  "app-3" => {
    labels: ["category=app"],
    memory: 2048,
    cpus: 2,
    ip: "192.168.56.40",
  },
  "dmz-1" => {
    labels: ["category=dmz"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.41",
  },
  "dmz-2" => {
    labels: ["category=dmz"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.42",
  },
  "dmz-3" => {
    labels: ["category=dmz"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.43",
  },
  "gateway-1" => {
    labels: ["category=gateway"],
    memory: 4096,
    cpus: 2,
    ip: "192.168.56.44",
  },
  "gateway-2" => {
    labels: ["category=gateway"],
    memory: 4096,
    cpus: 2,
    ip: "192.168.56.45",
  },
}
  .map { |k, v| [k, v.merge({ vb_name: "gsa-#{k}" })] }.to_h

$swarm_vms = {
  "#{$manager_vm_name}" => $manager_vm,
}.merge($worker_vms)

$all_vms = {
  "#{$dns_vm_name}" => $dns_vm,
}.merge($swarm_vms)
