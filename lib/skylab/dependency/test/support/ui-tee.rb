require 'stringio'

module Skylab; end
module Skylab::Dependency
  module Test; end
  module Test::Support
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
    class UiTee < Struct.new(:out, :err)
      def initialize out=nil, err=nil
        self.out = out || Tee.new(:stream => $stdout, :buffer => MyStringIO.new)
        self.err = err || Tee.new(:stream => $stderr, :buffer => MyStringIO.new)
      end
      %w(out err).each do |stream|
        define_method("#{stream}_string") do
          buffer = send(stream)[:buffer]
          buffer.rewind
          buffer.read
        end
      end
    end
  end
end

