# ArgoCD (single multi-source Application)

This directory is the GitOps root for the ShortLink homelab cluster.

- `project.yaml` is the `shortlink` AppProject. It allows the service repositories and
  the `shortlink-dev` namespace on the in-cluster API server.
- `bootstrap/dev-root-app.yaml` is the single logical `ShortLink` Application. Its Kubernetes
  resource name is `shortlink` because Application metadata names must be lowercase RFC-1123
  identifiers. Apply it once manually with `kubectl apply -n argocd -f argocd/bootstrap/dev-root-app.yaml`.
- `apps/dev/` intentionally contains no child Applications. AdminUI and ShortLinkUI are
  rendered as two sources, and therefore two resource subtrees, of `ShortLink`.

`ShortLink` uses ArgoCD multi-source Application support:

- `ShortLinksTB/AdminUI.git`, `charts/adminui`, `targetRevision: dev`, Helm release
  `adminui-dev`.
- `ShortLinksTB/ShortLinkUI.git`, `charts/shortlinkui`, `targetRevision: dev`, Helm release
  `shortlinkui-dev`.

Both sources target `shortlink-dev` and share automated sync, prune, self-heal, and
`CreateNamespace=true`. Explicit release names preserve the resource names used by the
former child Applications while ArgoCD presents them under the single `ShortLink` tree.

## Branch and routing convention

Both service sources follow the dev convention:

- **`dev` - auto-sync, active now.** A push to either service repository's `dev` branch is
  reconciled by the corresponding source of `ShortLink`.
- **`main` - reserved for prd.** Do not add a production source or `argocd/apps/prd/` until
  a separate `[Promote][prd]` issue explicitly scopes it.
- Existing ingress/DNS configuration is outside these Application manifests. This change does
  not rename or replace `argocd-shortlink-dev.giamha.online`,
  `admin-shortlink-dev.giamha.online`, or `app-shortlink-dev.giamha.online`.

## Application convention

Stateless ShortLink workloads remain sources of the `shortlink` Application in the
`shortlink-dev` namespace. Stateful shared dependencies are deliberately isolated in their own
`shortlink-infra-dev` Application and `shortlink-infra-dev` namespace. This creates an
independent Argo CD prune/self-heal boundary so a workload-source change cannot remove dependency
PVCs.

`shortlink-infra-dev` is defined at `argocd/apps/dev/shortlink-infra-dev.yaml` and renders the
chart at `charts/shortlink-infra-dev` from this repository's `main` branch. It is ClusterIP-only;
it must not be given an Ingress or public DNS entry.

`headlamp-dev` is defined at `argocd/apps/dev/headlamp.yaml`. It renders the official Headlamp
chart into the dedicated `headlamp` namespace. Its ServiceAccount `headlamp-admin` is bound to the
built-in `cluster-admin` ClusterRole (SL-32, owner-approved, reverses the SL-17 least-privilege
decision) so Headlamp works as a full cluster management UI. Because Headlamp is publicly exposed
via Cloudflare Tunnel and its bearer token now equals full cluster control, only mint short-lived
tokens (`kubectl -n headlamp create token headlamp-admin --duration=8h`) and never record one in
an issue or PR. Cloudflare Tunnel routing is managed outside this manifest and targets the
cluster-local Service; a follow-up tracks putting Cloudflare Access in front of the public
hostname.

## Updating the Application

Keep workload sources in the existing Application, and keep stateful dependencies in the dedicated
infrastructure Application. Every Helm source must use a unique release name.
