"use client"

import { useState, useEffect } from 'react'
import { Button } from '@/components/ui/button'

export default function GoogleTestPage() {
  const [logs, setLogs] = useState<string[]>([])
  const [clientId, setClientId] = useState<string>('')

  useEffect(() => {
    setClientId(process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || 'Not set')
    addLog(`Client ID: ${process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || 'Not set'}`)
    addLog(`Current origin: ${window.location.origin}`)
    addLog(`API URL: ${process.env.NEXT_PUBLIC_API_BASE_URL || 'Not set'}`)
  }, [])

  const addLog = (message: string) => {
    const timestamp = new Date().toLocaleTimeString()
    setLogs(prev => [...prev, `[${timestamp}] ${message}`])
  }

  const testGoogleScript = async () => {
    addLog('Testing Google Identity Services script loading...')
    
    if (!window.google) {
      addLog('Google script not loaded, loading now...')
      
      const script = document.createElement('script')
      script.src = 'https://accounts.google.com/gsi/client'
      script.async = true
      script.defer = true
      
      script.onload = () => {
        addLog('✅ Google script loaded successfully')
        addLog(`Google object available: ${!!window.google}`)
        addLog(`OAuth2 available: ${!!window.google?.accounts?.oauth2}`)
      }
      
      script.onerror = () => {
        addLog('❌ Failed to load Google script')
      }
      
      document.head.appendChild(script)
    } else {
      addLog('✅ Google script already loaded')
      addLog(`OAuth2 available: ${!!window.google?.accounts?.oauth2}`)
    }
  }

  const testGoogleAuth = async () => {
    if (!window.google?.accounts?.oauth2) {
      addLog('❌ Google OAuth2 not available')
      return
    }

    addLog('🔄 Initializing Google OAuth client...')
    
    try {
      const client = window.google.accounts.oauth2.initTokenClient({
        client_id: clientId,
        scope: 'openid email profile',
        callback: (response: any) => {
          addLog(`📥 OAuth callback received:`)
          addLog(`  - Error: ${response.error || 'None'}`)
          addLog(`  - Access token: ${response.access_token ? '✅ Received' : '❌ Missing'}`)
          addLog(`  - Full response: ${JSON.stringify(response, null, 2)}`)
        },
        error_callback: (error: any) => {
          addLog(`❌ OAuth error: ${JSON.stringify(error, null, 2)}`)
        }
      })

      addLog('🚀 Requesting access token...')
      client.requestAccessToken()
      
    } catch (error: any) {
      addLog(`❌ Error during OAuth setup: ${error.message}`)
    }
  }

  const clearLogs = () => {
    setLogs([])
  }

  return (
    <div className="container mx-auto p-6 max-w-4xl">
      <h1 className="text-2xl font-bold mb-6">Google OAuth Debug Tool</h1>
      
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div>
          <h2 className="text-lg font-semibold mb-4">Configuration</h2>
          <div className="space-y-2 text-sm bg-gray-100 dark:bg-gray-800 p-4 rounded">
            <div><strong>Client ID:</strong> {clientId}</div>
            <div><strong>Origin:</strong> {typeof window !== 'undefined' ? window.location.origin : 'Loading...'}</div>
            <div><strong>API URL:</strong> {process.env.NEXT_PUBLIC_API_BASE_URL}</div>
          </div>
          
          <div className="mt-4 space-y-2">
            <Button onClick={testGoogleScript} className="w-full">
              1. Test Google Script Loading
            </Button>
            <Button onClick={testGoogleAuth} className="w-full">
              2. Test Google OAuth
            </Button>
            <Button onClick={clearLogs} variant="outline" className="w-full">
              Clear Logs
            </Button>
          </div>
        </div>
        
        <div>
          <h2 className="text-lg font-semibold mb-4">Debug Logs</h2>
          <div className="bg-black text-green-400 p-4 rounded font-mono text-xs h-96 overflow-y-auto">
            {logs.length === 0 ? (
              <div className="text-gray-500">No logs yet. Click buttons to start testing.</div>
            ) : (
              logs.map((log, i) => (
                <div key={i} className="mb-1">{log}</div>
              ))
            )}
          </div>
        </div>
      </div>
      
      <div className="mt-6 p-4 bg-blue-50 dark:bg-blue-900/20 rounded">
        <h3 className="font-semibold mb-2">Required Google Console URLs:</h3>
        <div className="text-sm space-y-1">
          <div><strong>Authorized JavaScript origins:</strong></div>
          <ul className="list-disc list-inside ml-4">
            <li>http://localhost:3000</li>
            <li>http://127.0.0.1:3000</li>
          </ul>
          <div className="mt-2"><strong>Authorized redirect URIs:</strong></div>
          <ul className="list-disc list-inside ml-4">
            <li>http://localhost:3000</li>
            <li>http://localhost:3000/</li>
          </ul>
        </div>
      </div>
    </div>
  )
}
