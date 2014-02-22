QuestionnaireEdit.QuestionnaireRoute = Ember.Route.extend
  model: (controller) ->
    questionnaireId = jQuery('#questionnaire_edit').data('questionnaire-id')
    @store.find('questionnaire', questionnaireId)