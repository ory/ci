const fs = require("node:fs")
const path = require("node:path")
const { execFileSync } = require("node:child_process")
const { createRequire } = require("node:module")
const { createHash } = require("node:crypto")

function collectPaths(tree, result = new Set()) {
  const manifestPath = tree.path && path.join(tree.path, "package.json")
  const optional =
    manifestPath && fs.existsSync(manifestPath)
      ? JSON.parse(fs.readFileSync(manifestPath)).optionalDependencies || {}
      : tree.optionalDependencies || {}
  for (const [name, dependency] of Object.entries({
    ...tree.dependencies,
    ...tree.optionalDependencies,
  })) {
    if (optional[name] && (!dependency.path || !fs.existsSync(dependency.path)))
      continue
    if (!dependency.path || dependency.missing)
      throw new Error("Missing installed dependency in package-manager output")
    result.add(dependency.path)
    collectPaths(dependency, result)
  }
  return result
}

function applyReview(record, directory, evidence) {
  const review = evidence.find(
    (item) =>
      item.ecosystem === record.ecosystem &&
      item.name === record.name &&
      item.version === record.version,
  )
  const result = { ...record, reviewed_license: "", review_evidence: "" }
  if (!review || !directory || !Object.keys(review.files).length) return result
  for (const [file, expected] of Object.entries(review.files)) {
    const location = path.resolve(directory, file)
    if (
      !location.startsWith(path.resolve(directory) + path.sep) ||
      !fs.existsSync(location)
    )
      return result
    if (
      createHash("sha256").update(fs.readFileSync(location)).digest("hex") !==
      expected
    )
      return result
  }
  return {
    ...result,
    reviewed_license: review.reviewed_license,
    review_evidence: review.evidence,
  }
}

function toCSV(records) {
  const quote = (value) => '"' + String(value).replaceAll('"', '""') + '"'
  const rows = records.map((record) =>
    [record.name, record.reviewed_license || record.detected_license]
      .map(quote)
      .join(","),
  )
  return (
    '"module name","licenses"\n' +
    [...new Set(rows)]
      .sort()
      .map((row) => row + "\n")
      .join("")
  )
}

function usesPnpm(cwd) {
  for (let directory = cwd; ; directory = path.dirname(directory)) {
    if (fs.existsSync(path.join(directory, "pnpm-lock.yaml"))) return true
    if (fs.existsSync(path.join(directory, "package-lock.json"))) return false
    if (directory === path.dirname(directory)) return false
  }
}

async function scanNode(cwd, evidence) {
  const manifest = JSON.parse(fs.readFileSync(path.join(cwd, "package.json")))
  if (
    !Object.keys({ ...manifest.dependencies, ...manifest.optionalDependencies })
      .length
  )
    return []
  const checker = createRequire(__filename)("license-checker")
  const classify = (directory, direct) =>
    new Promise((resolve, reject) => {
      checker.init(
        {
          start: directory,
          direct,
          production: direct === undefined,
          excludePrivatePackages: true,
        },
        (error, data) => (error ? reject(error) : resolve(data)),
      )
    })
  let packages = []
  if (usesPnpm(cwd)) {
    let installationRoot = cwd
    while (
      !fs.existsSync(
        path.join(installationRoot, "node_modules/.modules.yaml"),
      ) &&
      path.dirname(installationRoot) !== installationRoot
    )
      installationRoot = path.dirname(installationRoot)
    const args = ["list", "--prod", "--depth", "Infinity", "--json"]
    if (
      installationRoot !== cwd &&
      fs.existsSync(path.join(installationRoot, "node_modules/.modules.yaml"))
    )
      args.unshift(
        "--dir",
        installationRoot,
        "--filter",
        "{./" + path.relative(installationRoot, cwd) + "}",
      )
    const trees = JSON.parse(
      execFileSync("pnpm", args, {
        cwd,
        encoding: "utf8",
        maxBuffer: 128 * 1024 * 1024,
      }),
    )
    const tree = trees.find(
      (item) =>
        item.path && fs.realpathSync(item.path) === fs.realpathSync(cwd),
    )
    if (!tree) throw new Error("pnpm did not return the requested project")
    const direct = Object.keys({
      ...manifest.dependencies,
      ...manifest.optionalDependencies,
    }).filter((name) => !manifest.optionalDependencies?.[name])
    for (const name of direct) {
      if (!tree.dependencies?.[name])
        throw new Error(`pnpm omitted required dependency ${name}`)
    }
    for (const directory of collectPaths(tree)) {
      const real = fs.realpathSync(directory)
      const installed = JSON.parse(
        fs.readFileSync(path.join(real, "package.json")),
      )
      const classified = Object.entries(await classify(real, 0)).filter(
        ([, info]) => info.path && fs.realpathSync(info.path) === real,
      )
      if (!classified.length && !installed.private)
        throw new Error(`License scanner omitted ${installed.name}`)
      packages.push(...classified)
    }
  } else {
    packages = Object.entries(await classify(cwd))
  }
  return packages.map(([name, info]) => {
    const manifest = JSON.parse(
      fs.readFileSync(path.join(info.path, "package.json")),
    )
    const record = {
      ecosystem: "node",
      name,
      module: manifest.name,
      version: manifest.version,
      local: !fs
        .realpathSync(info.path)
        .split(path.sep)
        .includes("node_modules"),
      detected_license: Array.isArray(info.licenses)
        ? info.licenses.join(" AND ")
        : info.licenses || "UNKNOWN",
    }
    return applyReview(record, info.path, evidence)
  })
}

