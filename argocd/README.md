# ArgoCD (single multi-source Application)

This directory is the GitOps root for the ShortLink homelab cluster.

- `project.yaml` is the `shortlink` AppProject. It allows the service repositories and
  the `shortlink-dev` namespace on the in-cluster API server.
- `bootstrap/dev-root-app.yaml` is the single `ShortLink` Application. Apply it once
  manually with `kubectl apply -n argocd -f argocd/bootstrap/dev-root-app.yaml`.
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

## Updating the Application

Keep one `Application` manifest and add or remove service sources there only when the scope
explicitly changes. Every source must use a unique Helm `releaseName`; otherwise charts that
use `.Release.Name` can collide on Kubernetes resource names.
