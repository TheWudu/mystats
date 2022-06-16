module Parser
  class Xml
    attr_accessor :data

    def initialize(data:)
      self.data = data
    end

    def parse
      ary = []

      current_tag = next_tag(data, 0)
      raise ArgumentError.new("xml is not the first tag") unless current_tag[:tag] == "?xml"

      current_tag = next_tag(data, current_tag[:end_at])
      handle_tag(current_tag, ary)

      ary
    end

    def handle_tag(tag, ary)
      offset = tag[:end_at]
      loop do
        current_tag = next_tag(data, offset)
        return unless current_tag

        if end_current_tag?(current_tag, tag)
          d = data[offset..current_tag[:start_at]-1].strip
          tag[:data] = d unless d.empty?
          ary << tag
          return (current_tag[:end_at])  # to update offset in loop
        end

        tag[:tags] ||= []
        offset = handle_tag(current_tag, tag[:tags])
        
        break if offset >= data.size
      end
      return data.size
    end

    def end_current_tag?(current_tag, tag)
       current_tag[:tag].start_with?("/") && current_tag[:tag][1..-1] == tag[:tag]
    end

    def meta(str) 
      return unless str
      return if str.empty?

      h = {}
      sa = str.split(/"/).collect { |x| x.strip }
      splits = (1..sa.length).zip(sa).collect { |i,x| (i&1).zero? ? x : x.split }.flatten

      for i in 0..(splits.size/2 - 1) do
        k = splits[i*2].gsub("=", "")
        v = splits[i*2+1]
        h[k.to_sym] = v
      end
      h
    end

    def next_tag(data, offset)
      opening, closing = find_tag_borders(data, offset)
      build_tag(data, opening, closing)
    end

    def build_tag(data, opening, closing)
      tag_data = data[opening..closing-1]

      current_tag = tag_data.split(" ").first.gsub("<","").gsub(">","")
      tag_meta    = meta(tag_data.split(" ", 2)[1])

      { tag: current_tag, meta: tag_meta, start_at: opening, end_at: closing+1 }.compact
    end

    def find_tag_borders(data, offset)
      opening = find_tag(data, offset, "<")
      return unless opening
      closing = find_tag(data, opening, ">")
      return unless closing
      [opening, closing]
    end

    def find_tag(data, offset, char)
      pos = data[offset..-1] =~ /#{char}/
      return nil unless pos
      pos.to_i + offset
    end
  end
end
