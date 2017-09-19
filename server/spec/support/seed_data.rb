module SeedData

  def seed_test_data
    system('bin/rails runner "Seeder.new(100, 10).seed"')    
  end
end
