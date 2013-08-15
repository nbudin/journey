QuestionnaireEdit.Questionnaire = DS.Model.extend
  advertiseLogin: DS.attr 'boolean'
  
  pages: DS.hasMany 'QuestionnaireEdit.Page'
  
  hasMultiplePages: ( -> @get('pages.length') > 1 ).property('pages')