def _helm3_package_impl(ctx):
  helm3 = ctx.executable.helm3
  deps = depset(ctx.files.srcs)
  print(ctx.files.srcs)
  out = ctx.actions.declare_file("package.tgz")
  chart_path = find_chart_path(ctx.files.srcs)
  cmd = "%s package %s ; mv *tgz %s" % (helm3.path, chart_path, out.path)
  ctx.actions.run_shell(
    tools = [helm3],
    inputs = deps.to_list(),
    outputs = [out],
    command = cmd,
  )
  return [DefaultInfo(files = depset([out]))]

helm3_package = rule(
  implementation = _helm3_package_impl,
  attrs = {
    "srcs": attr.label_list(
        mandatory = True,
        allow_files = True
    ),
    "helm3": attr.label(
      default = "@helm3//:helm",
      allow_files = True,
      executable = True,
      cfg = "host",
    ),
  },
)

def find_chart_path(files):
  for file in files:
    if file.basename == "Chart.yaml":
      return file.dirname
  return ""