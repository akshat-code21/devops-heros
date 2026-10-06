# Session 14: Kubernetes Troubleshooting

This assignment documents a repeatable Kubernetes troubleshooting workflow and
hands-on investigations of common Pod, image, scheduling, Service, DNS, and
configuration failures.

## Deliverables

- Practical use of the required `kubectl` commands
- Problem statement, investigation, root cause, fix, and verification for each issue
- Before and after output
- Mini-project implementation
- Screenshot evidence

## Prerequisites

```bash
minikube start
kubectl get nodes
kubectl version --short
```

The exact Pod names, IP addresses, timestamps, and event wording vary by cluster.
The examples below use the manifests in
[`session-14-kubernetes-troubleshooting`](../../session-14-kubernetes-troubleshooting/).

## Troubleshooting workflow

Use this sequence instead of changing YAML immediately:

```text
Observe -> identify resource -> inspect status -> describe -> check events
-> read logs -> exec into the container -> test connectivity
-> identify root cause -> fix -> verify
```

Useful first questions are:

1. Is the resource created in the namespace I am inspecting?
2. Is the Pod scheduled and is its container ready?
3. What do the Events and container logs say?
4. Do the Service selector and Pod labels match?
5. Can the application respond from inside the Pod?

## Task 1: Kubernetes commands

### `kubectl get`

Use `get` for a quick current-state summary:

```bash
kubectl get pods
kubectl get deployments
kubectl get services
kubectl get nodes
kubectl get all
kubectl get pods -w
```

The important columns are `READY`, `STATUS`, `RESTARTS`, and `AGE`. For example,
`0/1 CrashLoopBackOff` immediately indicates that the container is repeatedly
starting and failing, but it does not explain why.

### `kubectl get -o wide`

Use the wide output when node placement and networking matter:

```bash
kubectl get pods -o wide
```

This adds the Pod IP, node, nominated node, and readiness gates. The Pod IP and
node are useful when investigating scheduling, Pod networking, or a node-specific
problem.

### `kubectl describe`

Use `describe` for resource details and the most useful first diagnostic view:

```bash
kubectl describe pod <pod-name>
kubectl describe deployment <deployment-name>
kubectl describe service <service-name>
kubectl describe node <node-name>
```

Inspect `Status`, `Conditions`, container `State`, `Last State`, `Restart Count`,
image, labels, mounts, and especially the `Events` section at the bottom.

### `kubectl logs`

Use logs to read the application output written to standard output or standard
error:

```bash
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs <pod-name> --previous
kubectl logs <pod-name> -c <container-name>
```

`--previous` is essential when a crashing container has already restarted. The
logs lab produced messages such as `Application started`, `Database connection
successful`, and `Application is healthy`.

### `kubectl exec`

Use `exec` to test the application from inside a running container:

```bash
kubectl exec -it <pod-name> -- bash
kubectl exec <pod-name> -- hostname
kubectl exec <pod-name> -- ls /usr/share/nginx/html
kubectl exec <pod-name> -- cat /etc/hosts
```

Inside an NGINX container, `curl localhost` or `wget -qO- http://localhost`
checks whether the application itself is responding. If localhost works but the
Service does not, investigate the Service, endpoints, port, selector, or DNS.

`exec` requires a running container. For a container that exits immediately, use
`describe` and `logs --previous` instead.

### `kubectl events`

Events show what the control plane and kubelet attempted:

```bash
kubectl get events
kubectl get events --sort-by=.lastTimestamp
kubectl events
kubectl events --watch
kubectl events --for pod/<pod-name>
kubectl get events --field-selector type=Warning
```

Typical useful reasons include `FailedScheduling`, `Failed`, `BackOff`,
`Pulling`, `Pulled`, `Created`, and `Started`. Events are retained for a limited
period, so collect them while reproducing the problem.

### `kubectl explain`

Use `explain` to inspect Kubernetes API fields without guessing their names or
nesting:

```bash
kubectl explain pod.spec.containers
kubectl explain pod.spec.containers.resources
kubectl explain pod.spec.nodeSelector
kubectl explain service.spec.selector
kubectl explain deployment.spec.template.spec
```

This is especially useful for checking whether a field belongs under the Pod,
container, or Service specification before editing a manifest.

### `kubectl top`

Use `top` for current CPU and memory usage. It requires Metrics Server:

```bash
minikube addons enable metrics-server
kubectl top nodes
kubectl top pods
kubectl top pod <pod-name> --containers
```

