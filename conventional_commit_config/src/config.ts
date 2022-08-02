/** data format of the configuration file */
export interface FileFormat {
  /** link to JSON schema */
  $schema?: string

  /** add to the default scopes */
  addScopes?: string[]

  /** add to the default types */
  addTypes?: string[]

  /** whether to enforce a scope in pull request titles */
  requireScope?: boolean

  /** override the default scopes */
  scopes?: string[]

  /** override the default types */
  types?: string[]
}
