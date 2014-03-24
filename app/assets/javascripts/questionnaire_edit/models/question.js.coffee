QuestionnaireEdit.Question = DS.Model.extend
  page: DS.belongsTo 'page'
  #questionOptions: DS.hasMany 'QuestionnaireEdit.QuestionOption'
  
  caption: DS.attr 'string'
  type: DS.attr 'string'
  position: DS.attr 'number'
  layout: DS.attr 'string'
  required: DS.attr 'boolean'
  
  isDisplay: ( ->
    @get('type') in ["Questions::Divider", "Questions::Heading", "Questions::Label"]
  ).property('type')
  
  hasPurpose: ( ->
    @get('purpose') && @get('purpose').trim() != ''
  ).property('purpose')