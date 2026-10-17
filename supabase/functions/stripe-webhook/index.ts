import { serve } from "https://deno.land"
import { createClient } from "https://esm.sh"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    
    const supabase = createClient(supabaseUrl, supabaseServiceKey)
    const event = await req.json()

    switch (event.type) {
      case 'payment_intent.succeeded': {
        const paymentIntent = event.data.object
        const tradeOfferId = paymentIntent.metadata.tradeOfferId

        const { error } = await supabase
          .from('escrow_transactions')
          .update({ status: 'held_in_escrow', updated_at: new Date().toISOString() })
          .eq('trade_offer_id', tradeOfferId)

        if (error) throw error
        console.log(`[Stripe Webhook] Escrow actualizado con éxito para la oferta: ${tradeOfferId}`)
        break
      }
      
      case 'payment_intent.payment_failed': {
        const paymentIntent = event.data.object
        const tradeOfferId = paymentIntent.metadata.tradeOfferId
        
        console.log(`[Stripe Webhook] Intento de pago fallido para la oferta: ${tradeOfferId}`)
        break
      }

      case 'payment_intent.canceled': {
        const paymentIntent = event.data.object
        const tradeOfferId = paymentIntent.metadata.tradeOfferId

        const { error } = await supabase
          .from('escrow_transactions')
          .update({ status: 'refunded', updated_at: new Date().toISOString() })
          .eq('trade_offer_id', tradeOfferId)

        if (error) throw error
        console.log(`[Stripe Webhook] Transacción marcada como devuelta/cancelada: ${tradeOfferId}`)
        break
      }
    }

    return new Response(JSON.stringify({ received: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (err) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 400,
    })
  }
})
