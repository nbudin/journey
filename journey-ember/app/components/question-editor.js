import Ember from 'ember';

export default Ember.Component.extend({
  tagName: 'li',
  classNames: ['question'],
  classNameBindings: [
    'resetsCycle:reset-cycle',
    'ignoresCycle:ignore-cycle',
    'content.cardinality',
    'layoutClass',
    'editMode:edit-mode:'
  ],
  editMode: false,

  layoutClass: function() {
    "layout-" + this.get("question.layout")
  }.property('question.layout'),

  click(event) {
    // don't bubble clicks inside a question up to the current page; stops link-to from preventing inputs from working
    event.stopPropagation();
  },

  actions: {
    save() {
      this.get('question').save().then(
        () => { this.set('editMode', false); },
        (error) => { alert("Saving failed with error: " + error); }
      )
    },

    toggleEditMode() {
      if (this.get('editMode') && this.get('question.isDirty')) {
        if (!confirm("There are unsaved changes.  Are you sure you want to lose them?")) {
          return;
        }

        this.get('question').rollback();
      }

      this.set('editMode', !this.get('editMode'));
      if (this.get('editMode')) {
        this.sendAction('enteredEditMode', this.get('question'));
      }
    }
  }
});

