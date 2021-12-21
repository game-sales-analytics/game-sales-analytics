# Game Sales Analytics

![Diagram](diagram.png)

## Setup

### Prerequisites

- Vagrant (`2.2.19`): <https://www.vagrantup.com/downloads>

- VirtualBox (`6.1.30`): <https://download.virtualbox.org/virtualbox/6.1.30/>

### Run

Assuming `vagrant` and `vboxmanage` commands are accessible in your command line:

1. Clone the repository

   ```sh
   git clone git@github.com:game-sales-analytics/game-sales-analytics.git game-sales-analytics
   cd game-sales-analytics
   ```

2. Configure

   Set values for different application services. Copy each one of the following templates to their respective `.env` file as shown below:

   - Copy `vms/dbs/.env.core.template` to `vms/dbs/.env.core`

   - Copy `vms/dbs/.env.users.template` to `vms/dbs/.env.users`

   - Copy `vms/dba/.env.core.template` to `vms/dba/.env.core`

   - Copy `vms/dba/.env.users.template` to `vms/dba/.env.users`

   - Copy `vms/apps/.env.cache.template` to `vms/apps/.env.cache`

   - Copy `vms/apps/.env.coresrv.template` to `vms/apps/.env.coresrv`

   - Copy `vms/apps/.env.userssrv.template` to `vms/apps/.env.userssrv`

   Each one of these files is a `KEY=VALUE` pair of options. Fill each provided key with the proper value.

   Consult their commented documentation for further information on what each field is and how they will be used.

3. Start machines

   ```sh
   vagrant up
   ```

   This command will download the base box image which is about ~1.5GB and depending on your internet speed, it might take few minutes to complete. After downloading the box, it will spin up the machines with the help of VirtualBox.

4. Create the Docker Swarm

   ```sh
   vagrant docker-swarm-init
   ```

   It:

   1. Creates the Docker Swarm in `manager` machine.

   2. Joins all the worker machines to the Swarm.

   3. Uploads configuration files to `manager` machine.

   4. Initializes the Swarm custom internal private network used for communications between nodes.

5. Start Docker services

   ```sh
   vagrant docker-swarm-start
   ```

   This command downloads and starts the services in order. Depending on your internet connection speed, it might take some time to download Docker images.

6. Visit the services

   Using your favorite browser, you can reach following addresses:

   - <http://localhost:8181>: Users service database admin dashboard

     Use credentials set in `vms/dba/.env.users` to login to dashboard.

   - <http://localhost:8585>: Core service database admin dashboard

     Use credentials set in `vms/dba/.env.core` to login to dashboard.

     After successful login, create a server with the following configurations:

     - Server name: `CoreDB`

     - Host: `coredb`

     - Database Name: Database name you have set in `vms/dbs/.env.core` (`POSTGRESQL_DATABASE`)

     - Username: Application user's username you have set in `vms/dbs/.env.core` (`POSTGRESQL_USERNAME`)

     - Password: Application user's password you have set in `vms/dbs/.env.core` (`POSTGRESQL_PASSWORD`)

   - <http://localhost:8383>: Docker Swarm Orchestrator visualizer service. You can see live graphical representation of the swarm at this address.

   Also, <http://localhost:9292> is exposed by the API web server which can be used for API communications.

### API Documentation

Postman collection for REST APIs is available at: <https://www.postman.com/xeptore/workspace/gsa/collection/6663032-e7ea02bf-4666-4820-a8ff-dfa3ecbf3fbe>

## Hardware Requirements

With default setup, a 4 core CPU and ~16GB memory would be enough. If you want to decrease the amount of memory, or number of CPU cores allocated to each virtual machine, you can do it in [`Vagrantfile`]('./../Vagrantfile). Of course there is no guarantee that the application works correctly after those changes!

## TODOs

- [x] Fix automatic monitoring stack `$DNS_SERVER_IP` variable setup
- [ ] Fix service startup ordering
- [ ] Listen docker swarm manager only on private interface
- [x] Use internal network for swarm internal communication
- [ ] Run swarm node vagrant commands in parallel
- [ ] Enable secure access to admin dashboards
- [ ] Add _prepper_ job executor command
