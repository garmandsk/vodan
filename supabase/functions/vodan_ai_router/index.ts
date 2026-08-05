import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { Database } from "./database.types.ts";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })

  try {
    const { workspace_id, voice_text } = await req.json()
    if (!workspace_id || !voice_text) throw new Error("Data tidak lengkap")

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient<Database>(supabaseUrl, supabaseServiceRoleKey);

    // 1. Tarik Data Workspace & Katalog Menu
    const { data: workspaceData } = await supabase.from('workspaces').select('ai_keys').eq('id', workspace_id).single()
    const { data: menuData } = await supabase.from('products').select('id, name, price, nlp_alias').eq('workspace_id', workspace_id).eq('is_active', true)
    
    if (!workspaceData) throw new Error("Workspace tidak ditemukan")
    
    const aiKeys = workspaceData.ai_keys
    if (!aiKeys || aiKeys.length === 0) throw new Error("AI Key tidak ditemukan.")

    // 2. Siapkan System Prompt
    const systemPrompt = `
      You are an AI Cashier. Extract the orders from voice text to JSON format.
      Menu List: ${JSON.stringify(menuData)}.

      Rules:
      1. Match the product with 'nlp_alias' or 'name'.
      2. Make 'voice_response' (max 15 words) matching the style, tone, and personality of the fiction character mentioned.
      3. Define the speech configuration in 'tts_config' (pitch: 0.1-2.0, rate: 0.1-1.0).
      4. NATIVE LANGUAGE ENFORCEMENT: The 'voice_response' MUST be written entirely in the character's native language. For Japanese anime characters, you MUST generate the text using actual Japanese script (Kanji/Hiragana/Katakana), NOT English translations. ONLY the menu item name remains in Indonesian.
      5. The 'language_code' MUST accurately reflect the script generated in 'voice_response' (e.g., use 'ja-JP' ONLY if the text is in Japanese script, 'en-US' for English).
      6. MENTIONING PRICE: You MUST include the exact placeholder [TOTAL_PRICE] in your 'voice_response' where the total price should be spoken. DO NOT calculate the math yourself. Example: "Pesanan siap! Totalnya [TOTAL_PRICE] ya."
    `;

    // 3. MESIN LOAD BALANCER & FALLBACK
    let finalJsonData = null;
    let lastErrorMessage = "";

    // Lakukan perulangan untuk setiap kunci yang terdaftar (prioritaskan Gemini, fallback ke GPT)
    for (const keyObj of aiKeys) {
      try {
        if (keyObj.provider === 'gemini') {
           // Eksekusi API Gemini
          const models = ['gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-3.1-flash-lite',];

          for (const model of models) {
            const controller = new AbortController();
            const timeoutId = setTimeout(() => {
              controller.abort();
            }, 4000);

            try {
              const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent`
              const res = await fetch(geminiUrl, {
                method: 'POST',
                signal: controller.signal,
                headers: { 
                  'x-goog-api-key': keyObj.key,
                  'Content-Type': 'application/json',
                },
                 body: JSON.stringify({
                  systemInstruction: { 
                    parts: [
                      { 
                        text: systemPrompt 
                      }
                    ] 
                  },
                  contents: [
                    { 
                      parts: [
                        { 
                          text: `${voice_text}"` 
                        }
                        
                      ] 
                    }
                  ],
                  generationConfig: {
                    thinkingConfig: {
                      thinkingLevel: "low" 
                    },
                    responseMimeType: "application/json",
                    responseSchema: {
                      type: "object",
                      properties: {
                        orders: {
                          type: "array",
                          description: "orders from the voice text",
                          items: {
                            type: "object",
                            properties: {
                              id: { type: "string", description: "id of the order" },
                              qty: { type: "integer", description: "quantity of the order" }
                            },
                            required: ["id", "qty"]
                          }
                        },
                        voice_response: {
                          type: "string",
                          description: "voice response of the character mentioned signaturely"
                        },
                        tts_config: {
                          type: "object",
                          properties: {
                            "language_code": { type: "string", description: "BCP-47 language code of the voice_response, e.g., 'id-ID', 'en-US', 'ja-JP'" },
                            pitch: { type: "number", description: "pitch value of the character mentioned" },
                            rate: { type: "number", description: "rate value of the character mentioned" }
                          },
                          required: ["language_code", "pitch", "rate"]
                        }
                      },
                      required: ["orders", "voice_response", "tts_config"]
                    }
                  }
                 })
               });

               clearTimeout(timeoutId);

               const aiResult = await res.json();
               if (!res.ok || aiResult.error) {
                const errorCode = res.status || (aiResult.error && aiResult.error.code);
                if (errorCode === 429) {
                  console.warn(`[Quota] Model ${model} habis/terkena limit. Melompat...`);
                  continue;
                }
                throw new Error(aiResult.error ? aiResult.error.message : "Gagal menghubungi Gemini");
               }
               
               // Parsing hasil Gemini
               finalJsonData = JSON.parse(aiResult.candidates[0].content.parts[0].text);
               break; // Berhasil! Keluar dari loop
              
            } catch (error: any) {
              clearTimeout(timeoutId);
              if (error.name === 'AbortError') {
                console.warn(`[Timeout] Model ${model} terlalu lama merespons. Melompat...`);
                continue;
              }

              throw error;
            }
          }

          // Saat data didapat
          if (finalJsonData) break;

        } else {
          throw new Error('Provider atau Model AI lain belum didukung.')
        }
      } catch (error: any) {
        // Jika gagal, simpan pesan error, lalu biarkan loop lanjut ke kunci berikutnya
        lastErrorMessage = error.message;
        console.error(`[Fallback Engine] Gagal dengan ${keyObj.provider}:`, lastErrorMessage);
      }
    }

    // 4. Cek Hasil Akhir
    // Jika loop selesai tapi finalJsonData masih kosong, berarti semua kunci mati
    if (!finalJsonData) {
      throw new Error(`Sistem AI Sedang Sibuk atau Kuota Lapak Habis. (Error Terakhir: ${lastErrorMessage})`);
    }

    if (finalJsonData.orders && Array.isArray(finalJsonData.orders)) {
      let totalPrice = 0;

      finalJsonData.orders.forEach((order: any) => {
        const product = menuData.find((p: any) => p.id == order.id);
        if (product && product.price) {
          totalPrice += product.price * order.qty;
        }
      });

      const totalPriceResponse = `${totalPrice.toLocaleString('id-ID')} rupiah`;

      if (finalJsonData.voice_response.includes('[TOTAL_PRICE]')) {
        finalJsonData.voice_response = finalJsonData.voice_response.replace('[TOTAL_PRICE]', totalPriceResponse);
      } else {
        finalJsonData.voice_response += ` Totalnya ${totalPriceResponse}.`;
      }
    }

    // 5. Kembalikan ke Flutter
    return new Response(
      JSON.stringify(finalJsonData),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )

  } catch (error: any) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 400 }
    )
  }
})