High usage can explain slow responses or OOM kills. Compare usage with the
resource requests and limits shown by `kubectl describe pod`.

## Task 2: Common troubleshooting issues

Each investigation follows the required pattern: identify the symptom,
investigate, find the root cause, fix it, and verify the result.

### CrashLoopBackOff

**Problem:** The `crash-demo` Pod repeatedly starts and exits.

**Identify and investigate:**

```bash
cd ../../session-14-kubernetes-troubleshooting/06-crashloopbackoff
kubectl apply -f broken-pod.yaml
kubectl get pod crash-demo
kubectl describe pod crash-demo
kubectl logs crash-demo
kubectl logs crash-demo --previous
```

The status becomes `CrashLoopBackOff`; the logs show `Something went wrong!` and
the manifest contains `exit 1`.

**Root cause:** The container command deliberately exits with a failure code, so
the kubelet restarts the container and applies backoff between attempts.

**Fix and verify:**

```bash
kubectl delete pod crash-demo
kubectl apply -f fixed-pod.yaml
kubectl get pod crash-demo
kubectl logs crash-demo
```

The fixed command prints `Application is healthy` and sleeps, so the Pod reaches
`1/1 Running`.

### ImagePullBackOff and ErrImagePull

**Problem:** The `image-demo` Pod cannot start because its image cannot be pulled.
`ErrImagePull` is the initial pull failure; `ImagePullBackOff` means Kubernetes is
retrying with increasing delay.

```bash
cd ../../session-14-kubernetes-troubleshooting/07-imagepullbackoff
kubectl apply -f broken-pod.yaml
kubectl get pod image-demo
kubectl describe pod image-demo
kubectl get events --sort-by=.lastTimestamp
```

The Events show a failed pull, and the manifest requests
`nginx:this-image-does-not-exist`.

**Root cause:** The image tag does not exist. Other possible causes include a
private registry without credentials, registry connectivity, or a typo in the
repository name.

**Fix and verify:**

```bash
kubectl delete pod image-demo
kubectl apply -f fixed-pod.yaml
kubectl get pod image-demo
```

The fixed manifest uses `nginx:1.27`, and the Pod reaches `1/1 Running`.

### Pending

**Problem:** The `pending-demo` Pod is created but is never scheduled.

```bash
cd ../../session-14-kubernetes-troubleshooting/08-pending-pods
kubectl apply -f broken-pod.yaml
kubectl get pod pending-demo
kubectl describe pod pending-demo
kubectl get nodes
kubectl get events --sort-by=.lastTimestamp
```

**Root cause:** The Pod requests the node selector
`kubernetes.io/hostname: node-that-does-not-exist`, while the available Minikube
node has a different name. `PodScheduled` is false and Events report
`FailedScheduling`.

**Fix and verify:**

```bash
kubectl delete pod pending-demo
kubectl apply -f fixed-pod.yaml
kubectl get pod pending-demo
kubectl get pod pending-demo -o wide
```

The fixed manifest removes the invalid selector and the Pod becomes `1/1 Running`.
Other Pending causes include insufficient CPU or memory, taints, affinity rules,
and unavailable PVCs, so always use the Events message rather than assuming the
cause.

### ContainerCreating

**Problem:** A Pod can temporarily show `ContainerCreating` while Kubernetes is
pulling an image, mounting volumes, configuring networking, or creating the
container sandbox.

```bash
kubectl get pod <pod-name> -w
kubectl describe pod <pod-name>
kubectl get events --sort-by=.lastTimestamp
```

**Investigation and root cause:** Check whether Events show image pulling, volume
mount errors, CNI errors, or secret/configuration failures. In the image exercise,
the early `ContainerCreating` state transitions to `ErrImagePull` because the
requested image tag is invalid.

**Verification:** A healthy Pod transitions through `ContainerCreating` to
`Running`; a Pod that remains there requires investigation of the latest Events,
image availability, volumes, service account, and node health.

### Service connectivity issues

**Problem:** A Service exists, but requests do not reach the application.

```bash
kubectl get pods --show-labels
kubectl get service web-service
kubectl describe service web-service
kubectl get endpoints web-service
```

The Service selector must match the labels on the selected Pods. In the service
lab, the Pods use `app: web` while the broken Service selects
`app: web-ahsgdf`, so the endpoint list is `<none>`.

**Root cause:** A selector/label mismatch prevents EndpointSlices from selecting
the application Pods.

