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

  private

    O__, E__= Headless::System::IO.to_two

    def initialize i=nil, o=O__, e=E__, pen=DEV::Pen.new
      self.io_adapter = Headless::CLI::IO_Adapter::Minimal.
        new i, o, e, pen ; nil
    end
  end
end
