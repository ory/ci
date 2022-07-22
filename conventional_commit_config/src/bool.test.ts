import { strict as assert } from "assert"
import * as bool from "./bool"

suite("bool", function () {
  suite("merge", function () {
    test("true, no override", function () {
      const have = bool.merge({ defaultValue: true })
      const want = true
      assert.equal(have, want)
    })

    test("false, no override", function () {
      const have = bool.merge({ defaultValue: false })
      const want = false
      assert.equal(have, want)
    })

    test("true, override true", function () {
      const have = bool.merge({ defaultValue: true, override: true })
      const want = true
      assert.equal(have, want)
    })

    test("true, override false", function () {
      const have = bool.merge({ defaultValue: true, override: false })
      const want = false
      assert.equal(have, want)
    })

    test("false, override true", function () {
      const have = bool.merge({ defaultValue: false, override: true })
      const want = true
      assert.equal(have, want)
    })

    test("false, override false", function () {
      const have = bool.merge({ defaultValue: false, override: false })
      const want = false
      assert.equal(have, want)
    })
  })
})
