module Skylab::Basic

  module List::From

    def self.[] x

      if x.respond_to? :each_with_index
        :Array
      else
        raise "implement me - #{ x.class }"
      end
    end
  end
end
