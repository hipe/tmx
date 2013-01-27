module Skylab::Treemap
  class CLI::DynamicOptionParser < ::OptionParser

  protected

    wat_a = [ ].freeze # #todo wat

    define_method :more do |_|
      wat_a
    end
  end
end
