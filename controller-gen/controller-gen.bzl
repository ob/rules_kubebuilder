""" Rules to run controller-gen
"""

load("@io_bazel_rules_go//go:def.bzl", "go_context", "go_path")
load("@io_bazel_rules_go//go/private:providers.bzl", "GoPath")

def _controller_gen_action(ctx, cg_cmd, outputs, output_path):
    """ Run controller-gen in the sandbox.

    This function sets up the necessary dependencies in the Bazel sandbox to
    run controller-gen (which compiles Go code), then creates an action that
    runs it.

    Args:
      ctx         - The Rule's context
      cg_cmd      - The controller-gen subcommand to run
      output      - List of File/Dir produced by the action (delcare dependencies)
      output_path - Path of outputs
    """

    # TODO: what should GOPATH be if there are no dependencies?
    go_ctx = go_context(ctx)
    cg_info = ctx.toolchains["@rules_kubebuilder//controller-gen:toolchain"].controller_gen_info
    gopath = ""
    if ctx.attr.gopath_dep:
        gopath = "$(pwd)/" + ctx.bin_dir.path + "/" + ctx.attr.gopath_dep[GoPath].gopath

    cmd = """
          source <($PWD/{godir}/go env) &&
          export PATH=$GOROOT/bin:$PWD/{godir}:$PATH &&
          export GOPATH={gopath} &&
          mkdir -p .gocache &&
          export GOCACHE=$PWD/.gocache &&
          {cmd} {args}
        """.format(
        godir = go_ctx.go.path[:-1 - len(go_ctx.go.basename)],
        gopath = gopath,
        cmd = "$(pwd)/" + cg_info.controller_gen_bin.path,
        args = "{cg_cmd} paths={{{files}}} output:dir={outputpath}".format(
            cg_cmd = cg_cmd,
            files = ",".join([f.path for f in ctx.files.srcs]),
            outputpath = output_path,
        ),
    )
    ctx.actions.run_shell(
        mnemonic = "ControllerGen",
        outputs = outputs,
        inputs = _inputs(ctx, go_ctx),
        env = _env(),
        command = cmd,
        tools = [
            go_ctx.go,
            cg_info.controller_gen_bin,
        ],
    )

def _inputs(ctx, go_ctx):
    inputs = (ctx.files.srcs + go_ctx.sdk.srcs + go_ctx.sdk.tools +
              go_ctx.sdk.headers + go_ctx.stdlib.libs)

    if ctx.attr.gopath_dep:
        inputs += ctx.attr.gopath_dep.files.to_list()
    return inputs

def _env():
    return {
        "GO111MODULE": "off",  # explicitly relying on passed in go_path to not download modules while doing codegen
    }

def _controller_gen_crd_impl(ctx):
    outputdir = ctx.actions.declare_directory(ctx.label.name)
    cg_cmd = "crd"
    extra_args = []
    if ctx.attr.trivialVersions:
        extra_args.append("trivialVersions=true")
    if ctx.attr.preserveUnknownFields:
        extra_args.append("preserveUnknownFields=true")
    if ctx.attr.crdVersions:
        fail("Unsuppored argument, please file a feature request")
    if ctx.attr.maxDescLen:
        fail("Unsupported argument, please file a feature request")
    if len(extra_args) > 0:
        cg_cmd += ":{args}".format(args = ",".join(extra_args))

    _controller_gen_action(ctx, cg_cmd, [outputdir], outputdir.path)

    return DefaultInfo(
        files = depset([outputdir]),
    )

def _controller_gen_object_impl(ctx):
    output = ctx.actions.declare_file("zz_generated.deepcopy.go")

    _controller_gen_action(ctx, "object", [output], output.dirname)

    return DefaultInfo(
        files = depset([output]),
    )

