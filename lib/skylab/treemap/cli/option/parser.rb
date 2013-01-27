module Skylab::Treemap
  class CLI::Option::Parser < ::OptionParser

  protected

    wat_a = [ ].freeze # [#039] - wat

    define_method :more do |_|
      wat_a
    end
  end
end
