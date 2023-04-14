""" Toolchain definitions for controller-gen
"""

CONTROLLER_GEN_VERSIONS = [
    "0.3.0",
    "0.4.1",
]
CONTROLLER_GEN_DEFAULT_VERSION = CONTROLLER_GEN_VERSIONS[0]

CONTROLLER_GEN_ARCHES = [
    "x86_64",
    "arm64",
]

ControllerGenInfo = provider(
    doc = "Information about how to invoke controller-gen",
    fields = ["controller_gen_bin"],
)

def _controller_gen_toolchain_impl(ctx):
    toolchain_info = platform_common.ToolchainInfo(
        controller_gen_info = ControllerGenInfo(
            controller_gen_bin = ctx.file.controller_gen_bin,
        ),
    )
    return [toolchain_info]

controller_gen_toolchain = rule(
    implementation = _controller_gen_toolchain_impl,
    attrs = {
        "controller_gen_bin": attr.label(allow_single_file = True),
    },
)
