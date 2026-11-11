import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/utils/validators.dart';

void main() {
  group('Validators.isValidEmail', () {
    test('menerima email dengan format valid', () {
      expect(Validators.isValidEmail('user@example.com'), isTrue);
      expect(
        Validators.isValidEmail('first.last+tag@sub.domain.co.id'),
        isTrue,
      );
    });

    test('menolak email tanpa karakter @', () {
      expect(Validators.isValidEmail('userexample.com'), isFalse);
    });

    test('menolak email tanpa nama pengguna', () {
      expect(Validators.isValidEmail('@example.com'), isFalse);
    });

    test('menolak email tanpa domain', () {
      expect(Validators.isValidEmail('user@'), isFalse);
    });

    test('menolak email tanpa ekstensi domain', () {
      expect(Validators.isValidEmail('user@example'), isFalse);
    });

    test('menolak email dengan lebih dari satu @', () {
      expect(Validators.isValidEmail('user@@example.com'), isFalse);
    });

    test('menolak string kosong', () {
      expect(Validators.isValidEmail(''), isFalse);
    });
  });

  group('Validators.sanitize', () {
    test('mengubah tag script berbahaya menjadi HTML entities', () {
      expect(
        Validators.sanitize('<script>alert("xss")</script>'),
        '&lt;script&gt;alert(&quot;xss&quot;)&lt;/script&gt;',
      );
    });

    test('mengubah tanda kutip tunggal menjadi entity', () {
      expect(Validators.sanitize("O'Reilly"), 'O&#39;Reilly');
    });

    test('mengubah karakter ampersand menjadi entity', () {
      expect(Validators.sanitize('A & B'), 'A &amp; B');
    });

    test('memangkas spasi di awal dan akhir', () {
      expect(Validators.sanitize('  teks aman  '), 'teks aman');
    });

    test('tidak mengubah teks biasa', () {
      expect(Validators.sanitize('Halo dunia'), 'Halo dunia');
    });
  });

  group('Validators.validateText', () {
    test('menolak nilai null', () {
      expect(
        Validators.validateText(null, fieldName: 'Nama'),
        'Nama tidak boleh kosong',
      );
    });

    test('menolak nilai kosong atau hanya spasi', () {
      expect(
        Validators.validateText('   ', fieldName: 'Nama'),
        'Nama tidak boleh kosong',
      );
    });

    test('menolak teks yang lebih pendek dari batas minimum', () {
      expect(
        Validators.validateText('ab', fieldName: 'Nama', minLength: 3),
        'Nama harus antara 3-100 karakter',
      );
    });

    test('menolak teks yang lebih panjang dari batas maksimum', () {
      expect(
        Validators.validateText(
          'abcdefghijk',
          fieldName: 'Nama',
          maxLength: 10,
        ),
        'Nama harus antara 1-10 karakter',
      );
    });

    test('menerima teks tepat pada batas minimum', () {
      expect(
        Validators.validateText('abc', fieldName: 'Nama', minLength: 3),
        isNull,
      );
    });

    test('menerima teks tepat pada batas maksimum', () {
      expect(
        Validators.validateText('abcdefghij', fieldName: 'Nama', maxLength: 10),
        isNull,
      );
    });

    test('menerima teks dengan panjang wajar', () {
      expect(
        Validators.validateText('Nama yang valid', fieldName: 'Nama'),
        isNull,
      );
    });
  });

  group('Validators.validatePhone', () {
    test('menerima nomor telepon 10 digit', () {
      expect(Validators.validatePhone('0812345678'), isNull);
    });

    test('menerima nomor telepon 13 digit', () {
      expect(Validators.validatePhone('0812345678901'), isNull);
    });

    test('menolak nomor telepon kurang dari 10 digit', () {
      expect(
        Validators.validatePhone('081234567'),
        'Nomor telepon harus terdiri dari 10-13 digit angka',
      );
    });

    test('menolak nomor telepon lebih dari 13 digit', () {
      expect(
        Validators.validatePhone('08123456789012'),
        'Nomor telepon harus terdiri dari 10-13 digit angka',
      );
    });

    test('menolak nomor telepon yang mengandung huruf atau simbol', () {
      expect(
        Validators.validatePhone('0812-345-678'),
        'Nomor telepon harus terdiri dari 10-13 digit angka',
      );
      expect(
        Validators.validatePhone('0812345678a'),
        'Nomor telepon harus terdiri dari 10-13 digit angka',
      );
    });

    test('menolak nomor telepon kosong', () {
      expect(Validators.validatePhone(''), 'Nomor telepon tidak boleh kosong');
    });
  });

  group('Validators.validateUrl', () {
    test('menerima URL dengan http://', () {
      expect(Validators.validateUrl('http://example.com'), isNull);
    });

    test('menerima URL dengan https://', () {
      expect(
        Validators.validateUrl('https://jsonplaceholder.typicode.com'),
        isNull,
      );
    });

    test('menolak URL tanpa http:// atau https://', () {
      expect(
        Validators.validateUrl('example.com'),
        'URL harus dimulai dengan http:// atau https://',
      );
      expect(
        Validators.validateUrl('ftp://example.com'),
        'URL harus dimulai dengan http:// atau https://',
      );
    });

    test('menolak URL kosong', () {
      expect(Validators.validateUrl(''), 'URL tidak boleh kosong');
    });
  });

  group('Validators.validatePassword', () {
    test('menerima password yang kuat', () {
      expect(Validators.validatePassword('Password1!'), isNull);
      expect(Validators.validatePassword('Rahasia#2024'), isNull);
    });

    test('menolak password kurang dari 8 karakter', () {
      expect(
        Validators.validatePassword('Pass1!'),
        'Password minimal 8 karakter',
      );
    });

    test('menolak password tanpa huruf kapital', () {
      expect(
        Validators.validatePassword('password1!'),
        'Password harus mengandung huruf kapital',
      );
    });

    test('menolak password tanpa angka', () {
      expect(
        Validators.validatePassword('Password!'),
        'Password harus mengandung angka',
      );
    });

    test('menolak password tanpa simbol', () {
      expect(
        Validators.validatePassword('Password1'),
        'Password harus mengandung simbol',
      );
    });

    test('menolak password kosong', () {
      expect(Validators.validatePassword(''), 'Password tidak boleh kosong');
    });
  });
}
