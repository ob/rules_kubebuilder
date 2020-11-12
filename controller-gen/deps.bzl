""" Dependencies for controller-gen
"""

def controller_gen_register_toolchain(name = None):
    native.register_toolchains(
        "@rules_kubebuilder//controller-gen:controller_gen_linux_toolchain",
        "@rules_kubebuilder//controller-gen:controller_gen_darwin_toolchain",
    )
