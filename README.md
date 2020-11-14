# rules_kubebuilder

These bazel rules download and make available the [Kubebuilder SDK](https://github.com/kubernetes-sigs/kubebuilder) for building kubernetes operators in bazel.

To use these rules, add the following to your `WORKSPACE` file:

```
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "rules_kubebuilder",
    branch = "main",
    remote = "https://github.com/ob/rules_kubebuilder.git",
)

load("@rules_kubebuilder//kubebuilder:sdk.bzl", "kubebuilder_register_sdk")

kubebuilder_register_sdk(version = "2.3.1")

load("@rules_kubebuilder//controller-gen:deps.bzl", "controller_gen_register_toolchain")

controller_gen_register_toolchain()

load("@rules_kubebuilder//kustomize:deps.bzl", "kustomize_register_toolchain")

kustomize_register_toolchain()
```

And in your `go_test()` files, add `etcd` as a data dependency like this:

```
go_test(
    name = "go_default_test",
    srcs = ["apackage_test.go"],
    data = [
        "@kubebuilder_sdk//:bin/etcd",
    ],
    embed = [":go_default_library"],
    deps = [
    ],
)
```
You'll need to run the test as:

```
bazel test --test_env=KUBEBUILDER_ASSETS=$(bazel info execution_root 2>/dev/null)/$(bazel run @kubebuilder_sdk//:pwd 2>/dev/null) //...
```

You can also add the following to `BUILD.bazel` at the root of your workspace:

```
load("@rules_kubebuilder//kubebuilder:def.bzl", "kubebuilder")
kubebuilder(name = "kubebuilder")
```

to be able to run `kubebuilder` like so:

```
$ bazel run //:kubebuilder -- --help
```

## Controller-gen

In order to use `controller-gen` you will need to do something like the following in your `api/v1alpha1` directory (essentially where the `*_type.go` files are):

```
load("@io_bazel_rules_go//go:def.bzl", "go_library")
load(
    "@rules_kubebuilder//controller-gen:controller-gen.bzl",
    "controller_gen_crd",
    "controller_gen_object",
    "controller_gen_rbac",
)

filegroup(
    name = "srcs",
    srcs = [
        "groupversion_info.go",
        # your source files here, except for zz_generated_deepcopy.go
    ],
)

DEPS = [
    "@io_k8s_api//core/v1:go_default_library",
    "@io_k8s_apimachinery//pkg/api/resource:go_default_library",
    "@io_k8s_apimachinery//pkg/apis/meta/v1:go_default_library",
    "@io_k8s_apimachinery//pkg/runtime:go_default_library",
    "@io_k8s_apimachinery//pkg/runtime/schema:go_default_library",
    "@io_k8s_sigs_controller_runtime//pkg/scheme:go_default_library",
]

controller_gen_object(
    name = "generated_sources",
    srcs = [
        ":srcs",
    ],
    deps = DEPS,
)

# keep
go_library(
    name = "go_default_library",
    srcs = [
        "generated_sources",
        "srcs",
    ],
    importpath = "yourdomain.com/your-operator/api/v1alpha1",
    visibility = ["//visibility:public"],
    deps = DEPS,
)

controller_gen_crd(
    name = "crds",
    srcs = [
        ":srcs",
    ],
    visibility = ["//visibility:public"],
    deps = DEPS,
)
```

## Developers

The toolchain that describes `controller-gen` needs to be built and the binaries committed so that
they can be used. Fortunately Go supports cross compiling so in order to build the controller, you'll
need to get and install Go either from [their download page](https://golang.org/doc/install) or from
homebrew by running

```
$ brew install golang
```

After that you can run the script in `scripts/build-controller-gen.sh` which will compile `controller-gen`
for both Linux and macOS.
