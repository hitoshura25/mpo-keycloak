ARG KC_VERSION=26.2.4

FROM quay.io/keycloak/keycloak:${KC_VERSION} AS builder

ARG KC_VERSION=26.2.4
ARG KC_HEALTH_ENABLED=true
ARG KC_METRICS_ENABLED=true
ARG KC_DB=postgres
ARG KC_HOSTNAME_PATH=auth
ARG KC_HTTP_RELATIVE_PATH=/auth

ENV KC_VERSION=${KC_VERSION}
ENV KC_HEALTH_ENABLED=${KC_HEALTH_ENABLED}
ENV KC_DB=${KC_DB}
ENV KC_HOSTNAME_PATH=${KC_HOSTNAME_PATH}
ENV KC_HTTP_RELATIVE_PATH=${KC_HTTP_RELATIVE_PATH}

RUN /opt/keycloak/bin/kc.sh build

# Installing additional RPM packages https://www.keycloak.org/server/containers
FROM registry.access.redhat.com/ubi9:9.4 AS ubi-micro-build
RUN mkdir -p /mnt/rootfs
RUN dnf install -y curl-7.76.1 --installroot /mnt/rootfs  --releasever 9 --setopt install_weak_deps=false --nodocs && \
    dnf --installroot /mnt/rootfs clean all && \
    rpm --root /mnt/rootfs -e --nodeps setup

FROM quay.io/keycloak/keycloak:${KC_VERSION}

COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --from=ubi-micro-build /mnt/rootfs /

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]