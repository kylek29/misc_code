# syntax=docker/dockerfile:1

## Original GUS Build by: testdasi/grafana-unraid-stack
FROM testdasi/grafana-unraid-stack:latest as gusbuilder
RUN /bin/sh -c echo "$(date "+%d.%m.%Y %T") Finished original GUS image." >> /build.info # buildkit


## Add On Layers by: ...
FROM gusbuilder AS buildnew
RUN /bin/sh -c echo "$(date "+%d.%m.%Y %T") Begin new commands .." >> /build.info \
    && mkdir -p /temp \
    && curl -sL "https://raw.githubusercontent.com/kylek29/misc_code/main/unRAID/Grafana-Unraid-Stack/fix_influxdb_2023.sh" -o /temp/fix.sh \
    && /bin/bash /temp/fix.sh && echo "$(date "+%d.%m.%Y %T") Finished with new commands .." >> /build.info

# Add Tini
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# Original Entrypoint & Healthchecks
ENTRYPOINT ["/tini", "--", "/static-ubuntu/grafana-unraid-stack/entrypoint.sh"]
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=2 CMD /static-ubuntu/grafana-unraid-stack/healthcheck.sh
