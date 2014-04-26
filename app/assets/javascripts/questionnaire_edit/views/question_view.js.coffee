QuestionnaireEdit.QuestionView = Ember.View.extend
  tagName: 'li'
  classNames: ['question']
  classNameBindings: ['resetsCycle:reset-cycle', 'ignoresCycle:ignore-cycle', 'cardinality', 'layoutClass']
  templateName: 'question'
  controllerBinding: 'content'
    
  resetsCycle: ( ->
    @get('content.type') == "Questions::Divider"
  ).property('content.type')
  
  ignoresCycle: ( ->
    @get('content.type') in ["Questions::Heading", "Questions::Label"]
  ).property('content.type')
  
  layoutClass: ( ->
    "layout-#{@get "content.layout"}"
  ).property('content.layout')
  
  saveInPlace: ( ->
    Ember.run.debounce(@get('content'), 'save', 300)
  ).observes('content.defaultAnswer', 'content.min', 'content.max', 'content.step', 'content.layout', 'content.radioLayout', 'content.required')
  
  defaultAnswerBoolean: ( (key, value, oldValue) ->
    # getter
    if arguments.length == 1
      defaultAnswer = @get('content.defaultAnswer')
      defaultAnswer != null && defaultAnswer != ''
    
    # setter
    else
      @set('content.defaultAnswer', (if value then 'true' else null))
  ).property('content.defaultAnswer')
  
  isLeftLayout: ( ->
    @get('content.layout') == 'left'
  ).property('content.layout')
  
  isRadio: ( ->
    @get('content.type') == 'Questions::RadioField'
  ).property('content.type')
  
  isVerticalRadioLayout: ( ->
    @get('content.radioLayout') == 'vertical'
  ).property('content.radioLayout')
  
  optionsVisible: false
  actions:
    eraseDefaultAnswer: -> @set('content.defaultAnswer', null)
    hideOptions: -> @set('optionsVisible', false)
    setLayout: (layout) -> @set('content.layout', layout)    
    setRadioLayout: (radioLayout) -> @set('content.radioLayout', radioLayout)
    showOptions: -> @set('optionsVisible', true)
    toggleRequired: -> @set('content.required', !@get('content.required'))
      
    
