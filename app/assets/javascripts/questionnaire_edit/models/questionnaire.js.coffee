QuestionnaireEdit.Questionnaire = DS.Model.extend
  advertiseLogin: DS.attr 'boolean'
  
  pages: DS.hasMany 'page', async: true
  
  hasMultiplePages: ( -> @get('pages.length') > 1 ).property('pages')