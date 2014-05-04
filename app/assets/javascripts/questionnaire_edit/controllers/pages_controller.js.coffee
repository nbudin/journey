QuestionnaireEdit.PagesController = Ember.ArrayController.extend
  questionnaire: null
  needs: "questionnaire"
  questionnaireBinding: "controllers.questionnaire"
  contentBinding: "questionnaire.pages"
  itemController: 'page'
  defaultLayout: 'left'
  currentPage: null
  
  actions:
    addQuestion: (type, purpose) ->
      question = this.store.createRecord 'question',
        page: @get('model')
        type: type
        purpose: purpose
        layout: @get('defaultLayout')
      question.save().then =>
        @get('questions').addObject(question)
    
    createPage: ->
      page = @get('store').createRecord QuestionnaireEdit.Page,
        questionnaire: @get('questionnaire.content')
      
      page.save()
      @transitionToRoute 'page', page
    
    deletePage: (page) ->
      if confirm("Do you really want to delete the page \"#{page.get 'title'}\"?")
        page.deleteRecord()
        page.save()
      
        @transitionToRoute 'pages'