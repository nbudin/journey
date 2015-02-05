`import Ember from 'ember'`

PageController = Ember.ObjectController.extend
  questionnaire: null
  needs: ['questionnaire', 'pages']
  questionnaireBinding: 'controllers.questionnaire'
  defaultLayoutBinding: 'controllers.pages.defaultLayout'
  
  isCurrent: ( ->
    @get('controllers.pages.currentPage.id') == @get('id')
  ).property('controllers.pages.currentPage.id', 'id')

  scrollIntoView: -> 
    element = $(".answerpage[data-page-id=#{@get('id')}]").get(0)
    if element
      element.scrollIntoViewIfNeeded()
    else
      Ember.run.next this, this.scrollIntoView
      
  actions:
    addQuestion: (type, purpose) ->
      question = @get('store').createRecord 'question',
        page: @get('model')
        type: type
        purpose: purpose
        layout: @get('defaultLayout')
      question.save().then =>
        @get('questions').addObject(question)

`export default PageController`