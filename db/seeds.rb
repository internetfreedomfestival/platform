# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Daley', city: cities.first)
PaperTrail.enabled = false

person = Person.create!(
  email: 'admin@example.org',
  first_name: 'admin',
  last_name: 'admin',
  public_name: 'admin_127',
  country_of_origin: 'Spain',
  professional_background: ['Developer'],
  iff_before: ['none'],
  gender: ['female']
)

password = Rails.env.production? ? SecureRandom.urlsafe_base64(32) : 'test123'

admin = User.new(
  email: person.email,
  password: password,
  password_confirmation: password
)
admin.person = person
admin.role = 'admin'
admin.confirmed_at = Time.now
admin.save!
person.user_id = admin.id
person.save!

puts "Created admin user (#{admin.email}) with password #{password}"

conference = Conference.new(title: "Internet Freedom Festival",
                            acronym: 'iff',
                            email: person.email,
                            color: '00ff7f')
conference.save!

puts "Created conference [#{conference.acronym}] #{conference.title}"
