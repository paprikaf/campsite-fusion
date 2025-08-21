class DropProjectMemberships < ActiveRecord::Migration[7.0]
  def change
    # Skip if table doesn't exist yet
    if table_exists?(:project_memberships)
      drop_table :project_memberships
    end
  end
end
