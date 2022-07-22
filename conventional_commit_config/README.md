# Conventional Commits GitHub Action

This Github Action is only used in
https://github.com/ory/meta/blob/master/templates/repository/common/.github/workflows/conventional_commits.yml.
It allows individual repositories to override the default scopes for
conventional commits via a config file.

This config file must be at `.github/conventional_commits.json` in your
repository and have content that looks like this:

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

You never need all options together. Set only the ones you need.

| name           | description                                        | default |
| -------------- | -------------------------------------------------- | ------- |
| _types_        | overrides the default types                        | `[]`    |
| _addTypes_     | adds the given types to the set of default types   | `[]`    |
| _scopes_       | overrides the default scopes                       | `[]`    |
| _addScopes_    | adds the given scopes to the set of default scopes | `[]`    |
| _requireScope_ | enforces a scope in pull requests titles           | `false` |

### Development

GitHub Actions don't run `npm install` in production. This GitHub Actions
therefore bundles external production dependencies into `dist/index.js`. To keep
this file up to date, please remember to run `npm run build` before committing.
Otherwise, your changes won't show up in production.
