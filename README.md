# VoDan

VoDan adalah ekosistem Smart POS untuk membantu pemilik lapak dan kasir mengelola operasional penjualan dari satu tempat. Pemilik dapat membuat dan mengatur lapak, menyiapkan katalog serta pembayaran, lalu memantau transaksi dan stok. Kasir dapat masuk ke lapak yang ditugaskan, menerima pesanan, memproses pembayaran, dan bekerja melalui alur antrean yang terkontrol.

Data operasional disimpan di Supabase agar aplikasi Flutter, Google Spreadsheet, dan automasi backend dapat berbagi sumber data yang sama. Aplikasi tersedia untuk Android dan Web, dengan Google Apps Script sebagai pendamping untuk pengelolaan katalog dan laporan dari spreadsheet.

## Fitur Utama

- **Akun dan autentikasi**: registrasi, login, sesi pengguna, dan pengelolaan profil.
- **Manajemen lapak**: membuat lapak, memilih lapak aktif, membagikan ID lapak, serta mengubah nama dan konfigurasi lapak.
- **Akses kasir**: PIN lapak, device binding, waiting room, tiket akses, persetujuan atau penolakan kasir, dan penguncian otomatis saat sesi tidak aktif.
- **Katalog dan stok**: menampilkan produk aktif, harga, kategori, stok, status habis, serta jumlah produk terjual.
- **POS dan transaksi**: memilih produk, mengatur kuantitas, menghitung total, mencatat pelanggan, memilih metode pembayaran, dan menyimpan status transaksi.
- **Pembayaran lapak**: konfigurasi QRIS dan rekening transfer, upload gambar QRIS, serta tampilan instruksi pembayaran di kasir.
- **Transaksi berbasis suara**: speech-to-text, pemrosesan perintah transaksi melalui Edge Function, dan text-to-speech untuk umpan balik suara.
- **Integrasi AI**: konfigurasi API key per lapak dengan dukungan Gemini dan pilihan provider lain yang disiapkan untuk pengembangan berikutnya.
- **Riwayat dan dokumen**: melihat detail transaksi, membuat dokumen PDF, mencetak, serta membagikan hasil transaksi.
- **Sinkronisasi spreadsheet**: mengirim katalog produk dari Google Spreadsheet ke Supabase dan menarik laporan transaksi berdasarkan lapak.
- **Keamanan backend**: Supabase Auth, Row Level Security, verifikasi PIN ter-hash, pembatasan percobaan, Storage policy, dan Edge Functions.

## Gambaran Arsitektur

```text
Flutter Android/Web
	|
	+--> Supabase Auth, Postgres, Realtime, Storage, Edge Functions
	|
	+--> Google Apps Script <--> Google Spreadsheet
```

Flutter menjadi antarmuka utama untuk pemilik dan kasir. Supabase menangani autentikasi, database, sinkronisasi realtime, file QRIS, serta proses backend seperti transaksi suara dan email unlock. Google Apps Script menyediakan alur kerja spreadsheet untuk katalog dan laporan.

## Komponen

- `app/`: aplikasi Flutter untuk Android dan Web.
- `supabase/`: migration database, konfigurasi lokal, dan Edge Functions.
- `master-script/`: Google Apps Script untuk sinkronisasi katalog dan laporan transaksi dengan spreadsheet.
- `.github/workflows/`: workflow CI/CD untuk release APK dan deployment Web ke Vercel.

## Prasyarat

- Flutter SDK dan Dart SDK yang kompatibel dengan `app/pubspec.yaml`.
- Supabase CLI untuk deployment database dan Edge Functions.
- Node.js, npm, dan `clasp` untuk Google Apps Script.
- Akun GitHub dengan akses ke repository dan GitHub Actions.
- Akun Vercel untuk deployment Web.

## Setup Lokal

```powershell
cd app
flutter pub get
```

Buat file `app/.env` secara lokal:

```env
SUPABASE_URL=https://<project-ref>.supabase.co
SUPABASE_PUBLISHABLE_KEY=<publishable-key>
```

Generate file Dart yang diperlukan oleh Riverpod, router, dan Envied:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Jalankan pemeriksaan dan aplikasi:

```powershell
flutter analyze
flutter test
flutter run
```

Jangan commit `app/.env` atau file hasil generate yang memuat nilai rahasia.

## Signing Android

File signing production tidak disimpan di repository. Untuk build lokal, letakkan:

- keystore di `app/android/app/upload-keystore.jks`;
- konfigurasi di `app/android/key.properties`.

