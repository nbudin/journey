export default {
  name: 'preload-questionnaire',
  after: 'store',
  initialize: function (container) {
    if (window.questionnaireData) {
      container.lookup('store:main').pushPayload('questionnaire', window.questionnaireData);
    }
  }
};   