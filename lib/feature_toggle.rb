class FeatureToggle
  class << self
    def new_ticketing_system_enabled?
      ENV['NEW_TICKETING_SYSTEM_ENABLED'] == "true"
    end
  end
end
