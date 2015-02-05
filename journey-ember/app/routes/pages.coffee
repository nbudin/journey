`import Ember from 'ember'`

PagesRoute = Ember.Route.extend
  model: -> @modelFor('questionnaire').get('pages')
  actions:
    setCurrentPage: (page) ->
      @transitionTo('page', page)
      pageController = @controllerFor('page')
      Ember.run.schedule 'afterRender', pageController, pageController.scrollIntoView
      
`export default PagesRoute`