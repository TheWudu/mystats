# frozen_string_literal: true

require 'definitions'

module Models
  class Course < Definition::Model
    required :id, Definition.Type(String)
    required :name, Definition.Type(String)
    required :distance, Definition.Type(Integer)
    required :trace, Definition.Nilable(Definition.Each(Definitions::GpsPoint))
    required :session_ids, Definition.Each(Definition.Type(String))
  end
end
