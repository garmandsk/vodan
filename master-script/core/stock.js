/**
 * ----------------------------------------------------------------------------
 * PULL SOLD STOCK LOGIC (Supabase ➔ Excel)
 * ----------------------------------------------------------------------------
 */

/**
 * Fetches sold stock quantities from Supabase and updates the spreadsheet.
 * 
 * @return {void}
 */
function checkStock() {
  const ui = SpreadsheetApp.getUi();
  const workspaceId = getWorkspaceId();
  
  if (!workspaceId) {
    ui.alert('❌ Error Konfigurasi', 'WORKSPACE_ID belum diisi di dalam spreadsheet ini!', ui.ButtonSet.OK);
    return;
  }

  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(CONFIG.TAB_PRODUCTS);
  if (!sheet) {
    ui.alert('❌ Error', `Tab "${CONFIG.TAB_PRODUCTS}" tidak ditemukan!`, ui.ButtonSet.OK);
    return;
  }

  const endpoint = `${CONFIG.SUPABASE_URL}/rest/v1/products?workspace_id=eq.${workspaceId}&select=id,sold`;
  const options = {
    'method': 'get',
    'headers': {
      'apikey': CONFIG.SUPABASE_PUBLISHABLE_KEY,
      'Authorization': `Bearer ${CONFIG.SUPABASE_PUBLISHABLE_KEY}`
    },
    'muteHttpExceptions': true
  };

  try {
    const response = UrlFetchApp.fetch(endpoint, options);
    const data = JSON.parse(response.getContentText());

    const dbStockMap = {};
    data.forEach(item => {
      dbStockMap[String(item.id).trim()] = item.sold || 0;
    });

    const lastRow = sheet.getLastRow();
    if (lastRow < 2) {
      ui.alert('ℹ️ Info', 'Tidak ada data produk di dalam Sheet.', ui.ButtonSet.OK);
      return;
    }

    const values = sheet.getRange(2, 1, lastRow - 1, 8).getValues();
    const stockUpdates = [];
    let matchCount = 0;
    let validProductCount = 0;

    for (let i = 0; i < values.length; i++) {
      const sheetId = String(values[i][0]).trim();
      
      if (!sheetId) {
        break; 
      }

      validProductCount++;
      const initialStock = Number(values[i][5]) || 0;
      let soldStock = 0;

      if (dbStockMap[sheetId] !== undefined) {
        soldStock = dbStockMap[sheetId];
        matchCount++;
      } else {
        soldStock = Number(values[i][6]) || 0;
      }

      const remainingStock = initialStock - soldStock;
      stockUpdates.push([soldStock, remainingStock]);
    }

    if (stockUpdates.length > 0) {
      // getRange(row, column, numRow, numColumn)
      sheet.getRange(2, 7, stockUpdates.length, 2).setValues(stockUpdates);
    }

    ui.alert('✅ Sinkronisasi Selesai', 
      `Total Produk Valid: ${validProductCount} item\n` +
      `Berhasil Disinkronkan: ${matchCount} item`, 
      ui.ButtonSet.OK);

  } catch (error) {
    ui.alert('❌ Error Koneksi', `Gagal menarik data: ${error.message}`, ui.ButtonSet.OK);
  }
}