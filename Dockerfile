FROM registry.access.redhat.com/ubi8/ubi-minimal as base
USER root
RUN  microdnf update -y && \
     microdnf install --nodocs python3 unzip openssl && \
     microdnf clean all && \
     rm -rf /var/cache/yum

#-- Builder Image

FROM base as builder
USER root
RUN  microdnf install python3-pip
COPY requirements.txt requirements.txt
RUN  pip3 install -r requirements.txt --no-cache-dir 

#-- Deployment Image

FROM base
ARG TMP_USER_ID=1001
ARG TMP_USER_GROUP=1001

USER root

ADD . /usr/src/app

COPY ./configurations /usr/src/app/configurations
COPY /licenses/LA_en /licenses/LA_en

RUN chown -R ${TMP_USER_ID}:${TMP_USER_GROUP} /usr/src/app

COPY --from=builder /usr/local/lib64/python3.6/site-packages /usr/local/lib64/python3.6/site-packages
COPY --from=builder /usr/local/lib/python3.6/site-packages /usr/local/lib/python3.6/site-packages
COPY --from=builder /usr/lib64/python3.6/site-packages /usr/lib64/python3.6/site-packages
COPY --from=builder /usr/lib/python3.6/site-packages /usr/lib/python3.6/site-packages

USER ${TMP_USER_ID}

WORKDIR /usr/src/app

LABEL name="isc-car-connector-tenable" \
			vendor="tenable.io" \
			summary="tenable connector to Connect Asset/Risk (CAR)" \
			release="1.6" \
			version="1.6.0.0" \
			description="Tenable connector feeds CAR with assets informations and vulnerabilities."

CMD python3 main.py
