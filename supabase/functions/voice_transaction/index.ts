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
    const { workspace_id, voice_text, available_languages } = await req.json()
    if (!workspace_id || !voice_text) throw new Error("Data tidak lengkap")

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient<Database>(supabaseUrl, supabaseServiceRoleKey);

    // 1. Tarik Data Workspace & Katalog Menu
    const { data: workspaceData } = await supabase
        .from('workspaces')
        .select('ai_keys')
        .eq('id', workspace_id)
        .single();

    const { data: productData } = await supabase
        .from('products')
        .select('id, name, nlp_alias, price, stock, sold')
        .eq('workspace_id', workspace_id)
        .eq('is_active', true);
    
    if (!workspaceData) throw new Error("Workspace tidak ditemukan")
    
    const aiKeys = workspaceData.ai_keys
    if (!aiKeys || aiKeys.length === 0) throw new Error("AI Key tidak ditemukan.")

    const supportedLanguages = (available_languages && available_languages.length > 0)
        ? available_languages.join(", ")
        : "id-ID, en-US";

    // 2. Siapkan System Prompt
    const systemPrompt = `
      You are an AI Cashier. Analyze the 'voice_text' to extract orders to JSON format and determine the user's intent.
      Menu List: ${JSON.stringify(productData)}.

      Rules:
      1. CLASSIFY INTENT: 
         - If the user is just greeting, making small talk, or asking non-order questions, set 'intent' to "chat".
         - If the user is ordering items from the menu, set 'intent' to "transaction".
      2. Match the product with 'nlp_alias' or 'name' ONLY if intent is "transaction". If "chat" or there is no product matched, leave the orders array empty.
      3. Make 'voice_response' (max 15 words) matching the style, tone, and personality of the fiction character mentioned. If nothing mentioned, create normal response with indonesian language.
      4. Define the speech configuration in 'tts_config' (pitch: 0.1-2.0, rate: 0.1-1.0).
      5. NATIVE LANGUAGE ENFORCEMENT: The 'voice_response' MUST be written entirely in the character's native language. For Japanese anime characters, you MUST generate the text using actual Japanese script (Kanji/Hiragana/Katakana), NOT English translations. ONLY the menu item name remains in Indonesian.
      6. TTS LANGUAGE LIMITATION (CRITICAL): 
         The user's device ONLY supports these TTS language codes: [${supportedLanguages}].
         - You MUST choose a 'language_code' strictly from that list.
         - If the character's native language (e.g., Japanese/ja-JP) is NOT in the list, DO NOT write the 'voice_response' in their native script. Instead, adapt their personality, catchphrases, and tone into Indonesian (id-ID) or English (en-US) depending on what is available in the list.
      7. MENTIONING PRICE: If intent is "transaction", you MUST include the exact placeholder [TOTAL_PRICE] in your 'voice_response' where the total price should be spoken. DO NOT calculate the math yourself. Example: "Pesanan siap! Totalnya [TOTAL_PRICE] ya. If intent is "chat", DO NOT include [TOTAL_PRICE] or mention any price."
      8. Create fallback response with example like this "Maaf, sistem sedang sibuk. Tolong ulangi pesanan." that matched the supported tts language codes.
    `;

    // 3. MESIN LOAD BALANCER & FALLBACK
    let finalJsonData = null;
    let lastErrorMessage = "";

    // Lakukan perulangan untuk setiap kunci yang terdaftar (prioritaskan Gemini, fallback ke GPT)
    for (const keyObj of aiKeys) {
      const provider = keyObj.provider.toLowerCase();
      // console.log('provider: ' + provider);
      // console.log('key: ' + keyObj.key);
      // console.log(`Provider: ${provider}, Key: ${keyObj.key ? 'ADA (Tiga Huruf Awal: ' + keyObj.key.substring(0,3) + ')' : 'KOSONG/UNDEFINED'}`);

      try {
        if (provider === 'gemini') {
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
                        intent: {
                          type: "string",
                          description: "The intent of the user. Must be strictly 'chat' or 'transaction'",
                          enum: ["chat", "transaction"]
                        },
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
                        fallback_response: {
                          type: "string",
                          description: "fallback response that matched the supported language codes"
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
                      required: ["intent", "orders", "voice_response", "fallback_response", "tts_config"]
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

    if (finalJsonData.intent === 'transaction'){
      if  (finalJsonData.orders && Array.isArray(finalJsonData.orders)) {
        let totalPrice = 0;
        let isStockAdjusted = false;

        finalJsonData.orders = finalJsonData.orders.map((order: any) => {
          const product = productData.find((p: any) => p.id === order.id);

          if (product && product.price) {
            const availableStock = product.stock - product.sold;

            if (availableStock <= 0) {
              isStockAdjusted = true;
              return null;
            }

            let finalQty = order.qty;
            if (finalQty > availableStock) {
              finalQty = availableStock;
              isStockAdjusted = true;
            }

            const subTotal = product.price * finalQty;
            totalPrice += subTotal;

            // Konstruk items
            return {
              id: order.id,
              name: product.name,
              price: product.price,
              qty: finalQty,
              subTotal: subTotal
            };
          }

          // Fallback jika produk tidak ditemukan
          return null;
        }).filter((item: any) => item != null);

        // Penambahan key & Value totalPrice ke data json
        finalJsonData.total_price = totalPrice;

        // Penambahan key & value isStockAdjusted
        finalJsonData.is_stock_adjusted = isStockAdjusted;

        // Respons total price yang dibaca flutter tts nant
        const aiLangCode = finalJsonData.tts_config?.language_code || 'id-ID';
        const formattedPrice = totalPrice.toLocaleString(aiLangCode);
        const totalPriceResponse = `${formattedPrice} rupiah`;

        if (finalJsonData.voice_response.includes('[TOTAL_PRICE]')) {
          finalJsonData.voice_response = finalJsonData.voice_response.replace('[TOTAL_PRICE]', totalPriceResponse);
        } else {
          finalJsonData.voice_response += ` Totalnya ${totalPriceResponse}.`;
        }
      }
    } else {
      finalJsonData.orders = [];
      finalJsonData.total_price = 0;
      finalJsonData.is_stock_adjusted = false;
    }

    console.log("Voice transaction selesai");

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