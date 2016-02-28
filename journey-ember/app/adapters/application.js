import ActiveModelAdapter from 'active-model-adapter';
import Ember from 'ember';

const token = Ember.$('meta[name="csrf-token"]').attr('content');

const ApplicationAdapter = ActiveModelAdapter.extend({
  namespace: 'api/v1',
  headers: {
    "X-CSRF-TOKEN": token
  }
});

export default ApplicationAdapter;
