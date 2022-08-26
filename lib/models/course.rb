# frozen_string_literal: true

require 'definitions'

module Models
  class Course < Definition::ValueObject
    definition(Definition.Keys do
      required :id, Definition.Type(String)
      required :name, Definition.Type(String)
      required :distance, Definition.Type(Integer)
      required :trace, Definition.Nilable(Definition.CoercibleValueObject(Definitions::GpsPointArray))
      required :session_ids, Definition.Each(Definition.Type(String))
    end)
  end
end
