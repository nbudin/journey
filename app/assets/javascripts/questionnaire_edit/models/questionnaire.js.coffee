QuestionnaireEdit.Questionnaire = DS.Model.extend
  advertiseLogin: DS.attr 'boolean'
  
  pages: DS.hasMany 'QuestionnaireEdit.Page'