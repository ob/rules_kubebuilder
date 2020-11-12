""" Dependencies for kustomize
"""

def kustomize_register_toolchain(name = None):
    native.register_toolchains(
        "@rules_kubebuilder//kustomize:kustomize_linux_toolchain",
        "@rules_kubebuilder//kustomize:kustomize_darwin_toolchain",
    )
