class ProxyEvaluationUpdateListenToken {
  ProxyEvaluationUpdateListenToken._();

  // The native SDK listen token
  static String? _proxyEvaluationUpdateListenToken;

  static void setToken(String value) {
    _proxyEvaluationUpdateListenToken = value;
  }

  static void clearToken() {
    _proxyEvaluationUpdateListenToken = null;
  }

  static String? getToken() {
    return _proxyEvaluationUpdateListenToken;
  }
}
