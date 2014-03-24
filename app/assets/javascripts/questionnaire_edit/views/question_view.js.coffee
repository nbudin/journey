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
  
  optionsVisible: false
  actions:
    hideOptions: -> @set('optionsVisible', false)
    showOptions: -> @set('optionsVisible', true)