Contoh format konfigurasi tersedia di `app/android/key.properties.example`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=vodan-upload
storeFile=upload-keystore.jks
```

Build APK release:

```powershell
cd app
flutter build apk --release
```

Simpan keystore, password, dan alias sebagai backup yang aman. Jangan commit file `.jks` atau `key.properties`.

## Supabase

Jalankan perintah berikut dari root repository:

```powershell
supabase login
supabase link --project-ref <project-ref>
supabase db push
supabase functions deploy voice_transaction
supabase functions deploy send_unlock_email
```

Sebelum production, pastikan konfigurasi berikut sudah tersedia di Supabase:

- Auth dan redirect URL production.
- RLS policies untuk tabel dan Storage bucket.
- SMTP production untuk email unlock/reset password.
- Secret yang dibutuhkan Edge Functions.
- Bucket `workspace-qris` dan policy upload/read yang sesuai.

Uji migration pada project/staging terlebih dahulu sebelum menjalankan `supabase db push` ke production.

## Google Apps Script

Masuk ke folder script dan autentikasi project jika diperlukan:

```powershell
cd master-script
clasp login
clasp push
clasp deploy
```

Script memakai Supabase URL dan publishable key pada `master-script/config/env.js`. Pastikan spreadsheet memiliki tab berikut:

- `products (editable)`
- `transaction_log (uneditable)`

Setelah script terpasang, jalankan aktivasi workspace dari menu spreadsheet, kemudian uji sinkronisasi katalog dan penarikan laporan transaksi.

## Deployment Otomatis

### Web ke Vercel

Push ke branch `main` akan menjalankan `.github/workflows/deploy_web.yml` apabila ada perubahan pada `app/` atau workflow tersebut. Workflow akan membuat file environment, menjalankan generator, build Flutter Web, lalu deploy ke Vercel.

GitHub Actions secret yang diperlukan:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `VERCEL_TOKEN`

### APK ke GitHub Release

Push tag dengan pola `v*` akan menjalankan `.github/workflows/deploy_apk.yml` dan mengunggah APK release ke GitHub Release.

Tambahkan secrets berikut di repository GitHub:

- `SUPABASE_URL`
- `SUPABASE_PUBLISHABLE_KEY`
- `KEYSTORE_BASE64`
- `KEYSTORE_PASSWORD`
- `KEY_ALIAS`
- `KEY_PASSWORD`

Membuat nilai `KEYSTORE_BASE64` di PowerShell:

```powershell
[Convert]::ToBase64String(
	[IO.File]::ReadAllBytes(
		"C:\Users\<user>\path\to\app\android\app\upload-keystore.jks"
	)
)
```

Rilis versi baru:

```powershell
git add .
git commit -m "Prepare release v0.1.1"
git push origin main

git tag v0.1.1
git push origin v0.1.1
```

Naikkan `version` pada `app/pubspec.yaml` sebelum membuat tag baru. Formatnya adalah `versi+build`, misalnya `0.1.1+2`.

## Checklist Sebelum Production

- [ ] `flutter analyze` dan `flutter test` berhasil.
- [ ] Login, pembuatan workspace, PIN, produk, transaksi, QRIS, dan laporan sudah diuji.
- [ ] Migration Supabase berhasil di staging dan backup production tersedia.
- [ ] RLS, Auth redirect URL, Storage policy, SMTP, dan Edge Function secrets sudah benar.
- [ ] `app/.env`, keystore, `key.properties`, token Vercel, dan secret lain tidak masuk git.
- [ ] Versi aplikasi sudah dinaikkan.
- [ ] APK release terpasang dan diuji pada perangkat Android.
- [ ] Web production dapat login dan melakukan transaksi.
- [ ] Google Apps Script berhasil sync produk dan pull report.

## Troubleshooting Singkat

**Build APK gagal karena signing**

Pastikan `key.properties` berada di `app/android/key.properties`, sedangkan keystore berada di `app/android/app/upload-keystore.jks`. Nilai `storeFile` harus `upload-keystore.jks`.

**Generator Dart gagal**

Jalankan dari folder `app`:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

**Supabase CLI tidak menemukan project**

Jalankan `supabase link --project-ref <project-ref>` dari root repository, bukan dari folder `app`.

**Web berhasil build tetapi refresh route 404**

Pastikan `vercel.json` ikut disalin ke `app/build/web`. Workflow Web sudah melakukan langkah tersebut.
