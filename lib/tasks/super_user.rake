namespace :super_user do
  desc "Create super user account"
  task create: :environment do
    puts "Creating super user account..."

    user = User.find_or_initialize_by(email: 'longpc.cbimage@wano.com')
    
    if user.new_record?
      user.password = 'LongPC123456789'
      user.password_confirmation = 'LongPC123456789'
      user.role = 'super_user'
      
      if user.save
        puts "✓ Super user created successfully!"
        puts "  Email: #{user.email}"
        puts "  Role: #{user.role}"
        puts "  Password: LongPC123456789"
        puts "  Status: Permanent subscription access (no expiration)"
      else
        puts "✗ Failed to create super user:"
        user.errors.full_messages.each { |msg| puts "  - #{msg}" }
      end
    else
      # Update existing user to super_user
      user.role = 'super_user'
      if user.save
        puts "✓ Existing user updated to super_user!"
        puts "  Email: #{user.email}"
        puts "  Role: #{user.role}"
      else
        puts "✗ Failed to update user:"
        user.errors.full_messages.each { |msg| puts "  - #{msg}" }
      end
    end
  end
end
