module StatsHelpers

  private

  def build_breakdown(actual_data, all_items)
    base_data = all_items.zip([0] * all_items.size).to_h
    base_data.merge(actual_data) { |_, base_data_value, actual_data_value| base_data_value + actual_data_value }
  end
end
