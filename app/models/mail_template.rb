class MailTemplate < ActiveRecord::Base
  belongs_to :conference
  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :content

  def content_for(user)
    content
      .gsub('#first_name',  user.first_name)
      .gsub('#last_name',   user.last_name)
      .gsub('#public_name', user.public_name)
      .gsub('#person_id', user.id.to_s)
      .gsub('#confirm_attendance', "https://platform.internetfreedomfestival.org/en/IFF2018/cfp/user/confirmation/confirm_attendance?confirm_attendance_token=#{user.user.confirm_attendance_token}")
  end

  def send_sync(filter)
    job = SendBulkMailJob.new
    job.perform self, filter
  end

  def send_async(filter)
    job = SendBulkMailJob.new
    job.async.perform self, filter
  end
end
