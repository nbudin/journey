import Ember from 'ember';
const $ = Ember.$;

export default Ember.Component.extend({
  willRender() {
    this.set('pageEditors', Ember.A());
  },

  didInsertElement() {
    this._super(...arguments);

    this.set('scrollHandler', () => { this.scrolled(...arguments); });

    $(window).on('scroll', this.get('scrollHandler'));
    $(document).on('touchmove', this.get('scrollHandler'));
  },

  willDestroyElement() {
    $(window).off('scroll', this.get('scrollHandler'));
    $(document).off('scroll', this.get('scrollHandler'));
  },

  scrolled() {
    const $window = $(window);
    const docViewTop = $window.scrollTop();
    const docViewBottom = docViewTop + $window.height();

    let currentPageIsInvisible = false;
    let nextVisibleOffset = null;
    let currentPageIndex = null;

    const pageStates = this.get('pageEditors').map((page, index) => {
      const $element = $(page.get('element'));
      const elemTop = $element.offset().top;
      const elemBottom = elemTop + $element.height();

      const invisible = (elemBottom < docViewTop || elemTop > docViewBottom);
      if (page.get('content.model') === this.get('controller.currentPage') && invisible) {
        currentPageIsInvisible = true;
        currentPageIndex = index;

        if (elemBottom < docViewTop) {
          nextVisibleOffset = 1;
        } else {
          nextVisibleOffset = -1;
        }
      }

      return { page: page, index: index, invisible: invisible };
    });

    if (currentPageIsInvisible) {
      const nextVisiblePage = pageStates[currentPageIndex + nextVisibleOffset].page;
      this.get('controller').transitionToRoute('admin.questionnaire.pages.page', nextVisiblePage.get('page'));
    }
  },

  actions: {
    register: function(pageEditor) {
      this.get('pageEditors').addObject(pageEditor);
    }
  }
});
