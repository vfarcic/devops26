```bash
curl --version | grep LibreSSL

git clone \
    https://github.com/nicholasjackson/mtls-go-example

cd mtls-go-example

./generate.sh go-demo-7.com mysecretpass

# Answer with `y` to all questions

mkdir -p ../k8s-specs/certs/go-demo-7.com

mv \
    1_root \
    2_intermediate \
    3_application \
    4_client \
    ../k8s-specs/certs/go-demo-7.com
```