# Website Laporan Kegiatan & Keuangan IRMAS AL-MUMINUN

Aplikasi PHP Native OOP (MVC) untuk pencatatan kegiatan, keuangan, dan cetak laporan PDF organisasi IRMAS AL-MUMINUN.

## Persyaratan

- PHP 8.1+ (disarankan XAMPP dengan PHP 8.1/8.2)
- MySQL 8.0
- Apache dengan `mod_rewrite`
- Ekstensi PHP: `pdo_mysql`, `gd`, `fileinfo`, `mbstring`
- Composer (sudah disertakan `composer.phar` untuk memasang Dompdf)

## Langkah instalasi (XAMPP / localhost)

1. **Salin folder proyek** ke `C:\xampp\htdocs\Irmasweb` (atau `htdocs\irmas-almuminun`).

2. **Buat database dan import data dummy**
   - Buka phpMyAdmin: http://localhost/phpmyadmin
   - Import file `database.sql`
   - Atau dari terminal:
     ```
     C:\xampp\mysql\bin\mysql.exe -u root < C:\xampp\htdocs\Irmasweb\database.sql
     ```

3. **Sesuaikan koneksi MySQL** di `config/database.php`
   - Default XAMPP: user `root`, password kosong, database `irmas_almuminun`.

4. **Pasang Dompdf** (jika folder `vendor` belum ada):
   ```
   cd C:\xampp\htdocs\Irmasweb
   C:\xampp\php\php.exe -d extension=zip composer.phar install
   ```

5. **Pastikan folder unggahan bisa ditulis**
   - `assets/uploads/kegiatan`
   - `assets/uploads/bukti`

6. **Jalankan dummy gambar** (sekali saja, membuat foto kegiatan + bukti + logo PNG):
   ```
   C:\xampp\php\php.exe -d extension=gd tools/generate_dummy_images.php
   ```

7. **Nyalakan Apache & MySQL** di XAMPP Control Panel.

8. **Buka di browser**
   - http://localhost/Irmasweb/
   - Jika folder bernama `irmas-almuminun`: http://localhost/irmas-almuminun/

## Akses dari HP dan QR pembuka web

Untuk akses melalui internet, gunakan Cloudflare Tunnel pada komputer yang menjalankan XAMPP:

1. Instal `cloudflared`.
2. Jalankan Apache, lalu jalankan:
   ```
   cloudflared tunnel --url http://localhost/Irmasweb
   ```
3. Buka URL `https://...trycloudflare.com` yang ditampilkan.
4. Login pengurus dan buka `/donasi/akses` pada URL tunnel tersebut.
5. Scan QR code yang tampil. QR akan membuka URL tunnel yang sama dari HP.

URL tunnel sementara berubah jika proses dihentikan. Untuk URL tetap, gunakan tunnel bernama dan domain sendiri.

## Akun demo

| Role        | Username    | Password  |
|-------------|-------------|-----------|
| Admin       | admin       | admin123  |
| Bendahara   | bendahara   | admin123  |
| Sekretaris  | sekretaris  | admin123  |

- **Admin**: akses penuh.
- **Bendahara**: dashboard, keuangan, kategori, laporan keuangan.
- **Sekretaris**: dashboard, kegiatan, laporan kegiatan.

## Fitur

- Login session, hash password (`password_hash`), middleware role.
- Dashboard: saldo, pemasukan/pengeluaran bulan ini, jumlah kegiatan, Chart.js 6 bulan, 5 kegiatan terbaru.
- CRUD kegiatan + unggah banyak foto (JPG/PNG, maks 5MB), galeri, hapus foto, filter bulan/tahun.
- CRUD pemasukan & pengeluaran + bukti. Pengeluaran > Rp 100.000 wajib bukti.
- Buku kas gabungan, saldo otomatis = SUM(pemasukan) − SUM(pengeluaran).
- Laporan PDF (Dompdf): kegiatan (tabel + galeri 2 kolom), LPJ keuangan, Buku Kas Umum. Kop surat + kolom TTD Ketua & Bendahara.
- UI hijau `#16a34a`, sidebar Bootstrap 5, dark mode.

## Struktur

```
config/          koneksi & profil organisasi
core/            Router, Auth, Upload, Validator, PdfGenerator
controllers/
models/
views/
lib/FPDF/        library FPDF
assets/uploads/  hasil unggahan
```

Ubah nama ketua/bendahara/alamat di `config/app.php`.
