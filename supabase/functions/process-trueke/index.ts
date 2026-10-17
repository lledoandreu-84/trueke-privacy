const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-trueke-signature',
}

function base64url(source: ArrayBuffer | string): string {
  let buf: Uint8Array
  if (typeof source === 'string') {
    buf = new TextEncoder().encode(source)
  } else {
    buf = new Uint8Array(source)
  }
  let binary = ''
  for (let i = 0; i < buf.byteLength; i++) {
    binary += String.fromCharCode(buf[i])
  }
  return btoa(binary).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
}

async function getFcmAccessToken(serviceAccountJson: string): Promise<string> {
  const credentials = JSON.parse(serviceAccountJson)
  const header = { alg: 'RS256', typ: 'JWT' }
  const iat = Math.floor(Date.now() / 1000)
  const exp = iat + 3600
  
  const payload = {
    iss: credentials.client_email,
    scope: 'https://googleapis.com',
    aud: 'https://googleapis.com',
    exp: exp,
    iat: iat
  }

  const encodedHeader = base64url(JSON.stringify(header))
  const encodedPayload = base64url(JSON.stringify(payload))
  const tokenString = `${encodedHeader}.${encodedPayload}`

  const pemHeader = "-----BEGIN PRIVATE KEY-----"
  const pemFooter = "-----END PRIVATE KEY-----"
  const pemContents = credentials.private_key
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\s+/g, "")
    
  const binaryDerString = atob(pemContents)
  const binaryDer = new Uint8Array(binaryDerString.length)
  for (let i = 0; i < binaryDerString.length; i++) {
    binaryDer[i] = binaryDerString.charCodeAt(i)
  }

  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8',
    binaryDer.buffer,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false,
    ['sign']
  )

  const signature = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(tokenString)
  )

  const signedJwt = `${tokenString}.${base64url(signature)}`

  const response = await fetch('https://googleapis.com', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${signedJwt}`
  })

  const data = await response.json()
  if (!response.ok) throw new Error(`Fallo OAuth2 Google: ${JSON.stringify(data)}`)
  return data.access_token
}

// Validar firma HMAC-SHA256 de forma asíncrona y nativa
async function verifyHmacSignature(rawBody: string, incomingSignature: string, secretKey: string): Promise<boolean> {
  const encoder = new TextEncoder()
  const keyData = encoder.encode(secretKey)
  const messageData = encoder.encode(rawBody)

  const cryptoKey = await crypto.subtle.importKey(
    "raw",
    keyData,
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"]
  )

  const signatureBuffer = await crypto.subtle.sign("HMAC", cryptoKey, messageData)
  
  // Convertir a representación hexadecimal para confrontación idéntica con Postgres hmac()
  const hashArray = Array.from(new Uint8Array(signatureBuffer))
  const computedHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')
  
  return computedHex === incomingSignature
}

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    const firebaseAccount = Deno.env.get('FIREBASE_SERVICE_ACCOUNT') ?? ''
    const signingKey = Deno.env.get('TRUEKE_INTERNAL_SIGNING_KEY') ?? ''
    const authorization = req.headers.get('Authorization') ?? ''
    const incomingSignature = req.headers.get('X-Trueke-Signature') ?? ''

    // Leer el cuerpo en crudo una sola vez para no invalidar el stream de lectura
    const rawBody = await req.text()
    const body = JSON.parse(rawBody)
    
    if (body.action === 'STATUS_CHANGED') {
      // Validar integridad criptográfica de origen de forma obligatoria
      const isSignatureValid = await verifyHmacSignature(rawBody, incomingSignature, signingKey)
      if (!isSignatureValid) {
        return new Response(
          JSON.stringify({ error: "Firma inválida o ausente. Acceso denegado." }),
          { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 403 }
        )
      }

      const { receiver_id, new_status, trueke_id } = body

      const response = await fetch(
        `${supabaseUrl}/rest/v1/user_push_tokens?user_id=eq.${receiver_id}&select=token`,
        {
          headers: {
            'apikey': supabaseAnonKey,
            'Authorization': authorization,
            'Content-Type': 'application/json'
          }
        }
      )

      const tokens = await response.json()
      const tokenData = tokens?.[0]

      if (tokenData?.token && firebaseAccount) {
        const credentials = JSON.parse(firebaseAccount)
        const accessToken = await getFcmAccessToken(firebaseAccount)
        const fcmUrl = `https://googleapis.com{credentials.project_id}/messages:send`
        
        await fetch(fcmUrl, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            message: {
              token: tokenData.token,
              notification: {
                title: "Actualización de tu Trueke 🔄",
                body: `El estado de tu intercambio ha cambiado a: ${new_status}`
              },
              data: {
                trueke_id: String(trueke_id),
                status: String(new_status)
              }
            }
          })
        })
        console.log(`[FCM] Notificación push enviada con éxito al token del usuario.`);
      }

      return new Response(
        JSON.stringify({ success: true, message: "Flujo de notificación FCM completado y verificado" }),
        { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
      )
    }

    return new Response(
      JSON.stringify({ success: true, message: "Llamada directa procesada" }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 200 }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, "Content-Type": "application/json" }, status: 400 }
    )
  }
})
