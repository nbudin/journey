QuestionnaireEdit.PagesController = Ember.ArrayController.extend
  questionnaire: null
  needs: "questionnaire"
  questionnaireBinding: "controllers.questionnaire"

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