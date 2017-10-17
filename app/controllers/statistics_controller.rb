class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def events_by_state
    authorize! :read, @conference
    case params[:type]
    when 'lectures'
      result = @conference.events_by_state_and_type(:lecture)
    when 'workshops'
      result = @conference.events_by_state_and_type(:workshop)
    when 'others'
      remaining = Event::TYPES - [:workshop, :lecture]
      result = @conference.events_by_state_and_type(remaining)
    else
      result = @conference.events_by_state
    end

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def language_breakdown
    authorize! :read, @conference
    result = @conference.language_breakdown(params[:accepted_only])

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def gender_breakdown
    authorize! :read, @conference
    result = @conference.gender_breakdown(params[:accepted_only])
   
    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def all_stats
    authorize! :administrate, Person
    @all_stats = Hash.new(0)
    @people = Person.all
    @events = Event.all

    dif_people_count = 0
    volunteers_count = 0
    user_genders = Hash.new(0)
    prof_back = Hash.new(0)
    user_iff_before = Hash.new(0)
    person_countries = Hash.new(0)
    event_formats = Hash.new(0)
    event_person_prof = Hash.new(0)
    presented_before = Hash.new(0)
    event_languages = Hash.new(0)
    event_gender = Hash.new(0)
    event_states = Hash.new(0)

    @people.each do |person|
      if person.dif
        dif_people_count += 1
      end
      if person.interested_in_volunteer == true
        volunteers_count += 1
      end
      user_genders[person.gender] += 1 unless person.gender.nil?

      if person.professional_background.class == String
        prof_back[person.professional_background] += 1
      else 
        person.professional_background.each do |prof|
          prof_back[prof] += 1 unless prof == ""
        end
      end
      if person.iff_before.class == String
        user_iff_before[person.iff_before]
      else 
        person.iff_before.each do |year|
          user_iff_before[year] += 1
        end
      end
      if person.country_of_origin.nil?
        person_countries["Not_Yet_Selected"] += 1
      else 
        person_countries[person.country_of_origin] += 1
      end
      if !person.events.empty? && person.professional_background.class == String
        event_person_prof[person.professional_background] += 1
      elsif !person.events.empty?
        person.professional_background.each do |prof|
          event_person_prof[prof] += 1
        end
      end
      # unless person.events.empty?
      #   person.events.each do |event|
      #     event_gender[person.gender + ":"] += 1
      #   end
      # end
    end

    @events.each do |event|
      if event.track 
        event_formats[event.track.name] += 1
      end
      if event.iff_before
        if event.iff_before.include?("2015") || event.iff_before.include?("2016") || event.iff_before.include?("2017")
          presented_before["Already Presented"] += 1
        else
          presented_before["First Presentation"] += 1
        end
      end
      event_languages[event.language] += 1
     
      e_p = EventPerson.where(event_role: "submitter").find_by(event_id: event.id)
      unless e_p.nil?
        per = Person.find_by(id: e_p.person_id)
        event_gender[per.gender] += 1
      end
      event_states[event.state] += 1
    end


    @all_stats["Users"] = "Totals"
    @all_stats["Total Users"] = @people.count
    @all_stats["Total Attendees"] = "Not Yet Created!"
    @all_stats["Total DIF Applicants"] = dif_people_count
    @all_stats["Interested in Volunteering"] = volunteers_count
    user_genders.each do |gender, count|
      @all_stats[gender] = count    
    end
    @all_stats["Professional Background"] = "Totals"
    prof_back.each do |profession, count|
      @all_stats[profession] = count
    end
    @all_stats["Returning vs New"] = "Totals"
    user_iff_before.each do |year, count|
      @all_stats[year] = count
    end
    @all_stats["Countries of Origin"] = "Totals"
    person_countries.each do |country, count|
      @all_stats[country] = count
    end
    @all_stats["Events"] = "Events"
    @all_stats["By Format"] = "Totals"
    event_formats.each do |format, count|
      @all_stats[format] = count
    end
    @all_stats["By Professional Background of Presenter"] = "Totals"
    event_person_prof.each do |prof, count|
      @all_stats[prof + ":"] = count
    end
    @all_stats["Presenters"] = "Totals"
    presented_before.each do |status, count|
      @all_stats[status] = count
    end
    @all_stats["Events By Language"] = "Totals"
    event_languages.each do |lang, count|
      @all_stats[lang] = count
    end
    @all_stats["Events By Gender"] = "Totals"
    event_gender.each do |gender, count|
      @all_stats[gender + ":"] = count
    end
    @all_stats["Events By State"] = "Totals"
    event_states.each do |state, count|
      @all_stats[state] = count
    end

    respond_to do |format|
      format.csv  { send_data to_csv_stats(@all_stats), filename: "people-user-stats-#{Date.today}.csv" }
    end
  end

  private

  def to_csv_stats(stats_object)
    CSV.generate(headers: true) do |csv|
      stats_object.each do |key, value|
        csv << [key, value]
      end
    end
  end
end
