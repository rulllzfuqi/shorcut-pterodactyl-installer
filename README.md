Berikut adalah template **`README.md`** untuk repositori GitHub yang berisi skrip Bash untuk mengotomatisasi instalasi Pterodactyl Panel dengan input otomatis, menggunakan lisensi **Apache 2.0**:

---

# shorcut-pterodactyl-installer (Shell)

Skrip ini dirancang untuk mengotomatiskan proses instalasi Pterodactyl Panel di server berbasis Linux (Ubuntu/Debian). Skrip ini menggunakan Bash murni dan `curl` untuk mengunduh serta menjalankan installer resmi Pterodactyl, dengan input otomatis untuk mempercepat proses instalasi.

## Fitur Utama

* **Instalasi Otomatis**: Mengotomatiskan proses instalasi Pterodactyl Panel dan Wings.
* **Input Otomatis**: Mengisi jawaban default untuk pertanyaan yang muncul selama instalasi.
* **Pengaturan Waktu dan Email**: Menyesuaikan zona waktu dan alamat email untuk konfigurasi Let's Encrypt dan Pterodactyl.
* **Pengaturan Domain**: Menanyakan dan mengonfigurasi Fully Qualified Domain Name (FQDN) untuk panel.
* **Lisensi Apache 2.0**: Skrip ini dilisensikan di bawah lisensi Apache License 2.0.

## Persyaratan Sistem

## 🖥️ Persyaratan Sistem Operasi dan PHP

| Sistem Operasi           | Versi Minimal | Status Dukungan | Versi PHP yang Disarankan |
|--------------------------|---------------|-----------------|---------------------------|
| **Ubuntu**               |               |                 |                           |
|                          | 14.04         | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 16.04         | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 18.04         | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 20.04         | ✅ Didukung      | 8.3                       |
|                          | 22.04         | ✅ Didukung      | 8.3                       |
|                          | 24.04         | ✅ Didukung      | 8.3                       |
| **Debian**               |               |                 |                           |
|                          | 8             | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 9             | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 10            | ✅ Didukung      | 8.3                       |
|                          | 11            | ✅ Didukung      | 8.3                       |
|                          | 12            | ✅ Didukung      | 8.3                       |
| **CentOS**               |               |                 |                           |
|                          | 6             | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 7             | 🔴 Tidak Didukung | 7.4 (EOL)                 |
|                          | 8             | 🔴 Tidak Didukung | 7.4 (EOL)                 |
| **Rocky Linux**          |               |                 |                           |
|                          | 8             | ✅ Didukung      | 8.3                       |
|                          | 9             | ✅ Didukung      | 8.3                       |
| **AlmaLinux**            |               |                 |                           |
|                          | 8             | ✅ Didukung      | 8.3                       |
|                          | 9             | ✅ Didukung      | 8.3                       |

* **Akses Root**: Skrip harus dijalankan dengan hak akses root.
* **Koneksi Internet**: Diperlukan untuk mengunduh dependensi dan skrip instalasi.

## Cara Penggunaan

1. **Unduh Skrip**:

   ```bash
   curl -s https://raw.githubusercontent.com/rulllzfuqi/shorcut-pterodactyl-installer/main/install.sh -o install.sh
   ```

2. **Beri Izin Eksekusi**:

   ```bash
   chmod +x install.sh
   ```

3. **Jalankan Skrip**:

   ```bash
   ./install.sh
   ```

   Selama eksekusi, skrip akan meminta Anda untuk memasukkan domain panel dan password admin. Masukkan informasi yang diminta sesuai petunjuk.

## Lisensi

Skrip ini dilisensikan di bawah [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0).

## ℹ️ Catatan

- Skrip ini **bukan bagian dari proyek resmi Pterodactyl** dan tidak dikembangkan oleh tim Pterodactyl.
- Skrip ini dikembangkan dan dipelihara oleh komunitas melalui [pterodactyl-installer](https://github.com/pterodactyl-installer/pterodactyl-installer).
- Pastikan server Anda memenuhi persyaratan sistem yang tercantum sebelum menjalankan skrip.
- Untuk dokumentasi resmi Pterodactyl, kunjungi [https://pterodactyl.io](https://pterodactyl.io).
- Skrip ini mendukung instalasi otomatis Pterodactyl Panel dan Wings pada sistem operasi berikut:
  - Ubuntu 20.04, 22.04, 24.04
  - Debian 10, 11, 12
  - Rocky Linux 8, 9
  - AlmaLinux 8, 9
- Skrip ini **tidak kompatibel** dengan:
  - Ubuntu 14.04, 16.04, 18.04
  - Debian 8, 9
  - CentOS 6, 7, 8
- **Disarankan untuk menggunakan versi PHP 8.3** atau lebih tinggi.
- Untuk informasi lebih lanjut dan pembaruan, kunjungi [https://pterodactyl-installer.se](https://pterodactyl-installer.se).

---

Jika Anda memerlukan bantuan lebih lanjut atau memiliki pertanyaan, silakan buka [issue](https://github.com/rulllzfuqi/shorcut-pterodactyl-installer/issues) di repositori ini.

---
