class MailTemplate < ActiveRecord::Base
  belongs_to :conference
  validates_presence_of :name
  validates_presence_of :subject
  validates_presence_of :content

  def content_for(person, conference)
    ticket = Ticket.find_by(person: person, conference: conference, status: Ticket::COMPLETED)
    event = person.events.find_by(conference: conference, state: :confirmed)

    content
      .gsub('#iff_id', person&.id.to_s)
      .gsub('#first_name',  person&.first_name.to_s)
      .gsub('#last_name',   person&.last_name.to_s)
      .gsub('#public_name', ticket&.public_name.to_s)
      .gsub('#gender_pronoun', ticket&.gender_pronoun.to_s)
      .gsub('#ticket_id', ticket&.id.to_s)
      .gsub('#session_title', event&.title.to_s)
      .gsub('#other_presenters', event&.other_presenters.to_s)
      .gsub('#room', event&.room.to_s)
      .gsub('#time_slots', event&.time_slots.to_s)
      .gsub('#etherpad_url', event&.etherpad_url.to_s)

      # .gsub('#confirm_attendance', "https://platform.internetfreedomfestival.org/en/iff/cfp/user/confirmation/confirm_attendance?confirm_attendance_token=#{person.user.confirm_attendance_token}")
  end

  def send_sync(filter)
    job = SendBulkMailJob.new
    job.perform(self, filter)
  end

  def send_async(filter)
    job = SendBulkMailJob.new
    job.async.perform(self, filter)
  end
end
