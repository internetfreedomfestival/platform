class FeatureToggle
  class << self
    def cfp_enabled?
      ENV['CFP_ENABLED'] == "true"
    end

    def user_invites_enabled?
      ENV['USER_INVITES_ENABLED'] == "true"
    end
  end
end
