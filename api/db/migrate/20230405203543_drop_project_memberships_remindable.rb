# frozen_string_literal: true

class DropProjectMembershipsRemindable < ActiveRecord::Migration[7.0]
  def change
    # Skip if table doesn't exist yet
    if table_exists?(:project_memberships)
      remove_index(:project_memberships, [:remindable, :member_id]) if index_exists?(:project_memberships, [:remindable, :member_id])
      remove_index(:project_memberships, :remindable) if index_exists?(:project_memberships, :remindable)
      remove_column(:project_memberships, :remindable, :boolean, default: true) if column_exists?(:project_memberships, :remindable)
    end
  end
end
