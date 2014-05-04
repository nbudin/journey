QuestionnaireEdit.QuestionnaireController = Ember.ObjectController.extend
  actions:
    createPage: ->
      page = @get('store').createRecord QuestionnaireEdit.Page,
        questionnaire: @get('content')
      
      page.save().then (=>
        @get('pages').then => @get('pages').addObject(page)
        @transitionToRoute 'page', page
      ), (error) -> alert(error)
    
    deletePage: (page) ->
      if confirm("Do you really want to delete the page \"#{page.get 'title'}\"?")
        page.deleteRecord()
        page.save().then (=>
          @get('pages').then => @get('pages').removeObject(page)
          @transitionToRoute 'pages'
        ), (error) -> alert(error)
          
        
      
