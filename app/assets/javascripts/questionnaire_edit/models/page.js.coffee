QuestionnaireEdit.Page = DS.Model.extend
  questionnaire: DS.belongsTo 'QuestionnaireEdit.Questionnaire'
  questions: DS.hasMany 'QuestionnaireEdit.Question'
  
  title: DS.attr 'string'
  
  number: ( ->
    pages = @get('questionnaire.pages')
    pages && (pages.indexOf(@) + 1)
  ).property('questionnaire.pages')
  
  isFirstPage: ( ->
    @get('number') == 1
  ).property('number')
  
  isLastPage: ( ->
    @get('number') < @get('questionnaire.pages.size')
  ).property('questionnaire.pages.size', 'number')