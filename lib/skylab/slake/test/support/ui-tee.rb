require 'stringio'

module Skylab ; end
module Skylab::Dependency ; end
module Skylab::Dependency::TestSupport
  class MyStringIO < StringIO
    def to_str
      rewind
      read
    end
  end
  class Tee < Hash
    def initialize hash
      hash.each do |k, v|
        self[k] = v
      end
    end
    %w(puts write).each do |meth|
      define_method(meth) do |*a|
        each do |k, v|
          v.send(meth, *a)
        end
      end
    end
  end
  class UiTee
    def initialize opts=nil
      opts and opts.each { |k, v| send("#{k}=", v) }
      @out ||= (@silent ? Tee.new(:buffer => MyStringIO.new) : Tee.new(:stream => $stdout, :buffer => MyStringIO.new))
      @err ||= (@silent ? Tee.new(:buffer => MyStringIO.new) : Tee.new(:stream => $stderr, :buffer => MyStringIO.new))
    end
    attr_accessor :err, :out, :silent
    %w(out err).each do |stream|
      define_method("#{stream}_string") do
        buffer = send(stream)[:buffer]
        buffer.rewind
        buffer.read
      end
    end
  end
end

