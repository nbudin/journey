QuestionnaireEdit.QuestionView = Ember.View.extend
  tagName: 'li'
  classNames: ['question']
  classNameBindings: ['resetsCycle:reset-cycle', 'ignoresCycle:ignore-cycle', 'cardinality', 'layoutClass']
  templateName: 'question'
  contentBinding: 'controller'
    
  resetsCycle: ( ->
    @get('content.type') == "Questions::Divider"
  ).property('content.type')
  
  ignoresCycle: ( ->
    @get('content.type') in ["Questions::Heading", "Questions::Label"]
  ).property('content.type')
  
  layoutClass: ( ->
    "layout-#{@get "content.layout"}"
  ).property('content.layout')
  
  optionsVisible: false
  actions:
    eraseDefaultAnswer: -> @set('content.defaultAnswer', null)
    hideOptions: -> @set('optionsVisible', false)
    setLayout: (layout) -> @set('content.layout', layout)    
    setRadioLayout: (radioLayout) -> @set('content.radioLayout', radioLayout)
    showOptions: -> @set('optionsVisible', true)
    toggleRequired: -> @set('content.required', !@get('content.required'))
      
    
