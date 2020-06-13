load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

HELM_BUILD_FILE = """
package(default_visibility = ["//visibility:public"])
exports_files( ["helm"] )
"""

def _helm3_repository_impl(repository_ctx):
    os_arch = repository_ctx.attr.os_arch

    os_name = repository_ctx.os.name.lower()
    if os_name.startswith("mac os"):
        os_arch = "darwin-amd64"
    else:
        os_arch = "linux-amd64"
    url = "https://get.helm.sh/helm-v{version}-{os_arch}.tar.gz".format(
        os_arch = os_arch,
        version = repository_ctx.attr.version,
    )
    repository_ctx.download_and_extract(
        url = url,
        sha256 = repository_ctx.attr.sha256,
        stripPrefix = os_arch
    )

    repository_ctx.file("BUILD.bazel", HELM_BUILD_FILE)

helm3_repository = repository_rule(
    _helm3_repository_impl,
    attrs = {
        "version": attr.string(
            default = "3.2.3",
            doc = "The helm3 version to use",
        ),
        "sha256": attr.string(
            doc = "The sha256 value for the binary",
        ),
        "os_arch": attr.string(
            doc = "The os arch value. If empty, autodetect it",
        ),
    },
)