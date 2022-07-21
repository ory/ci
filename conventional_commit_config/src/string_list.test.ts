import { strict as assert } from "assert"
import * as stringList from "./string_list"

suite("string_list", function () {
  suite("merge", function () {
    test("no replacement, no additions", function () {
      const have = stringList.merge({
        defaults: "default1\ndefault2",
      })
      const want = "default1\ndefault2"
      assert.deepEqual(have, want)
    })

    test("no replacement, with additions", function () {
      const have = stringList.merge({
        defaults: "default1\ndefault2",
        additions: "addition1\naddition2",
      })
      const want = "default1\ndefault2\naddition1\naddition2"
      assert.deepEqual(have, want)
    })

    test("with replacement, no additions", function () {
      const have = stringList.merge({
        defaults: "default1\ndefault2",
        replacements: "replace1\nreplace2",
      })
      const want = "replace1\nreplace2"
      assert.deepEqual(have, want)
    })

    test("with replacement, with additions", function () {
      const have = stringList.merge({
        defaults: "default1\ndefault2",
        replacements: "replace1\nreplace2",
        additions: "addition1\naddition2",
      })
      const want = "replace1\nreplace2\naddition1\naddition2"
      assert.deepEqual(have, want)
    })
  })
})
