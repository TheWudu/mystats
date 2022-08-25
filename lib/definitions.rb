module Definitions
  class GpsPointArray < Definition::ValueObject
    definition(Definition.Each(Definition.Keys do
      required 'time', Definition.Type(Time)
      required 'lat', Definition.Type(Float)
      required 'lng', Definition.Type(Float)
      optional 'ele', Definition.Type(Float)
    end))
  end

end
