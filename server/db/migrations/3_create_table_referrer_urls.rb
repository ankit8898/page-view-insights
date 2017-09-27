Sequel.migration do
  change do
    create_table(:referrer_urls) do
      primary_key :id
      String :name
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
    end
  end
end
