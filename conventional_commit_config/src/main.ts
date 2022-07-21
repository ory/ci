import * as fs from "fs"
import * as stringList from "./string_list"
import * as bool from "./bool"
import * as util from "util"
import * as config from "./config"

/** the outputs of this GitHub action */
export interface Outputs {
  types: string
  scopes: string
  requireScope: boolean
}

export type Logger = (message: string) => void

export function run(args: {
  configPath: string
  defaults: Outputs
  log: Logger
}): Outputs {
  args.log(`Looking for config file "${args.configPath}" ...`)
  try {
    var configText = fs.readFileSync(args.configPath, "utf8")
  } catch (e) {
    args.log("no config file found, using default values")
    return args.defaults
  }
  try {
    var config: config.Format = JSON.parse(configText)
  } catch (e) {
    args.log(`ERROR: invalid JSON in ${args.configPath}: ${util.inspect(e)}`)
    return args.defaults
  }

  const types = stringList.merge({
    defaults: args.defaults.types,
    replacements: config.types?.join("\n"),
    additions: config.addTypes?.join("\n"),
  })
  args.log(`using types:\n${types}`)

  const scopes = stringList.merge({
    defaults: args.defaults.scopes,
    replacements: config.scopes?.join("\n"),
    additions: config.addScopes?.join("\n"),
  })
  args.log(`using scopes:\n${scopes}`)

  const requireScope = bool.merge({
    defaultValue: args.defaults.requireScope,
    override: config.requireScope,
  })
  args.log(`using requireScope: ${requireScope}`)

  return { types, scopes, requireScope }
}
