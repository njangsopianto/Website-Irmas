-- ==========================================================
-- Database Website Laporan Kegiatan & Keuangan IRMAS AL-MUMINUN
-- Sistem Informasi Manajemen Masjid & Remaja Masjid Profesional
-- ==========================================================

CREATE DATABASE IF NOT EXISTS irmas_almuminun CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE irmas_almuminun;

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS absensi;
DROP TABLE IF EXISTS settings;
DROP TABLE IF EXISTS foto_kegiatan;
DROP TABLE IF EXISTS pemasukan;
DROP TABLE IF EXISTS pengeluaran;
DROP TABLE IF EXISTS kegiatan;
DROP TABLE IF EXISTS kategori_keuangan;
DROP TABLE IF EXISTS password_resets;
DROP TABLE IF EXISTS users;

-- 1. Tabel Users
CREATE TABLE users (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama VARCHAR(100) NOT NULL,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin', 'bendahara', 'sekretaris') NOT NULL DEFAULT 'sekretaris',
    telepon VARCHAR(20) DEFAULT NULL,
    foto VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. Tabel Kegiatan
CREATE TABLE kegiatan (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_kegiatan VARCHAR(150) NOT NULL,
    tanggal DATE NOT NULL,
    waktu_mulai TIME DEFAULT '08:00:00',
    waktu_selesai TIME DEFAULT NULL,
    lokasi VARCHAR(150) NOT NULL,
    penanggung_jawab VARCHAR(100) DEFAULT NULL,
    deskripsi TEXT,
    anggaran DECIMAL(15,2) NOT NULL DEFAULT 0,
    realisasi DECIMAL(15,2) NOT NULL DEFAULT 0,
    status ENUM('Rencana', 'Berjalan', 'Selesai') NOT NULL DEFAULT 'Rencana',
    qr_code VARCHAR(100) UNIQUE DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 3. Tabel Foto Kegiatan (Multi Upload)
CREATE TABLE foto_kegiatan (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_kegiatan INT UNSIGNED NOT NULL,
    nama_file VARCHAR(255) NOT NULL,
    caption VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_foto_kegiatan FOREIGN KEY (id_kegiatan) REFERENCES kegiatan(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Tabel Kategori Keuangan
CREATE TABLE kategori_keuangan (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nama_kategori VARCHAR(100) NOT NULL,
    jenis ENUM('pemasukan', 'pengeluaran') NOT NULL,
    deskripsi VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 5. Tabel Pemasukan
CREATE TABLE pemasukan (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tanggal DATE NOT NULL,
    sumber_dana VARCHAR(150) NOT NULL,
    id_kategori INT UNSIGNED DEFAULT NULL,
    keterangan VARCHAR(255) DEFAULT NULL,
    jumlah DECIMAL(15,2) NOT NULL,
    bukti_file VARCHAR(255) DEFAULT NULL,
    created_by INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_in_kategori FOREIGN KEY (id_kategori) REFERENCES kategori_keuangan(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 6. Tabel Pengeluaran (Dengan Workflow Approval >1jt)
CREATE TABLE pengeluaran (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tanggal DATE NOT NULL,
    keperluan VARCHAR(150) NOT NULL,
    id_kategori INT UNSIGNED DEFAULT NULL,
    keterangan VARCHAR(255) DEFAULT NULL,
    jumlah DECIMAL(15,2) NOT NULL,
    bukti_file VARCHAR(255) DEFAULT NULL,
    status_approval ENUM('approved', 'pending', 'rejected') NOT NULL DEFAULT 'approved',
    catatan_approval TEXT DEFAULT NULL,
    approved_by INT UNSIGNED DEFAULT NULL,
    approved_at DATETIME DEFAULT NULL,
    created_by INT UNSIGNED DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_out_kategori FOREIGN KEY (id_kategori) REFERENCES kategori_keuangan(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- 7. Tabel Absensi QR Peserta
CREATE TABLE absensi (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    id_kegiatan INT UNSIGNED NOT NULL,
    nama VARCHAR(100) NOT NULL,
    telepon VARCHAR(20) DEFAULT NULL,
    email VARCHAR(100) DEFAULT NULL,
    status ENUM('Hadir', 'Izin', 'Sakit') NOT NULL DEFAULT 'Hadir',
    catatan VARCHAR(255) DEFAULT NULL,
    waktu_absen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_absensi_kegiatan FOREIGN KEY (id_kegiatan) REFERENCES kegiatan(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 8. Tabel Dynamic Settings
CREATE TABLE settings (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    key_name VARCHAR(100) NOT NULL UNIQUE,
    value_data LONGTEXT DEFAULT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 9. Tabel Activity Log (Audit Trail)
CREATE TABLE activity_logs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNSIGNED DEFAULT NULL,
    user_nama VARCHAR(100) DEFAULT 'Sistem',
    user_role VARCHAR(50) DEFAULT 'system',
    action VARCHAR(100) NOT NULL,
    module VARCHAR(50) NOT NULL,
    description TEXT,
    ip_address VARCHAR(45) DEFAULT NULL,
    user_agent VARCHAR(255) DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 10. Tabel Password Resets
CREATE TABLE password_resets (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) NOT NULL,
    token VARCHAR(255) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ==========================================================
-- SEED DATA AWAL
-- ==========================================================

-- Data Pengguna Default (Password default: admin123)
INSERT INTO users (nama, username, email, password, role, telepon) VALUES
('Administrator Utama', 'admin', 'admin@irmas.com', '$2y$10$71gigsuqxOVxJ8A4ZkNrfujqUZaKvqKeI2UvfGbYSeMoIQ5BCHOUi', 'admin', '0831-9957-8412'),
('Astri Novianti', 'bendahara', 'bendahara@irmas.com', '$2y$10$71gigsuqxOVxJ8A4ZkNrfujqUZaKvqKeI2UvfGbYSeMoIQ5BCHOUi', 'bendahara', '0812-3456-7890'),
('Putri Alawiyyah', 'sekretaris', 'sekretaris@irmas.com', '$2y$10$71gigsuqxOVxJ8A4ZkNrfujqUZaKvqKeI2UvfGbYSeMoIQ5BCHOUi', 'sekretaris', '0898-7654-3210');

-- Kategori Keuangan
INSERT INTO kategori_keuangan (nama_kategori, jenis, deskripsi) VALUES
('Infaq Jemaah', 'pemasukan', 'Infaq rutin jemaah shalat jumat dan harian'),
('Donasi & Sedekah', 'pemasukan', 'Donasi perorangan atau instansi untuk kegiatan remaja'),
('Iuran Anggota', 'pemasukan', 'Iuran bulanan anggota IRMAS'),
('Hibah DKM', 'pemasukan', 'Alokasi bantuan dana dari pengurus DKM Al-Muminun'),
('Konsumsi Kegiatan', 'pengeluaran', 'Makan, minum, snack rapat dan pengajian'),
('Perlengkapan & Sound', 'pengeluaran', 'Sewa atau beli alat, sound system, proyektor'),
('Transport & Akomodasi', 'pengeluaran', 'Transport panitia dan penceramah/narasumber'),
('Santunan Sosial & Yatim', 'pengeluaran', 'Program sosial, santunan yatim dan dhuafa'),
('Operasional & ATK', 'pengeluaran', 'Kertas, banner, cetak laporan, materai, kebersihan');

-- Data Kegiatan Default
INSERT INTO kegiatan (nama_kegiatan, tanggal, waktu_mulai, waktu_selesai, lokasi, penanggung_jawab, deskripsi, anggaran, realisasi, status, qr_code) VALUES
('Pengajian Rutin Remaja', '2026-08-15', '19:30:00', '21:30:00', 'Masjid Al-Muminun', 'Muhammad Bintang Hazazi', 'Kajian tafsir tematik bersama pemuda dan santri.', 500000, 475000, 'Selesai', 'QR-PENG-20260815'),
('Bakti Sosial & Santunan Yatim', '2026-08-22', '08:30:00', '12:00:00', 'Halaman Masjid Al-Muminun', 'Astri Novianti', 'Penyaluran 50 paket sembako dan santunan tunai anak yatim.', 2500000, 2450000, 'Selesai', 'QR-BAKSOS-20260822'),
('Kajian Akbar & Malam Bina Iman Taqwa (MABIT)', '2026-09-12', '18:00:00', '06:00:00', 'Masjid Al-Muminun', 'Putri Alawiyyah', 'Mabit remaja masjid se-Kecamatan Patokbeusi.', 3500000, 0, 'Berjalan', 'QR-MABIT-20260912'),
('Peringatan Maulid Nabi Muhammad SAW 1448 H', '2026-09-28', '19:30:00', '23:00:00', 'Aula Masjid Al-Muminun', 'Muhammad Bintang Hazazi', 'Tabligh akbar dan pentas seni hadroh remaja.', 5000000, 0, 'Rencana', 'QR-MAULID-20260928');

-- Foto Kegiatan
INSERT INTO foto_kegiatan (id_kegiatan, nama_file, caption) VALUES
(1, 'foto1.jpg', 'Dokumentasi suasana pengajian di ruang utama'),
(2, 'foto2.jpg', 'Penyerahan santunan kepada adik-adik yatim');

-- Data Pemasukan
INSERT INTO pemasukan (tanggal, sumber_dana, id_kategori, keterangan, jumlah, bukti_file) VALUES
('2026-08-01', 'Kotak Infaq Jumat Pertama', 1, 'Infaq jemaah shalat Jumat', 1750000, 'bukti_in_01.jpg'),
('2026-08-08', 'Donasi Hamba Allah (Alumni)', 2, 'Transfer untuk santunan yatim', 2500000, 'bukti_in_02.jpg'),
('2026-08-15', 'Iuran Anggota Bulan Agustus', 3, 'Iuran terkumpul dari 35 anggota', 700000, 'bukti_in_03.jpg'),
('2026-08-20', 'Bantuan Hibah DKM Al-Muminun', 4, 'Bantuan operasional program remaja', 2000000, 'bukti_in_04.jpg');

-- Data Pengeluaran
INSERT INTO pengeluaran (tanggal, keperluan, id_kategori, keterangan, jumlah, bukti_file, status_approval) VALUES
('2026-08-05', 'Beli ATK dan Buku Absensi', 9, 'Kertas HVS, map, binder', 175000, 'bukti_out_01.jpg', 'approved'),
('2026-08-15', 'Konsumsi Pengajian Remaja', 5, 'Snack dan air mineral 50 jemaah', 475000, 'bukti_out_02.jpg', 'approved'),
('2026-08-21', 'Belanja Paket Sembako Yatim', 8, '50 paket beras, minyak, gula', 2000000, 'bukti_out_03.jpg', 'approved'),
('2026-08-22', 'Sewa Sound System & Tenda', 6, 'Peralatan acara baksos', 450000, 'bukti_out_04.jpg', 'approved');

-- Absensi Contoh
INSERT INTO absensi (id_kegiatan, nama, telepon, email, status, catatan) VALUES
(1, 'Ahmad Fauzi', '08123456701', 'fauzi@gmail.com', 'Hadir', 'Tepat waktu'),
(1, 'Rifky Pratama', '08123456702', 'rifky@gmail.com', 'Hadir', 'Hadir bersama rombongan'),
(1, 'Siti Nurhaliza', '08123456703', 'siti@gmail.com', 'Hadir', 'Hadir'),
(2, 'Muhammad Bintang Hazazi', '083199578412', 'bintang@gmail.com', 'Hadir', 'Koordinator');

-- Dynamic Settings
INSERT INTO settings (key_name, value_data) VALUES
('nama_organisasi', 'IRMAS AL-MUMINUN'),
('nama_lengkap', 'Ikatan Remaja Masjid Al-Muminun'),
('nama_masjid', 'Masjid Al-Muminun'),
('kota', 'Subang'),
('alamat', 'Jl. Raya Patokbeusi No.32 Rt.027/013 Desa Rancamulya Kec. Patokbeusi Kab. Subang'),
('telepon', '0831-9957-8412'),
('email', 'irmas.almuminun@gmail.com'),
('ketua', 'Muhammad Bintang Hazazi'),
('bendahara', 'Astri Novianti'),
('sekretaris', 'Putri Alawiyyah'),
('tahun_berdiri', '2010'),
('motto', 'Bersama meramaikan masjid, membangun generasi berakhlak.'),
('target_infaq_bulanan', '10000000'),
('fonnte_token', ''),
('wa_notif_aktif', '0'),
('nomor_wa_admin', '083199578412'),
('qris_gambar', 'assets/img/qris_dummy.png'),
('qris_keterangan', 'Pindai kode QRIS di atas melalui mobile banking (BCA, Mandiri, BRI, BSI) atau dompet digital (GoPay, OVO, Dana, ShopeePay).'),
('bank_nama', 'Bank Syariah Indonesia (BSI)'),
('bank_rekening', '7123456789'),
('bank_atas_nama', 'IRMAS AL-MUMINUN SUBANG');

-- Activity Log Contoh
INSERT INTO activity_logs (user_id, user_nama, user_role, action, module, description, ip_address) VALUES
(1, 'Administrator Utama', 'admin', 'Inisialisasi Sistem', 'Pengaturan', 'Setup konfigurasi awal sistem IRMAS AL-MUMINUN', '127.0.0.1');
