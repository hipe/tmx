module Skylab
  module Dependency; end
end

module Skylab::Dependency
  module NodeMethods
    def initialize data, parent
      data = Hash[ * data.map{ |k, v| [k.gsub(' ', '_').intern, v] }.flatten(1) ]
      update_attributes Hash[ * (self.class.defaults.keys - data.keys).map { |k| [k, self.class.defaults[k]] }.flatten(1) ]
      parent and meet_parent(parent, data)
      update_attributes data
    end
    # assumes symbol keys!
    def update_attributes data
      data.each do |k, v|
        send("#{k}=", v)
      end
    end
  end
end

