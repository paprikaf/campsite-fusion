class ChangeProjectMembershipsRemindableDefault < ActiveRecord::Migration[7.0]
  def change
    # Skip this migration if table doesn't exist yet (it gets created later)
    if table_exists?(:project_memberships)
      change_column_default(:project_memberships, :remindable, true)
    end
  end
end
