import * as core from "@actions/core"
import * as main from "./main"

const configPath = core.getInput("config_path")
const defaults: main.Outputs = {
  types: core.getInput("default_types"),
  scopes: core.getInput("default_scopes"),
  requireScope: core.getBooleanInput("default_require_scope"),
}
try {
  var result = main.run({ configPath, defaults, log: console.log })
} catch (e) {
  if (e instanceof Error) {
    core.setFailed(e.message)
  }
  process.exit(1)
}
core.setOutput("types", result.types)
core.setOutput("scopes", result.scopes)
core.setOutput("requireScope", result.requireScope.toString())
