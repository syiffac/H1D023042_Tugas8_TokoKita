# 🛒 **Tokokita — Flutter Product Management App**

Tokokita adalah aplikasi Flutter untuk manajemen produk dengan fitur lengkap: Login, Registrasi, List Produk, Detail Produk, dan Form Produk (Tambah/Edit/Hapus).
Aplikasi ini terintegrasi dengan REST API dan memiliki UI modern dengan gradient, animasi, dan desain yang eye-catching.

---

## 🧍‍♀️ **Identitas**

| Field | Value |
|-------|-------|
| **Nama** | Aisyah Syifa Karima |
| **NIM** | H1D023042 |
| **Shift Lama** | Shift C |
| **Shift Baru** | Shift A |

---

## 📁 **Struktur Project**

```txt
lib/
├── main.dart                    # Entry point aplikasi
├── bloc/
│   ├── login_bloc.dart          # API call untuk login
│   ├── logout_bloc.dart         # API call untuk logout
│   ├── produk_bloc.dart         # API CRUD produk
│   └── registrasi_bloc.dart     # API call untuk registrasi
├── helpers/
│   ├── api.dart                 # Helper HTTP request
│   ├── api_url.dart             # Base URL API
│   ├── app_exception.dart       # Custom exception handling
│   └── user_info.dart           # Penyimpanan token & user ID
├── model/
│   ├── login.dart               # Model response login
│   ├── produk.dart              # Model data produk
│   └── registrasi.dart          # Model response registrasi
├── ui/
│   ├── login_page.dart          # Halaman login
│   ├── registrasi_page.dart     # Halaman registrasi
│   ├── produk_page.dart         # Halaman list produk
│   ├── produk_form.dart         # Form tambah/edit produk
│   └── produk_detail.dart       # Detail produk
└── widget/
    ├── success_dialog.dart      # Dialog sukses
    └── warning_dialog.dart      # Dialog warning/error
```

---

## 📦 **Fitur Utama**

- ✅ **Login & Registrasi** dengan API
- ✅ **CRUD Produk** (Create, Read, Update, Delete)
- ✅ **Token-based Authentication**
- ✅ **Modern UI** dengan gradient, shadow, dan animasi
- ✅ **Form Validation** yang lengkap
- ✅ **Dialog Konfirmasi** untuk aksi penting

---

## 🔧 **Penjelasan Code Penting**

### 1️⃣ **API Helper (`lib/helpers/api.dart`)**

Helper untuk melakukan HTTP request ke server.

```dart
class Api {
  // POST request dengan header token
  Future<dynamic> post(String url, dynamic data) async {
    var token = await UserInfo().getToken();
    var responseJson;
    try {
      final response = await http.post(
        Uri.parse(url),
        body: data,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

  // Handle response berdasarkan status code
  dynamic _returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:
      default:
        throw FetchDataException('Error: ${response.statusCode}');
    }
  }
}
```

**Penjelasan:**
- `post()`, `get()`, `put()`, `delete()` — method untuk HTTP request
- `_returnResponse()` — handle response dan throw exception jika error
- Token diambil dari `UserInfo` untuk autentikasi

---

### 2️⃣ **Login Bloc (`lib/bloc/login_bloc.dart`)**

Menangani proses login ke API.

```dart
class LoginBloc {
  static Future<Login> login({String? email, String? password}) async {
    String apiUrl = ApiUrl.login;

    var body = {"email": email, "password": password};

    var response = await Api().post(apiUrl, body);
    return Login.fromJson(response);
  }
}
```

**Penjelasan:**
- Mengirim email & password ke API endpoint login
- Response di-parse ke model `Login` yang berisi token & userID

---

### 3️⃣ **Produk Bloc (`lib/bloc/produk_bloc.dart`)**

Menangani semua operasi CRUD produk.

```dart
class ProdukBloc {
  // GET semua produk
  static Future<List<Produk>> getProduks() async {
    String apiUrl = ApiUrl.listProduk;
    var response = await Api().get(apiUrl);
    var results = response['data'];
    List<Produk> produks = [];
    for (var result in results) {
      produks.add(Produk.fromJson(result));
    }
    return produks;
  }

  // POST tambah produk baru
  static Future addProduk({Produk? produk}) async {
    String apiUrl = ApiUrl.createProduk;
    var body = {
      "kode_produk": produk!.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString()
    };
    var response = await Api().post(apiUrl, body);
    return response['status'];
  }

  // PUT update produk
  static Future updateProduk({required Produk produk}) async {
    String apiUrl = ApiUrl.updateProduk(produk.id!);
    var body = {
      "kode_produk": produk.kodeProduk,
      "nama_produk": produk.namaProduk,
      "harga": produk.hargaProduk.toString()
    };
    var response = await Api().put(apiUrl, body);
    return response['status'];
  }

  // DELETE hapus produk
  static Future<bool> deleteProduk({required int id}) async {
    String apiUrl = ApiUrl.deleteProduk(id);
    var response = await Api().delete(apiUrl);
    return response['status'];
  }
}
```

