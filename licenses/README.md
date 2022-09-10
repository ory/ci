# License checkers

The scripts in this folder ensure that your source code uses dependencies with
an appropriately permissive license. When finding non-compliant licenses, they
print the affected libraries and licenses and exit with error code 1.

### Installation

```
curl https://raw.githubusercontent.com/ory/ci/master/licenses/install | sh
```

### Checking Go licenses

To check licenses of Go dependencies, run this in your repo:

```
.bin/licenses-go <go module name>
```

For example, when you are checking licenses for the https://github.com/ory/cli
repo and are in the folder containing its source code:

```
.bin/licenses-go github.com/ory/cli
```

### Checking Node licenses

To check licenses of Node.js dependencies:

```
.bin/licenses-node
```
