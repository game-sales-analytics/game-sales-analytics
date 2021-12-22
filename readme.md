# Game Sales Analytics

![Diagram](diagram.png)

## TOC

- [Setup](#setup)

  - [Prerequisites](#prerequisites)

  - [Run](#run)

- [API Documentation](#api-documentation)

- [Hardware Requirements](#hardware-requirements)

- [Troubleshoot](#troubleshoot)

- [TODOs](#todos)

## Setup

### Prerequisites

- Vagrant (`2.2.19`): <https://www.vagrantup.com/downloads>

- VirtualBox (`6.1.30r148432`): <https://download.virtualbox.org/virtualbox/6.1.30/>

[toc ↑](#toc)

### Run

Assuming `vagrant` and VirtualBox (e.g., `vboxmanage`, `vboxheadless`) commands are accessible from the command line:

1. Download the repository

   - If `git` installed on your machine, run:

     ```sh
     git clone git@github.com:game-sales-analytics/game-sales-analytics.git game-sales-analytics
     cd game-sales-analytics
     ```

   - Otherwise, to download the project use the following URL:

     <https://github.com/game-sales-analytics/game-sales-analytics/archive/refs/heads/main.zip>

     Then extract the archive file.

2. Configure

   Set values for different application services. Copy each one of the following templates to their respective `.env` file as shown below:

   - Copy `swarm/dbs/.env.core.template` to `swarm/dbs/.env.core`

   - Copy `swarm/dbs/.env.users.template` to `swarm/dbs/.env.users`

   - Copy `swarm/dba/.env.core.template` to `swarm/dba/.env.core`

   - Copy `swarm/dba/.env.users.template` to `swarm/dba/.env.users`

   - Copy `swarm/gsa/.env.cache.template` to `swarm/gsa/.env.cache`

   - Copy `swarm/gsa/.env.coresrv.template` to `swarm/gsa/.env.coresrv`

   - Copy `swarm/gsa/.env.userssrv.template` to `swarm/gsa/.env.userssrv`

   Each one of these files is a `KEY=VALUE` pair of options. Fill each provided key with the proper value.

   Consult their commented documentation for further information on what each field is and how they will be used.

3. In the project directory, start the machines

   ```sh
   vagrant up
   ```

   This command will download the base box image which is about ~250MB, and depending on your internet speed, it might take few minutes to complete. After downloading the box, it will spin up the machines with the help of VirtualBox.

4. Initialize the Docker Swarm

   ```sh
   vagrant docker-swarm-init
   ```

   It:

   1. Creates the Docker Swarm in `manager` machine.

   2. Joins all the worker machines to the Swarm.

   3. Uploads configuration files to `manager` machine.

5. Start Docker services

   1. Connect to `manager` machine:

      ```sh
      vagrant ssh manager
      ```

   2. Go to swarm configuration directory:

      ```sh
      cd swarm
      ```

   3. Deploy GSA stack

      ```sh
      docker stack deploy --compose-file compose.gsa.yaml gsa
      ```

   4. Deploy Monitoring stack

      ```sh
      docker stack deploy --compose-file compose.mon.yaml mon
      ```

   5. Deploy Telegraf metrics collector

      ```sh
      docker stack deploy --compose-file compose.tel.yaml tel
      ```

   These commands download and run all the Docker images, and depending on your internet connection speed, it might take a while for stacks to become available and healthy. Meanwhile, you can check the state of stacks using the following commands:

   - List of stacks:

     ```sh
     docker stack ls
     ```

   - List GSA stack services:

     ```sh
     docker stack services gsa
     ```

   - List Monitoring stack services:

     ```sh
     docker stack services mon
     ```

   - List Telegraf collector stack services:

     ```sh
     docker stack services tel
     ```

   - List of all created services:

     ```sh
     docker service ls
     ```

   You can see the deployment status, health status, and number of replicas of services using above list services commands. Once all the deployed replicas of services are ready and healthy, you can move to the next step.

6. Accessing the services

   Using your favorite browser, you can reach following addresses:

   - <http://localhost:3000>: [Grafana](https://grafana.com/) monitoring dashboard. Use the credentials set in `swarm/mon/.env.grafana` to login into the dashboard. Create a Prometheus connection and once connected to Prometheus, you can create dashboards as you need. Also, you can start by importing available dashboards at <https://grafana.com/grafana/dashboards/>.

   - <http://localhost:8086>: [InfluxDB](https://www.influxdata.com/) dashboard. Use the credentials set in `swarm/mon/.env.influxdb` to login into the dashboard. Create a Telegraf connection API Token from **Data > Telegraf**. Click on the **+ Create Configuration** button, and activate **System** configuration. Click on _continue_, choose a name (and an optional description) for the Telegraf configuration. Click the **Create And Verify** button. Copy the generated token shown in format `export INFLUX_TOKEN=HERE_MUST_BE_THE_TOKEN`. Once you copied the Telegraf API Token, set it for `INFLUXDB_TELEGRAF_TOKEN` in `swarm/mon/.env.telegraf`. Upload it to `manager` machine using `vagrant upload-swarm-files`, then (re)start the Telegraf stack using the command mentioned [above](#run). After successful run, Telegraf will send the metrics from all nodes to InfluxDB, and you can reach the dashboards from InfluxDB Boards section.

   - <http://localhost:8181>: Users database admin dashboard

     Use credentials set in `swarm/dba/.env.users` to login into the dashboard.

   - <http://localhost:8585>: Core database admin dashboard

     Use credentials set in `swarm/dba/.env.core` to login into the dashboard.

     After first successful login, create a server from the panel with the following configurations:

     - Server name: `CoreDB`

     - Host: `coredb`

     - Database Name: Database name you have set in `swarm/dbs/.env.core` (`POSTGRESQL_DATABASE`)

     - Username: Application user's username you have set in `swarm/dbs/.env.core` (`POSTGRESQL_USERNAME`)

     - Password: Application user's password you have set in `swarm/dbs/.env.core` (`POSTGRESQL_PASSWORD`)

   - <http://localhost:8383>: [Docker Swarm Visualizer](https://github.com/dockersamples/docker-swarm-visualizer) service. You can see live graphical representation of the swarm nodes, and running services on each node here. Use the username and **un-encrypted** version of the password you've already set for `MONITORING_ADMIN_PASSWORD` in `swarm/mon/.env.caddy` to log in.

   - <http://localhost:8888>: [Chronograf](https://www.influxdata.com/time-series-platform/chronograf/) dashboard. It is a simpler version of InfluxDB dashboard with the only purpose of viewing metrics in dashboards. It connects to InfluxDB using an API Token and you can create visualization dashboards in Chronograf.

   - <http://localhost:9292>: GSA API interface. You can use [Postman](#api-documentation) to interact with the APIs.

   - <http://localhost:9393>: [Prometheus](https://prometheus.io/) dashboard. Use the username and **un-encrypted** version of the password you've already set for `MONITORING_ADMIN_PASSWORD` in `swarm/mon/.env.caddy` to log in.

[toc ↑](#toc)

### API Documentation

Postman collection for REST APIs is available at: <https://www.postman.com/xeptore/workspace/gsa/collection/6663032-e7ea02bf-4666-4820-a8ff-dfa3ecbf3fbe>

[toc ↑](#toc)

## Hardware Requirements

With default setup, a 4 core CPU and ~25GB memory would be enough. If you want to decrease the amount of memory, or number of CPU cores allocated to each virtual machine, you can do it in [`Vagrantfile`]('./../Vagrantfile). Of course there is no guarantee that the application works correctly after those changes!

[toc ↑](#toc)

## Troubleshoot

- Waiting for a long time, but there are still services or replicas waiting to run without any changes

  You waited for a relatively long time, watching stack services list, and still there are services or replicas not being started. This might be due to slow download speed which should be fixed by waiting more until all necessary Docker images gets downloaded and run on virtual machines.

  If you noticed there is nothing being downloaded (e.g., by checking your system network internet usage), but still there are services not being started, it might be because of reaching maximum retires for downloading Docker images. In this case you can simply remove the stack(s) using `docker stack rm STACK [STACK...]` command, and re-deploy it using the commands explained [above](#run).

- Services are deployed and they are ready, but I cannot access one or some of them from my machine.

  If listing stack services shows all the services are successfully deployed and in ready state, but you cannot reach some or any of them by hitting their URLs (e.g., receiving _connection reset_ error), there might be a bug with VirtualBox. One solution is to re-deploy the stack(s) which contain the service(s). For example, if accessing application APIs returns _connection reset_ error after some amount of time, remove the stack from `manager` machine, using `docker stack rm gsa`, wait about 1-2 minute for the stack to be completely removed from all swarm nodes, and re-deploy it using the command explained [above](#run).

[toc ↑](#toc)

## TODOs

- [x] Fix automatic monitoring stack `$DNS_SERVER_IP` variable setup
- [x] Fix service startup ordering
- [x] Listen docker swarm manager only on private interface
- [x] Revise swarm services restart policy condition (shutting down a service due to service health check timeout, will result in `0` status code exit)
- [x] Use internal network for swarm internal communication
- [x] Run swarm nodes vagrant commands in parallel
- [x] Enable secure access to admin dashboards
- [x] Add docker swarm visualizer service health check test command
- [x] Add _prepper_ job executor command
- [ ] Add gRPC logo as the inter-service communication mechanism to the diagram

[toc ↑](#toc)
