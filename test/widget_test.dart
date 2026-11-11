import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rpl_keamanan/models/post.dart';
import 'package:rpl_keamanan/repositories/post_repository.dart';
import 'package:rpl_keamanan/screens/post_list_screen.dart';

class FakePostRepository implements PostRepository {
  @override
  Future<List<Post>> getPosts() async {
    return [Post(userId: 1, id: 1, title: 'Judul Post', body: 'Isi post')];
  }
}

void main() {
  testWidgets('PostListScreen menampilkan data dari repository', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: PostListScreen(repository: FakePostRepository())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Post'), findsOneWidget);
    expect(find.text('Judul Post'), findsOneWidget);
  });
}
