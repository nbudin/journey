QuestionnaireEdit.QuestionsController = Ember.ArrayController.extend
  page: null
  needs: 'page'
  pageBinding: 'controllers.page'
  contentBinding: 'page.questions'
  
  sortProperties: ['position']
  sortAscending: true