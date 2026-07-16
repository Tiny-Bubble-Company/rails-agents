# frozen_string_literal: true
# what it can do — Tool Bridge / local tool stub

class FetchForecast < RailsAgents::Tool
  description "Fetch current or daily forecast for a city"

  param :city, :string, description: "City name"

  def call(city:)
    {city: city, summary: "Implement FetchForecast in your app"}
  end
end
