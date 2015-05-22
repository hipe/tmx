module Skylab::Basic

  module Number

    class << self

      def normalization
        Number_::Normalization__
      end

      def of_digits_in_positive_integer d
        digits = 1
        begin
          d /= 10
          d.zero? and break
          digits += 1
          redo
        end while nil
        digits
      end
    end  # >>

    class As_noun_inflectee  # an [#hu-037] adapter

      # this is a production - it can hold arbitrary state representing
      # how it is to be expressed (for example degrees of precision,
      # maybe it will do num2s etc)

      class << self
        alias_method :[], :new
      end  # >>

      def initialize assume_d
        @_x = assume_d
      end

      def inflect_words_into_against_noun_phrase y, np
        y << "#{ @_x }"  # etc
      end
    end

    Number_ = self
  end
end
