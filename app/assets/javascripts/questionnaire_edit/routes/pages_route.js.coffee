QuestionnaireEdit.PagesRoute = Ember.Route.extend
  actions:
    setCurrentPage: (page) ->
      @transitionTo('page', page)
      pageController = @controllerFor('page')
      Ember.run.schedule 'afterRender', pageController, pageController.scrollIntoView