""" Rules and Macros to allow running kubebuilder from within bazel.
"""

def _kubebuilder_impl(ctx):
    """Implementation of the _kubebuilder rule.

    Args:
      ctx: the repository_context
    """

    out_file = ctx.actions.declare_file(ctx.label.name + ".bash")
    substitutions = {
        "@@KUBEBUILDER_SHORT_PATH@@": ctx.executable._kubebuilder.short_path,
    }
    ctx.actions.expand_template(
        template = ctx.file._runner,
        output = out_file,
        substitutions = substitutions,
        is_executable = True,
    )
    runfiles = ctx.runfiles(files = [ctx.executable._kubebuilder])
    return [DefaultInfo(
        files = depset([out_file]),
        runfiles = runfiles,
        executable = out_file,
    )]

_kubebuilder = rule(
    implementation = _kubebuilder_impl,
    attrs = {
        "_kubebuilder": attr.label(
            default = "@kubebuilder_sdk//:bin/kubebuilder",
            allow_single_file = True,
            cfg = "host",
            executable = True,
        ),
        "_runner": attr.label(
            default = "@rules_kubebuilder//kubebuilder:kubebuilder-runner.sh.template",
            allow_single_file = True,
        ),
    },
    executable = True,
)

def kubebuilder(**kwargs):
    """ Macro to allow running kubebuilder from within Bazel.

    Args:
      **kwargs: the arguments to the macro.
    """
    tags = kwargs.get("tags", [])
    if "manual" not in tags:
        tags.append("manual")
        kwargs["tags"] = tags
    _kubebuilder(**kwargs)
