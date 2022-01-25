# ci
> GitHub Actions CI

This repository contains reusable actions for various CI tasks.

### releaser

Release automation action.

Inputs:
- `token`: Personal access token
- `goreleaser_key`: GoReleaser Pro license key
- `cosign_pwd`: Password to decrypt signing key
- `docker_username`: Docker username
- `docker_password`: Docker password

Usage:
```yaml
uses: ory/ci/releaser@ref
```

### newsletter

Newsletter draft/send automation.

Inputs:
- `mailchimp_api_key`: Mailchimp API key
- `mailchimp_list_id`: Mailchimp list ID
- `mailchmip_segment_id`: Mailchimp segment ID
- `draft`: Either `"true"` or `"false"` (string, not boolean!)
- `ssh_key`: SSH private key used to fetch the repository

Usage:
```yaml
uses: ory/ci/newsletter@ref
```

### prettier

Runs prettier with some Ory-specific configuration.

Inputs:
- `dir`: Directory to 'cd' into before running prettier
- `action`: Action to perform: 'check' or 'write'

Usage:
```yaml
uses: ory/ci/prettier@ref
```

### docs

Documentation generation action.

Inputs:
- `job`: Job to run. Options: build (default), cli
- `swag-spec-location`: Location where the Swagger spec should be saved to
- `swag-spec-ignore`: Packages to ignore when generating the Swagger spec (space delimited).
- `token`: Personal access token

Usage:
```yaml
uses: ory/ci/docs@ref
```

### changelog

Changlelog generation action.

Inputs:
- `token`: Personal access token
