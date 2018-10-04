class MigrateOldAttendanceStatusToAttendanceStatus < ActiveRecord::Migration
  def up
    conference = find_past_conference
    unless conference
      Rails.logger.info "Conference IFF2018 not found. Nothing to migrate"
      return
    end

    Person.where(old_attendance_status: 'confirmed').each do |person|
      Rails.logger.info "Migrating #{person.email}"

      AttendanceStatus.create(
        person: person,
        conference: conference,
        status: AttendanceStatus::REGISTERED
      )
    end
  end

  def down
    conference = find_past_conference
    unless conference
      Rails.logger.info "Conference IFF2018 not found. Nothing to migrate"
      return
    end

    AttendanceStatus.where(status: AttendanceStatus::REGISTERED, conference: conference).each do |attendance|
      Rails.logger.info "Migrating #{person.email}"

      person = attendance.person
      person.update_attributes(old_attendance_status: 'confirmed')
    end
  end

  private

  def find_past_conference
    Conference.find_by(acronym: 'IFF2018')
  end
end
