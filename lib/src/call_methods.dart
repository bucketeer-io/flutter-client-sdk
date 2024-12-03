enum CallMethods {
  initialize,
  stringVariation,
  intVariation,
  doubleVariation,
  boolVariation,
  jsonVariation,
  track,
  currentUser,
  updateUserAttributes,
  fetchEvaluations,
  flush,
  evaluationDetails,
  addProxyEvaluationUpdateListener,
  destroy,
  unknown,

  objectVariation,
  objectVariationDetails,
  intVariationDetails,
  boolVariationDetails,
  doubleVariationDetails,
  stringVariationDetails,
}

abstract class CallMethodParams {
  static const featureId = 'featureId';
  static const defaultValue = 'defaultValue';
}
