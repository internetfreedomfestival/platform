class FeatureToggle
  class << self
    def cfp_enabled?
      ENV['CFP_ENABLED'] == "true"
    end

    def self_sessions_enabled?
      ENV['SELF_SESSIONS_ENABLED'] == "true"
    end

    def user_invites_enabled?
      ENV['USER_INVITES_ENABLED'] == "true"
    end
  end
end
