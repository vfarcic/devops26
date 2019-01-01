## Docker Registry

So far, we used [Docker Hub](https://hub.docker.com/) to store our images. If your are allowed to store images in the Cloud, that is probably the best option. You would need to make your repositories private and pay a fee for that to Docker. Paying for a service is often worth the money. You'll be saving your time by letting others take care of one of the third-party applications (Docker Registry). Each hour we save from doing mundane work on maintaining third-part applications, is an hour we can dedicate to our applications. After all, applications we develop are applications we hope to give us a competitive advantage. Third-party applications are there mostly to support ours.

Even though using container registry as a service (e.g., Docker Hub) means that we have one thing less to worry about, sometimes the price is too high. We might make a calculation that the total price we'd need to pay is higher than the cost if we'd do it alone. If a sum of the cost of underlying infrastructure together with the cost of the time required for setting up and maintaining the registry is still lower than what we'd pay to Docker, running your own registry might be a better option. On top of that we need to contemplate the situation in which the motivation for running a self-hosted registry is not financial, but driven by regulations or security. You might not be allowed to push your images to Docker Hub, or any other third-party managed registry. Such a restriction might be imposed by regulations of the country where your business operates, specifics of the industry you're in, or simply an internal top-level decision you cannot change (just yet). No matter the reasons, you might opt for the option to run your own registry.

There is one more important thing to take into account when evaluating whether to use third-party services or host them yourself. Kubernetes makes many of the tasks related to running and maintaining applications easier and more reliable than before. Container registry is not an exception. We can easily spin up our own registry. Helm will help us with the definition of the resources required for running a registry and Kubernetes will make sure that it is always up and running. Our effort will be relatively small.

This short discourse does not aim to convince to use registry-as-a-service, nor it tries to convince you to run it yourself. The choice is yours and it will depend on your specific use case. We'll choose to self-host a container registry only because I want to make you self-sufficient. Switching from self-hosted to a service maintained by others is always easier than the other way around.

We already know how to use Helm to search for Charts, so let's check whether a container registry is available in the official repository.

```bash
helm search registry
```

The output, limited to the relevant parts, is as follows.

```
NAME                   CHART VERSION APP VERSION DESCRIPTION
stable/docker-registry 1.4.2         2.6.2       A Helm chart for Docker Registry
...
```

Only one solution for container registry is available. Even though there are others in the market, [Docker Registry](https://docs.docker.com/registry/) is the most widely used free one. Most of the other solutions, like [Docker Trusted Registry](https://docs.docker.com/ee/dtr/) and JFrog' [Artifactory](https://www.jfrog.com/confluence/display/RTF/Docker+Registry), are commercial products. You should check them out since they, and many others, provide additional features that might be worth the investment. We, on the other hand, will stick with the free option and install Docker Registry.

You already used at least one Docker Registry. Even if this book is your first contact with containers, you used [Docker Hub](https://hub.docker.com/). Docker Registry is not much different from Docker Hub. The only significant difference is that the latter does not come with a UI. You'd need to install it separately. We won't need "pretty colors" on top of the registry, so we'll ignore UI altogether.

The primary purpose of any container registry is to store and distribute images. Anything else is a bonus built on those two requirements.

Before we install the registry, we should explore the available values and decide whether we should overwrite any of them.

```bash
helm inspect values \
    stable/docker-registry
```

The output, limited to the relevant parts, is as follows.

```yaml
...
image:
  repository: registry
  tag: 2.6.2
  ...
service:
  name: registry
  type: ClusterIP
  ...
resources: {}
  # We usually recommend not to specify default resources and to leave this as a conscious
  # choice for the user. This also increases chances charts run on environments with little
  # resources, such as Minikube. If you do want to specify resources, uncomment the following
  # lines, adjust them as necessary, and remove the curly braces after 'resources:'.
  # limits:
  #  cpu: 100m
  #  memory: 128Mi
  # requests:
  #  cpu: 100m
  #  memory: 128Mi
persistence:
  accessMode: 'ReadWriteOnce'
  enabled: false
  ...
secrets:
  haSharedSecret: ""
  htpasswd: ""
...
```

We should use a specific tag of the Registry, instead of relying on whatever is set in the Chart. So, we'll overwrite the `image.tag` variable and thus control the `registry` image we are about to install. Also, we'll have to make the registry accessible outside of the cluster. We can do that either through Ingress or by setting the `service.type` value to `NodePort`. We'll to the latter.

This Chart, just like most of the others, does not specify the `resources`, leaving it as a conscious choice users should make. We will specify both the `requests` and the `limits`.

We should persist Registry's state on disk by setting `persistence.enabled` to `true`. Assuming that your cluster has a default StorageClass, there's no need to change anything else related to persistence.

Finally, the last thing we should assue is authentication. We should set the `secrets.htpasswd` value. For the obvious security concerns, the value cannot be plain text username and password but it must be encrypted. The problem is to find out how to do that.

Let's `inspect` the whole Chart, instead of only the values.

```bash
helm inspect stable/docker-registry
```

The output, limited to the last few lines, is as follows.

```
...
To generate htpasswd file, run this docker command:
`docker run --entrypoint htpasswd registry:2 -Bbn user password > ./htpasswd`.
```

This time we retrieved the complete instructions and, luckily, the last few lines tell us how to encrypt the credentials in the format the Registry expects.

However, since we are using a Kubernetes cluster, and not a single Docker server, we'll transform the command suggested in the instructions with a `kubectl` equivalent. We'll create a Pod with a single container based on `registry:2` image. We'll use `--rm` to ensure that it is removed from the system once the process inside finishes executing. Also, we'll use `--restart Never` so that Kubernetes does not create a Deployment instead.

```bash
HTPASSWR=$(kubectl run --rm -it \
    registry-htpasswd \
    --image registry:2 \
    --restart Never \
    -- htpasswd -Bbn admin admin \
    | head -n 1) 

echo $HTPASSWR
```

The first command encrypted the credentials and stored the result in the `HTPASSWR` variable. We used `admin` as both the username and the password.

On my laptop, the output of the latter command is as follows.

```
admin:$2y$05$KTVgVnQ0uruDBZ/rbmtK9.fWU6VBe9EzOcBu1n27BO0wDzvMMfT4y
```

Let's take a quick look at the variables we'll use with the registry Chart.

```bash
cat helm/registry-values.yml
```

The output is as follows.

```yaml
image:
  tag: 2.6.2
service:
  type: LoadBalancer
resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 80m
    memory: 64Mi
persistence:
  enabled: true
```

You'll notice that the file does not contain the value for `secrets.htpasswd`. I could not know in advance what will it be on your laptop, so, we'll use `--set` to specify it. In a real-world scenario, you can put it to the YAML file since it is already encrypted.

W> Do NOT use the same `resources` in a production cluster. Depending on your load, the values should differ. Observe the actual memory and CPU usage over time and use that information to set the `resources`.

Now we have everything we need and we can proceed and install the Chart.

```bash
helm install stable/docker-registry \
    --namespace registry \
    --name registry \
    --values helm/registry-values.yml \
    --set secrets.htpasswd=$HTPASSWR

kubectl -n registry \
    rollout status deploy \
    registry-docker-registry
```

The latter command waited until the Deployment of the registry is rolled out.

The only thing left before we test whether we can indeed push and pull from the registry is to find out the address through which we can access it.

```bash
REGISTRY_ADDR=$(kubectl get \
    -n registry \
    svc registry-docker-registry \
    -o jsonpath="{.status.loadBalancer.ingress[0].hostname}"):5000

# TODO: Remove
# REGISTRY_ADDR=$LB_IP:$(kubectl get \
#     -n registry \
#     svc registry-docker-registry \
#     -o jsonpath="{.spec.ports[0].nodePort}")

echo $REGISTRY_ADDR
```

In my case, the output is as follows.

```
52.15.140.221:5000
```

Now we can try to push the image we built in the previous chapter. We want to confirm that the Registry works and is accessible from outside the cluster. If it is, we can give the address and the credentials to our developers who would use it to pull the images they need as well as to integrate the Registry into their continuous deployment pipelines.

I> Please consider commercial registries if you need a more elaborate authentication mechanism.

Please make sure that the commands that the `docker image` and `docker login` commands that follow require a Docker server. For your convenience, you can use Docker For Mac or Windows, unless you are using Linux as your desktop OS. Also, you'll have to replace `[...]` with your Docker Hub user.

```bash
DH_USER=[...]

docker image pull \
    $DH_USER/go-demo-3:1.0
```

We'll pulled the image from Docker Hub. That was faster than if we built it again. Next, we should tag the image using the registry address we retrieved a few moments earlier.

```bash
docker image tag \
    $DH_USER/go-demo-3:1.0 \
    $REGISTRY_ADDR/go-demo-3:1.0
```

The only thing left is to log into our registry and push the image.

```bash
docker login $REGISTRY_ADDR \
    -u admin -p admin

docker image push \
    $REGISTRY_ADDR/go-demo-3:1.0
```

That was easy. Assuming that you are already familiar to Docker and, to some extent, to Kubernetes, the usage of a registry should come naturally. Even if you never used one hosted by yourself, the principles are the same as when using Docker Hub. The only noticeable difference is that this time we're using registry address as the image prefix instead of our Docker Hub user.

Let's turn our attention to the need to have our Charts available in a repository.
