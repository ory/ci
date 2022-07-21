export function merge(args: {
  defaults: string
  replacements?: string
  additions?: string
}): string {
  let result = args.defaults
  if (args.replacements) {
    result = args.replacements
  }
  if (args.additions) {
    result = result + "\n" + args.additions
  }
  return result
}
