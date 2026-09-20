# ArgoCD (App-of-Apps)

This directory is the GitOps root for the ShortLink homelab cluster.

- `project.yaml` — the `shortlink` AppProject: restricts sync to this repo and to the
  `shortlink-dev` / `shortlink-sandbox` namespaces on the in-cluster API server.
- `bootstrap/` — the two root Applications (`shortlink-dev`, `shortlink-sandbox`), applied
  once manually to the cluster (`kubectl apply -n argocd -f argocd/bootstrap/`). They are the
  only manifests ArgoCD does not manage via GitOps itself (chicken-and-egg bootstrap step).
- `apps/dev/`, `apps/sandbox/` — each root Application watches its matching directory here
  (recursively). To deploy a new service to an environment, add its Helm `Application`
  manifest (pointing at that service's chart/values) as a file under the matching directory
  and push to `main`; the root Application picks it up automatically (automated sync +
  self-heal + prune are enabled).

Both root Applications target namespace `shortlink-dev` / `shortlink-sandbox` respectively
and create them on first sync (`CreateNamespace=true`).
