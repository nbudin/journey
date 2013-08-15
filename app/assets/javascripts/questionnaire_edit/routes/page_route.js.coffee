QuestionnaireEdit.PageRoute = Ember.Route.extend
  model: (params) ->
    QuestionnaireEdit.Page.find(params.page_id)