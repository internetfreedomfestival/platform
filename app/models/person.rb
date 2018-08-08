class Person < ActiveRecord::Base
  serialize :professional_background, Array
  serialize :iff_before, Array

  GENDERS = ["Female", "Male", "Gender Nonconforming", "Other"].freeze
  COUNTRIES = ["Afghanistan", "Åland Islands", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Antarctic Territory", "British Indian Ocean Territory", "British Virgin Islands", "Brunei", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Canton and Enderbury Islands", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos [Keeling] Islands", "Colombia", "Comoros", "Congo - Brazzaville", "Congo - Kinshasa", "Cook Islands", "Costa Rica", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Côte d’Ivoire", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Dronning Maud Land", "East Germany", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern Territories", "French Southern and Antarctic Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard Island and McDonald Islands", "Honduras", "Hong Kong SAR China", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Isle of Man", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Johnston Island", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Kuwait", "Kyrgyzstan", "Laos", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau SAR China", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Metropolitan France", "Mexico", "Micronesia", "Midway Islands", "Moldova", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Myanmar [Burma]", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "Neutral Zone", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "North Korea", "North Vietnam", "Northern Mariana Islands", "Norway", "Oman", "Pacific Islands Trust Territory", "Pakistan", "Palau", "Palestine", "Panama", "Panama Canal Zone", "Papua New Guinea", "Paraguay", "People's Democratic Republic of Yemen", "Peru", "Philippines", "Pitcairn Islands", "Poland", "Portugal", "Puerto Rico", "Qatar", "Romania", "Russia", "Rwanda", "Réunion", "Saint Barthélemy", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Martin", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Saudi Arabia", "Senegal", "Serbia", "Serbia and Montenegro", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "South Korea", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syria", "São Tomé and Príncipe", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Tibet", "Timor-Leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "U.S. Minor Outlying Islands", "U.S. Miscellaneous Pacific Islands", "U.S. Virgin Islands", "Uganda", "Ukraine", "Union of Soviet Socialist Republics", "United Arab Emirates", "United Kingdom", "United States", "Unknown or Invalid Region", "Uruguay", "Uzbekistan", "Vanuatu", "Vatican City", "Venezuela", "Vietnam", "Wake Island", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"].freeze
  has_many :availabilities, dependent: :destroy
  has_many :event_people, dependent: :destroy
  has_many :event_ratings, dependent: :destroy
  has_many :events, -> { uniq }, through: :event_people
  has_many :im_accounts, dependent: :destroy
  has_many :languages, as: :attachable, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  has_many :phone_numbers, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :transport_needs, dependent: :destroy
  has_one :ticket, as: :object, dependent: :destroy
  has_one :dif, dependent: :destroy

  accepts_nested_attributes_for :availabilities, reject_if: :all_blank
  accepts_nested_attributes_for :im_accounts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :languages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :phone_numbers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :ticket, reject_if: :all_blank, allow_destroy: true

  belongs_to :user, dependent: :destroy

  before_save :nilify_empty

  has_paper_trail

  has_attached_file :avatar,
    styles: { tiny: '16x16>', small: '32x32>', large: '128x128>' },
    default_url: 'person_:style.png'

  validates_attachment_content_type :avatar, content_type: [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :public_name, :email
  validates :public_name, uniqueness: true, on: :update
  ### validates_inclusion_of :gender, in: GENDERS, allow_nil: true

  validates_presence_of :country_of_origin, :professional_background, :iff_before, :gender, :on => :update

  scope :involved_in, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).uniq
  }
  scope :speaking_at, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).where('event_people.event_role': EventPerson::SPEAKER).where('events.state': Event::ACCEPTED).uniq
  }
  scope :publicly_speaking_at, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).where('event_people.event_role': EventPerson::SPEAKER).where('events.public': true).where('events.state': Event::ACCEPTED).uniq
  }
  scope :confirmed, ->(conference) {
    joins(events: :conference).where('conferences.id': conference).where('events.state': %w(confirmed scheduled))
  }

  def self.fullname_options
    all.sort_by(&:full_name).map do |p|
      { id: p.id, text: p.full_name_annotated }
    end
  end

  def newer_than?(person)
    updated_at > person.updated_at
  end

  def full_name
    if first_name.blank? or last_name.blank?
      public_name
    else
      "#{first_name} #{last_name}"
    end
  end

  def full_name_annotated
    full_name + " (#{email}, \##{id})"
  end

  def user_email
    user.email if user.present?
  end

  def avatar_path(size = :large)
    avatar(size) if avatar.present?
  end

  def involved_in?(conference)
    found = Person.joins(events: :conference)
                  .where('conferences.id': conference.id)
                  .where(id: id)
                  .count
    found.positive?
  end

  def active_in_any_conference?
    found = Conference.joins(events: [{ event_people: :person }])
                      .where(Event.arel_table[:state].in(Event::ACCEPTED))
                      .where(EventPerson.arel_table[:event_role].in(EventPerson::SPEAKER))
                      .where(Person.arel_table[:id].eq(id))
                      .count
    found.positive?
  end

  def events_in(conference)
    events.where(conference_id: conference.id)
  end

  def events_as_presenter_in(conference)
    events.where('event_people.event_role': EventPerson::SPEAKER, conference: conference)
  end

  def events_as_presenter_not_in(conference)
    events.where('event_people.event_role': EventPerson::SPEAKER).where.not(conference: conference)
  end

  def public_and_accepted_events_as_speaker_in(conference)
    events.is_public.accepted.where('events.state': %w(confirmed scheduled), 'event_people.event_role': EventPerson::SPEAKER, conference_id: conference)
  end

  def role_state(conference)
    event_people.
      presenter_at(conference).
      order('created_at ASC').
      map(&:role_state).
      uniq.
      join(', ')
  end

  def set_role_state(conference, state)
    event_people.presenter_at(conference).each do |ep|
      ep.role_state = state
      ep.save!
    end
  end

  def availabilities_in(conference)
    availabilities = self.availabilities.where(conference: conference)
    availabilities.each { |a|
      a.start_date = a.start_date.in_time_zone
      a.end_date = a.end_date.in_time_zone
    }
    availabilities
  end

  def update_attributes_from_slider_form(params)
    # remove empty availabilities
    return unless params and params.key? 'availabilities_attributes'
    params['availabilities_attributes'].each { |_k, v|
      Availability.delete(v['id']) if v['start_date'].to_i == -1
    }
    params['availabilities_attributes'].select! { |_k, v| v['start_date'].to_i > 0 }
    # fix dates
    params['availabilities_attributes'].each { |_k, v|
      v['start_date'] = Time.zone.parse(v['start_date'])
      v['end_date'] = Time.zone.parse(v['end_date'])
    }
    update_attributes(params)
  end

  def average_feedback_as_speaker
    events = event_people.where(event_role: EventPerson::SPEAKER).map(&:event)
    feedback = 0.0
    count = 0
    events.each do |event|
      if event
        if current_feedback = event.average_feedback
          feedback += current_feedback * event.event_feedbacks_count
          count += event.event_feedbacks_count
        end
      end
    end
    return nil if count == 0
    feedback / count
  end

  def locale_for_mailing(conference)
    own_locales = languages.all.map { |l| l.code.downcase.to_sym }
    conference_locales = conference.languages.all.map { |l| l.code.downcase.to_sym }
    return :en if own_locales.include? :en or own_locales.empty? or (own_locales & conference_locales).empty?
    (own_locales & conference_locales).first
  end

  def sum_of_expenses(conference, reimbursed)
    expenses.where(conference_id: conference.id, reimbursed: reimbursed).sum(:value)
  end

  def to_s
    "#{model_name.human}: #{full_name}"
  end

  def remote_ticket?
    ticket.present? and ticket.remote_ticket_id.present?
  end

  def merge_with(doppelgaenger, keep_last_updated = false)
    MergePersons.new(keep_last_updated).combine!(self, doppelgaenger)
  end

  def self.to_csv(options = {})
    attributes = %w{id email public_name first_name last_name pgp_key gender country_of_origin professional_background other_background organization project title iff_before iff_goals challenges other_resources complete_mailing complete_mattermost interested_in_volunteer attendance_status created_at travel_support past_travel_assistance willing_to_facilitate}

    non_dif_attributes = %w{id email public_name first_name last_name pgp_key gender country_of_origin professional_background other_background organization project title iff_before iff_goals challenges other_resources complete_mailing complete_mattermost interested_in_volunteer attendance_status created_at}

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |person|
        if person.dif
          csv << attributes.map do |attr|
            if person.try(attr).nil?
              person.dif.send(attr)
            else
              person.send(attr)
            end
          end
        else
          csv << non_dif_attributes.map{ |attr| person.send(attr) }
        end
      end
    end
  end

  private

  def nilify_empty
    self.gender = nil if gender and gender.empty?
  end
end