function scanGo(cwd, evidence) {
  const options = {
    cwd,
    encoding: "utf8",
    maxBuffer: 128 * 1024 * 1024,
    stdio: ["ignore", "pipe", "inherit"],
  }
  const format =
    "{{.Path}}|{{.Version}}|{{.Dir}}|{{.Main}}|{{if .Replace}}{{.Replace.Path}}|{{.Replace.Version}}|{{.Replace.Dir}}{{end}}"
  const modules = execFileSync(
    "go",
    ["list", "-m", "-f", format, "all"],
    options,
  )
    .trim()
    .split("\n")
    .map((line) => {
      const [
        name,
        version,
        directory,
        main,
        replacement,
        replacementVersion,
        replacementDirectory,
      ] = line.split("|")
      return {
        name,
        version: replacementVersion || version,
        directory: replacementDirectory || directory,
        local: main === "true" || Boolean(replacement && !replacementVersion),
      }
    })
    .sort((a, b) => b.name.length - a.name.length)
  const env = {
    ...process.env,
    GOROOT: execFileSync("go", ["env", "GOROOT"], options).trim(),
  }
  const output = execFileSync(
    path.join(__dirname, "go-licenses"),
    [
      "report",
      "--template",
      path.join(__dirname, "license-template-go.json.tpl"),
      "./...",
    ],
    { ...options, env },
  )
  return output
    .split("\n")
    .filter((line) => line.trim())
    .map((line) => {
      const detected = JSON.parse(line)
      const module = modules.find(
        (item) =>
          detected.name === item.name ||
          detected.name.startsWith(item.name + "/"),
      )
      const record = {
        ecosystem: "go",
        name: detected.name,
        module: module?.name || "",
        version: module?.local ? "" : module?.version || detected.version,
        local: module?.local || false,
        detected_license: detected.license,
      }
      return applyReview(record, module?.directory, evidence)
    })
}

async function main() {
  if (process.argv.slice(2).some((arg) => arg !== "--json"))
    throw new Error("Usage: list-licenses [--json]")
  const cwd = process.cwd()
  const evidence = JSON.parse(
    fs.readFileSync(path.join(__dirname, "reviewed-licenses.json")),
  )
  const records = []
  if (fs.existsSync(path.join(cwd, "package.json")))
    records.push(...(await scanNode(cwd, evidence)))
  if (
    fs.existsSync(path.join(cwd, "go.mod")) ||
    fs.readdirSync(cwd).some((name) => name.endsWith(".go"))
  )
    records.push(...scanGo(cwd, evidence))
  const unique = [
    ...new Map(
      records.map((record) => [JSON.stringify(record), record]),
    ).values(),
  ].sort((a, b) =>
    (a.ecosystem + a.name + a.detected_license).localeCompare(
      b.ecosystem + b.name + b.detected_license,
    ),
  )
  process.stdout.write(
    process.argv.includes("--json")
      ? JSON.stringify(unique, null, 2) + "\n"
      : toCSV(unique),
  )
}

module.exports = { collectPaths, applyReview, toCSV, scanNode, scanGo }
if (require.main === module)
  main().catch((error) => {
    console.error(error.message)
    process.exitCode = 1
  })
