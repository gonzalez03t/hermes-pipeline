import { Timestamp } from 'firebase-admin/firestore'
import { NextRequest, NextResponse } from 'next/server'
import { getFirestore } from '@/lib/firestore'

const COLLECTION = 'items'

interface ItemDocument {
  name: string
  createdAt: Timestamp
}

interface ItemResponse {
  id: string
  name: string
  createdAt: string
}

export async function GET(): Promise<NextResponse> {
  try {
    const db = getFirestore()
    const snapshot = await db.collection(COLLECTION).get()

    const items: ItemResponse[] = snapshot.docs.map((doc) => {
      const data = doc.data() as ItemDocument
      return {
        id: doc.id,
        name: data.name,
        createdAt: data.createdAt.toDate().toISOString(),
      }
    })

    console.log(JSON.stringify({ level: 'info', message: 'Listed items', count: items.length }))
    return NextResponse.json({ items })
  } catch (err) {
    console.log(JSON.stringify({ level: 'error', message: 'Failed to list items', error: String(err) }))
    return NextResponse.json({ error: 'Failed to list items' }, { status: 500 })
  }
}

export async function POST(request: NextRequest): Promise<NextResponse> {
  try {
    const body: unknown = await request.json()

    if (
      typeof body !== 'object' ||
      body === null ||
      !('name' in body) ||
      typeof (body as Record<string, unknown>).name !== 'string'
    ) {
      return NextResponse.json({ error: 'Request body must include a name string' }, { status: 400 })
    }

    const name = (body as { name: string }).name.trim()
    if (!name) {
      return NextResponse.json({ error: 'name must not be empty' }, { status: 400 })
    }

    const db = getFirestore()
    const docData: ItemDocument = { name, createdAt: Timestamp.now() }
    const ref = await db.collection(COLLECTION).add(docData)

    const created: ItemResponse = {
      id: ref.id,
      name: docData.name,
      createdAt: docData.createdAt.toDate().toISOString(),
    }

    console.log(JSON.stringify({ level: 'info', message: 'Created item', id: ref.id, name }))
    return NextResponse.json(created, { status: 201 })
  } catch (err) {
    console.log(JSON.stringify({ level: 'error', message: 'Failed to create item', error: String(err) }))
    return NextResponse.json({ error: 'Failed to create item' }, { status: 500 })
  }
}