**Fix and verify:** Apply the corrected `service.yaml`, then check that endpoints
contain Pod IPs and test from another Pod:

```bash
kubectl apply -f service.yaml
kubectl get endpoints web-service
kubectl exec dns-test -- wget -qO- http://web-service
```

The NGINX HTML response verifies Service routing.

### DNS issues

**Problem:** A client cannot resolve or reach a Service by name.

```bash
kubectl apply -f dns-test-pod.yaml
kubectl get pod dns-test
kubectl exec dns-test -- cat /etc/resolv.conf
kubectl exec -it dns-test -- nslookup web-service
kubectl exec -it dns-test -- nslookup web-service.default.svc.cluster.local
kubectl get pods -n kube-system
kubectl logs -n kube-system -l k8s-app=kube-dns
```

Kubernetes Service DNS uses the form
`service-name.namespace.svc.cluster.local`. The captured test resolved
`web-service.default.svc.cluster.local` through the cluster DNS Service at
`10.96.0.10`.

**Root cause checks:** Confirm the Service exists in the expected namespace, the
name is spelled correctly, CoreDNS is running, and the client Pod has the expected
nameserver and search domains.

**Verification:** Successful `nslookup` followed by
`wget -qO- http://web-service` proves DNS resolution and HTTP connectivity.

### Pod networking issues

Separate the network path into layers:

```text
container process -> Pod IP -> Service ClusterIP -> Service endpoints -> target Pod
```

Investigate each layer:

```bash
kubectl get pods -o wide
kubectl exec <pod-name> -- wget -qO- http://localhost
kubectl exec <client-pod> -- wget -qO- http://<pod-ip>:80
kubectl get service <service-name>
kubectl get endpoints <service-name>
kubectl exec <client-pod> -- nslookup <service-name>
```

If localhost fails, inspect the application and container port. If the Pod IP
works but the Service fails, inspect selectors, endpoints, and target ports. If
the Service name fails, inspect DNS and namespace. This layered method avoids
mistaking a Service problem for an application or CNI problem.

### Configuration issues

Configuration failures can come from a bad command, image, port, selector,
environment variable, ConfigMap, Secret, volume, or probe. Use the manifest and
the live object together:

```bash
kubectl get pod <pod-name> -o yaml
kubectl describe pod <pod-name>
kubectl logs <pod-name> --previous
kubectl explain pod.spec.containers
kubectl explain service.spec.selector
```

Compare the intended configuration with the live Pod spec, then fix the owning
manifest and reapply it. Verify both resource status and application behavior;
`Running` alone does not prove that traffic is working.

## Task 3: Mini-project

The mini-project deploys an NGINX Deployment and ClusterIP Service, then introduces
two faults for investigation:

- `project-broken-pod` uses the nonexistent image tag
	`nginx:this-tag-does-not-exist`.
- `troubleshooting-service` selects `app: wrong-app`, while the Deployment Pods
	use `app: troubleshooting-app`.

### Deploy the working application

```bash
cd ../../session-14-kubernetes-troubleshooting/mini-project
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
kubectl get pods
kubectl get service
kubectl get pods -o wide
kubectl get endpoints troubleshooting-service
```

The Deployment creates two running Pods. The Service should have two endpoints
after its selector is corrected to `app: troubleshooting-app`.

Verify the application from inside a Pod:

```bash
POD_NAME=$(kubectl get pods -l app=troubleshooting-app \
	-o jsonpath='{.items[0].metadata.name}')
kubectl exec -it "$POD_NAME" -- bash
curl localhost
exit
```

### Mini-project investigation: broken image

```bash
kubectl apply -f broken-pod.yaml
kubectl get pod project-broken-pod
kubectl describe pod project-broken-pod
kubectl get events --sort-by=.lastTimestamp
```

**Before:** `project-broken-pod` is `0/1 ErrImagePull` or
`ImagePullBackOff`. Events report that the manifest for
`nginx:this-tag-does-not-exist` was not found.

**Root cause:** The image tag is invalid.

**Solution and after state:** Delete the broken Pod or update it to use a valid
image, then verify:

```bash
kubectl delete pod project-broken-pod
kubectl run project-broken-pod --image=nginx:1.27
kubectl get pod project-broken-pod
kubectl logs project-broken-pod
```

The corrected Pod reaches `1/1 Running`. In a real application, the durable fix
belongs in the Deployment or source manifest rather than a one-off `kubectl run`.

### Mini-project investigation: Service selector

