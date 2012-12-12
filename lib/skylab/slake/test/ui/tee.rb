module Skylab::Slake::TestSupport

  class UI::Tee
    tee = -> silent, stream do
      if silent
        Slake_TestSupport::Tee.new buffer: ::StringIO.new
      else
        Slake_TestSupport::Tee.new stream: stream, buffer: ::StringIO.new
      end
    end
    define_method :initialize do |opts=nil|
      opts and opts.each { |k, v| send("#{k}=", v) }
      @out ||= tee[ silent, $stdout ]
      @err ||= tee[ silent, $stderr ]
    end
    attr_accessor :err, :out, :silent
    %w(out err).each do |stream|
      define_method "#{ stream }_string" do
        send(stream)[:buffer].string
      end
    end
  end
end
