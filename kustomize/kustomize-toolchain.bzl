""" Toolchain definitions for kustomize
"""

KUSTOMIZE_VERSIONS = [
    "4.2.0",
]

KUSTOMIZE_DEFAULT_VERSION = "4.2.0"

KUSTOMIZE_SHA256S = {
    "4.2.0": {
        "linux": {
            "x86_64": "220dd03dcda8e45dc50e4e42b2d71882cbc4c05e0ed863513e67930ecad939eb",
            "arm64": "33f2cf3b5db64c09560c187224e9d29452fde2b7f00f85941604fc75d9769e4a",
        },
        "osx": {
            "x86_64": "808d86fc15cec9226dd8b6440f39cfa8e8e31452efc70fb2f35c59529ddebfbf",
            "arm64": "7ad70475fe5684f7150f7f1825df5f17652ec812fa65129b756000e9a6b49fff",
        },
    },
}

# Map from bazel arch to kustomize arch
# (only used in the open source version of the rules)
ARCH_MAP = {
    "x86_64": "amd64",
    "arm64": "arm64",
}

# Map from bazel platform to kustomize platform
PLATFORM_MAP = {
    "linux": "linux",
    "osx": "darwin",
}

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
        "version": attr.string(
            default = KUSTOMIZE_DEFAULT_VERSION,
            values = KUSTOMIZE_VERSIONS,
        ),
        "kustomize_bin": attr.label(allow_single_file = True),
    },
)
