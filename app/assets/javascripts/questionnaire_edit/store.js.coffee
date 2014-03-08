# http://emberjs.com/guides/models/defining-a-store/

token = $('meta[name="csrf-token"]').attr('content')

DS.RESTAdapter.reopen
  namespace: 'api/v1'
  headers:
    "X-CSRF-TOKEN": token

QuestionnaireEdit.Store = DS.Store.extend
  adapter: "-active-model"