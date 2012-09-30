require 'skylab/porcelain/tite-color'
require 'skylab/test-support/core'
require 'skylab/test-support/tmpdir'

module Skylab::TanMan::TestSupport
  include Skylab::TestSupport

  Porcelain = Skylab::Porcelain
  TanMan = Skylab::TanMan

  TMPDIR_STEM = 'tan-man'
  TMPDIR = Tmpdir.new(::Skylab::TMPDIR_PATHNAME.join(TMPDIR_STEM).to_s)

  # the below machinery has been rigged carefully and is a precision insturment
  class StreamsSpy < Array # that's "streams" plural
    attr_accessor :debug
    alias_method :debug?, :debug
    def debug! ; tap { |o| o.debug = true } end
    def for name
      @streams[name]
    end
    def initialize
      @debug = false
      @streams = Hash.new do |h, k|
        h[k] = StreamSpy.new(self, k, ->() { debug? } )
      end
    end
    attr_reader :streams
  end
  class StreamSpy # that's "stream" singular
    attr_reader :buffer
    attr_reader :debug_f
    def initialize stack, name, debug_f
      @buffer = StringIO.new
      @debug_f = debug_f
      @name = name
      @stack = stack
    end
    def puts string
      res = buffer.puts(string)
      line = buffer.string.dup
      buffer.rewind
      buffer.truncate(0)
      unstyled = Porcelain::TiteColor.unstylize_if_stylized(line)
      if debug_f.call
        $stderr.puts("dbg:#{name}:puts:#{string}#{'(line was colored)' if unstyled}")
      end
      stack.push Line.new(name, unstyled || line)
      res
    end
    attr_reader :name
    attr_reader :stack
    def write string
      if debug_f.call
        $stderr.write("dbg:#{name}:write:-->#{string}<--")
      end
      buffer.write(string)
    end
  end
  class Line < Struct.new(:name, :string)
  end

  # this is dodgy but should be ok as long as you accept that:
  # 1) you are assuming meta-attributes work and 2) the below is universe-wide!
  # 3) the below presents holes that need to be tested manually
  TanMan::API.tap do |c|
    c.local_conf_dirname = 'local-conf.d' # a more visible name
    c.local_conf_maxdepth = 1
    c.local_conf_startpath = ->(){ TMPDIR }
    c.global_conf_path = ->() { TMPDIR.join('global-conf-file') } # a more visible name
  end
end

module Skylab::TanMan::TestSupport
  module Tmpdir_InstanceMethods
    MEMO = ::Class.new.class_eval do
      execute_f = -> { TMPDIR.prepare }
      get_f = ->{ _memo = execute_f.call ; (get_f = ->{ _memo }).call }
      define_method(:get) { get_f.call }
      define_method(:execute) { execute_f.call }
      self
    end.new
    def prepare_submodule_tmpdir
      MEMO.execute
    end
    def prepared_submodule_tmpdir
      MEMO.get
    end
  end
  module InstanceMethods
    extend Tmpdir_InstanceMethods
    my_before_all_f = -> do
      prepared_submodule_tmpdir
      my_before_all_f = ->{ }
    end
    MY_BEFORE_ALL_F = ->{ my_before_all_f.call }
    def _my_before_all
      MY_BEFORE_ALL_F.call
    end
  end
end

if defined?(::RSpec) # egads sorry -- for running CLI visual testing clients
  require_relative('test-support/for-rspec')
end
