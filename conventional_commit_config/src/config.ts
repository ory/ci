/** data format of the configuration file */
export interface FileFormat {
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
