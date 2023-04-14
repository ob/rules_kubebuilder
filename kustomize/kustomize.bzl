""" Rules to run kustomize
"""

def _kustomize_impl(ctx):
    output = ctx.actions.declare_file(ctx.label.name + ".yaml")
    tmpdir = ctx.actions.declare_directory(ctx.label.name + ".tmp")
    kustomize_info = ctx.toolchains["@rules_kubebuilder//kustomize:toolchain_type"].kustomize_info

    ctx.actions.run_shell(
        mnemonic = "Kustomize",
        outputs = [output, tmpdir],
        inputs = ctx.files.srcs,
        command = """
        mkdir -p {tmp_path} &&
        cp -RL {srcs} {tmp_path} &&
        {kustomize} build {tmp_path} > {output}
        """.format(
            kustomize = kustomize_info.kustomize_bin.path,
            srcs = " ".join(['"{}"'.format(f.path) for f in ctx.files.srcs]),
            tmp_path = tmpdir.short_path,
            output = output.path,
        ),
        tools = [
            kustomize_info.kustomize_bin,
        ],
    )

    return DefaultInfo(
        files = depset([output]),
    )

kustomize = rule(
    implementation = _kustomize_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_empty = False,
            allow_files = True,
            mandatory = True,
            doc = "Source files passed to kustomize",
        ),
    },
    toolchains = [
        "@rules_kubebuilder//kustomize:toolchain_type",
    ],
    doc = "",
)
