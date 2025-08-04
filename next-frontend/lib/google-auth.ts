// Google OAuth Configuration and Service

interface GoogleAuthResponse {
  access_token: string
  id_token: string
  expires_in: number
  token_type: string
  scope: string
  error?: string
}

interface GoogleUserInfo {
  id: string
  email: string
  name: string
  given_name: string
  family_name: string
  picture?: string
  verified_email: boolean
}

class GoogleAuthService {
  private clientId: string
  private isInitialized = false

  constructor() {
    this.clientId = process.env.NEXT_PUBLIC_GOOGLE_CLIENT_ID || ''
  }

  /**
   * Initialize Google Identity Services
   */
  async initialize(): Promise<void> {
    if (this.isInitialized) return

    if (!this.clientId) {
      throw new Error('Google Client ID not configured. Please set NEXT_PUBLIC_GOOGLE_CLIENT_ID in your environment variables.')
    }

    console.log('Initializing Google Auth with Client ID:', this.clientId)
    console.log('Current origin:', window.location.origin)

    // Load Google Identity Services script
    if (!window.google) {
      console.log('Loading Google Identity Services script...')
      const script = document.createElement('script')
      script.src = 'https://accounts.google.com/gsi/client'
      script.async = true
      script.defer = true
      
      await new Promise<void>((resolve, reject) => {
        script.onload = () => {
          console.log('Google Identity Services script loaded successfully')
          resolve()
        }
        script.onerror = () => reject(new Error('Failed to load Google Identity Services'))
        document.head.appendChild(script)
      })
    }

    this.isInitialized = true
  }

  /**
   * Sign in with Google using popup
   */
  async signInWithPopup(): Promise<{ token: string; userInfo: GoogleUserInfo }> {
    await this.initialize()

    return new Promise((resolve, reject) => {
      if (!window.google?.accounts?.oauth2) {
        reject(new Error('Google Identity Services not loaded'))
        return
      }

      const client = window.google.accounts.oauth2.initTokenClient({
        client_id: this.clientId,
        scope: 'openid email profile',
        callback: async (response: GoogleAuthResponse) => {
          try {
            console.log('Google OAuth callback response:', response)
            
            if (response.error) {
              console.error('Google OAuth error:', response.error)
              reject(new Error(response.error || 'Google authentication failed'))
              return
            }

            if (!response.access_token) {
              console.error('No access token received:', response)
              reject(new Error('No access token received from Google'))
              return
            }

            console.log('Google OAuth success, fetching user info...')
            
            // Get user info using the access token
            const userInfo = await this.getUserInfo(response.access_token)
            console.log('User info received:', userInfo)
            
            resolve({
              token: response.access_token,
              userInfo
            })
          } catch (error) {
            console.error('Error processing Google auth response:', error)
            reject(error)
          }
        },
        error_callback: (error: any) => {
          console.error('Google OAuth error callback:', error)
          reject(new Error(error.message || 'Google authentication failed'))
        }
      })

      try {
        console.log('Requesting Google access token...')
        client.requestAccessToken()
      } catch (error) {
        console.error('Error requesting access token:', error)
        reject(new Error('Failed to initialize Google authentication'))
      }
    })
  }

  /**
   * Get user information using access token
   */
  private async getUserInfo(accessToken: string): Promise<GoogleUserInfo> {
    const response = await fetch('https://www.googleapis.com/oauth2/v2/userinfo', {
      headers: {
        Authorization: `Bearer ${accessToken}`
      }
    })

    if (!response.ok) {
      throw new Error('Failed to fetch user information from Google')
    }

    return response.json()
  }

  /**
   * Sign out from Google
   */
  async signOut(): Promise<void> {
    if (window.google?.accounts?.oauth2) {
      window.google.accounts.oauth2.revoke('', () => {
        console.log('Google access revoked')
      })
    }
  }
}

// Global Google API types
declare global {
  interface Window {
    google?: {
      accounts: {
        oauth2: {
          initTokenClient: (config: {
            client_id: string
            scope: string
            callback: (response: any) => void
            error_callback?: (error: any) => void
          }) => {
            requestAccessToken: () => void
          }
          revoke: (token: string, callback: () => void) => void
        }
      }
    }
  }
}

export const googleAuthService = new GoogleAuthService()
export type { GoogleUserInfo }
