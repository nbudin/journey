# http://emberjs.com/guides/models/defining-a-store/

DS.RESTAdapter.reopen
  namespace: 'api/v1'

QuestionnaireEdit.Store = DS.Store.extend
  revision: 11
  adapter: DS.RESTAdapter.create()