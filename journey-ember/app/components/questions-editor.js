import Ember from 'ember';

export default Ember.Component.extend({
  questions: Ember.A(),

  rezebrify() {
    let i = 1;
    this.get('questions').forEach((item) => {
      if (item.get('resetsCycle')) {
        i = 1;
      }

      if (item.get('ignoresCycle')) {
        item.set('cardinality', null);
      } else {
        item.set('cardinality', ['even', 'odd'][i % 2]);
        i++;
      }
    });
  },

  rezebrifyObserver: function() {
    Ember.run.debounce(this, this.rezebrify, 50);
  }.observes('questions.@each.position', 'questions.@each.type')
});
