# 📝 Node.js PostgreSQL Todo Application

A simple Node.js application with PostgreSQL integration and database migrations using `node-pg-migrate`. This project supports both Docker-based local development and Kubernetes-based production deployment.

---

## 🚀 Features

* Node.js + PostgreSQL Todo API
* Schema migrations via `node-pg-migrate`
* Dockerized services for local development
* Kubernetes manifests for orchestration
* One-command deployment and migration support
* Persistent volume support for PostgreSQL

---

## 📁 Project Structure

```
.
├── docker-compose.yml        # Docker services (Node.js, PostgreSQL)
├── Dockerfile                # Node.js app container definition
├── index.js                  # App entry point
├── migrations/               # DB migration files
├── views/                    # EJS templates
├── k8s/                      # Kubernetes manifests
│   ├── node-app-pod.yml
│   ├── node-app-pvc.yml
│   ├── node-app-svc.yml
│   ├── pg-app-pod.yml
│   ├── pg-app-pvc.yml
│   ├── pg-app-svc.yml
├── deploy.sh                 # Script to deploy app to Kubernetes and run migrations
├── package.json
├── .env.example
└── README.md
```

---

## 🧪 Local Development (Docker)

### Prerequisites

* [Docker](https://www.docker.com/)
* [Docker Compose](https://docs.docker.com/compose/)

### Steps

1. Build and run the services:

   ```bash
   docker-compose up --build
   ```

2. Run migrations inside the Node.js container:

   ```bash
   docker exec -it node-app npm run migrate:up
   ```

3. Visit the app:

   ```
   http://localhost:3000
   ```

---

## ☸️ Kubernetes Deployment

### Prerequisites

* Kubernetes cluster (minikube, Docker Desktop, or cloud)
* `kubectl` configured
* Docker image `node-app:latest` built and pushed to a registry accessible by your cluster

### 🚀 One-Command Deployment

Use the `deploy.sh` script:

```bash
./deploy.sh [namespace]
```

* Defaults to `todo` namespace if none is provided.
* Performs the following:

  * Creates namespace
  * Deploys PVCs, Services, and Pods
  * Waits for readiness
  * Runs DB migrations inside the Node.js pod

### Manual Kubernetes Steps

```bash
export NS=todo

kubectl create ns $NS

kubectl apply -f k8s/pg-app-pvc.yml -n $NS
kubectl apply -f k8s/node-app-pvc.yml -n $NS

kubectl apply -f k8s/pg-app-svc.yml -n $NS
kubectl apply -f k8s/node-app-svc.yml -n $NS

kubectl apply -f k8s/pg-app-pod.yml -n $NS
kubectl wait --for=condition=Ready pod/postgres -n $NS --timeout=90s

kubectl apply -f k8s/node-app-pod.yml -n $NS
kubectl wait --for=condition=Ready pod/node-app -n $NS --timeout=90s

kubectl exec -n $NS node-app -- npm run migrate:up
```

### Kubernetes Highlights

* Uses `initContainer` to wait for PostgreSQL readiness.
* Database connection via:

  ```yaml
  - name: DATABASE_URL
    value: postgresql://postgres:postgres@postgres.todo.svc.cluster.local:5432/postgres
  ```

---

## 🔄 Database Migrations

Using [`node-pg-migrate`](https://github.com/salsita/node-pg-migrate).

### Commands

```bash
npm run migrate:up       # Run all migrations
npm run migrate:down     # Revert last migration
npm run migrate -- --name create_some_table
```

### Example Migration

`1698765432345_create-todos-table.js` creates the `todos` table:

* `id`: Primary key
* `title`: Text
* `completed`: Boolean
* `created_at`: Timestamp

---

## 🌱 Environment Variables

`.env.example` includes:

| Variable       | Description                  | Example                                                |
| -------------- | ---------------------------- | ------------------------------------------------------ |
| `DATABASE_URL` | PostgreSQL connection string | `postgres://postgres:postgres@localhost:5432/postgres` |

---

## 📜 Scripts

| Script                 | Description                   |
| ---------------------- | ----------------------------- |
| `npm start`            | Start the Node.js application |
| `npm run migrate`      | Run `node-pg-migrate`         |
| `npm run migrate:up`   | Apply all migrations          |
| `npm run migrate:down` | Revert the last migration     |

---

## 🔐 Security Tips

* Don’t commit `.env` files with real credentials
* Use Kubernetes Secrets for sensitive data in production
* Limit access to PostgreSQL service inside the cluster

---

## 📦 Dependencies

* Node.js (v14+)
* PostgreSQL
* Docker & Docker Compose
* Kubernetes & kubectl
* `pg`, `node-pg-migrate`, `dotenv`

---

## 🙌🏼 Credits

* Original application logic and migrations are adapted from
  👉 [iam-veeramalla/cicd-for-databases](https://github.com/iam-veeramalla/cicd-for-databases)

* Dockerization and Kubernetes configuration by **me**

---