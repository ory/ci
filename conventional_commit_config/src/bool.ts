export function merge(args: {
  defaultValue: boolean
  override?: boolean
}): boolean {
  return args.override ?? args.defaultValue
}
