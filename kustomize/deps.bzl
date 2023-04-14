""" Dependencies for kustomize
"""

load("@rules_kubebuilder//kustomize:kustomize-toolchain.bzl", "ARCH_MAP", "KUSTOMIZE_DEFAULT_VERSION", "KUSTOMIZE_SHA256S", "PLATFORM_MAP")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def kustomize_url(platform, arch, version):
    """ Return the URL for a kustomize binary

    Args:
        platform: platform to download for
        arch: architecture to download for
        version: version of kustomize to download

    Returns:
        URL for the kustomize binary
    """
    
    url = "https://github.com/kubernetes-sigs/kustomize/releases/download/" + \
          "kustomize%2Fv{VERSION}/kustomize_v{VERSION}_{PLATFORM}_{ARCH}.tar.gz" \
              .format(VERSION = version, PLATFORM = PLATFORM_MAP[platform], ARCH = ARCH_MAP[arch])

    return url

def kustomize_register_toolchain(name = None, version = KUSTOMIZE_DEFAULT_VERSION):
    """ Register a kustomize toolchain

    Args:
        name: name of the toolchain (ignored)
        version: version of kustomize to use
    """

    if version not in KUSTOMIZE_SHA256S:
        fail("Kustomize version %s is not supported, please use one of %s" % (version, KUSTOMIZE_SHA256S.keys()))

    for platform in PLATFORM_MAP.keys():
        for arch in ARCH_MAP.keys():
            http_archive(
                name = "kustomize_%s_%s" % (platform, arch),
                sha256 = KUSTOMIZE_SHA256S[version][platform][arch],
                urls = [
                    kustomize_url(platform, arch, version),
                ],
                build_file_content = """
exports_files(
    ["kustomize"],
    visibility = ["//visibility:public"],
)
                """,
            )
            native.register_toolchains(
                "@rules_kubebuilder//kustomize:kustomize_%s_%s_toolchain" % (platform, arch),
            )
