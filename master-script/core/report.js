/**
 * ----------------------------------------------------------------------------
 * PULL TRANSACTION REPORT LOGIC (Supabase ➔ Excel)
 * ----------------------------------------------------------------------------
 */

/**
 * Retrieves the transaction log for the workspace and writes it to the spreadsheet.
 * 
 * @return {void}
 */
function pullReport() {
  const ui = SpreadsheetApp.getUi();
  const workspaceId = getWorkspaceId();
  
  if (!workspaceId) {
    ui.alert('❌ Error Konfigurasi', 'WORKSPACE_ID belum diisi di dalam spreadsheet ini!', ui.ButtonSet.OK);
    return;
  }

  const sheet = SpreadsheetApp.getActiveSpreadsheet().getSheetByName(CONFIG.TAB_TRANSACTION_LOG);
  if (!sheet) {
    ui.alert('❌ Error', `Tab "${CONFIG.TAB_TRANSACTION_LOG}" tidak ditemukan!`, ui.ButtonSet.OK);
    return;
  }

  const endpoint = `${CONFIG.SUPABASE_URL}/rest/v1/transaction_log?workspace_id=eq.${workspaceId}&order=transaction_time.desc`;
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
    const responseCode = response.getResponseCode();

    if (responseCode !== 200) {
      ui.alert('❌ Gagal Tarik Data', `Error (${responseCode}):\n${response.getContentText()}`, ui.ButtonSet.OK);
      return;
    }

    const data = JSON.parse(response.getContentText());

    if (data.length === 0) {
      ui.alert('ℹ️ Info', 'Belum ada data transaksi yang tercatat di lapak ini.', ui.ButtonSet.OK);
      return;
    }

    if (sheet.getLastRow() > 1) {
      sheet.getRange(2, 1, sheet.getLastRow() - 1, 7).clearContent();
    }

    const rowsToInsert = [];
    let totalIncome = 0;

    data.forEach(trx => {
      let itemSummary = "";
      if (Array.isArray(trx.items)) {
        itemSummary = trx.items.map(item => `${item.name} (${item.qty}x)`).join(", ");
      }

      rowsToInsert.push([
        trx.id,
        new Date(trx.transaction_time),
        itemSummary,
        trx.total_price,
        trx.payment_method,
        trx.cashier_name || "Kasir",
        trx.status
      ]);

      if (trx.status === "paid") {
        totalIncome += (Number(trx.total_price) || 0);
      }
    });

    sheet.getRange(2, 1, rowsToInsert.length, 7).setValues(rowsToInsert);
    sheet.getRange(2, 2, rowsToInsert.length, 1).setNumberFormat("dd/MM/yyyy HH:mm:ss");

    const dataRange = sheet.getRange(2, 1, rowsToInsert.length, 7);
    dataRange.setWrap(true);
    dataRange.setVerticalAlignment("middle");

    sheet.autoResizeColumns(1, 7);
    sheet.autoResizeRows(2, rowsToInsert.length);

    ui.alert('✅ Laporan Diperbarui!', `Berhasil menarik ${data.length} transaksi.\nTotal Pendapatan Valid: Rp ${totalIncome.toLocaleString('id-ID')}`, ui.ButtonSet.OK);

  } catch (error) {
    ui.alert('❌ Error Koneksi', `Gagal menarik data: ${error.message}`, ui.ButtonSet.OK);
  }
}