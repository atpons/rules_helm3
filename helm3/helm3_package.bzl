def _helm3_package_impl(ctx):
  helm3 = ctx.executable.helm3
  deps = depset(ctx.files.srcs)
  tar_name = "%s.tgz" % ctx.attr.name
  out = ctx.actions.declare_file(tar_name)
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

def find_values_yaml_path(files, values_yaml):
  for file in files:
    if file.basename == values_yaml:
      return file.dirname
  return ""

def gen_helm_command_template(cmd, kube_context = "", dry_run = True):
  if dry_run:
    prefix = "#!/bin/bash\nROOT=$(pwd)\ncd @@VALUES_YAML_DIR@@\nls -al\necho DRY_RUN: $ROOT/@@HELM@@ "
  else:
    prefix = "#!/bin/bash\nROOT=$(pwd)\ncd @@VALUES_YAML_DIR@@\nls -al\n$ROOT/@@HELM@@ "
  if kube_context != "":
    prefix += "--kube-context %s " % (kube_context)
  if cmd == "install":
    return prefix + "upgrade @@RELEASE_NAME@@ . -i -f @@VALUES_YAML@@"
  if cmd == "uninstall":
    return prefix + "uninstall @@RELEASE_NAME@@"
  return prefix + "version"


def _helm3_command_impl(ctx):
  helm3 = ctx.executable.helm3
  deps = depset(ctx.files.srcs)
  template = ctx.actions.declare_file(ctx.label.name + "_tmpl.sh")
  values_yaml_dir = find_values_yaml_path(ctx.files.srcs, ctx.attr.values_yaml)
  out = ctx.actions.declare_file(ctx.label.name + "_kicker.sh")
  ctx.actions.write(template, gen_helm_command_template(ctx.attr.cmd, ctx.attr.kube_context, ctx.attr.dry_run))
  substitutions = {
    "@@HELM@@": helm3.path,
    "@@CMD@@": ctx.attr.cmd,
    "@@RELEASE_NAME@@": ctx.attr.release_name,
    "@@VALUES_YAML_DIR@@": values_yaml_dir,
    "@@VALUES_YAML@@": ctx.attr.values_yaml,
  }
  ctx.actions.expand_template(
    template = template,
    output = out,
    substitutions = substitutions,
    is_executable = True,
  )
  runfiles = ctx.runfiles(files = [helm3] + deps.to_list())
  return [DefaultInfo(runfiles = runfiles, executable = out)]

_helm3_command = rule(
  implementation = _helm3_command_impl,
  executable = True,
  attrs = {
    "srcs": attr.label_list(
        mandatory = True,
        allow_files = True
    ),
    "cmd": attr.string(
      default = "version",
    ),
    "dry_run": attr.bool(default=False),
    "release_name": attr.string(),
    "kube_context": attr.string(default = ""),
    "values_yaml": attr.string(default = "values.yaml"),
    "helm3": attr.label(
      default = "@helm3//:helm",
      allow_files = True,
      executable = True,
      cfg = "host",
    ),
  },
)

def helm3_release(name, **kwargs):
  _helm3_command(name = name + ".version", cmd = "version", **kwargs)
  _helm3_command(name = name + ".version.dryrun", cmd = "version", dry_run = True, **kwargs)
  _helm3_command(name = name + ".install", cmd = "install", **kwargs)
  _helm3_command(name = name + ".install.dryrun", cmd = "install", dry_run = True, **kwargs)
  _helm3_command(name = name + ".uninstall", cmd = "uninstall", **kwargs)
  _helm3_command(name = name + ".uninstall.dryrun", cmd = "uninstall", dry_run = True, **kwargs)