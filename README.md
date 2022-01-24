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

Usage:
```yaml
uses: ory/ci/prettier@ref
```
