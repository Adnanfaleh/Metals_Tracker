import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req: Request) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  const apiKey = Deno.env.get('GOLD_API_KEY') ?? ''

  try {
    const goldRes = await fetch('https://www.goldapi.io/api/XAU/USD', {
      headers: { 'x-access-token': apiKey }
    })
    const goldData = await goldRes.json()
    
    // 🔍 DEBUG: Print exactly what GoldAPI gave us
    console.log("Raw Gold Data:", goldData)

    const silverRes = await fetch('https://www.goldapi.io/api/XAG/USD', {
      headers: { 'x-access-token': apiKey }
    })
    const silverData = await silverRes.json()
    
    // 🔍 DEBUG: Print exactly what GoldAPI gave us
    console.log("Raw Silver Data:", silverData)

    const troyOunceInGrams = 31.1034768;
    const goldGramPrice = goldData.price / troyOunceInGrams;
    const silverGramPrice = silverData.price / troyOunceInGrams;

    // 🌟 THE FIX: Add .throwOnError() so the function actually crashes if the DB rejects it
    const { error } = await supabase.from('market_prices').upsert([
      { asset_type: 'gold', price_usd: goldGramPrice, updated_at: new Date().toISOString() },
      { asset_type: 'silver', price_usd: silverGramPrice, updated_at: new Date().toISOString() }
    ]).throwOnError() 

    return new Response(JSON.stringify({ success: true, gold: goldGramPrice, silver: silverGramPrice }), { 
      headers: { "Content-Type": "application/json" },
      status: 200 
    })
  } catch (error: any) { 
    // 🔍 DEBUG: Print the exact reason it failed
    console.error("Function Failed:", error.message)
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})