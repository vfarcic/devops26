## Hands-On Time

---

# Promoting To Production


## Promoting To Production

---

```bash
git checkout master

jx get applications -e staging

VERSION=[...]

jx promote go-demo-6 --version $VERSION --env production -b

PROD_ADDR=$(kubectl -n jx-production get ing go-demo-6 \
    -o jsonpath="{.spec.rules[0].host}")

curl "http://$PROD_ADDR/demo/hello"

# TODO: Increase the number of replicas of the DB and add HPA to the app.
```

When you think about it, there might be nothing to test in the production environment. If we run all sorts of application specific tests we know that the application in isolation behaves as expected. System-wide tests executed after deploying to the staging environment can confirm that our application behaves correctly when plugged into the system as a whole. What's left to check after we reach the production environment?

As a matter of fact, there are many validations we should perform after deploying a new release to production. I would even argue that production-specific tests should run all the time. However, they are not directly related to the pipeline that deploys new releases to production.