/**
 * Prompts the user to input their credentials to activate the workspace session.
 *
 * @return {string|null} The workspace UUID if activation is successful, null otherwise.
 */
function activateWorkspace() {
  const ui = SpreadsheetApp.getUi();
  const documentProps = PropertiesService.getDocumentProperties();

  // Autentikasi Akun
  const responseEmail = ui.prompt(
    "Email Akun VoDan",
    "Masukkan Email akun di Aplikasi VoDan:",
    ui.ButtonSet.OK_CANCEL,
  );
  if (responseEmail.getSelectedButton() != ui.Button.OK) return null;

  const responsePassword = ui.prompt(
    "Password Akun VoDan",
    "Masukkan Password akun di Aplikasi VoDan:",
    ui.ButtonSet.OK_CANCEL,
  );
  if (responsePassword.getSelectedButton() != ui.Button.OK) return null;

  const cleanEmail = responseEmail.getResponseText().trim();
  const cleanPassword = responsePassword.getResponseText().trim();

  const accessToken = getSupabaseAccessToken();
  if (!accessToken) {
    signInSupabase(cleanEmail, cleanPassword);
  }

  // Autentikasi Lapak
  const responseId = ui.prompt(
    "🔐 Aktivasi",
    "Masukkan ID Lapak (UUID):",
    ui.ButtonSet.OK_CANCEL,
  );
  if (responseId.getSelectedButton() != ui.Button.OK) return null;

  const responsePin = ui.prompt(
    "🔑 Keamanan",
    "Masukkan PIN Lapak:",
    ui.ButtonSet.OK_CANCEL,
  );
  if (responsePin.getSelectedButton() != ui.Button.OK) return null;

  const cleanWorkspaceId = responseId.getResponseText().trim();
  const cleanWorkspacePin = responsePin.getResponseText().trim();

  if (validateWorkspace(cleanWorkspaceId, cleanWorkspacePin)) {
    documentProps.setProperty("WORKSPACE_ID", cleanWorkspaceId);
    ui.alert("✅ Berhasil", "Lapak terhubung!", ui.ButtonSet.OK);
    return cleanWorkspaceId;
  } else {
    ui.alert("❌ Ditolak", "ID atau PIN salah.", ui.ButtonSet.OK);
    return null;
  }
}

/**
 * SignIn the VoDan Account Credentials against the database.
 *
 * @param {string} email
 * @param {string} password
 */
function signInSupabase(email, password) {
  const endpoint = `${CONFIG.SUPABASE_URL}/auth/v1/token?grant_type=password`;

  const response = UrlFetchApp.fetch(endpoint, {
    method: "post",
    headers: {
      apikey: CONFIG.SUPABASE_PUBLISHABLE_KEY,
      "Content-Type": "application/json",
    },
    payload: JSON.stringify({
      email: email,
      password: password,
    }),
    muteHttpExceptions: true,
  });

  const result = JSON.parse(response.getContentText());

  if (response.getResponseCode() !== 200) {
    throw new Error(result.error_description || "Login Supabase gagal");
  }

  const props = PropertiesService.getUserProperties();
  props.setProperty("SUPABASE_USER_ID", result.user.id);
  props.setProperty("SUPABASE_ACCESS_TOKEN", result.access_token);
  if (result.refresh_token) {
    props.setProperty("SUPABASE_REFRESH_TOKEN", result.refresh_token);
  }

  return result.user.id;
}

/**
 * Refreshes the Supabase session when possible and returns an access token.
 *
 * @return {string|null} A valid access token, or null when re-login is needed.
 */
function getSupabaseAccessToken() {
  const props = PropertiesService.getUserProperties();
  const refreshToken = props.getProperty("SUPABASE_REFRESH_TOKEN");

  if (!refreshToken) {
    return props.getProperty("SUPABASE_ACCESS_TOKEN");
  }

  const endpoint = `${CONFIG.SUPABASE_URL}/auth/v1/token?grant_type=refresh_token`;

  try {
    const response = UrlFetchApp.fetch(endpoint, {
      method: "post",
      headers: {
        apikey: CONFIG.SUPABASE_PUBLISHABLE_KEY,
        "Content-Type": "application/json",
      },
      payload: JSON.stringify({ refresh_token: refreshToken }),
      muteHttpExceptions: true,
    });

    if (response.getResponseCode() !== 200) {
      props.deleteProperty("SUPABASE_USER_ID");
      props.deleteProperty("SUPABASE_ACCESS_TOKEN");
      props.deleteProperty("SUPABASE_REFRESH_TOKEN");
      return null;
    }

    const result = JSON.parse(response.getContentText());
    props.setProperty("SUPABASE_ACCESS_TOKEN", result.access_token);
    if (result.refresh_token) {
      props.setProperty("SUPABASE_REFRESH_TOKEN", result.refresh_token);
    }

    return result.access_token;
  } catch (e) {
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
  const accessToken = getSupabaseAccessToken();

  if (!accessToken) {
    throw new Error("Belum login ke Supabase");
  }

  const options = {
    method: "post",
    headers: {
      apikey: CONFIG.SUPABASE_PUBLISHABLE_KEY,
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    payload: JSON.stringify({
      p_workspace_id: workspaceId,
      p_device_id: getDeviceId(),
      p_input_pin: sha256Hex(pin),
    }),
    muteHttpExceptions: true,
  };
  try {
    const response = UrlFetchApp.fetch(endpoint, options);
    const result = JSON.parse(response.getContentText());
    return (
      response.getResponseCode() >= 200 &&
      response.getResponseCode() < 300 &&
      result.status === "success"
    );
  } catch (e) {
    return false;
  }
}

/**
 * Returns a stable UUID for this spreadsheet installation.
 * The ID is generated once and reused for later RPC calls.
 *
 * @return {string} The device UUID.
 */
function getDeviceId() {
  const props = PropertiesService.getDocumentProperties();
  let deviceId = props.getProperty("DEVICE_ID");

  if (!deviceId) {
    deviceId = Utilities.getUuid();
    props.setProperty("DEVICE_ID", deviceId);
  }

  return deviceId;
}

/**
 * Hashes the PIN in the same format used by the Flutter client.
 *
 * @param {string} pin The plain-text PIN.
 * @return {string} The lowercase SHA-256 hex digest.
 */
function sha256Hex(pin) {
  const digest = Utilities.computeDigest(
    Utilities.DigestAlgorithm.SHA_256,
    pin,
    Utilities.Charset.UTF_8,
  );

  return digest
    .map(function (byte) {
      const value = byte < 0 ? byte + 256 : byte;
      return `0${value.toString(16)}`.slice(-2);
    })
    .join("");
}

/**
 * Retrieves the active workspace ID from document properties or triggers activation if missing.
 *
 * @return {string|null} The active workspace UUID, or null if activation was cancelled.
 */
function getWorkspaceId() {
  const props = PropertiesService.getDocumentProperties();
  let activeId = props.getProperty("WORKSPACE_ID");

  if (!activeId) {
    activeId = activateWorkspace();
  }

  return activeId;
}
