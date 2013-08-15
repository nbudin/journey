QuestionnaireEdit.EditQuestionComponent = Ember.Component.extend
  tagName: 'li'
  classNames: 'question'
  classNameBindings: ['resetsCycle:reset-cycle', 'ignoresCycle:ignore-cycle']
    
  resetsCycle: ( ->
    @get('question.type') == "Questions::Divider"
  ).property('question.type')
  
  ignoresCycle: ( ->
    @get('question.type') in ["Questions::Divider", "Questions::Heading", "Questions::Label"]
  ).property('question.type')