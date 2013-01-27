module Skylab::Treemap
  class CLI::Option::Parser < ::OptionParser

  protected

    wat_a = [ ].freeze # [#039] - track the ridiculousness of more-ness

    define_method :more do |_|
      wat_a
    end
  end
end
