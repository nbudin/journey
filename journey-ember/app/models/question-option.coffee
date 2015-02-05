`import DS from 'ember-data'`

QuestionOption = DS.Model.extend
  question: DS.belongsTo 'question'

  option: DS.attr 'string'
  outputValue: DS.attr 'string'
  position: DS.attr 'number'
  
`export default QuestionOption`