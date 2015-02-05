`import Ember from 'ember'`

QuestionnaireRoute = Ember.Route.extend
  model: (controller) ->
    questionnaireId = jQuery('#questionnaire_edit').data('questionnaire-id')
    @store.find('questionnaire', questionnaireId)
  redirect: -> this.transitionTo('pages')
    
`export default QuestionnaireRoute`