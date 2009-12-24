### DEPRECATED in favor of the "notes" attribute of the responses table.
#   Kept around only so that the migration away from
#   these will continue working.
class Questions::AnnotationField < Questions::FreeformField
  def self.friendly_name
    "Admin notes"
  end
end
