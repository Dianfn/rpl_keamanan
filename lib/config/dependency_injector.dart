import 'package:flutter/widgets.dart';
import '../repositories/post_repository.dart';
import '../repositories/post_repository_impl.dart';
import '../repositories/user_repository.dart';
import '../repositories/user_repository_impl.dart';
import '../services/api_service.dart';

/// Dependency injector sederhana untuk aplikasi.
///
/// Menyimpan satu instance [ApiService], [UserRepository], dan
/// [PostRepository]. [ApiService] dibuat sekali (singleton) sehingga
/// koneksi HTTP dapat digunakan bersama oleh semua repository.
class DependencyInjector {
  DependencyInjector._();

  /// Instance tunggal [DependencyInjector].
  static final DependencyInjector instance = DependencyInjector._();

  /// Instance tunggal [ApiService].
  final ApiService apiService = ApiService();

  late final UserRepository userRepository = UserRepositoryImpl(
    apiService: apiService,
  );

  late final PostRepository postRepository = PostRepositoryImpl(
    apiService: apiService,
  );
}

/// Menyediakan [DependencyInjector] ke seluruh widget tree.
///
/// Widget dapat mengakses dependency dengan:
/// `DependencyScope.of(context).userRepository`.
class DependencyScope extends InheritedWidget {
  final DependencyInjector injector;

  const DependencyScope({
    super.key,
    required this.injector,
    required super.child,
  });

  static DependencyInjector of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DependencyScope>();
    assert(scope != null, 'DependencyScope tidak ditemukan pada widget tree');
    return scope!.injector;
  }

  @override
  bool updateShouldNotify(DependencyScope oldWidget) {
    return injector != oldWidget.injector;
  }
}
