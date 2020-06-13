def _helm3_version_impl(ctx):
  helm3 = ctx.executable.helm3
  out = ctx.actions.declare_file("version.out")
  ctx.actions.run_shell(
    tools = [helm3],
    outputs = [out],
    command = "%s version > %s" % (helm3.path, out.path),
  )
  return [DefaultInfo(files = depset([out]))]

helm3_version = rule(
  implementation = _helm3_version_impl,
  attrs = {
    "helm3": attr.label(
      default = "@helm3//:helm",
      allow_files = True,
      executable = True,
      cfg = "host",
    ),
  },
)