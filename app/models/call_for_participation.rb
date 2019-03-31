class CallForParticipation < ActiveRecord::Base
  belongs_to :conference

  validates_presence_of :start_date, :end_date, :hard_deadline

  has_paper_trail

  def to_s
    "#{model_name.human}: #{self.conference.title}"
  end

  def closed?
    closing_date = end_date
    closing_date = hard_deadline if FeatureToggle.self_sessions_enabled?

    Date.current > closing_date
  end
end
