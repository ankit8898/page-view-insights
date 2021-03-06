Sequel.migration do
  change do
    create_table(:page_views) do
      primary_key :id
      Integer :url_id, null: false
      Integer :referrer_url_id, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
      String :hash
    end
  end
end
