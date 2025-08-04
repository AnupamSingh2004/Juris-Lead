"use client"

import { useState } from 'react'
import { Button } from '@/components/ui/button'

export function GoogleAuthTest() {
  const [result, setResult] = useState<string>('')

  const testGoogleConfig = () => {
    const clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID
    const apiUrl = process.env.NEXT_PUBLIC_API_BASE_URL
    const origin = window.location.origin

    const results = [
      `Current Origin: ${origin}`,
      `Google Client ID: ${clientId ? 'Configured ✓' : 'Missing ✗'}`,
      `API Base URL: ${apiUrl}`,
      `Google Script Loaded: ${window.google ? 'Yes ✓' : 'No ✗'}`,
      '',
      'Required OAuth URLs for Google Console:',
      '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━',
      'Authorized JavaScript origins:',
      `• ${origin}`,
      `• http://localhost:3000`,
      `• http://127.0.0.1:3000`,
      '',
      'Authorized redirect URIs:',
      `• ${origin}`,
      `• ${origin}/`,
      '• http://localhost:8001/api/v1/auth/google/callback/',
    ]

    setResult(results.join('\n'))
  }

  return (
    <div className="p-4 max-w-2xl mx-auto">
      <h3 className="text-lg font-bold mb-4">Google OAuth Configuration Test</h3>
      <Button onClick={testGoogleConfig} className="mb-4">
        Test Configuration
      </Button>
      {result && (
        <pre className="bg-gray-100 dark:bg-gray-800 p-4 rounded-lg text-sm whitespace-pre-wrap font-mono">
          {result}
        </pre>
      )}
    </div>
  )
}
