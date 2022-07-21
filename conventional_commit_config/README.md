# Conventional Commits GitHub Action

This [GitHub Action](https://github.com/features/actions) wraps
[amannn/action-semantic-pull-request](https://github.com/amannn/action-semantic-pull-request)
with Ory-specific defaults and an ability for customization.

### Usage

This action is automatically installed into your Ory repo as
`.github/workflows/conventional_commits.yml` through
https://github.com/ory/meta/blob/master/templates/repository/common/.github/workflows/conventional_commits.yml.
If your repo does not contain this file, please
[add it to the list of repos](https://github.com/ory/meta/blob/master/.github/workflows/sync.yml).

### Configuration

This action should work without configuration for most Ory repos. If your repo
requires additional commit types or scopes, please create a file
`.github/conventional_commits.json` in your repository. This file can contain
the following optional keys:

| name           | description                                        | default |
| -------------- | -------------------------------------------------- | ------- |
| _types_        | overrides the default types                        | `[]`    |
| _addTypes_     | adds the given types to the set of default types   | `[]`    |
| _scopes_       | overrides the default scopes                       | `[]`    |
| _addScopes_    | adds the given scopes to the set of default scopes | `[]`    |
| _requireScope_ | enforces a scope in pull requests titles           | `false` |

Here is an example file with all options set. Please note that you never need
all these options together. Set only the ones you need.

```json
{
  "$schema": "https://raw.githubusercontent.com/ory/ci/master/conventional_commit_config/dist/config.schema.json",
  "types": ["type1", "type2"],
  "addTypes": ["type3", "type4"],
  "scopes": ["scope1", "scope2"],
  "addScopes": ["scope3", "scope4"],
  "requireScope": true
}
```

### Development

To change the set of default titles of scopes, please update the variables with
SCREAMING_SNAKE_CASE in the action code.
