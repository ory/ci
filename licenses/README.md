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

## Inventory reports

The scanner requires Node.js 18 or later and the installed `license-checker`
package for JavaScript projects. Install the project's locked dependencies
first. For pnpm projects, the scanner uses `pnpm list` to follow the installed
dependency graph, including transitive packages in the virtual store. Missing
required packages fail the scan. Optional packages absent on the current
platform are not included. npm projects use the installed license-checker
dependency walker.

Go reports scan `./...` and its imports once. Set `GOFLAGS` for the build tags
used by the product. Test-only imports, other build configurations, and non-Go
native dependencies are outside this report's scope.

```sh
.bin/list-licenses > dependency-licenses.csv
.bin/list-licenses --json > dependency-licenses.json
```

JSON records preserve the raw `detected_license`, a separate `reviewed_license`,
the evidence reference, module version, and whether the source resolves locally.
Local source is not automatically classified as first-party or Apache-licensed.
The CSV uses the reviewed license when available and otherwise the detected
license. Policy approval remains a separate step performed by `.bin/licenses`.

Reviewed evidence applies only when the package name, version, and every
recorded file hash match the installed artifact. A changed artifact keeps its
detected result. These records correct specific detection gaps; they are not
wildcard license approvals. `linkio` remains unresolved pending verification of
its BSD and MIT notices.

The historical Keto namespace package's Apache-2.0 grant was confirmed by an Ory
maintainer. That record applies only to the exact published artifact; new
releases should contain their own license metadata and text.
