$manager_vm = {
  name: "manager",
  labels: [],
  memory: 4096,
  cpus: 2,
  ip: "192.168.56.30",
  vb_name: "gsa-manager",
}

$worker_vms = {
  dns: {
    labels: ["category=dns"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.31",
  },
  monitor: {
    labels: ["category=monitor"],
    memory: 8192,
    cpus: 4,
    ip: "192.168.56.32",
  },
  databases: {
    labels: ["category=dbs"],
    memory: 8192,
    cpus: 4,
    ip: "192.168.56.33",
  },
  dbadmins: {
    labels: ["category=dba"],
    memory: 4096,
    cpus: 2,
    ip: "192.168.56.34",
  },
  cache: {
    labels: ["category=cache"],
    memory: 2048,
    cpus: 4,
    ip: "192.168.56.35",
  },
  app1: {
    labels: ["category=app"],
    memory: 2048,
    cpus: 2,
    ip: "192.168.56.36",
  },
  app2: {
    labels: ["category=app"],
    memory: 2048,
    cpus: 2,
    ip: "192.168.56.37",
  },
  app3: {
    labels: ["category=app"],
    memory: 2048,
    cpus: 2,
    ip: "192.168.56.38",
  },
  dmz1: {
    labels: ["category=dmz"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.39",
  },
  dmz2: {
    labels: ["category=dmz"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.40",
  },
  dmz3: {
    labels: ["category=dmz"],
    memory: 1024,
    cpus: 2,
    ip: "192.168.56.41",
  },
  gateway1: {
    labels: ["category=gateway"],
    memory: 4096,
    cpus: 2,
    ip: "192.168.56.42",
  },
  gateway2: {
    labels: ["category=gateway"],
    memory: 4096,
    cpus: 2,
    ip: "192.168.56.43",
  },
}
  .map { |k, v| [k, v.merge({ name: "#{k}", vb_name: "gsa-#{k}" })] }.to_h

$swarm_vms = {
  "#{$manager_vm[:name]}" => $manager_vm,
}.merge($worker_vms)

$all_vms = {}.merge($swarm_vms)
