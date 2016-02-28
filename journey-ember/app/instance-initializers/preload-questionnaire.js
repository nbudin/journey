export function initialize(appInstance) {
  if (window.questionnaireData) {
    //appInstance.lookup('service:store').pushPayload('questionnaire', window.questionnaireData);
  }
}

export default {
  name: 'preload-questionnaire',
  initialize: initialize
};
