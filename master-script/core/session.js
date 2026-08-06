/**
 * ----------------------------------------------------------------------------
 * SESSION MANAGEMENT
 * ----------------------------------------------------------------------------
 */

/**
 * Clears the saved workspace session (UUID) from document properties.
 * 
 * @return {void}
 */
function clearSession(){
  PropertiesService.getDocumentProperties().deleteProperty('WORKSPACE_ID');
  SpreadsheetApp.getUi().alert('ℹ️ Info', 'Sesi Lapak dihapus. Silakan klik menu lagi untuk login baru.', SpreadsheetApp.getUi().ButtonSet.OK);
}