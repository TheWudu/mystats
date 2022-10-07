# frozen_string_literal: true

class SportType
  def self.unified(name:)
    SPORT_TYPE_UNIFIED[name] || name
  end

  def self.name_for_runtastic_id(id: nil)
    return 'other' unless id

    RUNTASTIC_SPORT_TYPE_MAPPING.fetch(id)
  end

  def self.default
    'unknown'
  end

  SPORT_TYPE_UNIFIED = {
    'open_water_swimming' => 'swimming'
  }.freeze

  RUNTASTIC_SPORT_TYPE_MAPPING = {
    1  => 'running',
    3  => 'cycling',
    4  => 'mountain-biking',
    5  => 'other',
    7  => 'hiking',
    9  => 'skiing',
    14 => 'treadmill',
    18 => 'swimming',
    19 => 'walking',
    22 => 'race-cycling',
    26 => 'yoga',
    31 => 'pilates',
    32 => 'climbing',
    34 => 'strength-training',
    38 => 'soccer',
    54 => 'ice-skating',
    55 => 'sledding',
    69 => 'crossfit',
    70 => 'dancing',
    71 => 'ice-hockey',
    72 => 'skateboarding',
    74 => 'gymnastics',
    76 => 'standup-paddling',
    81 => 'training',
    91 => 'body-weight training'
  }.freeze
end
