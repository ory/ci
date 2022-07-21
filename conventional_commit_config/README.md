# Conventional Commits GitHub Action

This [GitHub Action](https://github.com/features/actions) determines
Ory-specific configuration for
[amannn/action-semantic-pull-request](https://github.com/amannn/action-semantic-pull-request)
with an ability for individual repos to customize the allowed titles and scopes.

This action is used in
https://github.com/ory/meta/blob/master/templates/repository/common/.github/workflows/conventional_commits.yml.

### Config file

Only create a config file if the default set of pull request scopes doesn't work
for your repo. Create a file `.github/conventional_commits.json` in your
repository. Here is an example file with all options set.

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

Please note that you never need all these options together. Set only the ones
you need.

| name           | description                                        | default |
| -------------- | -------------------------------------------------- | ------- |
| _types_        | overrides the default types                        | `[]`    |
| _addTypes_     | adds the given types to the set of default types   | `[]`    |
| _scopes_       | overrides the default scopes                       | `[]`    |
| _addScopes_    | adds the given scopes to the set of default scopes | `[]`    |
| _requireScope_ | enforces a scope in pull requests titles           | `false` |
