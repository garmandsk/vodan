/**
 * Prompts the user to input their credentials to activate the workspace session.
 * 
 * @return {string|null} The workspace UUID if activation is successful, null otherwise.
 */
function activateWorkspace() {
  const ui = SpreadsheetApp.getUi();
  const props = PropertiesService.getDocumentProperties();

  const responseId = ui.prompt('🔐 Aktivasi', 'Masukkan ID Lapak (UUID):', ui.ButtonSet.OK_CANCEL);
  if(responseId.getSelectedButton() != ui.Button.OK) return null;

  const responsePin = ui.prompt('🔑 Keamanan', 'Masukkan PIN Lapak:', ui.ButtonSet.OK_CANCEL);
  if (responsePin.getSelectedButton() != ui.Button.OK) return null;

  const cleanWorkspaceId = responseId.getResponseText().trim();
  const cleanWorkspacePin = responsePin.getResponseText().trim();

  if (validateWorkspace(cleanWorkspaceId, cleanWorkspacePin)) {
    props.setProperty('WORKSPACE_ID', cleanWorkspaceId);
    ui.alert('✅ Berhasil', 'Lapak terhubung!', ui.ButtonSet.OK);
    return cleanWorkspaceId;
  } else {
    ui.alert('❌ Ditolak', 'ID atau PIN salah.', ui.ButtonSet.OK);
    return null;
  }
}

/**
 * Validates the workspace credentials against the database.
 * 
 * @param {string} workspaceId The UUID of the workspace.
 * @param {string} pin The security PIN of the workspace.
 * @return {boolean} True if credentials are valid, false otherwise.
 */
function validateWorkspace(workspaceId, pin) {
  const endpoint = `${CONFIG.SUPABASE_URL}/rest/v1/rpc/verify_workspace`;
  const options = {
    'method': 'post',
    'headers': {
      'apikey': CONFIG.SUPABASE_PUBLISHABLE_KEY,
      'Authorization': `Bearer ${CONFIG.SUPABASE_PUBLISHABLE_KEY}`,
      'Content-Type': 'application/json'
    },
    'payload': JSON.stringify({ "p_workspace_id": workspaceId, "p_pin": pin }),
    'muteHttpExceptions': true
  };
  try {
    return JSON.parse(UrlFetchApp.fetch(endpoint, options).getContentText()) === true;
  } catch (e) {
    return false;
  }
}

/**
 * Retrieves the active workspace ID from document properties or triggers activation if missing.
 * 
 * @return {string|null} The active workspace UUID, or null if activation was cancelled.
 */
function getWorkspaceId() {
  const props = PropertiesService.getDocumentProperties();
  let activeId = props.getProperty('WORKSPACE_ID');

  if (!activeId) {
    activeId = activateWorkspace();
  } 

  return activeId;
}