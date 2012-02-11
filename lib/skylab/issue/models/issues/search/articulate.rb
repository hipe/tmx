module Skylab::Issue
  class Models::Issues::Search
    def adjp
      flip = @index.invert
      names = (0..(@or.length-1)).map { |i| flip[i] }
      s = names.map do |name|
        if respond_to? name
          "#{name} #{send(name)}"
        end
      end.compact.join(' or ')
      s.empty? ? s : "with #{s}"
    end
  end
end

