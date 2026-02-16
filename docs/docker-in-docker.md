# Docker-in-Docker

The container includes the Docker CLI and is configured to connect to the host's Docker daemon. This means you can run Docker commands (like `docker ps`, `docker build`, etc.) from within the JB Gateway container, and they will affect the Docker environment on your host machine.

## Accessing Services on the Host

When you run services via Docker from within the container (or if they are already running on the host), they are executed on the host's Docker daemon. To access these services from within the JB Gateway container, you must use `host.docker.internal` instead of `localhost`.

For example, if you start a Postgres database on port 5432:

```bash
# Inside JB Gateway container
docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -p 5432:5432 -d postgres
```

To access it from within the JB Gateway container (e.g., using `psql`), use `host.docker.internal:5432`.
