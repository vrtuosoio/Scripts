FROM alpine/k8s:1.13.12
RUN mkdir kubernetes
ADD . kubernetes
WORKDIR kubernetes
ENV K8_ENV dev
ENV COMMIT_ID latest