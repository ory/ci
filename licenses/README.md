# License checkers

The scripts in this folder ensure that your source code uses dependencies with
an appropriately permissive license. When finding non-compliant licenses, they
print the affected libraries and licenses and exit with error code 1.

### Installation

```sh
ORY_CI_INSTALL_REF=<40-character-ory-ci-commit-sha>
curl --fail --location \
  "https://raw.githubusercontent.com/ory/ci/${ORY_CI_INSTALL_REF}/licenses/install" |
  sh
```

Calling the installer without arguments remains supported and installs the
license assets from its built-in, pinned revision.

Standalone consumers should pin both the installer itself and its asset source
to the same full commit SHA:

```sh
ORY_CI_REF=<40-character-ory-ci-commit-sha>
curl --fail --location \
  "https://raw.githubusercontent.com/ory/ci/${ORY_CI_REF}/licenses/install" |
  sh -s -- --source-ref "${ORY_CI_REF}"
```

Composite actions and local development can install the files bundled in a
checkout instead. The source directory must contain `checksums.sha256` and the
five license assets next to it:

```sh
sh licenses/install --source-dir "$(pwd)/licenses"
```

`--source-ref` and `--source-dir` are mutually exclusive. In either explicit
mode, every asset is staged, checked against the selected source's SHA-256
manifest, and only then moved into `.bin`. `--full-install` can be combined with
either source option to install both language templates.

### Usage

To check licenses, run this in your repo:

```
.bin/licenses
```

This script applies all known license checkers for all technology stacks that it
recognizes in the current directory.
