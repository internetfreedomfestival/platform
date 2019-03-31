require 'test_helper'

class UserStatsTest < ActiveSupport::TestCase
  setup do
    populate!

    @user_stats = UserStats.new
  end

  test 'reports the total number of users' do
    expected_number_of_users = 6

    assert_equal expected_number_of_users, @user_stats.total_users
  end

  test 'reports the number of different countries of origin' do
    expected_number_of_countries_of_origin = 4

    assert_equal expected_number_of_countries_of_origin, @user_stats.different_countries_of_origin
  end

  test 'reports the different countries of origin breakdown' do
    expected_countries_of_origin_breakdown_without_void_values = {
      'Armenia' => 2,
      'Belize' => 2,
      'Canada' => 1,
      'Denmark' => 1
    }

    assert_equal expected_countries_of_origin_breakdown_without_void_values, remove_voids_from(@user_stats.countries_of_origin_breakdown)
  end

  test 'reports the number of different professional backgrounds' do
    expected_number_of_professional_backgrounds = 5

    assert_equal expected_number_of_professional_backgrounds, @user_stats.different_professional_backgrounds
  end

  test 'reports the different professional backgrounds breakdown' do
    expected_professional_backgrounds_breakdown_without_void_values = {
      'Digital Security Training' => 2,
      'Frontline Activism' => 3,
      'Research/Academia' => 2,
      'Data Science' => 3,
      'Journalism and Media' => 1
    }

    assert_equal expected_professional_backgrounds_breakdown_without_void_values, remove_voids_from(@user_stats.professional_backgrounds_breakdown)
  end

  private

  def populate!
    create(:person,
      country_of_origin: 'Armenia',
      professional_background: ['Digital Security Training', 'Frontline Activism', 'Research/Academia', 'Data Science']
    )

    create(:person,
      country_of_origin: 'Belize',
      professional_background: ['Digital Security Training', 'Frontline Activism']
    )

    create(:person,
      country_of_origin: 'Canada',
      professional_background: ['Research/Academia', 'Data Science']
    )

    create(:person,
      country_of_origin: 'Denmark',
      professional_background: ['Frontline Activism']
    )

    create(:person,
      country_of_origin: 'Belize',
      professional_background: ['Data Science']
    )

    create(:person,
      country_of_origin: 'Armenia',
      professional_background: ['Journalism and Media']
    )
  end
end
