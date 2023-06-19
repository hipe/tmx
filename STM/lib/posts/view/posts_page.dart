import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '/posts/posts.dart';
import 'package:http/http.dart' as http;

class PostsPageXX extends StatelessWidget {
  const PostsPageXX({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: BlocProvider(
        create: (_) => PostBloc(httpClient: http.Client())..add(PostFetched()),
        child: const PostsList(),
      ),
    );
  }
}
/*
# #born (BLoC tutorial #3)
*/
