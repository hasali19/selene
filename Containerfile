# Renders the plymouth watermark from the SVG logo. Kept in its own stage,
# based on a small image with librsvg already packaged, so that neither it
# nor the font used to render the wordmark have to be installed (and then
# removed again) in the final image.
FROM docker.io/library/alpine:3.20 AS watermark
RUN apk add --no-cache rsvg-convert fontconfig
COPY branding/logo-dark.svg branding/Audiowide-Regular.ttf /branding/
RUN install -Dm644 /branding/Audiowide-Regular.ttf /usr/share/fonts/audiowide/Audiowide-Regular.ttf && \
    fc-cache -f && \
    rsvg-convert -w 225 /branding/logo-dark.svg -o /watermark.png

# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /
COPY system_files /system_files
COPY --from=watermark /watermark.png /system_files/usr/share/plymouth/themes/spinner/watermark.png

# Base Image
FROM ghcr.io/ublue-os/base-main:44
## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:testing
# FROM ghcr.io/ublue-os/aurora:stable
# FROM ghcr.io/ublue-os/bluefin-nvidia-open:stable
#
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:44
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

## KERNEL_VARIANT selects which kernel build.sh installs:
##   - fedora
##   - cachyos
ARG KERNEL_VARIANT=fedora
ENV KERNEL_VARIANT=${KERNEL_VARIANT}

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint
