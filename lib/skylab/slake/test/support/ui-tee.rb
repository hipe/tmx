require File.expand_path('../../../../test-support/test-support', __FILE__)

module Skylab::Slake
end

module Skylab::Slake::TestSupport
  include ::Skylab::TestSupport

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
      @out ||= (@silent ? Tee.new(:buffer => StringIO.new) : Tee.new(:stream => $stdout, :buffer => StringIO.new))
      @err ||= (@silent ? Tee.new(:buffer => StringIO.new) : Tee.new(:stream => $stderr, :buffer => StringIO.new))
    end
    attr_accessor :err, :out, :silent
    %w(out err).each do |stream|
      define_method("#{stream}_string") do
        send(stream)[:buffer].string
      end
    end
  end
end

