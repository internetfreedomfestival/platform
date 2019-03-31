ENV['RAILS_ENV'] ||= 'test'

require File.expand_path('../../config/environment', __FILE__)

require 'rails/test_help'
require 'minitest/pride'
require 'minitest/mock'
require 'database_cleaner'
require 'sucker_punch/testing/inline'

class ActiveSupport::TestCase
  ActiveRecord::Migration.check_pending!
  include FactoryBot::Syntax::Methods

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  DatabaseCleaner.strategy = :truncation

  def login_as(role)
    user = FactoryBot.create(
      :user,
      person: FactoryBot.create(:person),
      role: role.to_s
    )
    session[:user_id] = user.id
    user
  end

  def sign_in(user)
    post '/session', user: { email: user.email, password: user.password }
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end

  def with_cfp_enabled
    FeatureToggle.stub :cfp_enabled?, true do
      yield
    end
  end

  def with_cfp_disabled
    FeatureToggle.stub :cfp_enabled?, false do
      yield
    end
  end

  def with_user_invites_enabled
    FeatureToggle.stub :user_invites_enabled?, true do
      yield
    end
  end

  def with_user_invites_disabled
    FeatureToggle.stub :user_invites_enabled?, false do
      yield
    end
  end

  def with_self_sessions_enabled
    FeatureToggle.stub :self_sessions_enabled?, true do
      yield
    end
  end

  def with_self_sessions_disabled
    FeatureToggle.stub :self_sessions_enabled?, false do
      yield
    end
  end

  def remove_voids_from(hash_result)
    hash_result.reject { |_,value| value == 0 || value.blank? }
  end
end
