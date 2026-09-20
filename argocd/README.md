# ArgoCD (App-of-Apps)

This directory is the GitOps root for the ShortLink homelab cluster.

- `project.yaml` — the `shortlink` AppProject: restricts sync to this repo (plus any
  `ShortLinksTB/*` service repo, see below) and to the `shortlink-dev` / `shortlink-sandbox`
  namespaces on the in-cluster API server.
- `bootstrap/` — the two root Applications (`shortlink-dev`, `shortlink-sandbox`), applied
  once manually to the cluster (`kubectl apply -n argocd -f argocd/bootstrap/`). They are the
  only manifests ArgoCD does not manage via GitOps itself (chicken-and-egg bootstrap step).
- `apps/dev/`, `apps/sandbox/` — each root Application watches its matching directory here
  (recursively). To deploy a new service to an environment, add its Helm `Application`
  manifest (pointing at that service's chart/values) as a file under the matching directory
  and push to `main`; the root Application picks it up automatically (automated sync +
  self-heal + prune are enabled).
- `templates/service-application.example.yaml` — copy-and-fill template for a new service's
  dev Application (see convention below).

Both root Applications target namespace `shortlink-dev` / `shortlink-sandbox` respectively
and create them on first sync (`CreateNamespace=true`).

## Branch convention for service Applications

This is the standing convention for every service repo (created later) in the ShortLink
workspace — follow it directly for the first service without asking again.

- **`dev` — auto-sync, active now.** When a service repo's code is pushed to its own `dev`
  branch, the service's `Application` manifest under `argocd/apps/dev/<service>.yaml` must
  point `spec.source.repoURL` at that service repo and set `spec.source.targetRevision: dev`,
  with `syncPolicy.automated.selfHeal: true` + `prune: true` already on (see the template).
  ArgoCD then redeploys `shortlink-dev` automatically every time that service's `dev` branch
  moves — no manual sync step.
- **`main` — reserved for prd, NOT deployed yet.** Every service repo's `main` branch is
  reserved for production, but prd is out of scope at this stage. Do not add any
  `Application`, App-of-Apps entry, or `argocd/apps/prd/` directory pointing at `main` until
  prd is explicitly scoped in a separate `[Promote][prd]` issue. When a service repo is
  created, only add its dev Application under `apps/dev/`.
- **`sandbox`** — unchanged from the SL-1 bootstrap; not part of this convention change.

### Adding the first service

1. Confirm the service's repo URL is covered by `project.yaml`'s `sourceRepos` (a
   `ShortLinksTB/*` wildcard is already in place, so a new `ShortLinksTB/<service>` repo is
   already allowed — no AppProject edit needed).
2. Copy `templates/service-application.example.yaml` to
   `argocd/apps/dev/<service>.yaml`, fill in the placeholders (`repoURL`, chart `path`,
   `values-dev.yaml`), and push to `main` of this repo.
3. Do not create an `apps/prd/` counterpart or point anything at the service's `main` branch
   at this stage.
