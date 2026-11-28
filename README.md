# Helm

Repository này chứa Helm charts và cấu hình GitOps cho các môi trường ShortLinks.

## Cấu trúc

- `charts/`: Helm chart của các API, UI và thành phần hạ tầng; cấu hình môi trường Dev nằm trong các file `values-dev.yaml` tương ứng.
- `argocd/`: AppProject, Application manifests, bootstrap và tài liệu/cấu hình liên quan đến Argo CD. Các Application Dev tham chiếu chart trong repository này.
- `.github/workflows/`: GitHub Actions cập nhật image tag Dev khi nhận sự kiện `repository_dispatch` từ repository dịch vụ. Hai workflow hiện có là `shortlink-api-image.yml` và `compareshop-api-image.yml`.

## Luồng cập nhật image Dev

Repository ShortLinkAPI và CompareShopAPI build, publish image rồi gửi `repository_dispatch` tới repository này. Workflow `shortlink-api-image.yml` cập nhật tag trong `charts/shortlink-api/values-dev.yaml`; `compareshop-api-image.yml` cập nhật tag trong `charts/compareshop-api/values-dev.yaml` (bao gồm worker). Các thay đổi tag được commit lên `main`. Argo CD theo dõi cấu hình ứng dụng Dev và tự đồng bộ các chart khi cấu hình thay đổi.

## Quy ước thay đổi

Mọi thay đổi hạ tầng và cấu hình trong repository này đi qua pull request để được xem xét. Không chỉnh sửa trực tiếp tài nguyên trên Kubernetes cluster.
