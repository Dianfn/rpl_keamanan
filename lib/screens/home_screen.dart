import 'package:flutter/material.dart';
import '../config/dependency_injector.dart';
import '../core/logger.dart';
import '../services/secure_storage_service.dart';
import '../utils/validators.dart';
import 'post_list_screen.dart';
import 'user_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SecureStorageService _storageService = SecureStorageService();
  final TextEditingController _tokenController = TextEditingController();
  final GlobalKey<FormState> _validationFormKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _savedToken;
  bool _hasToken = false;
  Map<String, String>? _sanitizedResult;
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _urlController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkToken() async {
    final hasToken = await _storageService.hasToken();
    final token = await _storageService.getToken();
    setState(() {
      _hasToken = hasToken;
      _savedToken = token;
    });
  }

  Future<void> _saveToken() async {
    final token = _tokenController.text.trim();
    if (token.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token tidak boleh kosong'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (token.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token minimal 8 karakter'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    await _storageService.saveToken(token);
    _tokenController.clear();
    await _checkToken();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token berhasil disimpan di secure storage'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _deleteToken() async {
    await _storageService.deleteToken();
    await _checkToken();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Token berhasil dihapus'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _tokenPreview(String token) {
    if (token.length <= 10) return token;
    return '${token.substring(0, 10)}...';
  }

  void _submitValidation() {
    if (!(_validationFormKey.currentState?.validate() ?? false)) {
      Logger.warning('Validasi form gagal');
      return;
    }
    final sanitized = {
      'Nama': Validators.sanitize(_nameController.text),
      'Email': Validators.sanitize(_emailController.text),
      'Telepon': Validators.sanitize(_phoneController.text),
      'URL': Validators.sanitize(_urlController.text),
    };
    setState(() {
      _sanitizedResult = sanitized;
    });
    Logger.info('Validasi form berhasil untuk ${sanitized['Nama']}');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua input valid dan sudah disanitasi'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final injector = DependencyScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Storage & HTTP'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section 1: Secure Storage
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.lock, color: Colors.deepPurple),
                          const SizedBox(width: 8),
                          const Text(
                            'Secure Storage',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Simpan token atau PIN di secure storage (terenkripsi AES).',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _tokenController,
                        decoration: const InputDecoration(
                          labelText: 'Token',
                          hintText: 'Masukkan token dummy',
                          prefixIcon: Icon(Icons.vpn_key),
                          border: OutlineInputBorder(),
                          helperText: 'Minimal 8 karakter',
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saveToken,
                              icon: const Icon(Icons.save),
                              label: const Text('Simpan'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _hasToken ? _deleteToken : null,
                              icon: const Icon(Icons.delete),
                              label: const Text('Hapus'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _hasToken ? Colors.green[50] : Colors.red[50],

                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasToken ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _hasToken ? Icons.check_circle : Icons.cancel,
                              color: _hasToken ? Colors.green : Colors.red,
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                _hasToken
                                    ? 'Token tersimpan: ${_tokenPreview(_savedToken!)}'
                                    : 'Belum ada token tersimpan',

                                style: TextStyle(
                                  color: _hasToken
                                      ? Colors.green[800]
                                      : Colors.red[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Section 2: Form Validasi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _validationFormKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.fact_check, color: Colors.indigo),
                            const SizedBox(width: 8),
                            const Text(
                              'Form Validasi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Latihan 3: validasi nama, email, nomor telepon, URL, dan password.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nama Lengkap',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => Validators.validateText(
                            value,
                            fieldName: 'Nama',
                            minLength: 3,
                            maxLength: 50,
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: Validators.validateEmail,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Telepon',
                            prefixIcon: Icon(Icons.phone),
                            border: OutlineInputBorder(),
                            helperText: 'Hanya angka, 10-13 digit',
                          ),
                          validator: Validators.validatePhone,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _urlController,
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'URL',
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                            helperText:
                                'Harus dimulai dengan http:// atau https://',
                          ),
                          validator: Validators.validateUrl,
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submitValidation(),
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(),
                            helperText:
                                'Minimal 8 karakter, huruf kapital, angka, dan simbol',
                          ),
                          validator: Validators.validatePassword,
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _submitValidation,
                            icon: const Icon(Icons.verified_user),
                            label: const Text('Validasi Input'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        if (_sanitizedResult != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Input valid (hasil sanitasi)',
                                      style: TextStyle(
                                        color: Colors.green[800],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                for (final entry in _sanitizedResult!.entries)
                                  Text(
                                    '${entry.key}: ${entry.value}',
                                    style: TextStyle(color: Colors.green[800]),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Section 3: HTTP Request
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.cloud, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'HTTP Request',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Ambil data dari REST API (JSONPlaceholder) menggunakan GET request.',

                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserListScreen(
                                  repository: injector.userRepository,
                                ),
                              ),
                            );
                          },

                          icon: const Icon(Icons.list),

                          label: const Text('Lihat Daftar Pengguna'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostListScreen(
                                  repository: injector.postRepository,
                                ),
                              ),
                            );
                          },

                          icon: const Icon(Icons.article),

                          label: const Text('Lihat Daftar Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Section 4: Catatan Keamanan
              Card(
                color: Colors.amber[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.security, color: Colors.amber[800]),
                          const SizedBox(width: 8),
                          const Text(
                            'Catatan Keamanan',

                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        '1. Token dan PIN disimpan terenkripsi di secure storage.\n'
                        '2. Jangan pernah mencetak token ke log.\n'
                        '3. Gunakan HTTPS untuk komunikasi API.\n'
                        '4. Tangani error dengan pesan yang ramah pengguna.\n'
                        '5. Validasi dan sanitasi semua input sebelum diproses.\n'
                        '6. Log hanya aktif di mode debug dan tidak memuat data sensitif.\n'
                        '7. Jalankan "flutter test" untuk menguji Validators.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
