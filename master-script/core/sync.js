/**
 * ----------------------------------------------------------------------------
 * SYNC LOGIC (Excel ➔ Supabase)
 * ----------------------------------------------------------------------------
 */

/**
 * Synchronizes the product catalog from the spreadsheet to the Supabase database.
 * 
 * @return {void}
 */
function syncProducts() {
  const ui = SpreadsheetApp.getUi();
  const workspaceId = getWorkspaceId();
  
  if (!workspaceId) {
    ui.alert('❌ Error Konfigurasi', 'WORKSPACE_ID belum diisi di dalam spreadsheet ini!', ui.ButtonSet.OK);
    return;
  }

  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(CONFIG.TAB_PRODUCTS);
  if (!sheet) {
    ui.alert('❌ Error', `Tab "${CONFIG.TAB_PRODUCTS}" tidak ditemukan di spreadsheet ini!`, ui.ButtonSet.OK);
    return;
  }

  const values = sheet.getDataRange().getValues();
  if (values.length <= 1) {
    ui.alert('⚠️ Peringatan', 'Data katalog kosong! Silakan isi minimal 1 barang.', ui.ButtonSet.OK);
    return;
  }

  const payloadArray = [];

  // Loop starting from row 2 (index 1) to skip header
  for (let i = 1; i < values.length; i++) {
    const row = values[i];
    const productId = String(row[0]).trim();
    const productName = String(row[1]).trim();
    
    if (!productId || !productName) continue;

    const categoryRaw = String(row[2]).trim();
    const aliasRaw = String(row[3]).trim(); 
    const aliasArray = aliasRaw ? aliasRaw.split(',').map(item => item.trim()) : [productName.toLowerCase()];

    payloadArray.push({
      "id": productId,
      "workspace_id": workspaceId, 
      "name": productName,
      "category": categoryRaw,
      "nlp_alias": aliasArray,
      "price": Number(row[4]) || 0,
      "stock": Number(row[5]) || 0,
      "is_active": Boolean(row[8])
    });
  }

  const endpoint = `${CONFIG.SUPABASE_URL}/rest/v1/products?on_conflict=workspace_id,id`;
  const options = {
    'method': 'post',
    'contentType': 'application/json',
    'headers': {
      'apikey': CONFIG.SUPABASE_PUBLISHABLE_KEY,
      'Authorization': `Bearer ${CONFIG.SUPABASE_PUBLISHABLE_KEY}`,
      'Prefer': 'resolution=merge-duplicates'
    },
    'payload': JSON.stringify(payloadArray),
    'muteHttpExceptions': true
  };

  try {
    const response = UrlFetchApp.fetch(endpoint, options);
    const responseCode = response.getResponseCode();

    if (responseCode === 200 || responseCode === 201) {
      ui.alert('✅ Sukses!', `Berhasil menyinkronkan ${payloadArray.length} barang ke aplikasi lapangan!`, ui.ButtonSet.OK);
    } else {
      ui.alert('❌ Gagal Sync', `Error Supabase (${responseCode}):\n${response.getContentText()}`, ui.ButtonSet.OK);
    }
  } catch (error) {
    ui.alert('❌ Error Koneksi', `Gagal menghubungi server: ${error.message}`, ui.ButtonSet.OK);
  }
}