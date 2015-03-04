class CreateShortenedUrls < ActiveRecord::Migration
  def change
    create_table :shortened_urls do |t|
      t.string :long_url, null: false
      t.string :short_url, null: false, unique: true
      t.integer :submitter_id, null: false
      t.timestamps
    end

    add_index :shortened_urls, [:submitter_id]
  end
end