**Penjelasan:**
- `getProduks()` — ambil semua produk dari API
- `addProduk()` — tambah produk baru
- `updateProduk()` — update produk berdasarkan ID
- `deleteProduk()` — hapus produk berdasarkan ID

---

### 4️⃣ **User Info Helper (`lib/helpers/user_info.dart`)**

Menyimpan dan mengambil token & userID menggunakan SharedPreferences.

```dart
class UserInfo {
  // Simpan token
  Future setToken(String value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setString("token", value);
  }

  // Ambil token
  Future<String?> getToken() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString("token");
  }

  // Simpan user ID
  Future setUserID(int value) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.setInt("userID", value);
  }

  // Ambil user ID
  Future<int?> getUserID() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getInt("userID");
  }
}
```

**Penjelasan:**
- Token disimpan setelah login berhasil
- Token digunakan untuk autentikasi setiap request ke API
- `logout()` menghapus token dari storage

---

### 5️⃣ **Login Page — Proses Submit (`lib/ui/login_page.dart`)**

```dart
void _submit() {
  _formKey.currentState!.save();
  setState(() {
    _isLoading = true;
  });

  LoginBloc.login(
    email: _emailTextboxController.text,
    password: _passwordTextboxController.text,
  ).then((value) async {
    // Jika login berhasil (code == 200)
    if (value.code == 200) {
      // Simpan token dan userID
      await UserInfo().setToken(value.token ?? "");
      await UserInfo().setUserID(value.userID ?? 0);

      // Navigate ke halaman produk
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProdukPage()),
      );
    } else {
      // Login gagal
      showDialog(
        context: context,
        builder: (context) => const WarningDialog(
          description: "Login gagal, periksa email dan password",
        ),
      );
    }
  }, onError: (error) {
    // Error dari API
    showDialog(
      context: context,
      builder: (context) => const WarningDialog(
        description: "Login gagal, silahkan coba lagi",
      ),
    );
  });
}
```

**Penjelasan:**
- Memanggil `LoginBloc.login()` dengan email & password
- Jika berhasil (code 200), simpan token dan navigate ke `ProdukPage`
- Jika gagal, tampilkan `WarningDialog`

---

### 6️⃣ **Produk Page — FutureBuilder (`lib/ui/produk_page.dart`)**

```dart
body: FutureBuilder<List<Produk>>(
  future: ProdukBloc.getProduks(),
  builder: (context, snapshot) {
    // Loading state
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Error state
    if (snapshot.hasError) {
      return Center(
        child: Text('Error: ${snapshot.error}'),
      );
    }

    // Success state - tampilkan list produk
    if (snapshot.hasData) {
      return ListProduk(list: snapshot.data!);
    }

    return const Center(child: Text('Tidak ada data'));
  },
),
```

**Penjelasan:**
- `FutureBuilder` menangani 3 state: loading, error, dan success
- Data produk diambil dari `ProdukBloc.getProduks()`
- List ditampilkan menggunakan widget `ListProduk`

---

### 7️⃣ **Produk Form — Simpan & Ubah (`lib/ui/produk_form.dart`)**

```dart
// Fungsi simpan produk baru
simpan() {
  setState(() { _isLoading = true; });

  Produk createProduk = Produk(id: null);
  createProduk.kodeProduk = _kodeProdukTextboxController.text;
  createProduk.namaProduk = _namaProdukTextboxController.text;
  createProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);

  ProdukBloc.addProduk(produk: createProduk).then((value) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProdukPage()),
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (context) => const WarningDialog(
        description: "Simpan gagal, silahkan coba lagi",
      ),
    );
  });
  setState(() { _isLoading = false; });
}

// Fungsi ubah produk
ubah() {
  setState(() { _isLoading = true; });

  Produk updateProduk = Produk(id: widget.produk!.id!);
  updateProduk.kodeProduk = _kodeProdukTextboxController.text;
  updateProduk.namaProduk = _namaProdukTextboxController.text;
  updateProduk.hargaProduk = int.parse(_hargaProdukTextboxController.text);

  ProdukBloc.updateProduk(produk: updateProduk).then((value) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ProdukPage()),
    );
  }, onError: (error) {
    showDialog(
      context: context,
      builder: (context) => const WarningDialog(
        description: "Ubah gagal, silahkan coba lagi",
      ),
    );
  });
  setState(() { _isLoading = false; });
}
```

