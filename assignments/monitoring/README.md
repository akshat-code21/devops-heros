# Session 20: Monitoring, Observability and GitOps

This assignment combines operational monitoring, observability signals, and
GitOps delivery with Argo CD. The practical work covers Kubernetes application
health, Prometheus metrics, Grafana visualization, Git as the desired state, and
continuous reconciliation into a Kubernetes cluster.

## Deliverables

- Monitoring demo and health checks
- Metrics, logs, and traces documentation
- Prometheus and Grafana demonstrations
- GitOps and Argo CD demonstrations
- Session 20 mini-project
- All supplied screenshots embedded below

The source exercises are in
[`session20-monitoring-observability-gitops`](../../session20-monitoring-observability-gitops/).

## 1. Monitoring

Monitoring answers: **Is the system healthy?** It collects known signals and
alerts when they cross an operational threshold.

### Signals to monitor

| Signal | Example | Why it matters |
| :--- | :--- | :--- |
| Metrics | Request rate, error rate, latency | Shows trends and system behavior over time |
| Logs | Startup messages, errors, dependency failures | Explains events emitted by an application |
| Alerts | Error rate above 5% | Notifies an operator when action is required |
| CPU utilization | Node or container CPU percentage | Identifies saturation and capacity pressure |
| Memory utilization | Working set, limits, OOM kills | Finds leaks and memory pressure |
| Application health | `/health`, readiness, liveness | Shows whether traffic can be served |

An alert should be actionable. For example:

```text
IF error_rate > 5% for 5 minutes
THEN alert the on-call team
```

Metrics show **how much** or **how often**; logs explain **what happened**;
health checks show whether the application is available to users.

### Kubernetes health checks

```bash
kubectl get pods
kubectl get pods -o wide
kubectl describe pod <pod-name>
kubectl logs <pod-name>
kubectl top pods
kubectl top nodes
```

Use `kubectl get` for current state, `describe` for conditions and events, logs
for application output, and `top` for resource consumption. A Pod being
`Running` does not necessarily mean it is ready to receive traffic.

## 2. Observability

Observability asks: **Why is the system behaving this way?** It combines enough
internal evidence to investigate known and unknown failure modes.

### Three pillars

#### Metrics

Metrics are numeric measurements over time:

```text
http_requests_total 1200
http_request_duration_seconds 0.25
process_cpu_seconds_total 2.03
```

They are efficient for dashboards, trends, capacity planning, and alert rules.

#### Logs

Logs are timestamped events emitted by applications and infrastructure:

```text
INFO  observability demo started
INFO  request received
INFO  health check OK
ERROR database timeout
```

They provide event context, but should be structured and correlated with a
request or trace ID where possible.

#### Traces

A trace follows one request across services and shows where time was spent:

```text
Browser -> API Gateway (20ms) -> Order Service (80ms)
				-> Database (600ms)
```

Traces are especially valuable for distributed systems where one slow dependency
can make the whole request slow.

### Why observability is required

Monitoring can report that latency is high. Observability helps identify whether
the cause is a database query, a downstream service, CPU saturation, a failed
deployment, or a network problem. It reduces guesswork and shortens incident
response time.

### Common tools

| Signal or function | Common tools |
| :--- | :--- |
| Metrics | Prometheus, CloudWatch, OpenTelemetry Metrics |
| Logs | Loki, Elasticsearch, CloudWatch Logs, Fluent Bit |
| Traces | Jaeger, Tempo, Zipkin, OpenTelemetry |
| Dashboards | Grafana, Kibana, CloudWatch dashboards |
| Kubernetes signals | `kubectl`, kube-state-metrics, metrics-server |

## 3. Kubernetes metrics, logs, and traces demo

Create a local Kind cluster and deploy the example application:

```bash
cd ../../session20-monitoring-observability-gitops/02-metrics-logs-traces
kind create cluster --name session20
kubectl apply -f k8s-demo/
kubectl get pods
kubectl logs deployment/session20-demo
kubectl describe deployment session20-demo
```

The demo produces application logs such as `Session 20 observability demo
started`, `Request received`, and `Health check OK`. Kubernetes resource status
and events provide the infrastructure context around those logs.

Clean up the demo:

```bash
kubectl delete -f k8s-demo/
kind delete cluster --name session20
```

## 4. Prometheus

Prometheus is primarily a metrics collection and time-series database. It uses a
pull model: Prometheus periodically scrapes an HTTP metrics endpoint and stores
the samples with labels.

```text
Application /metrics -> Prometheus scrape -> time-series database -> PromQL
```

Start the supplied Compose demo:

```bash
cd ../../session20-monitoring-observability-gitops/03-prometheus
docker compose up -d
docker compose ps
```

Open `http://localhost:9090` and query:

```promql
up
prometheus_http_requests_total
process_cpu_seconds_total
```

The query `up` returns `1` when the target is healthy, for example:

```text
up{instance="prometheus:9090", job="prometheus"} 1
```

Prometheus terms:

- **Target:** Endpoint Prometheus is configured to monitor.
- **Scrape:** HTTP collection of the target's metrics.
- **Metric:** Named numeric time-series value.
- **Label:** Key/value dimension attached to a metric.
- **PromQL:** Query language used to select and aggregate time-series data.

Stop the demo when finished:

```bash
docker compose down
```

## 5. Grafana

Grafana visualizes metrics stored in Prometheus:

```text
Prometheus = collect and store metrics
Grafana    = query and visualize metrics
```

Start the supplied stack:

```bash
cd ../../session20-monitoring-observability-gitops/04-grafana
docker compose up -d
docker compose ps
```

Open:

- Prometheus: `http://localhost:9090`
- Grafana: `http://localhost:3000`

For this classroom demo, the initial Grafana credentials are `admin` / `admin`.
Do not use default credentials in production.

