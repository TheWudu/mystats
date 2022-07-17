# frozen_string_literal: true

class SportType
  def self.id_for(name: nil)
    return 5 unless name

    SPORT_TYPE_MAPPING.key(name)
  end

  def self.name_for(id: nil)
    return 'other' unless id

    SPORT_TYPE_MAPPING[id]
  end

  SPORT_TYPE_MAPPING = {
    1 => 'running',
    3 => 'cycling',
    4 => 'mountain-biking',
    5 => 'other',
    7 => 'hiking',
    9 => 'skiing',
    18 => 'swimming',
    19 => 'walking',
    22 => 'race-cycling',
    26 => 'yoga',
    31 => 'pilates',
    32 => 'climbing',
    34 => 'strength-training',
    54 => 'ice-skating',
    55 => 'sledding',
    69 => 'crossfit',
    70 => 'dancing',
    71 => 'ice-hockey',
    74 => 'gymnastics',
    81 => 'training',
    91 => 'body-weight training'
  }.freeze
end
