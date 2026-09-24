# Docker Networking & Volume Homework Tasks

## Task 1: Docker Container Networking

This task demonstrates Docker networking with a frontend container, backend container, and database container connected through multiple custom Docker networks.

### Create Docker networks

![Docker network creation](./screenshots/network_creation.png)

### Build frontend image

![Frontend build](./screenshots/frontend-build.png)

### Run frontend container

![Frontend running](./screenshots/fe_container_running.png)

### Build backend image

![Backend build](./screenshots/backend-build.png)

### Run backend container

![Backend running](./screenshots/be_container_running.png)

### Build database image

![Database build](./screenshots/database-build.png)

### Run database container

![Database running](./screenshots/db_container_running.png)

### Connect backend to multiple networks

![Backend connected to multiple networks](./screenshots/connect_to_multiple_networks.png)

### Verify connectivity between containers

![External connectivity check](./screenshots/external_connectivity_test.png)

---

## Task 2: Host Network

### Pull Apache image

![Pulling httpd image](./screenshots/apache_container_host.jpeg)

### Run Apache container on host network

![Apache container running on host network](./screenshots/apache_container_host.jpeg)

---

## Task 3: Bind Mount

### Start NGINX with bind mount

![Bind mount setup](./screenshots/bind_mount_start.png)

### Access the mounted web page

![Bind mount step 1](./screenshots/stage_1_bind_mount.png)

### Verify the updated content without restarting container

![Bind mount step 2](./screenshots/step_2_bind_mount.png)

---

## Task 4: Overlay Network

Docker overlay networks are used when containers need to communicate across multiple Docker hosts in a swarm or multi-host environment. Unlike bridge networks, which work only on a single host, overlay networks create a virtual network that spans several machines.

### Use cases

- Communication between containers running on different Docker hosts
- Multi-host application deployments in Docker Swarm
- Service discovery between containers in a distributed setup
- Scalable microservices architectures

### How overlay networks work

Overlay networks use a virtual network layer that is managed by Docker and sits above the host network. Docker encapsulates container traffic and forwards it between hosts so that containers can communicate as though they are on the same local network.

### Key points

- Overlay networks are designed for multi-host communication.
- Containers on different nodes can connect to each other through the overlay network.
- Docker Swarm is commonly used with overlay networking.
- They are especially useful when building distributed applications across multiple machines.

### Example concept

When an application has frontend and backend containers running on different hosts, the overlay network allows them to communicate using container names or service names instead of host IPs alone.

### Summary

Overlay networks are essential for connecting containers across multiple Docker hosts, making them a core feature for production distributed deployments.
