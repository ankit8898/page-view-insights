Sequel.migration do
  change do
    create_table(:page_views) do
      primary_key :id
      String :url, null: false
      String :referrer
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      String :hash
    end
  end
end