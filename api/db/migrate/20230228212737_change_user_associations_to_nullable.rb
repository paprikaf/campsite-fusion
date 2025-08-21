class ChangeUserAssociationsToNullable < ActiveRecord::Migration[7.0]
  def change
    change_column_null :poll_votes, :user_id, true
    change_column_null :post_views, :user_id, true
    change_column_null :post_comments, :user_id, true
    change_column_null :posts, :user_id, true
    
    # Skip project_memberships if table doesn't exist yet
    if table_exists?(:project_memberships)
      change_column_null :project_memberships, :user_id, true
    end
    
    change_column_null :reactions, :user_id, true
  end
end
