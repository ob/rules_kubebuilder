""" Dependencies for controller-gen
"""

load("@rules_kubebuilder//controller-gen:controller-gen-toolchain.bzl", "CONTROLLER_GEN_ARCHES", "CONTROLLER_GEN_DEFAULT_VERSION")

def controller_gen_register_toolchain(name = None, version = CONTROLLER_GEN_DEFAULT_VERSION):
    for arch in CONTROLLER_GEN_ARCHES:
        native.register_toolchains(
            "@rules_kubebuilder//controller-gen:controller_gen_darwin_toolchain_%s_%s" % (version, arch),
        )
    native.register_toolchains(
        "@rules_kubebuilder//controller-gen:controller_gen_linux_toolchain_%s" % version,
    )
