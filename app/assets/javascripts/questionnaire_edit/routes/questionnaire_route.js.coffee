QuestionnaireEdit.QuestionnaireRoute = Ember.Route.extend
  model: (controller) ->
    questionnaireId = jQuery('#questionnaire_edit').data('questionnaire-id')
    QuestionnaireEdit.Questionnaire.find(questionnaireId)