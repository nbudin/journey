QuestionnaireEdit.Question = DS.Model.extend
  page: DS.belongsTo 'page'
  #questionOptions: DS.hasMany 'QuestionnaireEdit.QuestionOption'
  
  caption: DS.attr 'string'
  type: DS.attr 'string'