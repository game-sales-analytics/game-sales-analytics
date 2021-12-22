$manager_vm = {
  name: "manager",
  labels: [],
  memory: 4096,
  cpus: 4,
  ip: "10.0.0.30",
  vb_name: "gsa-manager",
}

$worker_vms = {
  dns: {
    labels: ["category=dns"],
    memory: 2048,
    cpus: 4,
    ip: "10.0.0.31",
  },
  monitor: {
    labels: ["category=monitor"],
    memory: 8192,
    cpus: 4,
    ip: "10.0.0.32",
  },
  databases: {
    labels: ["category=dbs"],
    memory: 8192,
    cpus: 4,
    ip: "10.0.0.33",
  },
  dbadmins: {
    labels: ["category=dba"],
    memory: 4096,
    cpus: 4,
    ip: "10.0.0.34",
  },
  cache: {
    labels: ["category=cache"],
    memory: 2048,
    cpus: 4,
    ip: "10.0.0.35",
  },
  app1: {
    labels: ["category=app"],
    memory: 2048,
    cpus: 4,
    ip: "10.0.0.36",
  },
  app2: {
    labels: ["category=app"],
    memory: 2048,
    cpus: 4,
    ip: "10.0.0.37",
  },
  dmz1: {
    labels: ["category=dmz"],
    memory: 2048,
    cpus: 2,
    ip: "10.0.0.38",
  },
  dmz2: {
    labels: ["category=dmz"],
    memory: 2048,
    cpus: 2,
    ip: "10.0.0.39",
  },
  gateway: {
    labels: ["category=gateway"],
    memory: 4096,
    cpus: 2,
    ip: "10.0.0.40",
  },
}
  .map { |k, v| [k, v.merge({ name: "#{k}", vb_name: "gsa-#{k}" })] }.to_h

$swarm_vms = {
  "#{$manager_vm[:name]}" => $manager_vm,
}.merge($worker_vms)

$all_vms = {}.merge($swarm_vms)
