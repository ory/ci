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

### releaser/render-version-schema

Render version schema at a specified path.

Inputs:
- `schema-path`: Path to version schema

Usage:
```yaml
uses: ory/ci/releaser/render-version-schema@ref
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

### docs/build

Build and publish docs to [ory/web](https://github.com/ory/web).

Inputs:
- `swag-spec-location`: Location where the Swagger spec should be saved to
- `swag-spec-ignore`: Packages to ignore when generating the Swagger spec (space delimited).
- `token`: Personal access token

Usage:

```yaml
uses: ory/ci/docs/build@ref
```

### docs/cli

Build CLI docs.

Inputs:
- `token`: Personal access token

Usage:

```yaml
uses: ory/ci/docs/cli@ref
```

### changelog

Changelog generation action.

Inputs:
- `token`: Personal access token

### sdk/generate

SDK generation action.

Inputs:
- `token`: Personal access token
- `app-name`: Name of the application
- `swag-spec-location:` Location where the Swagger spec should be saved to
- `swag-spec-ignore`: Packages to ignore when generating the Swagger spec (space delimited)
- `swag-gen-path`: Where to generate the SDK to

Usage:

```yaml
uses: ory/ci/sdk/generate@ref
```

### sdk/release

Release SDKs to [ory/sdk](https://github.com/ory/sdk).

Inputs:
- `token`: Personal access token
- `app-name`: Name of the application
- `swag-spec-location:` Location where the Swagger spec should be saved to
- `swag-spec-ignore`: Packages to ignore when generating the Swagger spec (space delimited)
- `swag-gen-path`: Where to generate the SDK to

Usage:
```yaml
uses: ory/ci/sdk/generate@ref
```
