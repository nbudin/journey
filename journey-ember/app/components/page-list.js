import Ember from 'ember';

export default Ember.Component.extend({
  actions: {
    setCurrentPage(page) {
      this.sendAction('setCurrentPage', page);
    },

    deletePage(page) {
      this.get('deletePage')(page);
    }
  }
});
