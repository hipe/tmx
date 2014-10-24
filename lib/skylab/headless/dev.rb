module Skylab::Headless

  module DEV
    # for when you need a client now. attempt at a bare minimum
    # to get things running, for tests etc
  end

  class DEV::Pen < Headless_::CLI.pen.minimal_class
    def escape_path x
      x.to_s
    end
  end

  class DEV::Client

    include Headless_::Client::InstanceMethods

  private
    O__, E__ = Headles_.system.IO.some_two_IOs

    def initialize i=nil, o=O__, e=E__, pen=DEV::Pen.new
      self.io_adapter = Headless_::CLI::IO::Adapter::Minimal.
        new i, o, e, pen ; nil
    end
  end
end
