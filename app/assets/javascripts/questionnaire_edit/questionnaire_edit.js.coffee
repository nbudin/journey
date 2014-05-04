#= require handlebars
#= require ember
#= require ember-data
#= require underscore.string

#= require_self
#= require ./store
#= require_tree ./models
#= require_tree ./controllers
#= require_tree ./views
#= require_tree ./components
#= require_tree ./helpers
#= require_tree ../templates
#= require_tree ./routes
#= require ./router

window.QuestionnaireEdit = Ember.Application.create
  rootElement: "#questionnaire_edit"
  
QuestionnaireEdit.initializer
  name: "preloadQuestionnaire"
  initialize: (container, app) ->
    if window.questionnaireData
      container.lookup('store:main').pushPayload 'questionnaire', window.questionnaireData