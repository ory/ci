import * as fs from "fs"
import * as path from "path"
import * as util from "util"
import Ajv from "ajv"
import * as bool from "./bool"
import * as config from "./config"
import * as stringList from "./string_list"

/** the outputs of this GitHub action */
export interface Outputs {
  requireScope: boolean
  scopes: string
  types: string
}

/** interface of logger instances used here */
export type Logger = (message: string) => void

export function run(args: {
  configPath: string
  defaults: Outputs
  log: Logger
}): Outputs {
  // load config file
  args.log(`Looking for config file "${args.configPath}" ...`)
  try {
    var configText = fs.readFileSync(args.configPath, "utf8")
  } catch (e) {
    args.log("no config file found, using default values")
    return args.defaults
  }
  try {
    var config: config.FileFormat = JSON.parse(configText)
  } catch (e) {
    args.log(`ERROR: invalid JSON in ${args.configPath}: ${util.inspect(e)}`)
    return args.defaults
  }

  // validate config file structure
  try {
    const schemapath = path.join(__dirname, "..", "dist", "config.schema.json")
    var schemaText = fs.readFileSync(schemapath, "utf8")
  } catch (e) {
    args.log(`cannot load JSON Schema: ${util.inspect(e)}`)
    return args.defaults
  }
  try {
    var schema = JSON.parse(schemaText)
  } catch (e) {
    args.log(`cannot parse JSON Schema: ${util.inspect(e)}`)
    return args.defaults
  }
  const ajv = new Ajv()
  const validate = ajv.compile(schema)
  if (!validate(config)) {
    const errors = []
    for (const error of validate.errors || []) {
      errors.push(`${error.message}: ${util.inspect(error.params)}`)
    }
    throw new Error(errors.join("\n"))
  }

  // determine configuration
  const types = stringList.merge({
    defaults: args.defaults.types,
    replacements: config.types?.join("\n"),
    additions: config.addTypes?.join("\n"),
  })
  args.log(`\nRESULTING TYPES\n${types}`)

  const scopes = stringList.merge({
    defaults: args.defaults.scopes,
    replacements: config.scopes?.join("\n"),
    additions: config.addScopes?.join("\n"),
  })
  args.log(`\nRESULTING SCOPES\n${scopes}`)

  const requireScope = bool.merge({
    defaultValue: args.defaults.requireScope,
    override: config.requireScope,
  })
  args.log(`\nRESULTING REQUIRE_SCOPE: ${requireScope}`)

  return { types, scopes, requireScope }
}
