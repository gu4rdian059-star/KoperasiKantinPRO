SECTION 1: RELEASE GOALS
SekolahPRO — App Merchant merupakan aplikasi mobile yang digunakan oleh siswa, orang tua, dan merchant sekolah untuk melakukan transaksi pembelian secara cashless — termasuk kantin, koperasi (ATK & perlengkapan sekolah), dan merchant lainnya yang dapat ditambahkan sesuai kebutuhan. Aplikasi dilengkapi dengan fitur saldo digital (e-wallet), sistem token/voucher, informasi alergen menu kantin, dan notifikasi transaksi kepada orang tua — semua dalam satu aplikasi dengan sistem role-based access (Siswa / Orang Tua / Merchant).
SEKOLAHPRO — APP MERCHANT
FITUR INTI
Login & Registrasi Akun (Role-Based: Siswa / Orang Tua / Merchant),
Dashboard Saldo (e-Wallet), Top Up Saldo,
Katalog Produk per Merchant (Kantin & Koperasi/ATK),
Pembelian dengan Token/Voucher, Informasi Alergen Menu,
Monitoring & Notifikasi Orang Tua, Riwayat Transaksi,
Dashboard Kasir Merchant, Dashboard Admin Sekolah
KRITERIA SUKSES
99.9% uptime saat jam istirahat dan jam koperasi, transaksi selesai < 3 detik,
akurasi saldo 100%, notifikasi orang tua terkirim < 5 detik setelah transaksi,
support 300+ transaksi concurrent, onboarding merchant baru < 1 hari kerja
DEPENDENCIES
Database master produk per merchant (menu kantin, katalog ATK)
Sistem autentikasi berbasis role (NIS + PIN untuk siswa, nomor HP + OTP untuk orang tua)
Payment gateway untuk top up saldo
Koneksi internet stabil (minimum 3G) di lingkungan sekolah
IMPLEMENTASI SISTEM
Uji coba sistem dengan simulasi transaksi di kantin dan koperasi minimal 2 minggu sebelum go-live
Training staf tiap merchant (kasir kantin, kasir koperasi) dan admin sekolah
Sosialisasi kepada siswa dan orang tua terkait cara penggunaan SekolahPRO sesuai role masing-masing
Pendampingan awal implementasi pada minggu pertama operasional
Mekanisme onboarding merchant baru yang terdokumentasi untuk penambahan di masa mendatang
SECTION 2: USER STORIES
👨‍🎓 SISWA
LOGIN & REGISTRASI
Sebagai Siswa, saya ingin login menggunakan NIS dan PIN agar saya dapat mengakses saldo dan bertransaksi di semua merchant
Sebagai Siswa, saya ingin melihat pesan error yang jelas jika login gagal agar saya tahu letak kesalahan (NIS tidak ditemukan / PIN salah)
Sebagai Siswa, saya ingin mengubah PIN saya melalui menu pengaturan agar akun saya tetap aman
DASHBOARD SALDO
Sebagai Siswa, saya ingin melihat saldo saya saat ini agar saya tahu berapa uang yang tersedia untuk dibelanjakan
Sebagai Siswa, saya ingin melihat 5 transaksi terakhir di halaman utama agar saya dapat mengecek riwayat belanja dengan cepat
TOP UP SALDO
Sebagai Siswa, saya ingin melakukan top up saldo melalui transfer bank, QRIS, atau minimarket agar saya dapat mengisi saldo secara mandiri
Sebagai Siswa, saya ingin menerima notifikasi konfirmasi setelah top up berhasil agar saya yakin saldo sudah masuk
KATALOG MENU KANTIN
Sebagai Siswa, saya ingin melihat daftar menu kantin yang tersedia hari ini beserta foto, harga, dan label alergen agar saya dapat memilih dengan informasi yang cukup
Sebagai Siswa, saya ingin memfilter menu berdasarkan kategori (makanan berat, snack, minuman) agar pencarian lebih mudah
Sebagai Siswa, saya ingin mendapatkan peringatan pop-up jika menu yang saya pilih mengandung alergen yang sudah terdaftar di profil saya agar saya tidak salah pesan
KATALOG ATK & KOPERASI
Sebagai Siswa, saya ingin melihat daftar produk ATK dan perlengkapan sekolah di koperasi beserta harga dan stok agar saya tahu apa yang tersedia
Sebagai Siswa, saya ingin mencari produk ATK berdasarkan nama atau kategori agar pencarian lebih cepat
Sebagai Siswa, saya ingin membeli produk ATK menggunakan saldo SekolahPRO agar tidak perlu membawa uang tunai ke koperasi
PEMBELIAN DENGAN TOKEN / VOUCHER
Sebagai Siswa, saya ingin mendapatkan token/kode QR unik setiap transaksi agar saya dapat mengambil pesanan tanpa uang tunai
Sebagai Siswa, saya ingin menggunakan voucher diskon atau subsidi dari sekolah agar saya mendapatkan harga spesial di merchant tertentu
Sebagai Siswa, saya ingin melihat daftar voucher yang saya miliki beserta masa berlakunya agar saya tidak melewatkan voucher yang hampir kadaluarsa
RIWAYAT TRANSAKSI
Sebagai Siswa, saya ingin melihat riwayat semua transaksi pembelian saya di seluruh merchant agar saya dapat mengecek pengeluaran
Sebagai Siswa, saya ingin memfilter riwayat berdasarkan merchant atau rentang tanggal agar pencarian lebih mudah
👨‍👩‍👦 ORANG TUA
LOGIN & REGISTRASI
Sebagai Orang Tua, saya ingin mendaftar dan login ke SekolahPRO menggunakan nomor HP agar saya dapat memantau dan mengelola akun anak saya
Sebagai Orang Tua, saya ingin menghubungkan akun saya ke akun anak menggunakan kode verifikasi agar saya dapat melihat saldo dan aktivitas transaksi anak
Sebagai Orang Tua, saya ingin menghubungkan lebih dari satu akun anak ke akun saya agar saya dapat memantau semua anak dalam satu tampilan
Sebagai Orang Tua, saya ingin melihat pesan error yang jelas jika login gagal agar saya tahu letak kesalahannya
DASHBOARD SALDO
Sebagai Orang Tua, saya ingin melihat saldo anak saya di dashboard agar saya dapat memantau tanpa harus bertanya langsung ke anak
Sebagai Orang Tua, saya ingin melihat kartu per anak beserta saldo masing-masing agar pemantauan lebih mudah jika memiliki lebih dari satu anak
Sebagai Orang Tua, saya ingin menetapkan batas pengeluaran harian anak dari akun saya agar pengeluaran tetap terkontrol
TOP UP SALDO
Sebagai Orang Tua, saya ingin melakukan top up saldo anak langsung dari akun saya agar anak tidak perlu membawa uang tunai ke sekolah
Sebagai Orang Tua, saya ingin memilih metode top up yang fleksibel (transfer bank, QRIS, minimarket) agar proses top up lebih mudah
Sebagai Orang Tua, saya ingin menerima konfirmasi notifikasi setelah top up berhasil agar saya yakin saldo sudah masuk ke akun anak
INFORMASI ALERGEN
Sebagai Orang Tua, saya ingin mendaftarkan riwayat alergi anak melalui menu Profil Anak di akun saya agar aplikasi otomatis memperingatkan anak saat memilih menu berbahaya
Sebagai Orang Tua, saya ingin melihat dan memperbarui daftar alergen anak kapan saja agar data alergi selalu sesuai kondisi kesehatan anak terkini
Sebagai Orang Tua, saya ingin menerima notifikasi khusus jika anak saya tetap membeli menu yang mengandung alergen agar saya dapat segera menindaklanjuti
MONITORING & NOTIFIKASI
Sebagai Orang Tua, saya ingin menerima notifikasi push setiap kali anak saya melakukan transaksi di merchant manapun agar saya mengetahui apa yang dibeli dan di mana
Sebagai Orang Tua, saya ingin notifikasi menampilkan nama merchant, produk yang dibeli, harga, dan sisa saldo agar saya mendapat informasi lengkap dalam satu pesan
Sebagai Orang Tua, saya ingin menerima peringatan jika saldo anak mendekati batas minimum agar saya dapat segera melakukan top up
Sebagai Orang Tua, saya ingin melihat rekap pengeluaran anak per merchant secara mingguan/bulanan di dashboard saya agar saya dapat memantau pola belanja anak
Sebagai Orang Tua, saya ingin mengatur jenis notifikasi yang ingin saya terima agar notifikasi tidak mengganggu
RIWAYAT TRANSAKSI
Sebagai Orang Tua, saya ingin mengakses riwayat transaksi anak langsung dari akun saya agar saya dapat mengaudit pengeluaran tanpa perlu perangkat anak
Sebagai Orang Tua, saya ingin memfilter riwayat transaksi anak berdasarkan merchant atau rentang tanggal agar pencarian lebih mudah
Sebagai Orang Tua, saya ingin mengekspor riwayat transaksi anak ke PDF agar saya dapat menyimpan catatan pengeluaran
🏪 MERCHANT
LOGIN & MANAJEMEN AKUN
Sebagai Merchant, saya ingin login menggunakan username dan password agar saya dapat mengakses dashboard kasir merchant saya
Sebagai Merchant, saya ingin hanya dapat mengakses data merchant saya sendiri agar data antar merchant tetap terisolasi dan aman
KATALOG & STOK PRODUK
Sebagai Merchant, saya ingin menambahkan produk/menu baru beserta foto, harga, dan kategori agar katalog selalu lengkap dan informatif bagi pembeli
Sebagai Merchant, saya ingin mengedit atau menonaktifkan produk/menu yang sudah tidak tersedia agar siswa tidak memesan produk yang sudah tidak ada
Sebagai Merchant (Kantin), saya ingin menginput dan memperbarui informasi alergen setiap menu agar data alergen selalu akurat dan aman bagi siswa
Sebagai Merchant, saya ingin memperbarui stok produk secara realtime agar ketersediaan selalu terupdate
TRANSAKSI
Sebagai Merchant, saya ingin memindai QR token siswa menggunakan kamera HP agar transaksi dapat diproses dengan cepat dan akurat
Sebagai Merchant, saya ingin memasukkan kode token secara manual jika QR tidak terbaca agar transaksi tetap dapat diproses
Sebagai Merchant, saya ingin mendapat notifikasi bunyi/getar saat scan berhasil dan saat scan gagal agar saya tahu status transaksi dengan segera
Sebagai Merchant, saya ingin setiap transaksi tercatat otomatis dengan timestamp agar data penjualan selalu akurat
LAPORAN PENJUALAN
Sebagai Merchant, saya ingin melihat rekap penjualan hari ini (total pendapatan dan jumlah transaksi) agar saya dapat melakukan setor kas di akhir hari
Sebagai Merchant, saya ingin memfilter laporan penjualan berdasarkan rentang tanggal agar saya dapat menganalisis performa penjualan
SECTION 3: FUNCTIONAL / NON-FUNCTIONAL
LOGIN & REGISTRASI
SekolahPRO menggunakan sistem role-based login dalam satu aplikasi:
Role	Metode Login	Akses Utama
Siswa	NIS + PIN (6 digit)	Belanja, saldo, riwayat
Orang Tua	Nomor HP + OTP	Monitor anak, top up, notifikasi
Merchant	Username + Password	Dashboard kasir & manajemen produk
Admin Sekolah	Username + Password	Dashboard admin penuh
Halaman awal menampilkan pilihan role (Siswa / Orang Tua / Merchant) sebelum masuk ke form login
Tombol "Login" aktif hanya jika semua field terisi
Menampilkan pesan error:
"NIS tidak ditemukan dalam sistem" (Siswa)
"PIN yang Anda masukkan salah" (Siswa)
"Nomor HP tidak terdaftar" (Orang Tua)
"Username atau password salah" (Merchant)
"Akun Anda dinonaktifkan, hubungi admin"
Setelah login sukses, aplikasi menampilkan dashboard sesuai role masing-masing
Auto logout setelah 15 menit tidak ada aktivitas
Registrasi orang tua: input nomor HP → verifikasi OTP → input kode linking anak → akun terhubung
Satu akun orang tua dapat terhubung ke maksimal 5 akun anak
Reset PIN siswa: melalui orang tua yang sudah terhubung, atau admin sekolah
DASHBOARD SALDO (e-WALLET)
Tampilan Siswa
Menampilkan saldo saat ini dalam format Rupiah (Rp)
Menampilkan 5 transaksi terakhir di halaman utama (lintas merchant)
Tombol shortcut: "Top Up", "Merchant", "Riwayat"
Indikator warna saldo:
Kondisi	Warna	Keterangan
Saldo > Rp 20.000	Hijau (#4CAF50)	Cukup
Saldo Rp 5.000 – 20.000	Kuning (#FFC107)	Hampir habis
Saldo < Rp 5.000	Merah (#F44336)	Segera top up
Tampilan Orang Tua
Menampilkan kartu per anak beserta saldo masing-masing
Tombol "Top Up" dan "Riwayat" tersedia langsung di kartu setiap anak
Pengaturan batas pengeluaran harian per anak (default: tidak ada batas)
Notifikasi push aktif secara default; dapat diatur per jenis di menu Pengaturan
TOP UP SALDO
Top up dapat dilakukan dari akun Siswa maupun akun Orang Tua
Metode top up yang didukung:
No	Metode	Proses	Biaya Admin
1	Transfer Bank (BCA, BRI, Mandiri, BNI)	Virtual Account	Gratis
2	QRIS	Scan & bayar	Gratis
3	Minimarket (Indomaret, Alfamart)	Kode pembayaran	Rp 2.500
4	Top Up Manual oleh Admin	Dashboard admin	Gratis
Minimum top up: Rp 10.000
Maksimum saldo: Rp 500.000
Konfirmasi top up dikirim via notifikasi push ke akun yang melakukan top up dan ke akun orang tua yang terhubung
Saldo aktif maksimal 1 tahun akademik; sisa saldo dapat ditarik di akhir tahun
MULTI-MERCHANT
Halaman merchant menampilkan daftar merchant aktif dalam format kartu
Setiap kartu merchant menampilkan: nama merchant, kategori, jam operasional, status (buka/tutup)
Status merchant:
Status	Warna	Keterangan
Buka	Hijau (#4CAF50)	Dapat melakukan transaksi
Tutup Sementara	Kuning (#FFC107)	Dinonaktifkan oleh admin
Tutup Hari Ini	Abu-abu (#9E9E9E)	Di luar jam operasional
Merchant default yang tersedia saat pertama launch:
ID	Nama Merchant	Kategori
M001	Kantin Sekolah	Makanan & Minuman
M002	Koperasi Sekolah	ATK & Perlengkapan
Admin dapat menambah merchant baru melalui dashboard dengan mengisi: nama, kategori, jam operasional, akun kasir
Saldo siswa berlaku di semua merchant (tidak dipisah per merchant)
KATALOG MENU KANTIN
Menampilkan daftar menu dalam format kartu/grid dengan foto
Setiap kartu menu menampilkan: foto, nama, harga, status stok, badge alergen
Filter kategori: Makanan Berat, Snack, Minuman, Semua
Status stok menu:
Status	Badge	Kondisi
Tersedia	Hijau	Stok > 5 porsi
Hampir Habis	Kuning	Stok 1–5 porsi
Habis	Merah	Stok 0, tombol pesan nonaktif
Pull-to-refresh untuk memperbarui ketersediaan menu
KATALOG ATK & KOPERASI
Menampilkan daftar produk dalam format list/grid
Setiap kartu produk menampilkan: foto produk, nama, harga satuan, stok tersedia, kategori
Kategori produk koperasi:
Kategori	Contoh Produk
Alat Tulis	Pulpen, pensil, penghapus, penggaris
Buku & Kertas	Buku tulis, kertas HVS, binder
Perlengkapan Sekolah	Seragam, topi, dasi, badge
Peralatan Lain	Gunting, lem, staples, map
Fitur pencarian produk berdasarkan nama
Filter berdasarkan kategori dan ketersediaan stok
Produk diambil di kasir koperasi dengan token QR setelah transaksi dikonfirmasi
PEMBELIAN DENGAN TOKEN / VOUCHER
Alur transaksi berlaku untuk semua merchant:
Siswa membuka halaman merchant dan memilih produk/menu
Sistem menampilkan ringkasan pesanan dan total harga
Jika ada voucher, siswa memasukkan kode voucher
Siswa konfirmasi pembelian → saldo terpotong otomatis
Sistem menghasilkan token berupa kode QR unik (berlaku 30 menit)
Siswa menunjukkan QR ke kasir merchant
Kasir scan QR → pesanan terkonfirmasi → barang/makanan diserahkan
Token/QR bersifat one-time-use, tidak dapat digunakan ulang setelah di-scan
Jenis voucher yang didukung:
Tipe Voucher	Keterangan	Berlaku di	Diterbitkan oleh
Voucher Subsidi	Nominal tertentu untuk siswa penerima bantuan	Semua / merchant tertentu	Admin Sekolah
Voucher Diskon	Potongan persentase (%) dari total belanja	Merchant tertentu	Admin/Merchant
Voucher Hadiah	Nominal dari program reward sekolah	Semua merchant	Admin Sekolah
Satu transaksi dapat menggunakan maksimal 1 voucher
Voucher memiliki masa berlaku yang ditampilkan jelas di halaman voucher siswa
INFORMASI ALERGEN MENU
Hanya berlaku untuk produk di merchant Kantin; tidak diterapkan untuk ATK/Koperasi
Kategori alergen yang didukung:
Kode	Alergen	Ikon
SF	Seafood (ikan, udang, cumi)	🦐
ML	Susu & Produk Susu	🥛
EG	Telur	🥚
NT	Kacang-kacangan	🥜
GL	Gluten (tepung terigu)	🌾
SY	Kedelai	🫘
CH	Cabai / Pedas	🌶️
Badge alergen ditampilkan di kartu katalog dan halaman detail menu
Pendaftaran alergi anak dilakukan oleh orang tua melalui menu Profil Anak → Riwayat Alergi
Alur peringatan alergen:
Orang tua mendaftarkan alergi anak di akun SekolahPRO
Saat siswa memilih menu yang mengandung alergen terdaftar, aplikasi menampilkan pop-up peringatan
Pop-up berisi: nama alergen, deskripsi risiko, dan dua pilihan: "Batalkan" atau "Tetap Lanjutkan"
Jika siswa memilih "Tetap Lanjutkan", transaksi dicatat dengan flag alergen dan orang tua menerima notifikasi khusus
Merchant (Kantin) wajib menginput data alergen saat menambahkan menu baru
MONITORING & NOTIFIKASI ORANG TUA
Semua fitur monitoring diakses dari dalam SekolahPRO dengan role Orang Tua
Notifikasi dikirim via push notification di SekolahPRO dan SMS (opsional, berbayar)
Isi notifikasi transaksi:
```
  \\\[SekolahPRO] \\\[Nama Anak] baru saja membeli di \\\[Nama Merchant]:
  - \\\[Nama Produk] — Rp \\\[Harga]
  Total: Rp \\\[Total] | Sisa saldo: Rp \\\[Saldo]
  Waktu: \\\[HH:MM], \\\[Tanggal]
  ```
Isi notifikasi saldo rendah:
```
  \\\[SekolahPRO] Saldo \\\[Nama Anak] tersisa Rp \\\[Saldo].
  Tap di sini untuk top up sekarang.
  ```
Isi notifikasi alergen:
```
  \\\[SekolahPRO] Perhatian! \\\[Nama Anak] membeli \\\[Nama Menu] yang mengandung \\\[Alergen].
  Waktu: \\\[HH:MM], \\\[Tanggal]
  ```
Rekap mingguan dikirim setiap Jumat pukul 17.00: total pengeluaran, rincian per merchant, rata-rata per hari
Pengaturan notifikasi per jenis di menu Pengaturan akun orang tua:
Jenis Notifikasi	Default
Setiap transaksi	Aktif
Saldo rendah	Aktif
Peringatan alergen	Aktif
Rekap mingguan	Aktif
Top up berhasil	Aktif
RIWAYAT TRANSAKSI
Tampilan Siswa
Menampilkan daftar transaksi dalam urutan terbaru, lintas merchant
Filter: Hari ini, 7 hari terakhir, 30 hari terakhir, Per Merchant, Pilih tanggal
Setiap item menampilkan: tanggal & waktu, nama merchant, nama produk, nominal, jenis transaksi, status
Tampilan Orang Tua
Akses riwayat transaksi anak langsung dari dashboard orang tua tanpa perlu perangkat anak
Filter yang sama dengan tampilan siswa, ditambah filter per nama anak (jika lebih dari satu anak terhubung)
Fitur export riwayat ke PDF
Tampilan Admin
Unduh laporan transaksi format Excel/CSV dengan filter: per siswa, per kelas, per merchant, per rentang tanggal
DASHBOARD KASIR (MERCHANT)
Setiap merchant memiliki akun tersendiri dengan akses terbatas pada data merchant masing-masing
Fitur utama:
Fitur	Keterangan
Scan QR Token	Kamera HP membaca QR siswa untuk konfirmasi transaksi
Input Manual	Masukkan kode token secara manual jika QR tidak terbaca
Rekap Penjualan	Total pendapatan dan jumlah transaksi hari ini
Manajemen Produk/Menu	Tambah, edit, nonaktifkan produk beserta harga (dan alergen untuk kantin)
Update Stok	Ubah jumlah stok/ketersediaan produk secara realtime
Merchant tidak memiliki akses ke data saldo siswa, hanya memproses konfirmasi token
Notifikasi bunyi/getar saat scan berhasil dan saat scan gagal (token tidak valid/kadaluarsa)
Merchant A tidak dapat mengakses data atau transaksi Merchant B
DASHBOARD ADMIN SEKOLAH
Admin memiliki akses penuh ke semua merchant dan semua data transaksi
Fitur utama:
Fitur	Keterangan
Manajemen Merchant	Tambah, edit, aktifkan/nonaktifkan merchant
Manajemen Siswa	Import bulk, reset PIN, nonaktifkan akun
Manajemen Orang Tua	Lihat status linking orang tua-anak, generate kode linking ulang
Top Up Manual	Top up saldo siswa secara manual
Manajemen Voucher	Buat, distribusikan, dan nonaktifkan voucher
Laporan Keuangan	Rekap transaksi semua merchant, export Excel/PDF
Pengaturan Alergen	Kelola profil alergi siswa jika orang tua tidak bisa mandiri
NON-FUNCTIONAL
Aplikasi mobile single app, multi-role (Android minimum SDK 23 / Android 6.0, iOS minimum iOS 13)
UI menyesuaikan role setelah login: siswa, orang tua, dan merchant masing-masing mendapat tampilan dan menu yang berbeda
Waktu respon transaksi (scan QR hingga konfirmasi) < 3 detik
Uptime sistem minimal 99.9%, terutama saat jam istirahat dan jam koperasi
Sistem autentikasi menggunakan JWT dengan enkripsi AES-256 untuk data sensitif
Data transaksi disimpan di server dengan backup harian otomatis
Mendukung minimal 300 transaksi concurrent dalam satu waktu
Mode offline terbatas: katalog produk dapat dilihat tanpa internet, transaksi tetap membutuhkan koneksi
Keamanan: token QR di-generate dengan UUID v4 + timestamp, tidak dapat direplikasi
Arsitektur multi-tenant per merchant: data transaksi, produk, dan laporan tiap merchant terisolasi
Kepatuhan PCI-DSS level dasar untuk penanganan data pembayaran
Semua data personal siswa dan orang tua disimpan sesuai regulasi perlindungan data
