class AddPreviousContentColumnsToPostAndPostComment < ActiveRecord::Migration[7.0]
  def change
    add_column :posts, :previous_description, :text
    add_column :post_comments, :previous_body, :text

    reversible do |dir|
      dir.up do
        # Use raw SQL to avoid model dependencies during migration
        execute "UPDATE posts SET previous_description = description WHERE previous_description IS NULL"
        execute "UPDATE post_comments SET previous_body = body WHERE previous_body IS NULL"
      end
    end
  end
end
