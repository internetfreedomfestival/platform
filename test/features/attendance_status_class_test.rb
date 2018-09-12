# require 'test_helper'
# require "minitest/rails/capybara"
#
# class AttendanceStatusClassTest < Capybara::Rails::TestCase
#   setup do
#     @conference = create(:conference)
#     @admin = create(:user, person: create(:person), role: 'admin')
#     @user = create(:user, person: create(:person), role: 'submitter')
#
#   end
#
#   test 'admin can view a requested status when user requests a ticket' do
#     create(:call_for_participation, conference: @conference)
#     login_as(@user)
#
#     within '#request_invitation' do
#       click_on 'Request Invite'
#     end
#     click_on 'Logout'
#
#     login_as(@admin)
#     go_to_conference_person_profile(@conference, @user.person)
#
#     assert_text 'Requested'
#   end
#
#   test 'admin can view an invited status when user is invited' do
#     create(:call_for_participation, conference: @conference)
#
#     login_as(@admin)
#
#     go_to_conference_person_profile(@conference, @user.person)
#
#     click_on 'Send invitation'
#
#     assert_text 'Invited'
#   end
#
#   private
#
#   def login_as(user)
#     visit '/'
#
#     within '#login' do
#       fill_in 'user_email', with: user.email
#       fill_in 'user_password', with: user.password
#
#       click_on 'Sign in'
#     end
#   end
#
#   def go_to_conference_person_profile(conference, person)
#     visit "/#{conference.acronym}/people"
#
#     click_on person.public_name
#   end
#
#   def with_an_invited_person(person)
#     login_as(@admin)
#     go_to_conference_person_profile(@conference, @user.person)
#     click_on 'Send invitation'
#     click_on 'Logout'
#   end
# end
