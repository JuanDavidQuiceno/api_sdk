import 'package:flutter/material.dart';
import 'package:api_sdk/api_sdk.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String apiData = '';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Example Call API',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Flutter Example Call API'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  apiData,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                ElevatedButton(
                  onPressed: () async {
                    /// Call the API using the [ApiSdk] class
                    /// and the [CountryEndpoint] class

                    setState(() {
                      apiData = 'Loading...';
                    });
                    await ApiSdk()
                        .raw(
                      endpoint: CountryEndpoint(),
                    )
                        .then((value) {
                      if (value['statusCode'] == 200) {
                        setState(() {
                          apiData = value.toString();
                        });
                      }
                    }).catchError((e) {
                      apiData = 'Error';
                    });
                  },
                  child: const Text('Call API'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Example endpoint extending the [Endpoint] class
class CountryEndpoint extends Endpoint {
  CountryEndpoint();

  /// set the [baseUrl] of the endpoint
  @override
  String get setApiUrl => 'https://restcountries.com';

  /// The method of the endpoint
  /// acepts [Method.get], [Method.post], [Method.put], [Method.delete]
  @override
  Method get method => Method.get;

  /// The path of the endpoint
  @override
  String get path => 'v3.1/alpha/col';

  /// The query parameters of the endpoint
  @override
  Map<String, dynamic> get queryParameters => {
        /// example of a query parameter
        /// 'key': 'value'
      };

  /// The headers of the endpoint
  @override
  Map<String, String> get headers => {
        /// example of a header
        /// HttpHeaders.authorizationHeader: 'token'
      };

  /// The body of the endpoint
  @override
  Map<String, dynamic> get body => {
        /// example of a body
        /// 'key': 'value'
      };

  /// files to upload
  /// [key] is default 'files'
  /// [path] is the path of the file
  /// [url] is the url of the file
  @override
  List<ImagesModelEndpoint> get files => [
        /// example of a file
        /// ImagesModelEndpoint(
        ///  key: 'files',
        /// path: 'path',
      ];
}
