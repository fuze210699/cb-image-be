# lib/tasks/seed_data.rake

namespace :db do
  desc "Seed sample data for development"
  task seed_data: :environment do
    puts "Creating sample data..."

    # Create admin user
    admin = User.find_or_create_by(email: 'admin@cbimage.com') do |user|
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = 'admin'
    end
    puts "Admin user created: #{admin.email}"

    # Create regular users
    5.times do |i|
      user = User.find_or_create_by(email: "user#{i+1}@example.com") do |u|
        u.password = 'password123'
        u.password_confirmation = 'password123'
        u.role = 'user'
      end
      puts "User created: #{user.email}"
    end

    # Create promotions
    Promotion.find_or_create_by(code: 'WELCOME20') do |promo|
      promo.description = 'Welcome discount - 20% off'
      promo.discount_type = 'percentage'
      promo.discount_value = 20
      promo.start_date = Time.current
      promo.end_date = Time.current + 30.days
      promo.max_uses = 100
      promo.active = true
    end

    Promotion.find_or_create_by(code: 'SAVE10') do |promo|
      promo.description = 'Save $10 on your purchase'
      promo.discount_type = 'fixed'
      promo.discount_value = 10
      promo.start_date = Time.current
      promo.end_date = Time.current + 60.days
      promo.max_uses = 50
      promo.min_purchase_amount = 50
      promo.active = true
    end

    puts "Sample promotions created"
    puts "Sample data seeding completed!"
  end
end
