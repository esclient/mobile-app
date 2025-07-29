import 'package:graphql_flutter/graphql_flutter.dart';

Future<GraphQLClient> initGraphQLClient() async {
  await initHiveForFlutter();
  final HttpLink httpLink = HttpLink('http://10.0.2.2:8000');

  return GraphQLClient(
    link: httpLink,
    cache: GraphQLCache(store: HiveStore()),
  );
}
