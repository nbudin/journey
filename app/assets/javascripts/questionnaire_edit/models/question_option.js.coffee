QuestionnaireEdit.QuestionOption = DS.Model.extend
  question: DS.belongsTo 'question'

  option: DS.attr 'string'
  outputValue: DS.attr 'string'
  position: DS.attr 'number'