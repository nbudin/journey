QuestionnaireEdit.Questionnaire = DS.Model.extend
  advertiseLogin: DS.attr 'boolean'
  
  pages: DS.hasMany 'page', async: true
  pagesSorting: ['position']
  pagesSorted: Ember.computed.sort('pages', 'pagesSorting')
  
  hasMultiplePages: ( -> @get('pages.length') > 1 ).property('pages')