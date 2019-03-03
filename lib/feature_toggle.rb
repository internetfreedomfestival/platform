class FeatureToggle
  class << self
    def new_cfp_enabled?
      ENV['NEW_CFP_ENABLED'] == "true"
    end

    def user_invites_enabled?
      ENV['USER_INVITES_ENABLED'] == "true"
    end
  end
end
