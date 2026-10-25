# UangKu - Aplikasi Pencatatan Keuangan Pribadi

## Deskripsi Singkat
UangKu adalah aplikasi mobile berbasis Flutter yang dirancang untuk membantu pengguna mencatat dan mengelola keuangan pribadi (pemasukan dan pengeluaran) secara luring (offline). Aplikasi ini dikembangkan untuk memenuhi Tugas Ujian Tengah Semester (UTS) mata kuliah Pemrograman Multiplatform. Proyek ini mendemonstrasikan penerapan **Asynchronous Programming** serta dua teknik **Data Persistence** (SQLite dan Shared Preferences) sesuai dengan persyaratan tugas.

## Fitur Utama
- **Pencatatan Transaksi:** Pengguna dapat menambahkan data keuangan berupa 'Pemasukan' atau 'Pengeluaran' lengkap dengan keterangan, nominal, dan waktu transaksi secara instan.
- **Kategorisasi Tab (Tab Bar):** Tampilan riwayat transaksi diatur menggunakan tab agar rapi dan mudah difilter: Tab Pengeluaran, Tab Pemasukan, dan Tab Campur (menampilkan semua transaksi terbaru).
- **Pemisah Ribuan Otomatis (Auto-formatter):** Memudahkan pembacaan nominal mata uang dengan penambahan koma secara real-time saat pengetikan dan saat data ditampilkan (contoh: Rp 150,000).
- **Hapus Transaksi:** Mendukung penghapusan data transaksi melalui ikon tong sampah secara langsung.
- **Penyimpanan Luring (Offline Storage):** Seluruh data transaksi tersimpan dengan aman di basis data lokal perangkat. Aplikasi 100% fungsional tanpa memerlukan koneksi internet.
- **Preferensi Mode Gelap/Terang (Theme Toggle):** Pengguna dapat mengubah tema aplikasi. Status tema yang dipilih akan tersimpan secara persisten meskipun aplikasi telah ditutup (restart).

## Teknologi dan Package yang Digunakan
- **Flutter & Dart:** Framework dan bahasa pemrograman utama.
- **Asynchronous Programming:** Penggunaan blok `Future`, `async`, dan `await` secara ekstensif pada I/O database. Hal ini memastikan UI tidak *freeze* atau tertahan saat aplikasi sedang membaca atau menulis data.
- **sqflite (^2.3.0) & path (^1.8.3):** Diimplementasikan sebagai teknik **Data Persistence pertama**. Berfungsi untuk menyimpan data transaksi secara terstruktur di dalam basis data SQLite lokal.
- **shared_preferences (^2.2.1):** Diimplementasikan sebagai teknik **Data Persistence kedua**. Digunakan untuk menyimpan data sederhana berpasangan *key-value*, yaitu status preferensi tema pengguna (Dark Mode / Light Mode).
- **intl (^0.18.1):** Digunakan untuk melakukan *formatting* angka (memberikan pemisah koma pada nominal uang) dan *formatting* format tanggal/waktu transaksi agar lebih mudah dibaca (Human-readable).

## Langkah Menjalankan Aplikasi
Untuk menjalankan proyek ini di perangkat fisik atau emulator Anda, ikuti instruksi berikut:

1. **Clone Repositori Ini**
   Buka terminal dan jalankan perintah:
   ```bash
   git clone https://github.com/YakzIsGood/uts-multiplatform.git
