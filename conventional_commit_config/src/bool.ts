// This file contains helper methods for handling boolean config settings.

/** merges the given override into the given defaultValue */
export function merge(args: {
  defaultValue: boolean
  override?: boolean
}): boolean {
  return args.override ?? args.defaultValue
}
