export const dynamic = 'force-dynamic'

export default function NotFound() {
  return (
    <div style={{ padding: '6rem 1rem', textAlign: 'center' }}>
      <h1 style={{ fontSize: '1.5rem', marginBottom: '1rem' }}>Page not found</h1>
      <p style={{ marginBottom: '1rem' }}>The page you tried to access does not exist.</p>
      <a href="/" style={{ textDecoration: 'underline' }}>
        Go to frontpage
      </a>
    </div>
  )
}
