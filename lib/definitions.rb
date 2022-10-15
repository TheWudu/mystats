# frozen_string_literal: true

module Definitions
  class GpsPoint < Definition::Model
    required 'time', Definition.Type(Time)
    required 'lat', Definition.Type(Float)
    required 'lng', Definition.Type(Float)
    optional 'ele', Definition.CoercibleType(Float)
    optional 'hr',  Definition.Nilable(Definition.CoercibleType(Integer))
  end
end
