""" Toolchain definitions for kustomize
"""

KustomizeInfo = provider(
    doc = "Information about how to invoke kustomize",
    fields = ["kustomize_bin"],
)

def _kustomize_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        kustomize_info = KustomizeInfo(
            kustomize_bin = ctx.file.kustomize_bin,
        ),
    )
    return [toolchain_info]

kustomize_toolchain = rule(
    implementation = _kustomize_toolchain_impl,
    attrs = {
        "kustomize_bin": attr.label(allow_single_file = True),
    },
)
