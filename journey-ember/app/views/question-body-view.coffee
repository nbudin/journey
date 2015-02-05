`import Ember from 'ember'`

QuestionBodyView = Ember.View.extend
  templateName: (->
    @get('content.type') && "question_body/#{_.snakeCase @get('content.type').replace("Questions::", "")}"
  ).property('content.type')
  
  radioLayoutClass: ( ->
    "layout-#{@get "content.radioLayout"}"
  ).property('content.radioLayout')

`export default QuestionBodyView`