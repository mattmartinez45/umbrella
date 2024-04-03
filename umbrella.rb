require "http"
require "json"
gmaps_key = ENV.fetch("GOOGLEMAPSAPI")
pirate_key = ENV.fetch("PIRATEWEATHER")

line_width = 45
puts "~" * line_width
puts "Will you need an umbrella today?".center(line_width)
puts "~" * line_width
puts ""

puts "Where will you be walking?"
location = gets.chomp

puts "Checking conditions in #{location}..."

gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{location}&key=#{gmaps_key}"

gmaps_data = HTTP.get(gmaps_url)

parsed_g_data = JSON.parse (gmaps_data)

results_array = parsed_g_data.fetch("results")

first_result_hash = results_array.at(0)

geometry_hash = first_result_hash.fetch("geometry")

location_hash = geometry_hash.fetch("location")

latitude = location_hash.fetch("lat")

longitude = location_hash.fetch("lng")

puts "Your coordinates are #{latitude}, #{longitude}."

pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_key}/#{latitude},#{longitude}"

raw_pirate_data = HTTP.get(pirate_weather_url)

parsed_pirate_data = JSON.parse(raw_pirate_data)

currently_hash = parsed_pirate_data.fetch("currently")

current_temp = currently_hash.fetch("temperature")

puts "It's currently #{current_temp}°F."

minutely_hash = parsed_pirate_data.fetch("minutely", false)

if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")
  next_hour_summary = next_hour_summary.to_s.lowercase
  puts "The next hour's weather is #{next_hour_summary}."
end

hourly_hash = parsed_pirate_data.fetch("hourly")

hourly_data_array = hourly_hash.fetch("data")

next_twelve_hours = hourly_data_array[1..12]
precip_prob_threshold = 0.10

any_precipitation = false

next_twelve_hours.each do |hour_hash|
  precip_prob = hour_hash.fetch("precipProbability")

  if precip_prob > precip_prob_threshold
    any_precipitation = true
    precip_time = Time.at(hour_hash.fetch("time"))
    seconds_from_now = precip_time - Time.now
    hours_from_now = seconds_from_now / 60 / 60

    puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
  end
end

if any_precipitation == true
  puts "You should probably take an umbrella!"
else
  puts "You'll probably be fine without an umbrella!"
end
