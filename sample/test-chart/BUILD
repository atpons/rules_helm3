load("@com_github_atpons_rules_helm3//helm3:helm3_package.bzl", "helm3_package", "helm3_release")
package(default_visibility = ["//visibility:public"])

helm3_package(
  name = "test-chart",
  srcs = glob(["*"])
)

helm3_release(
  name = "test-chart",
  release_name = "testhelm",
  values_yaml = "values.yaml",
  kube_context = "docker-for-desktop",
  srcs = glob(["**"])
)