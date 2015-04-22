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

    Number_ = self
  end
end
