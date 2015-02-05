`import Ember from 'ember'`

PagesView = Ember.CollectionView.extend
  contentBinding: 'controller'
  itemViewClass: Ember.View.extend
    template: Ember.Handlebars.compile """
    {{#with view.content}}
      {{#unless isFirstPage}}
        <div class="page-boundary"></div>
      {{/unless}}
      {{view PageView contentBinding="this"}}
    {{/with}}
    """

  didInsertElement: ->
    @set 'scrollHandler', => @scrolled(arguments)
    
    $(window).on 'scroll', @get('scrollHandler')
    $(document).on 'touchmove', @get('scrollHandler')
    
  willDestroyElement: ->
    $(window).off 'scroll', @get('scrollHandler')
    $(document).off 'scroll', @get('scrollHandler')
    
  scrolled: (event) ->
    $window = $(window)
    docViewTop = $window.scrollTop()
    docViewBottom = docViewTop + $window.height()
    
    currentPageIsInvisible = false
    nextVisibleOffset = null
    currentPageIndex = null
    
    childViewStates = @get('childViews').map (childView, index) =>
      $element = $(childView.get('element'))
      elemTop = $element.offset().top
      elemBottom = elemTop + $element.height()
      
      invisible = (elemBottom < docViewTop || elemTop > docViewBottom)
      if childView.get('content.model') == @get('controller.currentPage') && invisible
        currentPageIsInvisible = true
        currentPageIndex = index
        if elemBottom < docViewTop
          nextVisibleOffset = 1
        else
          nextVisibleOffset = -1

      { childView: childView, index: index, invisible: invisible }
    
    if currentPageIsInvisible
      nextVisibleView = childViewStates[currentPageIndex + nextVisibleOffset].childView
      @get('controller').transitionToRoute('page', nextVisibleView.get('content.model'))

`export default PagesView`