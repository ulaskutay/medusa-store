/** Icon fill colors — do not import tailwind.config in Server Components. */
export const themeIconColors = {
  bgPrimary: 'rgba(var(--bg-primary))',
  contentPrimary: 'rgba(var(--content-primary))',
  contentTertiary: 'rgba(var(--content-tertiary))',
  contentDisabled: 'rgba(var(--content-disabled))',
  actionOnPrimary: 'rgba(var(--content-action-on-primary))'
} as const;
