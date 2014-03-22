QuestionnaireEdit.QuestionView = Ember.View.extend
  tagName: 'li'
  classNames: ['question']
  classNameBindings: ['resetsCycle:reset-cycle', 'ignoresCycle:ignore-cycle', 'cardinality']
  templateName: 'question'
    
  resetsCycle: ( ->
    @get('content.type') == "Questions::Divider"
  ).property('question.type')
  
  ignoresCycle: ( ->
    @get('content.type') in ["Questions::Heading", "Questions::Label"]
  ).property('question.type')