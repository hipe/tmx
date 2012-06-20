require 'open3'
require 'stringio'
require 'strscan'

module Skylab::Interface::System
  module SelectLinesUntil

    MAXLEN = 4096

    def select_lines_until(timeout_seconds, streams)
      name = Hash[ * streams.map { |k, v| [v.object_id, k] }.flatten(1) ]
      remaining = streams.values
      e = StringEmitterFactory.new(*name.values).new
      yield(e)
      bytes = 0
      while remaining.any?
        read, _w, _e = IO.select(remaining, nil, nil, timeout_seconds)
        read or break
        read.each do |io|
          str = eof = nil
          begin
            str = io.readpartial MAXLEN
            eof = io.closed?
          rescue EOFError => e
            eof = true
          end
          if str
            bytes += str.length
            e.emit(name[io.object_id], str)
          end
          if eof
            remaining[remaining.index(io)] = nil
            remaining.compact!
          end
        end
      end
      e.flush!
      bytes
    end
  end
  module StringEmitterFactory
    def self.new(*a)
      Class.new(StringEmitter).class_eval do
        extend Skylab::PubSub::Emitter
        emits(*a)
        alias_method :emit_string, :emit
        alias_method :emit, :progressive_emit
        self
      end
    end
  end
  class StringEmitter
    def initialize
      @b = Hash.new { |h, k| h[k] = StringIO.new }
      @s = nil
    end
    def flush!
      @b.each do |k, b|
        _scan_out k, b, true
      end
    end
    def progressive_emit k, string
      (buffer = @b[k]).write string
      if buffer.string.index("\n")
        _scan_out k, buffer
      end
    end
    def _scan_out k, buffer, rest=false
      if @s
        @s.string = buffer.string
      else
        @s = StringScanner.new(buffer.string)
      end
      while line = @s.scan_until(/\n/)
        emit_string(k, line)
      end
      if rest
        unless @s.eos?
          emit_string(k, @s.rest)
        end
      end
      buffer.truncate(0)
      buffer.write(@s.rest)
    end
  end
end

