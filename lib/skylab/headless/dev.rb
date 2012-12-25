module Skylab::Headless

  module DEV
    # for when you need a client now. attempt at a bare minimum
    # to get things running, for tests etc
  end

  class DEV::Pen < Headless::CLI::Pen::Minimal
    def escape_path x
      x.to_s
    end
  end


  class DEV::Client
    include Headless::Client::InstanceMethods

  protected

    def initialize sin=nil, sout=$stdout, serr=$stderr, pen=DEV::Pen.new
      self.io_adapter = Headless::CLI::IO_Adapter::Minimal.new(
        sin, sout, serr, pen )
    end
  end
end
