require 'open3'
require 'stringio'
require 'strscan'

module Skylab::Interface
  module System::SelectLinesUntil

    MAXLEN = 4096

    def select_lines_until timeout_seconds, streams
      name = ::Hash[ * streams.map { |k, v| [v.object_id, k] }.flatten(1) ]
      remaining = streams.values
      e = StringEmitter.new( *name.values ).new
      yield e
      bytes = 0
      while remaining.any?
        read, _w, _e = ::IO.select remaining, nil, nil, timeout_seconds
        read or break
        read.each do |io|
          str = eof = nil
          begin
            str = io.readpartial MAXLEN
            eof = io.closed?
          rescue ::EOFError => e
            eof = true
          end
          if str
            bytes += str.length
            e.emit name[io.object_id], str
          end
          if eof
            remaining[ remaining.index io ] = nil
            remaining.compact!
          end
        end
      end
      e.flush!
      bytes
    end
  end

  class StringEmitter
    class << self
      alias_method :interface_original_new, :new
    end

    def self.new *a
      ::Class.new( self ).class_eval do
        class << self
          alias_method :new, :interface_original_new
        end
        extend PubSub::Emitter
        emits( *a )
        alias_method :emit_string, :emit
        alias_method :emit, :progressive_emit
        self
      end
    end

    def flush!
      @b.each do |k, b|
        scan_out k, b, true
      end
    end

    def progressive_emit k, string
      buffer = @b[k]
      b.write string
      if buffer.string.index "\n"
        scan_out k, buffer
      end
    end

  protected

    def initialize
      @b = ::Hash.new { |h, k| h[k] = ::StringIO.new }
      @scn = ::StringScanner.new ''
    end

    def scan_out k, buffer, rest=false
      @scn.string = buffer.string
      while line = @scn.scan_until( /\n/ )
        emit_string k, line
      end
      if rest
        if ! @scn.eos?
          emit_string k, @scn.rest
        end
      end
      buffer.truncate 0
      buffer.write @scn.rest
    end
  end
end
