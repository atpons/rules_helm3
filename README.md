# rules_helm3
Bazel Rules for Helm 3

Run Helm Command with Install / Uninstall / Version

```console
$ bazel query "//..."
//sample/test-chart:test-chart.version.dryrun
//sample/test-chart:test-chart.version
//sample/test-chart:test-chart.uninstall.dryrun
//sample/test-chart:test-chart.uninstall
//sample/test-chart:test-chart.install.dryrun
//sample/test-chart:test-chart.install
//sample/test-chart:test-chart
...
```

## Sample

```console
$ bazel run //sample/test-chart:test-chart.install
INFO: Analyzed target //sample/test-chart:test-chart.install (1 packages loaded, 11 targets configured).
INFO: Found 1 target...
Target //sample/test-chart:test-chart.install up-to-date:
  bazel-bin/sample/test-chart/test-chart.install_kicker.sh
INFO: Elapsed time: 0.071s, Critical Path: 0.00s
INFO: 0 processes.
INFO: Build completed successfully, 3 total actions
INFO: Build completed successfully, 3 total actions
...
Release "testhelm" has been upgraded. Happy Helming!
NAME: testhelm
LAST DEPLOYED: Sun Jun 14 19:00:17 2020
NAMESPACE: default
STATUS: deployed
REVISION: 2
NOTES:
1. Get the application URL by running these commands:
  export POD_NAME=$(kubectl get pods --namespace default -l "app.kubernetes.io/name=test-chart,app.kubernetes.io/instance=testhelm" -o jsonpath="{.items[0].metadata.name}")
  echo "Visit http://127.0.0.1:8080 to use your application"
  kubectl port-forward $POD_NAME 8080:80
```
