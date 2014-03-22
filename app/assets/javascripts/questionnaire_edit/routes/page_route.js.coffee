QuestionnaireEdit.PageRoute = Ember.Route.extend
  model: (params) -> @store.find('page', params.page_id)
  redirect: -> this.transitionTo('questions')