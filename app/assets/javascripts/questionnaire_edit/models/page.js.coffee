QuestionnaireEdit.Page = DS.Model.extend
  questionnaire: DS.belongsTo 'QuestionnaireEdit.Questionnaire'
  questions: DS.hasMany 'QuestionnaireEdit.Question'
  
  title: DS.attr 'string'
  
  number: ( ->
    @get('questionnaire.pages').indexOf(@) + 1
  ).property('questionnaire.pages')