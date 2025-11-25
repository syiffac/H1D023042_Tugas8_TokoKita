class Session {
  static String? token;
  static int? userID;
  static String? email;
  static bool isLoggedIn = false;

  // Menyimpan daftar user yang terdaftar (simulasi database)
  static List<Map<String, String>> registeredUsers = [
    {'email': 'syifa@gmail.com', 'password': 'syifa123', 'nama': 'Syifa'},
  ];

  static void login(String emailParam, int id, String tokenParam) {
    email = emailParam;
    userID = id;
    token = tokenParam;
    isLoggedIn = true;
  }

  static void logout() {
    email = null;
    userID = null;
    token = null;
    isLoggedIn = false;
  }

  // Tambah user baru
  static void registerUser(String nama, String email, String password) {
    registeredUsers.add({'nama': nama, 'email': email, 'password': password});
  }

  // Cek kredensial login
  static Map<String, dynamic>? validateLogin(String email, String password) {
    for (var user in registeredUsers) {
      if (user['email'] == email && user['password'] == password) {
        return {'nama': user['nama'], 'email': user['email']};
      }
    }
    return null;
  }
}