```bash
kubectl get pods --show-labels
kubectl describe service troubleshooting-service
kubectl get endpoints troubleshooting-service
```

**Before:** The Service has selector `app=wrong-app` and its endpoints are
`<none>`, even though the application Pods are `1/1 Running`.

**Root cause:** The Service selector does not match the Pod label
`app=troubleshooting-app`.

**Solution and after state:** Change the Service selector in `service.yaml` to
`app: troubleshooting-app` and reapply it:

```bash
kubectl apply -f service.yaml
kubectl get endpoints troubleshooting-service
kubectl exec "$POD_NAME" -- wget -qO- http://troubleshooting-service
```

The endpoints now contain the two Pod IPs and the request returns NGINX HTML.

## Troubleshooting summary

| Problem | Before | Investigation | Root cause | Fix and verification |
| :--- | :--- | :--- | :--- | :--- |
| CrashLoopBackOff | Pod restarts and exits | `describe`, `logs`, `logs --previous` | Command exits with code 1 | Apply fixed command; Pod runs and logs healthy output |
| ErrImagePull / ImagePullBackOff | Image cannot start | `describe`, Events | Image tag does not exist | Use `nginx:1.27`; Pod becomes Running |
| Pending | `PodScheduled: False` | `describe`, `get nodes`, Events | Invalid node selector | Remove selector; Pod schedules and runs |
| ContainerCreating | Container not ready yet | Watch status and Events | Image, volume, network, or runtime setup | Resolve the specific Event; Pod reaches Running |
| Service connectivity | Service has no endpoints | Labels, selector, endpoints | Selector does not match Pod labels | Correct selector; endpoints and HTTP response appear |
| DNS | Name does not resolve | `resolv.conf`, `nslookup`, CoreDNS logs | Wrong name/namespace or DNS failure | Use full Service DNS name and repair DNS if needed |
| Pod networking | One network layer fails | localhost, Pod IP, Service, DNS tests | Application, route, Service, or DNS layer issue | Fix the failing layer and retest |
| Configuration | Live behavior differs from intent | Live YAML, describe, explain, logs | Invalid field or value | Correct manifest and verify behavior |

## Evidence

### `kubectl` command labs

![kubectl get and wide output](screenshots/01/01.png)

![kubectl describe output](screenshots/02/01.png)
![kubectl describe conditions and events](screenshots/02/02.png)
![kubectl describe container details](screenshots/02/03.png)
![kubectl describe events](screenshots/02/04.png)

![kubectl logs output](screenshots/03/01.png)

![kubectl exec shell and application test](screenshots/04/01.png)
![kubectl exec NGINX configuration test](screenshots/04/02.png)

![kubectl events output](screenshots/05/01.png)
![kubectl events sorted by timestamp](screenshots/05/02.png)

### Common failure investigations

![CrashLoopBackOff investigation and previous logs](screenshots/06/01.png)
![CrashLoopBackOff fixed Pod and healthy logs](screenshots/06/02.png)

![ImagePullBackOff investigation](screenshots/07/01.png)
![ErrImagePull events and fixed Pod](screenshots/07/02.png)

![Pending Pod investigation](screenshots/08/01.png)
![Pending Pod scheduling event](screenshots/08/02.png)

![Service and DNS working path](screenshots/09/01.png)
![Service endpoints and CoreDNS output](screenshots/09/02.png)
![DNS lookup from a test Pod](screenshots/09/03.png)
![Broken Service with no endpoints](screenshots/09/04.png)
![Service selector mismatch](screenshots/09/05.png)

### Mini-project

![Mini-project application and Service](screenshots/mini-project/01.png)
![Mini-project application Pod details](screenshots/mini-project/02.png)
![Mini-project broken image status](screenshots/mini-project/03.png)
![Mini-project broken image Events](screenshots/mini-project/04.png)
![Mini-project Service selector mismatch](screenshots/mini-project/05.png)
![Mini-project corrected application Pods](screenshots/mini-project/06.png)
![Mini-project corrected Service endpoints](screenshots/mini-project/07.png)
![Mini-project NGINX response from inside Pod](screenshots/mini-project/08.png)
![Mini-project logs and container investigation](screenshots/mini-project/09.png)
![Mini-project final Service inspection](screenshots/mini-project/10.png)



The key lesson is that a Kubernetes status is a symptom. `get` identifies the
symptom, `describe` and Events explain control-plane behavior, logs explain the
application, `exec` tests from inside the Pod, and endpoint/DNS checks validate
the network path.
