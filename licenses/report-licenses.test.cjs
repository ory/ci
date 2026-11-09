const assert = require("node:assert/strict")
const {
  mkdtempSync,
  mkdirSync,
  writeFileSync,
  rmSync,
  symlinkSync,
  chmodSync,
} = require("node:fs")
const { tmpdir } = require("node:os")
const { join } = require("node:path")
const { test } = require("node:test")
const { createHash } = require("node:crypto")
const {
  collectPaths,
  applyReview,
  toCSV,
  scanNode,
} = require("./report-licenses.cjs")

test("pnpm traversal retains transitive and installed optional dependencies", () => {
  const directory = mkdtempSync(join(tmpdir(), "license-tree-"))
  try {
    const a = join(directory, "a"),
      b = join(directory, "b"),
      c = join(directory, "c")
    for (const item of [a, b, c]) mkdirSync(item)
    const tree = {
      dependencies: { a: { path: a, dependencies: { b: { path: b } } } },
      optionalDependencies: {
        c: { path: c },
        absent: { path: join(directory, "absent") },
      },
    }
    assert.deepEqual([...collectPaths(tree)].sort(), [a, b, c])
  } finally {
    rmSync(directory, { recursive: true, force: true })
  }
})

test("missing installed dependency fails rather than truncating the report", () => {
  assert.throws(
    () => collectPaths({ dependencies: { a: { version: "1.0.0" } } }),
    /Missing installed dependency/,
  )
})

test("review requires matching artifact version and every evidence hash", () => {
  const dir = mkdtempSync(join(tmpdir(), "license-evidence-"))
  try {
    writeFileSync(join(dir, "LICENSE"), "Apache notice")
    const hash = createHash("sha256").update("Apache notice").digest("hex")
    const record = {
      ecosystem: "go",
      name: "example.org/lib",
      version: "v1.0.0",
      detected_license: "Unknown",
    }
    const evidence = [
      {
        ecosystem: "go",
        name: record.name,
        version: record.version,
        reviewed_license: "Apache-2.0",
        evidence: "https://example.org/lib/LICENSE",
        files: { LICENSE: hash },
      },
    ]
    assert.equal(
      applyReview(record, dir, evidence).reviewed_license,
      "Apache-2.0",
    )
    assert.equal(
      applyReview({ ...record, version: "v2.0.0" }, dir, evidence)
        .reviewed_license,
      "",
    )
    writeFileSync(join(dir, "LICENSE"), "changed")
    assert.equal(applyReview(record, dir, evidence).reviewed_license, "")
    assert.equal(record.detected_license, "Unknown")
  } finally {
    rmSync(dir, { recursive: true, force: true })
  }
})

test("CSV escapes values and retains the reviewed license choice", () => {
  assert.equal(
    toCSV([
      {
        name: 'a"b',
        detected_license: "Unknown",
        reviewed_license: "FTL OR GPL-2.0-or-later",
      },
    ]),
    '"module name","licenses"\n"a""b","FTL OR GPL-2.0-or-later"\n',
  )
})

test("classifies pnpm packages from their real directories without losing transitive licenses", async () => {
  const directory = mkdtempSync(join(tmpdir(), "license-pnpm-"))
  const previousPath = process.env.PATH
  try {
    const a = join(directory, "node_modules/.pnpm/a/node_modules/a")
    const b = join(directory, "node_modules/.pnpm/b/node_modules/b")
    for (const [location, name, license] of [
      [a, "a", "MIT"],
      [b, "b", ["BSD-3-Clause", "MIT"]],
    ]) {
      mkdirSync(location, { recursive: true })
      writeFileSync(
        join(location, "package.json"),
        JSON.stringify({ name, version: "1.0.0", license }),
      )
    }
    writeFileSync(
      join(directory, "package.json"),
      JSON.stringify({
        name: "fixture",
        private: true,
        dependencies: { a: "1.0.0" },
      }),
    )
    writeFileSync(join(directory, "pnpm-lock.yaml"), "")
    symlinkSync(
      join(__dirname, "node_modules/license-checker"),
      join(directory, "node_modules/license-checker"),
    )
    const bin = join(directory, "bin")
    mkdirSync(bin)
    const tree = [
      {
        path: directory,
        dependencies: { a: { path: a, dependencies: { b: { path: b } } } },
      },
    ]
    const executable = join(bin, "pnpm")
    writeFileSync(
      executable,
      "#!/usr/bin/env node\nprocess.stdout.write(" +
        JSON.stringify(JSON.stringify(tree)) +
        ")\n",
    )
    chmodSync(executable, 0o755)
    process.env.PATH = bin + ":" + previousPath
    const rows = await scanNode(directory, [])
    assert.deepEqual(rows.map((r) => [r.name, r.detected_license]).sort(), [
      ["a@1.0.0", "MIT"],
      ["b@1.0.0", "BSD-3-Clause; MIT"],
    ])
  } finally {
    process.env.PATH = previousPath
    rmSync(directory, { recursive: true, force: true })
  }
})
