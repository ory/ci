/** data format of the configuration file for repo-specific conventional commit overrides */
export interface Format {
  /** link to JSON schema */
  $schema?: string

  /** override the default types */
  types?: string[]

  /** add to the default types */
  addTypes?: string[]

  /** override the default scopes */
  scopes?: string[]

  /** add to the default scopes */
  addScopes?: string[]

  /** whether to enforce a scope in pull request titles */
  requireScope?: boolean
}