def _controller_gen_rbac_impl(ctx):
    outputdir = ctx.actions.declare_directory("rbac")
    cg_cmd = "rbac"
    extra_args = []
    if ctx.attr.roleName:
        extra_args.append("roleName={}".format(ctx.attr.roleName))
    if len(extra_args) > 0:
        cg_cmd += ":{args}".format(args = ",".join(extra_args))

    _controller_gen_action(ctx, cg_cmd, [outputdir], outputdir.path)

    return DefaultInfo(
        files = depset([outputdir]),
    )

def _controller_gen_webhook_impl(ctx):
    outputdir = ctx.actions.declare_directory(ctx.label.name)

    _controller_gen_action(ctx, "webhook", [outputdir], outputdir.path)

    return DefaultInfo(
        files = depset([outputdir]),
    )

COMMON_ATTRS = {
    "srcs": attr.label_list(
        allow_empty = False,
        allow_files = True,
        mandatory = True,
        doc = "Source files passed to controller-gen",
    ),
    "gopath_dep": attr.label(
        providers = [GoPath],
        mandatory = False,
        doc = "Go lang dependencies, automatically bundled in a go_path() by the macro.",
    ),
    "_go_context_data": attr.label(
        default = "@io_bazel_rules_go//:go_context_data",
        doc = "Internal, context for go compilation.",
    ),
}

def _crd_extra_attrs():
    ret = COMMON_ATTRS
    ret.update({
        "trivialVersions": attr.bool(
            default = True,
        ),
        "preserveUnknownFields": attr.bool(
            default = False,
        ),
        "crdVersions": attr.string_list(
        ),
        "maxDescLen": attr.int(
        ),
    })
    return ret

def _rbac_extra_attrs():
    ret = COMMON_ATTRS
    ret.update({
        "roleName": attr.string(
            default = "manager-role",
        ),
    })
    return ret

def _webhook_extra_attrs():
    ret = COMMON_ATTRS
    return ret

def _toolchains():
    return [
        "@io_bazel_rules_go//go:toolchain",
        "@rules_kubebuilder//controller-gen:toolchain",
    ]

_controller_gen_crd = rule(
    implementation = _controller_gen_crd_impl,
    attrs = _crd_extra_attrs(),
    toolchains = _toolchains(),
    doc = "Run the CRD generating portion of controller-gen. " +
          "The output directory will be the name of the rule.",
)

_controller_gen_object = rule(
    implementation = _controller_gen_object_impl,
    attrs = COMMON_ATTRS,
    toolchains = _toolchains(),
    doc = "Run the code generating portion of controller-gen. " +
          "You can use the name of this rule as part of the `srcs` attribute " +
          " of a `go_library` rule.",
)

_controller_gen_rbac = rule(
    implementation = _controller_gen_rbac_impl,
    attrs = _rbac_extra_attrs(),
    toolchains = _toolchains(),
    doc = "Run the role binding generating portion of controller-gen. " +
          "The output directory will be `rbac`.",
)

_controller_gen_webhook = rule(
    implementation = _controller_gen_webhook_impl,
    attrs = _webhook_extra_attrs(),
    toolchains = _toolchains(),
    doc = "Run the webhook generating portion of controller-gen. " +
          "The output directory will be the name of the rule.",
)

def _maybe_add_gopath_dep(name, kwargs):
    if kwargs.get("deps", None):
        gopath_name = name + "_controller_gen"
        go_path(
            name = gopath_name,
            deps = kwargs["deps"],
        )
        kwargs["gopath_dep"] = gopath_name
        kwargs.pop("deps")

def controller_gen_crd(name, **kwargs):
    _maybe_add_gopath_dep(name, kwargs)
    _controller_gen_crd(name = name, **kwargs)

def controller_gen_object(name, **kwargs):
    _maybe_add_gopath_dep(name, kwargs)
    _controller_gen_object(name = name, **kwargs)

def controller_gen_rbac(name, **kwargs):
    _maybe_add_gopath_dep(name, kwargs)
    _controller_gen_rbac(name = name, **kwargs)
    
def controller_gen_webhook(name, **kwargs):
    _maybe_add_gopath_dep(name, kwargs)
    _controller_gen_webhook(name = name, **kwargs)
