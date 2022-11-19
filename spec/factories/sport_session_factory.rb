# frozen_string_literal: true

require 'repositories/sport_sessions'
require 'models/sport_session'

FactoryBot.define do
  factory :sport_session, class: 'Models::SportSession' do
    initialize_with { new(attributes) }
    to_create do |instance|
      Repositories::SportSessions.insert(session_hash: instance.to_h)
    end

    id { SecureRandom.uuid }

    notes { 'my session' }
    distance { 5270 }
    start_time { Time.at(1.hour.ago.to_i).utc }
    start_time_timezone_offset { 7200 }
    end_time { Time.at(30.minutes.ago.to_i).utc }
    timezone { 'Europe/Vienna' }
    duration { 30 * 60 }
    duration_up { 18 * 60 }
    pause { 0 }
    year { start_time.year }
    month { start_time.month }
    elevation_gain { 112 }
    elevation_loss { 110 }
    sport_type     { 'running' }

    trait :with_trace do
      trace do
        JSON.parse(File.read('spec/fixtures/traces/running_7km.json')).map do |p|
          p['time'] = Time.parse(p['time'])
          p
        end
      end
    end
  end
end