**Penjelasan:**
- `simpan()` — membuat objek `Produk` baru dan memanggil `ProdukBloc.addProduk()`
- `ubah()` — update objek `Produk` existing dan memanggil `ProdukBloc.updateProduk()`
- Setelah berhasil, navigate kembali ke `ProdukPage`

---

### 8️⃣ **Produk Detail — Hapus Produk (`lib/ui/produk_detail.dart`)**

```dart
void _confirmDelete() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Text("Yakin ingin menghapus '${widget.produk?.namaProduk}'?"),
        actions: [
          // Tombol Batal
          TextButton(
            child: const Text("Batal"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // Tombol Hapus
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Hapus"),
            onPressed: () {
              // Panggil API hapus
              ProdukBloc.deleteProduk(id: widget.produk!.id!).then(
                (value) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const ProdukPage()),
                    (route) => false,
                  );
                },
                onError: (error) {
                  Navigator.of(context).pop();
                  showDialog(
                    context: context,
                    builder: (context) => const WarningDialog(
                      description: "Hapus gagal, silahkan coba lagi",
                    ),
                  );
                },
              );
            },
          ),
        ],
      );
    },
  );
}
```

**Penjelasan:**
- Menampilkan dialog konfirmasi sebelum hapus
- Jika user konfirmasi, panggil `ProdukBloc.deleteProduk()`
- Setelah berhasil, navigate ke `ProdukPage` dan clear semua route sebelumnya

---

### 9️⃣ **Logout (`lib/ui/produk_page.dart`)**

```dart
void _logout() async {
  // Panggil API logout
  await LogoutBloc.logout().then((value) async {
    // Hapus token dari storage
    await UserInfo().logout();

    // Navigate ke login page
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  });
}
```

**Penjelasan:**
- Memanggil `LogoutBloc.logout()` ke API
- Menghapus token dari `SharedPreferences`
- Navigate ke `LoginPage` dan clear semua route

---

## 🎨 **UI Design**

Aplikasi menggunakan desain modern dengan:
- **Gradient Background** — warna biru untuk login, hijau untuk registrasi, orange untuk produk
- **Card dengan Radius Besar** — `BorderRadius.circular(24)`
- **Shadow Lembut** — `BoxShadow` dengan blur dan offset
- **Animasi** — Fade, Slide, dan Scale transition
- **Icon dalam Container** — prefix icon dengan background color

---

## 🖼️ **Screenshots**

### **1. Halaman Login**
*Halaman untuk user masuk ke aplikasi dengan email dan password*

<!-- Tambahkan screenshot login di sini -->
<img src="" width="300" />

---

### **2. Halaman Registrasi**
*Halaman untuk user baru mendaftar akun*

<!-- Tambahkan screenshot registrasi di sini -->
<img src="" width="300" />

---

### **3. Halaman List Produk**
*Menampilkan semua produk dalam bentuk card list*

<!-- Tambahkan screenshot list produk di sini -->
<img src="" width="300" />

---

### **4. Sidebar / Drawer**
*Menu navigasi dengan info user dan tombol logout*

<!-- Tambahkan screenshot drawer di sini -->
<img src="" width="300" />

---

### **5. Halaman Tambah Produk**
*Form untuk menambahkan produk baru*

<!-- Tambahkan screenshot form tambah di sini -->
<img src="" width="300" />

---

### **6. Halaman Detail Produk**
*Menampilkan detail lengkap produk dengan opsi edit dan hapus*

<!-- Tambahkan screenshot detail di sini -->
<img src="" width="300" />

---

### **7. Halaman Edit Produk**
*Form untuk mengubah data produk yang sudah ada*

<!-- Tambahkan screenshot form edit di sini -->
<img src="" width="300" />

---

### **8. Dialog Konfirmasi Hapus**
*Konfirmasi sebelum menghapus produk*

<!-- Tambahkan screenshot dialog hapus di sini -->
<img src="" width="300" />

---

## 🚀 **Cara Menjalankan**

1. Clone repository
```bash
git clone https://github.com/syiffac/H1D023042_Tugas8_TokoKita.git
```

2. Masuk ke folder project
```bash
cd H1D023042_Tugas8_TokoKita
```

3. Install dependencies
```bash
flutter pub get
```

4. Jalankan aplikasi
```bash
flutter run
```

---

## 📚 **Dependencies**

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

---

## 📝 **Catatan**

- Pastikan API server berjalan sebelum menjalankan aplikasi
- Base URL API dapat diubah di `lib/helpers/api_url.dart`
- Untuk development web, gunakan flag `--disable-web-security`:
  ```bash
  flutter run -d chrome --web-browser-flag "--disable-web-security"
  ```

---
