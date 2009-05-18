class AddOwnerToQuestionnaires < ActiveRecord::Migration
  def self.up
    add_column :questionnaires, :owner_id, :integer

    # populate initial owners
    # grandfather in unlimited entitlements for the existing owners
    Questionnaire.all(:include => :permissions).each do |q|
      owner = q.obtain_owner(:skip_save => true)
      if owner
        e = Entitlement.find_or_create_by_person_id(owner.id)
        e.unlimited = true
        e.save

        q.reload
        q.obtain_owner
      end
    end
  end

  def self.down
    remove_column :questionnaires, :owner_id
  end
end
