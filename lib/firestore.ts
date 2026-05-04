import { App, getApp, getApps, initializeApp } from 'firebase-admin/app'
import { Firestore, getFirestore as adminGetFirestore } from 'firebase-admin/firestore'

function getAdminApp(): App {
  if (getApps().length > 0) {
    return getApp()
  }

  const projectId = process.env.GCP_PROJECT_ID
  if (!projectId) {
    throw new Error('GCP_PROJECT_ID environment variable is not set')
  }

  return initializeApp({ projectId })
}

export function getFirestore(): Firestore {
  const app = getAdminApp()
  return adminGetFirestore(app)
}
