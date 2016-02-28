import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['pageview'],

  willRender() {
    this.attrs.register(this);
  },

  scrollIntoView: Ember.on('didInsertElement', function() {
    if (this.get('isCurrent')) {
      Ember.run.schedule('afterRender', this.get('controller'), this.get('controller').scrollIntoView);
    }
  }),

  actions: {
    questionEnteredEditMode(question) {
      this.sendAction('setCurrentPage', question.get('page'));
    }
  }
});
