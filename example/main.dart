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
          // backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    apiData,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    /// Call the API using the [ApiSdk] class
                    /// and the [CountryEndpoint] class

                    setState(() {
                      apiData = 'Loading...';
                    });
                    await ApiSdk()
                        .run(endpoint: CountryEndpoint())
                        .then((value) {
                      if (value.statusCode == 200) {
                        setState(() {
                          apiData = value.body.toString();
                        });
                      } else {
                        setState(() {
                          apiData = value.body.toString();
                        });
                      }
                    }).catchError((e) {
                      setState(() {
                        apiData = e.toString();
                      });
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
class CountryEndpoint extends EndpointConfig {
  CountryEndpoint();

  /// The setter base url of the endpoint
  ///
  /// set the [baseUrl] of the endpoint if you want to change the default
  /// [baseUrl] of the environment
  @override
  String get setBaseUrl => 'https://restcountries.com';

  /// The method of the endpoint
  ///
  /// Accepts [Method.get], [Method.post], [Method.put], [Method.delete]
  @override
  Method get method => Method.get;

  /// The path of the endpoint
  ///
  /// The default path is empty, if you want to add a path you can do it
  /// like this '/v3.1/alpha/col' or 'v3.1/alpha/col'
  @override
  String get path => 'v3.1/alpha/col';

  /// The query parameters of the endpoint
  ///
  /// The default query parameters is empty
  @override
  Map<String, dynamic> get queryParameters => {
        /// example of a query parameter
        /// 'key': 'value'
      };

  /// The headers of the endpoint
  ///
  /// The default headers depends of the [bodyType] or the headers you set
  @override
  Map<String, String> get headers => {
        /// example of a header
        /// HttpHeaders.authorizationHeader: 'token'
      };

  /// The body type of the endpoint
  ///
  /// [BodyType.raw], [BodyType.formData], [BodyType.xWwwformurlencoded],
  /// the default is [BodyType.raw]
  @override
  BodyType get bodyType => BodyType.raw;

  /// The body of the endpoint
  ///
  /// The default body is empty
  @override
  Map<String, dynamic> get body => {
        /// example of a body
        /// 'key': 'value'
      };

  /// Files to upload of the endpoint
  ///
  /// The default is empty, if you want to add a file you can do it like this:
  /// [key] is default 'files', [path] is the path of the file, [url] is the
  /// url of the file, the default key is 'files'
  @override
  List<ImagesModelEndpoint> get files => [
        /// example of a file
        /// ImagesModelEndpoint( key: 'files', path: 'path' )
      ];
}
