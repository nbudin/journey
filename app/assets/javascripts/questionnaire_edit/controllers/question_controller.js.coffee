QuestionnaireEdit.QuestionController = Ember.ObjectController.extend
  saveInPlace: ( ->
    Ember.run.debounce(@get('model'), 'save', 300)
  ).observes('defaultAnswer', 'min', 'max', 'step', 'layout', 'radioLayout', 'required')
  
  defaultAnswerBoolean: ( (key, value, oldValue) ->
    # getter
    if arguments.length == 1
      defaultAnswer = @get('defaultAnswer')
      defaultAnswer != null && defaultAnswer != ''
    
    # setter
    else
      @set('defaultAnswer', (if value then 'true' else null))
  ).property('defaultAnswer')
  
  isLeftLayout: ( ->
    @get('layout') == 'left'
  ).property('layout')
  
  isRadio: ( ->
    @get('type') == 'Questions::RadioField'
  ).property('type')
  
  isVerticalRadioLayout: ( ->
    @get('radioLayout') == 'vertical'
  ).property('radioLayout')
  
  resetsCycle: ( ->
    @get('type') == "Questions::Divider"
  ).property('type')
  
  ignoresCycle: ( ->
    @get('type') in ["Questions::Heading", "Questions::Label"]
  ).property('type')
  
  actions:
    eraseDefaultAnswer: -> @set('content.defaultAnswer', null)
    setLayout: (layout) -> @set('content.layout', layout)    
    setRadioLayout: (radioLayout) -> @set('content.radioLayout', radioLayout)
    toggleRequired: -> @set('required', !@get('required'))
    
  
  