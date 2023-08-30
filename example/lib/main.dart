import 'package:bucketeer_example/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:bucketeer_flutter_client_sdk/bucketeer_flutter_client_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ua_client_hints/ua_client_hints.dart';

import 'constant.dart';

const keyUserId = 'key_user_id';

Future<Map<String, String>> userMap() async {
  final uaData = await userAgentData();
  return {
    'platform': uaData.platform, // e.g.. 'Android'
    'platformVersion': uaData.platformVersion, // e.g.. '10'
    'device': uaData.device, // e.g.. 'coral'
    'appName': uaData.package.appName, // e.g.. 'SampleApp'
    'appVersion': uaData.package.appVersion, // e.g.. '1.0.0'
    'packageName': uaData.package.packageName, // e.g.. 'jp.wasabeef.ua'
    'buildNumber': uaData.package.buildNumber, // e.g.. '1'
  };
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AppState();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class _AppState extends State<MyApp>
    with WidgetsBindingObserver
    implements BKTEvaluationUpdateListener {
  late final String _listenToken;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Bucketeer Demo'),
    );
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      // Generate UserId for Demo
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString(keyUserId);
      if (userId == null) {
        userId = 'demo-userId-${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(keyUserId, userId);
      }
      final config = BKTConfigBuilder()
          .apiKey(Constants.apiKey)
          .apiEndpoint(Constants.apiEndpoint)
          .featureTag(Constants.exampleFeatureTag)
          .debugging(true)
          .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
          .eventsFlushInterval(Constants.exampleEventsFlushInterval)
          .pollingInterval(Constants.examplePollingInterval)
          .backgroundPollingInterval(Constants.exampleBackgroundPollingInterval)
          .appVersion("1.0.0")
          .build();
      final user =
          BKTUserBuilder().id(userId).customAttributes({'app_version': "1.2.3"}).build();
      final result = await BKTClient.initialize(config: config, user: user);
      if (result.isSuccess) {
        _listenToken = BKTClient.instance.addEvaluationUpdateListener(this);
      } else if (result.isFailure) {
        final errorMessage = result.asFailure.message;
        debugPrint(errorMessage);
      }
    });
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    BKTClient.instance.removeEvaluationUpdateListener(_listenToken);
  }

  @override
  void onUpdate() {
    // EvaluationUpdateListener onUpdate()
    debugPrint("EvaluationUpdateListener.onUpdate() called");
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flagController =
      TextEditingController(text: Constants.exampleFeatureTag);
  final goalController = TextEditingController(text: 'bucketeer-goal-id');
  final userIdController = TextEditingController(text: Constants.exampleUserId);

  Future<void> _getStringVariation(String featureId) async {
    final result = await BKTClient.instance
        .stringVariation(featureId, defaultValue: 'default value');
    debugPrint('getStringVariation: $result');
    showSnackbar(title: 'getStringVariation', message: result);
  }

  Future<void> _getIntVariation(String featureId) async {
    final result =
        await BKTClient.instance.intVariation(featureId, defaultValue: 0);
    debugPrint('getIntVariation: $result');
    showSnackbar(title: 'getIntVariation', message: '$result');
  }

  Future<void> _getDoubleVariation(String featureId) async {
    final result =
        await BKTClient.instance.doubleVariation(featureId, defaultValue: 0.0);
    debugPrint('getDoubleVariation: $result');
    showSnackbar(title: 'getDoubleVariation', message: '$result');
  }

  Future<void> _getBoolVariation(String featureId) async {
    final result =
        await BKTClient.instance.boolVariation(featureId, defaultValue: false);
    debugPrint('getBoolVariation: $result');
    showSnackbar(title: 'getBoolVariation', message: '$result');
  }

  Future<void> _getJSONVariation(String featureId) async {
    final result =
        await BKTClient.instance.jsonVariation(featureId, defaultValue: {});
    debugPrint('getJSONVariation: $result');
    showSnackbar(title: 'getJSONVariation', message: '$result');
  }

  Future<void> _getEvaluation(String featureId) async {
    final result = await BKTClient.instance.evaluationDetails(featureId);
    debugPrint('Successful get evaluation details');
    if (result != null) {
      showSnackbar(
          title: 'getEvaluation(${result.toString()})',
          message: 'Successful the evaluation.');
    }
  }

  Future<void> _sendGoal(String goalId) async {
    await BKTClient.instance.track(goalId, value: 3.1412);
    debugPrint('Successful the send goal.');
    showSnackbar(title: 'sendGoal', message: 'Successful the send goal.');
  }

  Future<void> _switchUser(String userId) async {
    // note: please initialize the Bucketeer again when switching the user
    final config = BKTConfigBuilder()
        .apiKey(Constants.apiKey)
        .apiEndpoint(Constants.apiEndpoint)
        .featureTag(Constants.exampleFeatureTag)
        .debugging(true)
        .eventsMaxQueueSize(Constants.exampleEventMaxQueueSize)
        .eventsFlushInterval(Constants.exampleEventsFlushInterval)
        .pollingInterval(Constants.examplePollingInterval)
        .backgroundPollingInterval(Constants.exampleBackgroundPollingInterval)
        .appVersion("1.0.0")
        .build();
    final user =
        BKTUserBuilder().id(userId).customAttributes({'app_version': "1.2.3"}).build();

    await BKTClient.instance.destroy();
    await BKTClient.initialize(
      config: config,
      user: user,
    );
    await BKTClient.instance.updateUserAttributes(
      {'app_version': "1.2.4"},
    );
    debugPrint('Successful the switchUser');
    showSnackbar(title: 'setUser', message: 'Successful the switchUser.');
  }

  Future<void> _getCurrentUser() async {
    final user = await BKTClient.instance.currentUser();
    if (user != null) {
      debugPrint('Successful the getUser');
      showSnackbar(title: 'getUser(${user.id})', message: user.attributes.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 36.0),
                  const Text(
                    'Feature Flag Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: flagController,
                    decoration: const InputDecoration(
                        hintText: 'bucketeer-feature-flag'),
                  ),
                  const SizedBox(height: 12),
                  const Text('GET VARIATION',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                          child: const Text('GET String param'),
                          onPressed: () async {
                            return _getStringVariation(flagController.text);
                          }),
                      TextButton(
                          child: const Text('GET int param'),
                          onPressed: () async {
                            return _getIntVariation(flagController.text);
                          }),
                      TextButton(
                          child: const Text('GET double params'),
                          onPressed: () async {
                            return _getDoubleVariation(flagController.text);
                          }),
                      TextButton(
                          child: const Text('GET bool params'),
                          onPressed: () async {
                            return _getBoolVariation(flagController.text);
                          }),
                      TextButton(
                          child: const Text('GET json params'),
                          onPressed: () async {
                            return _getJSONVariation(flagController.text);
                          }),
                      TextButton(
                          child: const Text('GET evaluation'),
                          onPressed: () async {
                            return _getEvaluation(flagController.text);
                          }),
                    ],
                  ),
                  const SizedBox(height: 36.0),
                  const Text(
                    'Goal Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: goalController,
                    decoration: InputDecoration(hintText: goalController.text),
                  ),
                  TextButton(
                      child: const Text('SEND GOAL'),
                      onPressed: () async {
                        return _sendGoal(goalController.text);
                      }),
                  const SizedBox(height: 36.0),
                  const Text(
                    'User Id',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextFormField(
                    controller: userIdController,
                    decoration:
                        InputDecoration(hintText: userIdController.text),
                  ),
                  Row(
                    children: [
                      TextButton(
                          child: const Text('SWITCH USER'),
                          onPressed: () async {
                            return _switchUser(userIdController.text);
                          }),
                      TextButton(
                        child: const Text('GET CURRENT USER'),
                        onPressed: () async {
                          return _getCurrentUser();
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
