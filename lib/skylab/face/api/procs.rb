module Skylab::Face

  module API::Procs

    def self.at * c_a
      c_a.map { |c| const_get c, false }
    end

    Chomp_single_letter_suffix = -> x do
      x.to_s.sub %r{_[a-z]\z}, ''
    end

    Local_normal_name_as_argument_raw = -> x do
      "<#{ x.to_s.gsub( '_', '-' ) }>"
    end
  end
end
