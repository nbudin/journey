`import DS from 'ember-data'`

Page = DS.Model.extend
  questionnaire: DS.belongsTo 'questionnaire'
  questions: DS.hasMany 'question', async: true
  
  title: DS.attr 'string'
  position: DS.attr 'number'
  questionsSorting: ['position']
  questionsSorted: Ember.computed.sort('questions', 'questionsSorting')
  
  number: ( ->
    pages = @get('questionnaire.pagesSorted')
    pages && (pages.indexOf(@) + 1)
  ).property('questionnaire.pagesSorted')
  
  isFirstPage: ( ->
    @get('number') == 1
  ).property('number')
  
  isLastPage: ( ->
    @get('number') < @get('questionnaire.pages.size')
  ).property('questionnaire.pages.size', 'number')
  
`export default Page`