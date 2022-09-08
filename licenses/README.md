# filter-permissive-licenses

This program filters known permissive licenses out of lists of used licenses.

### Installation

```
curl https://raw.githubusercontent.com/ory/ci/master/licenses/install | sh
```

### Usage

To check Go licenses:

```
go-licenses report <module name> --template .bin/check-license-template.tpl 2> /dev/null | .bin/check-licenses
```

For example when you are checking licenses for the https://github.com/ory/cli
repo and are in the `cli` folder:

```
go-licenses report github.com/ory/cli --template .bin/check-license-template.tpl 2> /dev/null | .bin/check-licenses
```
