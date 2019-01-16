class Person < ActiveRecord::Base
  serialize :professional_background, Array
  serialize :iff_before, Array
  serialize :iff_days, Array
  serialize :iff_goals, Array

  GENDERS = [
    "Female",
    "Gender Nonconforming",
    "Male",
    "Other"
  ].freeze
  COUNTRIES = [
    "Afghanistan",
    "Åland Islands",
    "Albania",
    "Algeria",
    "American Samoa",
    "Andorra",
    "Angola",
    "Anguilla",
    "Antarctica",
    "Antigua and Barbuda",
    "Argentina",
    "Armenia",
    "Aruba",
    "Australia",
    "Austria",
    "Azerbaijan",
    "Bahamas",
    "Bahrain",
    "Bangladesh",
    "Barbados",
    "Belarus",
    "Belgium",
    "Belize",
    "Benin",
    "Bermuda",
    "Bhutan",
    "Bolivia",
    "Bosnia and Herzegovina",
    "Botswana",
    "Bouvet Island",
    "Brazil",
    "British Antarctic Territory",
    "British Indian Ocean Territory",
    "British Virgin Islands",
    "Brunei",
    "Bulgaria",
    "Burkina Faso",
    "Burundi",
    "Cambodia",
    "Cameroon",
    "Canada",
    "Canton and Enderbury Islands",
    "Cape Verde",
    "Cayman Islands",
    "Central African Republic",
    "Chad",
    "Chile",
    "China",
    "Christmas Island",
    "Cocos [Keeling] Islands",
    "Colombia",
    "Comoros",
    "Congo - Brazzaville",
    "Congo - Kinshasa",
    "Cook Islands",
    "Costa Rica",
    "Croatia",
    "Cuba",
    "Cyprus",
    "Czech Republic",
    "Côte d’Ivoire",
    "Denmark",
    "Djibouti",
    "Dominica",
    "Dominican Republic",
    "Dronning Maud Land",
    "East Germany",
    "Ecuador",
    "Egypt",
    "El Salvador",
    "Equatorial Guinea",
    "Eritrea",
    "Estonia",
    "Ethiopia",
    "Falkland Islands",
    "Faroe Islands",
    "Fiji",
    "Finland",
    "France",
    "French Guiana",
    "French Polynesia",
    "French Southern Territories",
    "French Southern and Antarctic Territories",
    "Gabon",
    "Gambia",
    "Georgia",
    "Germany",
    "Ghana",
    "Gibraltar",
    "Greece",
    "Greenland",
    "Grenada",
    "Guadeloupe",
    "Guam",
    "Guatemala",
    "Guernsey",
    "Guinea",
    "Guinea-Bissau",
    "Guyana",
    "Haiti",
    "Heard Island and McDonald Islands",
    "Honduras",
    "Hong Kong SAR China",
    "Hungary",
    "Iceland",
    "India",
    "Indonesia",
    "Iran",
    "Iraq",
    "Ireland",
    "Isle of Man",
    "Israel",
    "Italy",
    "Jamaica",
    "Japan",
    "Jersey",
    "Johnston Island",
    "Jordan",
    "Kazakhstan",
    "Kenya",
    "Kiribati",
    "Kuwait",
    "Kyrgyzstan",
    "Laos",
    "Latvia",
    "Lebanon",
    "Lesotho",
    "Liberia",
    "Libya",
    "Liechtenstein",
    "Lithuania",
    "Luxembourg",
    "Macau SAR China",
    "Macedonia",
    "Madagascar",
    "Malawi",
    "Malaysia",
    "Maldives",
    "Mali",
    "Malta",
    "Marshall Islands",
    "Martinique",
    "Mauritania",
    "Mauritius",
    "Mayotte",
    "Metropolitan France",
    "Mexico",
    "Micronesia",
    "Midway Islands",
    "Moldova",
    "Monaco",
    "Mongolia",
    "Montenegro",
    "Montserrat",
    "Morocco",
    "Mozambique",
    "Myanmar [Burma]",
    "Namibia",
    "Nauru",
    "Nepal",
    "Netherlands",
    "Netherlands Antilles",
    "Neutral Zone",
    "New Caledonia",
    "New Zealand",
    "Nicaragua",
    "Niger",
    "Nigeria",
    "Niue",
    "Norfolk Island",
    "North Korea",
    "North Vietnam",
    "Northern Mariana Islands",
    "Norway",
    "Oman",
    "Pacific Islands Trust Territory",
    "Pakistan",
    "Palau",
    "Palestine",
    "Panama",
    "Panama Canal Zone",
    "Papua New Guinea",
    "Paraguay",
    "People's Democratic Republic of Yemen",
    "Peru",
    "Philippines",
    "Pitcairn Islands",
    "Poland",
    "Portugal",
    "Puerto Rico",
    "Qatar",
    "Romania",
    "Russia",
    "Rwanda",
    "Réunion",
    "Saint Barthélemy",
    "Saint Helena",
    "Saint Kitts and Nevis",
    "Saint Lucia",
    "Saint Martin",
    "Saint Pierre and Miquelon",
    "Saint Vincent and the Grenadines",
    "Samoa",
    "San Marino",
    "Saudi Arabia",
    "Senegal",
    "Serbia",
    "Serbia and Montenegro",
    "Seychelles",
    "Sierra Leone",
    "Singapore",
    "Slovakia",
    "Slovenia",
    "Solomon Islands",
    "Somalia",
    "South Africa",
    "South Georgia and the South Sandwich Islands",
    "South Korea",
    "South Sudan",
    "Spain",
    "Sri Lanka",
    "Sudan",
    "Suriname",
    "Svalbard and Jan Mayen",
    "Swaziland",
    "Sweden",
    "Switzerland",
    "Syria",
    "São Tomé and Príncipe",
    "Taiwan",
    "Tajikistan",
    "Tanzania",
    "Thailand",
    "Tibet",
    "Timor-Leste",
    "Togo",
    "Tokelau",
    "Tonga",
    "Trinidad and Tobago",
    "Tunisia",
    "Turkey",
    "Turkmenistan",
    "Turks and Caicos Islands",
    "Tuvalu",
    "U.S. Minor Outlying Islands",
    "U.S. Miscellaneous Pacific Islands",
    "U.S. Virgin Islands",
    "Uganda",
    "Ukraine",
    "Union of Soviet Socialist Republics",
    "United Arab Emirates",
    "United Kingdom",
    "United States",
    "Unknown or Invalid Region",
    "Uruguay",
    "Uzbekistan",
    "Vanuatu",
    "Vatican City",
    "Venezuela",
    "Vietnam",
    "Wake Island",
    "Wallis and Futuna",
    "Western Sahara",
    "Yemen",
    "Zambia",
    "Zimbabwe"
  ].freeze
  GENDER_PRONOUN = [
    "ze/hir",
    "ze/zir",
    "she",
    "he",
    "they/.../themselves",
    "they/.../themself",
    "xey",
    "sie",
    "it",
    "ey",
    "e",
    "hu",
    "peh",
    "per",
    "thon",
    "jee",
    "ve/ver",
    "xe",
    "zie/zir",
    "ze/zem",
    "zie/zem",
    "ze/mer",
    "se",
    "zme",
    "ve/vem",
    "zee",
    "fae",
    "zie/hir",
    "si",
    "kit",
    "Ne"
  ].freeze
  GOALS = [
    "Requesting support with a specific issue",
    "Making new connections",
    "Meeting with key constituents and partners",
    "Working hands-on",
    "Sharing a new project/initiative",
    "Getting funding for your project",
    "Improving digital security skills",
    "Introduction to digital security and Internet Freedom",
    "Professional development",
    "Learning more about the situation in Latin America",
    "Learning more about the situation in Eurasia/Central Asia",
    "Learning more about the situation in Middle East & Northern Africa",
    "Learning more about the situation in Sub-Saharan Africa",
    "Learning more about the situation in South Asia",
    "Learning more about the situation in Southeast Asia",
    "Learning more about the situation in East Asia"
  ].freeze
  IFF_BEFORE = [
    "Not yet!",
    "2015",
    "2016",
    "2017",
    "2018"
  ].freeze
  IFF_DAYS = [
    "Monday, April 1st",
    "Tuesday, April 2nd",
    "Wednesday, April 3rd",
    "Thursday, April 4th",
    "Friday, April 5th",
    "Full week"
  ].freeze
  PROFESSIONAL_BACKGROUND = [
    'Digital Security Training',
    'Software/Web Development',
    'Cryptography',
    'Information Security',
    'Student',
    'Frontline Activism',
    'Research/Academia',
    'Community Management',
    'Social Sciences',
    'Policy/Internet Governance',
    'Data Science',
    'Advocacy',
    'Communications',
    'Journalism and Media',
    'Arts & Culture',
    'Design',
    'Program Management',
    'Philanthropic/Grantmaking Organization'
  ].freeze

  has_many :attendance_statuses, dependent: :destroy
  has_many :availabilities, dependent: :destroy
  has_many :attendees, dependent: :destroy
  has_many :event_people, dependent: :destroy
  has_many :event_ratings, dependent: :destroy
  has_many :events, -> { uniq }, through: :event_people
  has_many :im_accounts, dependent: :destroy
  has_many :languages, as: :attachable, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  has_many :phone_numbers, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :transport_needs, dependent: :destroy
  has_many :invites, dependent: :destroy
  has_many :tickets, dependent: :destroy
  has_one :dif, dependent: :destroy

  accepts_nested_attributes_for :availabilities, reject_if: :all_blank
  accepts_nested_attributes_for :im_accounts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :languages, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :links, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :phone_numbers, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :expenses, reject_if: :all_blank, allow_destroy: true

  belongs_to :user, dependent: :destroy

  before_save :nilify_empty

  has_paper_trail

  has_attached_file :avatar,
    styles: { tiny: '16x16>', small: '32x32>', large: '128x128>' },
    default_url: 'person_:style.png'

  validates_attachment_content_type :avatar, content_type: [/jpg/, /jpeg/, /png/, /gif/]

  validates_presence_of :email, :first_name, :gender, :country_of_origin, :professional_background

  validates_inclusion_of :include_in_mailings, :invitation_to_mattermost, in: [true, false]

  validates_confirmation_of :email, message: "doesn't match email"

  validates_uniqueness_of :email

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
  scope :with_ticket, ->(conference) {
    joins(:attendance_statuses).where(attendance_statuses: {status: "Holds Ticket", conference_id: conference.id})
  }
  scope :with_dif_granted, ->(conference) {
    joins(events: :conference)
          .where(conferences: {id: conference.id} )
          .where(events: {travel_assistance: true, dif_status: "Granted", recipient_travel_stipend: [nil, ""]} )
          .where(event_people: {event_role: "submitter"})
  }
  scope :with_dif_travel_stipend_granted, ->(conference) {
    joins("INNER JOIN events ON events.recipient_travel_stipend = people.email AND events.conference_id = #{conference.id}" )
          .where(events: {travel_assistance: true, dif_status: "Granted"} )
  }
  scope :with_dif_requested, ->(conference) {
    joins(events: :conference)
          .where(conferences: {id: conference.id} )
          .where(events: {travel_assistance: true, dif_status: "Requested", recipient_travel_stipend: [nil, ""]} )
          .where(event_people: {event_role: "submitter"})
  }
  scope :with_dif_travel_stipend_requested, ->(conference) {
    joins("INNER JOIN events ON events.recipient_travel_stipend = people.email AND events.conference_id = #{conference.id}" )
          .where(events: {travel_assistance: true, dif_status: "Requested"} )
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

  def allowed_to_send_invites?(conference)
    invitation = Invite.find_by(email: email.downcase, conference: conference)

    return false unless invitation.present?

    invitation.sharing_allowed?
  end

  def serialize(conference)
    ticket = tickets.find_by(conference: conference)
    invite = Invite.find_by(conference: conference, email: email.downcase)
    current_submissions = events.where(conference: conference).count
    current_presentations = events.where(conference: conference).accepted.count
    previous_presentations = events.where.not(conference: conference).accepted.count

    {
      'IFF ID' => id,
      'Ticket Status' => ticket&.status,
      'Ticket ID' => ticket&.id,
      'Email' => email,
      'PGP Key' => pgp_key.blank? ? nil : pgp_key,
      'Invited By' => invite&.person&.email,
      'Public Name' => ticket&.public_name,
      'First Name' => first_name.blank? ? nil : first_name,
      'Last Name' => last_name.blank? ? nil : last_name,
      'Gender' => gender,
      'Public Gender Pronoun' => ticket&.gender_pronoun,
      'Country' => country_of_origin,
      'Professional Background' => professional_background&.reject(&:blank?)&.join(', '),
      'Organization' => organization.blank? ? nil : organization,
      'Project' => project.blank? ? nil : project,
      'Title' => title.blank? ? nil : title,
      'Attended IFF Before?' => ticket&.iff_before&.reject(&:blank?)&.join(', '),
      'Submitted Session' => current_submissions.zero? ? 'No' : 'Yes',
      'Presenter' => current_presentations.zero? ? 'No' : 'Yes',
      'Presented Before?' => previous_presentations.zero? ? 'No' : 'Yes',
      'Main goals for attending the IFF?' => ticket&.iff_goals&.reject(&:blank?)&.join(', '),
      'Include in Mailing' => include_in_mailings? ? 'Yes' : 'No',
      'Invite to Mattermost' => invitation_to_mattermost? ? 'Yes' : 'No',
      'Volunteeering Interest' => ticket&.interested_in_volunteer? ? 'Yes' : 'No'
    }
  end

  def self.to_csv(conference, options = {})
    options = options.merge(headers: true)

    CSV.generate(options) do |csv|
      csv << Person.first.serialize(conference).keys

      all.find_each do |person|
        csv << person.serialize(conference)
      end
    end
  end

  private

  def nilify_empty
    self.gender = nil if gender and gender.empty?
  end
end
