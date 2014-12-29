class MakeSubmittedAtARealDataColumn < ActiveRecord::Migration
  def self.up
    Response.where(:submitted => true).find_each do |resp|
      next unless resp.submitted
      
      say "Updating response #{resp.id}"
      resp.submitted_at = resp.answers.maximum(:updated_at)
      resp.save(false)
    end
  end

  def self.down
  end
end
