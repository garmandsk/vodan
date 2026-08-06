/**
 * ----------------------------------------------------------------------------
 * UI MENU CREATION
 * Note: The function names in .addItem() ('runSync', 'runPullReport', etc.)
 * MUST match the wrapper function names inside the client's spreadsheet!
 * ----------------------------------------------------------------------------
 */

/**
 * Creates the custom admin menu in the Google Sheets UI.
 * 
 * @return {void}
 */
function createMenu() {
  const ui = SpreadsheetApp.getUi();
  ui.createMenu('⚡ VoDan Admin')
    .addItem('🔄 1. Sync Produk ke Database', 'runSync')
    .addSeparator()
    .addItem('📦 2. Cek Stok Terjual (Update Sheet)', 'runCheckStock')
    .addSeparator()
    .addItem('📊 3. Tarik Laporan Transaksi Hari Ini dari Database', 'runPullReport')
    .addSeparator()
    .addItem('🗑️ 4. Hapus Sesi Lapak', 'runClearSession')
    .addToUi();
}