Add a Prometheus data source in Grafana with the Docker Compose service URL:

```text
http://prometheus:9090
```

Create a panel with the query `up` and use a Stat or Time series visualization.
A value of `1` indicates that the Prometheus target is up. Dashboards can combine
CPU, memory, request rate, errors, and latency so an operator can identify a
problem quickly.

Stop the stack:

```bash
docker compose down
```

## 6. GitOps

GitOps manages application and infrastructure delivery through Git. Git stores
the desired declarative state; a controller compares it with the cluster's actual
state and reconciles differences.

```text
Developer -> Git commit/push -> Argo CD -> Kubernetes cluster
```

### Git as the source of truth

If Git contains:

```yaml
spec:
	replicas: 3
```

then three replicas are the desired state. If the cluster currently has two,
Argo CD works to reconcile the actual state to three.

Git provides history, review, diffs, auditability, collaboration, and rollback
points. Routine production changes should be made through reviewed Git changes,
not ad hoc `kubectl` edits.

### GitOps principles

- **Declarative configuration:** Describe the desired result rather than a list of
	imperative commands.
- **Version control:** Store manifests in Git with reviewable history.
- **Continuous reconciliation:** A controller repeatedly compares desired and
	actual state.
- **Rollback:** Revert or select a known-good Git revision.
- **Self-healing:** Manual drift is corrected back toward the declared state.

### Basic GitOps workflow

```text
Edit manifest -> git diff -> review -> git commit -> git push
-> Argo CD detects change -> sync -> Kubernetes rollout -> verify health
```

## 7. Argo CD demo

The Argo CD exercise is in
[`07-argocd`](../../session20-monitoring-observability-gitops/07-argocd/).
Create a local cluster and install Argo CD:

```bash
kind create cluster --name session20
kubectl create namespace argocd
kubectl apply -n argocd \
	-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl get pods -n argocd -w
```

Access the UI in another terminal:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
kubectl -n argocd get secret argocd-initial-admin-secret \
	-o jsonpath="{.data.password}" | base64 -d && echo
```

Apply the Argo CD Application manifest once:

```bash
kubectl apply -f app/argocd-application.yaml
kubectl get applications -n argocd
```

Argo CD then watches the configured Git repository and the `app` path. It applies
the Deployment and Service, creates the target namespace when configured, and
reports synchronization and health status.

Verify the application:

```bash
kubectl get pods -n session20
kubectl get deployment -n session20
kubectl get service -n session20
kubectl get applications -n argocd
kubectl port-forward svc/session20-gitops-app -n session20 9090:80
```

Open `http://localhost:9090` to see the NGINX application.

## 8. Mini-project

The mini-project is in
[`08-mini-project`](../../session20-monitoring-observability-gitops/08-mini-project/).
It combines a Namespace, Deployment, Service, and Argo CD Application.

```bash
cd ../../session20-monitoring-observability-gitops/08-mini-project
kind create cluster --name session20
kubectl create namespace argocd
kubectl apply -n argocd \
	-f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -f app/argocd-application.yaml
kubectl get applications -n argocd -w
kubectl get all -n session20
```

The captured workflow shows the Application becoming `Synced` and `Healthy`, the
workload reaching `Running`, and the Deployment scaling through Git changes.

To demonstrate GitOps scaling, change the replicas in the Git-managed Deployment,
commit, and push:

```bash
git add app/deployment.yaml
git commit -m "Scale application to three replicas"
git push
kubectl get deployment -n session20 -w
```

Do not use `kubectl scale` as the normal production workflow. Change Git and let
Argo CD reconcile. With `selfHeal: true`, manual drift is corrected toward the
Git-declared value.

Cleanup:

```bash
kubectl delete -f app/argocd-application.yaml
kind delete cluster --name session20
```

## Evidence

Every screenshot supplied for this assignment is embedded below.

### Kubernetes observability demo

![Observability demo deployment and Pod lifecycle](screenshots/02/01.png)
![Observability demo logs and cleanup](screenshots/02/02.png)

### Prometheus

![Prometheus Compose startup instance](screenshots/03/compose-up-instance.png)
![Prometheus browser query page](screenshots/03/prometheus-browser.png)
![Prometheus empty query](screenshots/03/query.png)
![Prometheus HTTP request metric](screenshots/03/http-requests-total.png)
![Prometheus process CPU metric](screenshots/03/process-cpu-seconds-total.png)

### Grafana

![Grafana and Prometheus Compose services](screenshots/04/compose-up.png)
![Grafana dashboard panel](screenshots/04/dashboard.png)
![Grafana browser home](screenshots/04/grafana-browser.png)
![Grafana Prometheus browser view](screenshots/04/prometheus-browser.png)

### GitOps introduction

![GitOps application deployment status](screenshots/05/01.png)

### Argo CD

![Argo CD installation and cluster setup](screenshots/07/01.png)
![Argo CD components starting](screenshots/07/02.png)
![Argo CD pods becoming ready](screenshots/07/03.png)
![Argo CD application registration](screenshots/07/04.png)
![Argo CD application sync progress](screenshots/07/05.png)
![Argo CD application and service access](screenshots/07/06.png)
![Argo CD application UI](screenshots/07/07.png)

### Session 20 mini-project

![Mini-project cluster and Argo CD installation](screenshots/08/01.png)
![Mini-project Argo CD installation progress](screenshots/08/02.png)
![Mini-project Argo CD pods ready](screenshots/08/03.png)
![Mini-project Application manifest applied](screenshots/08/04.png)
![Mini-project Application synced and healthy](screenshots/08/05.png)
![Mini-project Deployment scaling](screenshots/08/06.png)
![Mini-project application logs and running Pod](screenshots/08/07.png)


