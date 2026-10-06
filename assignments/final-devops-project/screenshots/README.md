# Required Submission Screenshots Checklist

Save your proof screenshots in this directory using the filenames below:

- `01-pytest-pass.png`: Terminal output showing `pytest -v` passing 8/8 tests.
- `02-docker-compose-running.png`: Terminal showing `docker compose ps` with postgres, backend, and frontend healthy.
- `03-app-browser.png`: Browser window at `http://localhost:3000` showing the TaskBoard UI loaded.
- `04-github-commits.png`: Git log or GitHub repository commit history showing 10+ descriptive commits.
- `05-github-actions-pipeline.png`: GitHub Actions run page showing all pipeline stages green.
- `06-ghcr-packages.png`: GitHub Packages / GHCR page showing published images with Git commit SHA tags.
- `07-trivy-scan.png`: GitHub Actions Trivy step log showing vulnerability scan results.
- `08-terraform-plan.png`: Terminal output showing `terraform plan` execution with proposed AWS resources.
- `09-aws-eks-console.png` *(or `09-terraform-destroy.png`)*: AWS Console showing VPC/EKS or terminal showing clean teardown.
- `10-k8s-pods-running.png`: Terminal showing `kubectl get pods -n taskboard` with all pods in Running state.
- `11-helm-list.png`: Terminal showing `helm list -n taskboard` in deployed state.
- `12-ingress-access.png`: Browser accessing the application via Ingress hostname (`taskboard.local`).
- `13-prometheus-metrics.png`: Terminal `curl http://<backend>:8000/metrics` or Prometheus Targets page (`UP`).
- `14-grafana-dashboard.png`: Grafana dashboard showing live application metrics (requests, latency).
- `15-argocd-synced.png`: ArgoCD UI showing TaskBoard application as `Synced` and `Healthy`.
- `16-troubleshooting-fix.png`: Terminal showing pod recovering to `Running` after applying the fix.
