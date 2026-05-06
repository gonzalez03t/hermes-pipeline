export const dynamic = 'force-dynamic'

interface Item {
  id: string
  name: string
  createdAt: string
}

interface ItemsResponse {
  items: Item[]
}

async function fetchItems(): Promise<Item[]> {
  try {
    const baseUrl = process.env.NEXT_PUBLIC_BASE_URL ?? 'http://localhost:3000'
    const res = await fetch(`${baseUrl}/api/items`, { cache: 'no-store' })
    if (!res.ok) {
      console.log(JSON.stringify({ level: 'warn', message: 'Failed to fetch items', status: res.status }))
      return []
    }
    const data: ItemsResponse = await res.json() as ItemsResponse
    return data.items
  } catch (err) {
    console.log(JSON.stringify({ level: 'error', message: 'Error fetching items', error: String(err) }))
    return []
  }
}

export default async function HomePage() {
  const env = process.env.ENVIRONMENT ?? 'local'
  const items = await fetchItems()

  return (
    <main>
      <h1>Hermes Pipeline</h1>
      <p>Environment: {env}</p>
      <h2>Items</h2>
      {items.length === 0 ? (
        <p>No items found.</p>
      ) : (
        <ul>
          {items.map((item) => (
            <li key={item.id}>{item.name}</li>
          ))}
        </ul>
      )}
    </main>
  )
}
