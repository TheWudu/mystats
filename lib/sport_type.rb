# frozen_string_literal: true

class SportType
  def self.id_for(name: nil)
    raise 'do not use this'
    return 5 unless name

    SPORT_TYPE_MAPPING[name]
  end

  def self.name_for(id: nil)
    return 'other' unless id

    SPORT_TYPE_MAPPING.key(id)
  end

  SPORT_TYPE_MAPPING = {
    'running'              => 1,
    'cycling'              => 3,
    'mountain-biking'      => 4,
    'other'                => 5,
    'hiking'               => 7,
    'skiing'               => 9,
    'treadmill'            => 14,
    'swimming'             => 18,
    'open_water_swimming'  => 18,
    'walking'              => 19,
    'race-cycling'         => 22,
    'yoga'                 => 26,
    'pilates'              => 31,
    'climbing'             => 32,
    'strength-training'    => 34,
    'soccer'               => 38,
    'ice-skating'          => 54,
    'sledding'             => 55,
    'crossfit'             => 69,
    'dancing'              => 70,
    'ice-hockey'           => 71,
    'skateboarding'        => 72,
    'gymnastics'           => 74,
    'standup-paddling'     => 76,
    'training'             => 81,
    'body-weight training' => 91
  }.freeze
end
