QuestionnaireEdit.QuestionController = Ember.ObjectController.extend
  defaultAnswerBoolean: ( (key, value, oldValue) ->
    # getter
    if arguments.length == 1
      defaultAnswer = @get('defaultAnswer')
      defaultAnswer != null && defaultAnswer != ''
    
    # setter
    else
      @set('defaultAnswer', (if value then 'true' else null))
  ).property('defaultAnswer')
  
  saveInPlace: ( ->
    Ember.run.debounce(@get('model'), 'save', 300)
  ).observes('defaultAnswer', 'min', 'max', 'step')

  actions:
    toggleRequired: ->
      @set('required', !@get('required'))
      @get('content').save()