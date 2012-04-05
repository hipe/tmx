require 'skylab/test-support/test-support'
require 'skylab/test-support/tmpdir'
require 'shellwords'

module Skylab::TanMan::TestSupport
  TanMan = Skylab::TanMan
  include Skylab::TestSupport
  TMPDIR = Tmpdir.new(Skylab::ROOT.join('tmp/tanman'))
  Porcelain = Skylab::Porcelain
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
  TanMan::Api.tap do |c|
    c.local_conf_dirname = 'local-conf.d' # a more visible name
    c.local_conf_maxdepth = 1
    c.local_conf_startpath = ->(){ TMPDIR }
    c.global_conf_path = ->() { TMPDIR.join('global-conf-file') } # a more visible name
  end
  def api
    TanMan.api
  end
  def lone_error ee, regex
    ee.size.should eql(1)
    ee.should_not be_success
    ee.first.message.should match(regex)
  end
  def lone_success ee, regex
    ee.size.should eql(1)
    ee.should be_success
    ee.first.message.should match(regex)
  end
  def prepare_local_conf_dir
    TMPDIR.prepare.mkdir(TanMan::Api.local_conf_dirname)
  end
  attr_accessor :result
end

RSpec::Matchers.define(:be_trueish) { match { |actual| actual } }

RSpec::Matchers.define(:be_gte) { |expected| match { |actual| actual >= expected } }

