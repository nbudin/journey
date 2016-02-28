import Ember from 'ember';

export default Ember.Component.extend({
  editing: false,
  classNames: ['in-place-editor'],
  displayRawHtml: false,

  keyPress(e) {
    if (e.keyCode === 13 && this.get('editing')) {
      this.send('saveNewValue');
    }
  },

  actions: {
    startEditing() {
      this.set('newValue', this.get('value'));
      this.set('disabled', false);
      this.set('editing', true);
      this.$().find('input').focus();
    },

    saveNewValue() {
      this.set('disabled', true);

      const oldValue = this.get('value');
      this.set('value', this.get('newValue'));

      this.get('model').save().then(
        () => {
          this.set('disabled', false);
          this.set('editing', false);
        },
        (error) => {
          this.set('disabled', false);
          this.set('value', oldValue);
          alert(error);
        }
      );
    },

    cancelEditing() {
      this.set('newValue', null);
      this.set('editing', false);
    }
  }
});
