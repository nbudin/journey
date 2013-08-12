QuestionnaireEdit.Page = DS.Model.extend
  questionnaire: DS.belongsTo 'QuestionnaireEdit.Questionnaire'
  
  title: DS.attr 'string'