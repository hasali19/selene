# selene &nbsp; [![bluebuild build badge](https://github.com/hasali19/selene/actions/workflows/build.yml/badge.svg)](https://github.com/hasali19/selene/actions/workflows/build.yml)

See the [BlueBuild docs](https://blue-build.org/how-to/setup/) for quick setup instructions for setting up your own repository based on this template.

After setup, it is recommended you update this README to describe your custom image.

## Images

Two variants are built from the same set of packages and configuration, differing only in the kernel:

| Image | Kernel | Recipe |
| --- | --- | --- |
| `ghcr.io/hasali19/selene` | stock Fedora | `recipes/recipe.yml` |
| `ghcr.io/hasali19/selene-cachyos` | [CachyOS](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/) | `recipes/recipe-cachyos.yml` |

Everything shared between them lives in `recipes/common.yml`, so packages and configuration only need to be changed in one place.

## Installation

> [!WARNING]  
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable), try at your own discretion.

To rebase an existing atomic Fedora installation to the latest build (substitute `selene-cachyos` for `selene` below to use the CachyOS kernel image):

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/hasali19/selene:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/hasali19/selene:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

Switching between the two variants is the same rebase process, using the other image name.

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

If build on Fedora Atomic, you can generate an offline ISO with the instructions available [here](https://blue-build.org/how-to/generate-iso/#_top). These ISOs cannot unfortunately be distributed on GitHub for free due to large sizes, so for public projects something else has to be used for hosting.

## Verification

These images are signed with [Sigstore](https://www.sigstore.dev/)'s [cosign](https://github.com/sigstore/cosign). You can verify the signature by downloading the `cosign.pub` file from this repo and running the following command:

```bash
cosign verify --key cosign.pub ghcr.io/hasali19/selene
cosign verify --key cosign.pub ghcr.io/hasali19/selene-cachyos
```
