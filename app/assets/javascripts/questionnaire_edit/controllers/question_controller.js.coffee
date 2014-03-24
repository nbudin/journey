QuestionnaireEdit.QuestionController = Ember.ObjectController.extend
  actions:
    toggleRequired: ->
      @set('required', !@get('required'))
      @get('content').save()