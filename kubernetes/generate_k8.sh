rm -rf generated
mkdir -p generated
helm template \
  --values ./deploy-values.yaml \
  --set image.tag=${COMMIT_ID} \
  --output-dir ./generated \
    ./charts/vrtuoso


