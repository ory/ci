# License checkers

The scripts in this folder ensure that your source code uses dependencies with
an appropriately permissive license. When finding non-compliant licenses, they
print the affected libraries and licenses and exit with error code 1.

### Installation

```
curl https://raw.githubusercontent.com/ory/ci/master/licenses/install | sh
```

### Usage

To check licenses, run this in your repo:

```
.bin/licenses
```

This script applies all known license checkers for all technology stacks that it
recognizes in the current directory.
