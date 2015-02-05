`import Ember from 'ember'`

RadioButtonView = Ember.View.extend
  tagName: 'input'
  
  attributeBindings: ['type', 'value', 'checked']
  type: 'radio'
  
  checked: ( ->
    @get('target')?.toString() == @get('value')?.toString()
  ).property('target', 'value')

  change: -> @set('target', @get('value')) if @$().is(':checked')

`export default RadioButtonView`