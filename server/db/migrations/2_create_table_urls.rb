Sequel.migration do
  change do
    create_table(:urls) do
      primary_key :id
      String :name, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP, index: true
    end
  end
end
