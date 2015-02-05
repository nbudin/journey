`import DS from 'ember-data'`

token = $('meta[name="csrf-token"]').attr('content')

ApplicationAdapter = DS.ActiveModelAdapter.extend
  namespace: 'api/v1'
  headers:
    "X-CSRF-TOKEN": token

`export default ApplicationAdapter`
