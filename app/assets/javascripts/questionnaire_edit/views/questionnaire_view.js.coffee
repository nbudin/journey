QuestionnaireEdit.QuestionnaireView = Ember.View.extend
  didInsertElement: ->
    @$('#edit-toolbar .add-fields-menu').accordion
      heightStyle: "content"