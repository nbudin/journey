# http://emberjs.com/guides/models/defining-a-store/

QuestionnaireEdit.RESTAdapter = DS.RESTAdapter.extend
  namespace: 'api/v1'
  ajax: (url, type, hash) ->
    unless type == 'GET'
      hash ||= {}
      hash.headers ||= {}
      hash.headers['X-CSRF-Token'] = jQuery('meta[name="csrf-token"]').attr('content')
      
    @_super url, type, hash

QuestionnaireEdit.Store = DS.Store.extend
  revision: 11
  adapter: QuestionnaireEdit.RESTAdapter.create()