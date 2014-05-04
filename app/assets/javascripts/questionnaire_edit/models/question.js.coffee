QuestionnaireEdit.Question = DS.Model.extend
  page: DS.belongsTo 'page'
  questionOptions: DS.hasMany 'question_option', async: true
  
  caption: DS.attr 'string'
  type: DS.attr 'string'
  position: DS.attr 'number'
  layout: DS.attr 'string', defaultValue: 'left'
  radioLayout: DS.attr 'string', defaultValue: 'inline'
  required: DS.attr 'boolean'
  defaultAnswer: DS.attr 'string'
  min: DS.attr 'number', defaultValue: 0
  max: DS.attr 'number', defaultValue: 0
  step: DS.attr 'number', defaultValue: 1
  
  isDisplay: ( ->
    @get('type') in ["Questions::Divider", "Questions::Heading", "Questions::Label"]
  ).property('type')
  
  hasPurpose: ( ->
    !Ember.isBlank(@get('purpose'))
  ).property('purpose')

  rangeOptions: ( ->
    return [] unless @get('type') == "Questions::RangeField"
    options = ({value: i} for i in [parseInt(@get('min'))..parseInt(@get('max'))] by parseInt(@get('step')))
    
    length = options.length
    if length % 2 == 1
      options[Math.floor(length / 2)].isMedian = true
    
    options
  ).property('type', 'min', 'max', 'step')