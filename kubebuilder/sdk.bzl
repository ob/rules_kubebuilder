"""Bazel rules for kubebuilder based projects
"""

load(
    "@rules_kubebuilder//kubebuilder:sdk_list.bzl",
    "SDK_VERSION_SHA256",
)

def _kubebuilder_download_sdk_impl(ctx):
    platform = _detect_host_platform(ctx)
    version = ctx.attr.version
    if version not in SDK_VERSION_SHA256:
        fail("Unknown version {}".format(version))
    sha256 = SDK_VERSION_SHA256[version][platform]
    urls = [url.format(version = version, platform = platform) for url in ctx.attr.urls]
    strip_prefix = ctx.attr.strip_prefix.format(version = version, platform = platform)
    ctx.download_and_extract(
        url = urls,
        stripPrefix = strip_prefix,
        sha256 = sha256,
    )
    ctx.template(
        "BUILD.bazel",
        Label("@rules_kubebuilder//kubebuilder:BUILD.sdk.bazel"),
        executable = False,
    )

_kubebuilder_download_sdk = repository_rule(
    _kubebuilder_download_sdk_impl,
    attrs = {
        "version": attr.string(default = "2.3.1"),
        "urls": attr.string_list(
            default = [
                "https://github.com/kubernetes-sigs/kubebuilder/releases/download/v{version}/kubebuilder_{version}_{platform}.tar.gz",
            ],
        ),
        "strip_prefix": attr.string(default = "kubebuilder_{version}_{platform}"),
    },
)

def kubebuilder_download_sdk(name, **kwargs):
    _kubebuilder_download_sdk(name = name, **kwargs)

def _detect_host_platform(ctx):
    if ctx.os.name == "linux":
        host = "linux_amd64"
    elif ctx.os.name == "mac os x" and ctx.os.uname.machine == "x86_64":
        host = "darwin_amd64"
    elif ctx.os.name == "mac os x" and ctx.os.uname.machine == "arm64":
        host = "darwin_arm64"
    else:
        fail("Unsupported operating system: " + ctx.os.name)
    return host

def kubebuilder_register_sdk(version = "2.3.1"):
    kubebuilder_download_sdk(
        name = "kubebuilder_sdk",
        version = version,
    )

def _kubebuilder_pwd_impl(ctx):
    out_file = ctx.actions.declare_file(ctx.label.name + ".bash")
    exec_path = "$(execpath {})".format(ctx.attr.kubebuilder_binary.label)
    substitutions = {
        "@@PWD@@": ctx.expand_location(exec_path),
    }
    runfiles = None
    ctx.actions.expand_template(
        template = ctx.file._template,
        output = out_file,
        substitutions = substitutions,
        is_executable = True,
    )
    return [DefaultInfo(
        files = depset([out_file]),
        runfiles = runfiles,
        executable = out_file,
    )]

kubebuilder_pwd = rule(
    implementation = _kubebuilder_pwd_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "kubebuilder_binary": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "_template": attr.label(
            default = "@rules_kubebuilder//kubebuilder:kubebuilder_pwd.bash.in",
            allow_single_file = True,
        ),
    },
    executable = True,
)
