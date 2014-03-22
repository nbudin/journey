# For more information see: http://emberjs.com/guides/routing/

QuestionnaireEdit.Router.map ()->
  @resource 'questionnaire', ->
    @resource 'pages', ->
      @resource 'page', path: ':page_id', ->
        @resource 'questions'
      
QuestionnaireEdit.IndexRoute = Ember.Route.extend
  redirect: -> this.transitionTo('pages')
