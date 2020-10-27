#!/bin/bash
rm -rf generated
mkdir -p generated
helm template \
  --values ./deploy-values.yaml \
  --set image.tag=${VRT_VERSION} \
  --output-dir ./generated \
    ./charts/vrtuoso


