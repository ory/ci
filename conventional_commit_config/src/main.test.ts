import { strict as assert } from "assert"
import * as fs from "fs"
import * as main from "./main"

suite("integration tests", function () {
  const configPath = "test_config.json"

  test("no config file", function () {
    const log = new StubLog()
    const have = main.run({
      configPath,
      defaults: createDefaults(),
      log: log.callable(),
    })
    assert.deepEqual(have, createDefaults())
    assert.deepEqual(log.recordings, [
      'Looking for config file "test_config.json" ...',
      "no config file found, using default values",
    ])
  })

  test("config file adds types and scopes", function () {
    fs.writeFileSync(
      configPath,
      `
      {
        "addTypes": ["addType1", "addType2"],
        "addScopes": ["addScope1", "addScope2"],
        "requireScope": true
      }
      `,
    )
    const want: main.Outputs = {
      types: "defaultType1\naddType1\naddType2",
      scopes: "defaultScope1\naddScope1\naddScope2",
      requireScope: true,
    }
    const log = new StubLog()
    const have = main.run({
      configPath,
      defaults: createDefaults(),
      log: log.callable(),
    })
    assert.deepEqual(log.recordings, [
      'Looking for config file "test_config.json" ...',
      "using types:\ndefaultType1\naddType1\naddType2",
      "using scopes:\ndefaultScope1\naddScope1\naddScope2",
      "using requireScope: true",
    ])
    assert.deepEqual(have, want)
  })

  test("config file has invalid JSON content", function () {
    fs.writeFileSync(
      configPath,
      `
      {
        "addTypes": [
      }
      `,
    )
    const log = new StubLog()
    const have = main.run({
      configPath,
      defaults: createDefaults(),
      log: log.callable(),
    })
    assert.deepEqual(have, createDefaults())
    assert.equal(log.recordings.length, 2)
    assert.equal(
      log.recordings[0],
      'Looking for config file "test_config.json" ...',
    )
    assert.ok(
      log.recordings[1].startsWith(
        "ERROR: invalid JSON in test_config.json: SyntaxError: Unexpected token }",
      ),
    )
  })

  test("config file has unknown properties", function () {
    fs.writeFileSync(
      configPath,
      `
      {
        "addTypes": ["type1"],
        "foo": "bar"
      }
      `,
    )
    const log = new StubLog()
    try {
      main.run({
        configPath,
        defaults: createDefaults(),
        log: log.callable(),
      })
    } catch (e) {
      const error = e as Error
      assert.equal(
        error.message,
        "must NOT have additional properties: { additionalProperty: 'foo' }",
      )
    }
  })

  teardown(function () {
    try {
      fs.unlinkSync(configPath)
    } catch (e) {
      // nothing to do here
    }
  })
})

/** provides default values for testing */
function createDefaults(): main.Outputs {
  return {
    types: "defaultType1",
    scopes: "defaultScope1",
    requireScope: false,
  }
}

/** stub implementation of console.log */
class StubLog {
  recordings: string[] = []

  log(text: string) {
    this.recordings.push(text)
  }

  callable(): main.Logger {
    return this.log.bind(this)
  }
}
