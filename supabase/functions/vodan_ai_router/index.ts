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
    const { workspace_id, teks_suara } = await req.json()
    if (!workspace_id || !teks_suara) throw new Error("Data tidak lengkap")

    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseKey = Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    const supabase = createClient<Database>(supabaseUrl, supabaseKey)

    // 1. Tarik Data Workspace & Katalog Menu
    const { data: workspaceData } = await supabase.from('workspaces').select('ai_keys').eq('id', workspace_id).single()
    const { data: menuData } = await supabase.from('product_catalogue').select('id, product_name, price, nlp_alias').eq('workspace_id', workspace_id).eq('is_active', true)
    
    if (!workspaceData) throw new Error("Workspace tidak ditemukan")
    
    const aiKeys = workspaceData.ai_keys
    if (!aiKeys || aiKeys.length === 0) throw new Error("Lapak ini belum mendaftarkan API Key AI")

    // 2. Siapkan System Prompt
    const systemPrompt = `
      Kamu adalah AI kasir. Ekstrak pesanan dari teks suara ke format JSON murni.
      Daftar Menu: ${JSON.stringify(menuData)}
      
      ATURAN MUTLAK:
      1. Cocokkan barang dengan 'nlp_alias' atau 'product_name'.
      2. Buat 'respons_suara' (maksimal 15 kata). Jika dipanggil karakter fiksi, tirukan gayanya.
      3. Tentukan 'tts_config' (pitch: 0.1-2.0, rate: 0.1-1.0).
      
      FORMAT OUTPUT WAJIB BERUPA JSON SEPERTI INI:
      {
        "pesanan": [{"id": "BRG-001", "qty": 2}],
        "respons_suara": "Siap Tuan Stark!",
        "tts_config": {"pitch": 1.2, "rate": 0.9}
      }
    `

    // 3. MESIN LOAD BALANCER & FALLBACK
    let finalJsonData = null;
    let lastErrorMessage = "";

    // Lakukan perulangan untuk setiap kunci yang terdaftar (prioritaskan Gemini, fallback ke GPT)
    for (const keyObj of aiKeys) {
      try {
        if (keyObj.provider === 'gemini') {
           // Eksekusi API Gemini
           const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${keyObj.key}`
           const res = await fetch(geminiUrl, {
             method: 'POST',
             headers: { 'Content-Type': 'application/json' },
             body: JSON.stringify({
               contents: [{ parts: [{ text: `Teks Suara: "${teks_suara}"` }] }],
               systemInstruction: { parts: [{ text: systemPrompt }] },
               generationConfig: { responseMimeType: "application/json", // Contoh JSON Schema yang dikirim ke Gemini
"schema": {
  "type": "OBJECT",
  "properties": {
    "pesanan": {
      "type": "ARRAY",
      "items": {
        "type": "OBJECT",
        "properties": {
          "id": { "type": "STRING" },
          "qty": { "type": "INTEGER" }
        }
      }
    },
    "respons_suara": { "type": "STRING" }
  },
  "required": ["pesanan", "respons_suara"]
} }
             })
           });
           const aiResult = await res.json();
           if (aiResult.error) throw new Error(aiResult.error.message);
           
           // Parsing hasil Gemini
           finalJsonData = JSON.parse(aiResult.candidates[0].content.parts[0].text);
           break; // Berhasil! Keluar dari loop

        } else if (keyObj.provider === 'gpt') {
           // Eksekusi API OpenAI (GPT)
           const openaiUrl = 'https://api.openai.com/v1/chat/completions';
           const res = await fetch(openaiUrl, {
             method: 'POST',
             headers: { 
               'Content-Type': 'application/json',
               'Authorization': `Bearer ${keyObj.key}`
             },
             body: JSON.stringify({
               model: 'gpt-4o-mini', // Versi GPT yang cepat dan murah
               response_format: { type: "json_object", // Contoh JSON Schema yang dikirim ke Gemini
"schema": {
  "type": "OBJECT",
  "properties": {
    "pesanan": {
      "type": "ARRAY",
      "items": {
        "type": "OBJECT",
        "properties": {
          "id": { "type": "STRING" },
          "qty": { "type": "INTEGER" }
        }
      }
    },
    "respons_suara": { "type": "STRING" }
  },
  "required": ["pesanan", "respons_suara"]
} }, // Memaksa format JSON
               messages: [
                 { role: 'system', content: systemPrompt },
                 { role: 'user', content: `Teks Suara: "${teks_suara}"` }
               ]
             })
           });
           const aiResult = await res.json();
           if (aiResult.error) throw new Error(aiResult.error.message);
           
           // Parsing hasil GPT
           finalJsonData = JSON.parse(aiResult.choices[0].message.content);
           break; // Berhasil! Keluar dari loop
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