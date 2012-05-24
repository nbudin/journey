class MakeSubmittedAtARealDataColumn < ActiveRecord::Migration
  def self.up
    Response.all(:conditions => {:submitted => true}).each do |resp|
      next unless resp.submitted
      
      say "Updating response #{resp.id}"
      resp.submitted_at = resp.answers.maximum(:updated_at)
      resp.save!
    end
  end

  def self.down
  end
end
