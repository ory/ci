// This file contains helper methods for handling lists of newline-separated strings,
// which are used as input and output variables on Github Actions.

/** merges the given string lists */
export function merge(args: {
  additions?: string
  defaults: string
  replacements?: string
}): string {
  let result = args.replacements ?? args.defaults
  if (args.additions) {
    result = result + "\n" + args.additions
  }
  return result
}
