require 'rexml/document'

class JqmlController < ApplicationController
  layout "global", :except => :export
  
  def export
    @questionnaire = Questionnaire.find(@params[:id])
    @headers["Content-Disposition"] = "attachment; filename=\"#{@questionnaire.title}.jqml\""
    @headers["Content-Type"] = "application/xml; charset=utf-8"
  end
  
  def import
    if @params[:file]
      root = REXML::Document.new(@params[:file].read).root
      q = Questionnaire.create(:title => root.attributes['title'], :custom_html => '',
        :custom_css => '', :is_open => false)
      q.pages[0].destroy
      q.save
      root.each_element do |element|
        if element.name == 'custom_html'
          q.custom_html = element.text
        elsif element.name == 'custom_css'
          q.custom_css = element.text
        elsif element.name == 'page'
          p = Page.create :title => element.attributes['title'], :questionnaire => q
          element.each_element do |question|
            if question.name != 'question'
              raise "Found a #{question.name} tag that shouldn't be a direct child of page"
            end
            
            ques = Question.create(:required => question.attributes['required'], :page => p)
            
            question.each_element('caption') do |caption|
              ques.caption = caption.text
            end
            da = nil
            question.each_element('default_answer') do |default_answer|
              da = default_answer.text
              logger.info "Default answer is #{da}"
            end
            
            # a bit hackish, but I can't think of a better way to do it
            ques.update_attribute(:type, question.attributes['type'])
            ques.save
            ques = Question.find(ques.id)
            
            if ques.kind_of? RangeField
              question.each_element('range') do |range|
                ['min', 'max', 'step'].each do |attrib|
                  ques.send "#{attrib}=", range.attributes[attrib]
                end
              end
            end
            
            if ques.kind_of? SelectorField
              optrows = {}
              question.each_element('option') do |option|
                o = QuestionOption.new :option => option.text
                ques.question_options << o
                o.save
                optrows[option.text] = o
                logger.info("Inserted optrows[#{option.text}] with id #{o.id}")
              end
              if da and da.length > 0
                logger.info("Setting default answer for question to #{optrows[da].option}")
                ques.default_answer = optrows[da].option
              end
            end
            
            ques.position = p.questions.length + 1
            p.questions << ques
            ques.save
          end
          
          p.position = q.pages.length + 1
          q.pages << p
          p.save
        else
          raise "Found a #{element.name} tag that shouldn't be a direct child of questionnaire"
        end
      end
      q.save
      redirect_to :controller => 'questionnaire', :action => 'edit', :id => q.id
    end
  end
end
