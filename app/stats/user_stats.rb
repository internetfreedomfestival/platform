class UserStats
  include StatsHelpers

  def total_users
    @total_users ||= Person.count
  end

  def different_countries_of_origin
    @different_countries_of_origin ||= Person.distinct.select(:country_of_origin).count
  end

  def countries_of_origin_breakdown
    @countries_of_origin_breakdown ||= build_breakdown(Person.group(:country_of_origin).count, Person::COUNTRIES)
  end

  def different_professional_backgrounds
    @different_professional_backgrounds ||= professional_backgrounds.uniq.size
  end

  def professional_backgrounds_breakdown
    @professional_backgrounds_breakdown ||= build_breakdown(professional_backgrounds.group_by(&:itself).transform_values(&:size), Person::PROFESSIONAL_BACKGROUND)
  end

  private

  def professional_backgrounds
    @professional_backgrounds ||= Person.pluck(:professional_background).flatten.reject(&:blank?)
  end
end
