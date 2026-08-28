import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");

serve(async (req) => {
  try {
    // 1. Tangkap Payload
    const payload = await req.json();
    const record = payload.record;
    const oldRecord = payload.old_record;

    const isJustLocked = record.is_locked === true && oldRecord?.is_locked === false;

    if (payload.type === "UPDATE" && isJustLocked) {
      const unlockToken = record.unlock_token;
      const workspaceId = record.id; 
      
      const unlockLink = `https://vodan.app/unlock?id=${workspaceId}&token=${unlockToken}`;

      // 2. Tembak API Resend
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: "VoDan Security <noreply@vodan.app>",
          to: ["email_owner_lapak@gmail.com"],
          subject: "🚨 Peringatan: Akses Lapak Terkunci",
          html: `
            <div style="font-family: sans-serif; max-width: 600px; margin: auto;">
              <h2 style="color: #d32f2f;">Keamanan Lapak Anda Sedang Terancam!</h2>
              <p>Halo,</p>
              <p>Sistem kami mendeteksi ada seseorang yang memasukkan PIN Lapak Anda secara salah sebanyak 3 kali berturut-turut.</p>
              <p>Untuk melindungi data transaksi dan pengaturan Anda, <b>kami telah mengunci lapak ini secara otomatis</b>.</p>
              <br/>
              <a href="${unlockLink}" style="padding: 12px 24px; background-color: #2196f3; color: white; text-decoration: none; border-radius: 6px; font-weight: bold;">
                Buka Kunci Lapak Sekarang
              </a>
              <br/><br/>
              <p style="font-size: 12px; color: #666;">Jika Anda merasa tidak melakukan ini, amankan perangkat yang biasa digunakan sebagai kasir. Link ini aman dan dibuat otomatis oleh sistem VoDan.</p>
            </div>
          `,
        }),
      });

      const resData = await res.json();
      
      return new Response(JSON.stringify(resData), { 
        status: res.ok ? 200 : 400,
        headers: { "Content-Type": "application/json" }
      });
    }

    // Jika bukan event penguncian lapak, abaikan dengan sukses
    return new Response(JSON.stringify({ message: "Ignored: Not a lock event" }), { 
      status: 200,
      headers: { "Content-Type": "application/json" }
    });

  } catch (error) {
    console.error("Error mengirim email:", error);
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 500,
      headers: { "Content-Type": "application/json" }
    });
  }
});