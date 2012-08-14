require 'skylab/porcelain/tite-color'
require 'skylab/test-support/core'
require 'skylab/test-support/tmpdir'
require 'shellwords'

module Skylab::TanMan::TestSupport
  include Skylab::TestSupport

  Porcelain = Skylab::Porcelain
  TanMan = Skylab::TanMan

  TMPDIR = Tmpdir.new(Skylab::ROOT.join('tmp/tanman'))

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
  shared_context tanman: true do
  def api
    TanMan.api
  end
  let :cli do
    spy = output
    TanMan::CLI.new do |o|
      o.program_name = 'ferp'
      o.stdout = spy.for(:stdout)
      o.stderr = spy.for(:stderr)
      o.on_info { |x| o.stderr.puts x.touch!.message } # similar but not same to default
      o.on_out  { |x| o.stdout.puts x.touch!.message }
      o.on_all  { |x| o.stderr.puts(x.touch!.message) unless x.touched? }
    end
  end
  def input str
    argv = Shellwords.split(str)
    self.result = cli.invoke argv
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
  attr_accessor :result
  let(:output) { StreamsSpy.new }
  def output_shift_is *assertions
    subject = output.first
    assertions.each do |assertion|
      case assertion
      when FalseClass ; result.should_not be_trueish
      when Regexp     ; subject.string.should match(assertion)
      when String     ; subject.string.should be_include(assertion)
      when Symbol     ; subject.name.should eql(assertion)
      when TrueClass  ; result.should be_trueish
      else            ; fail("unrecognized assertion class: #{assertion}")
      end
    end
    output.shift # return subject, and change the stack only at the end
  end
  def output_shift_only_is *assertions
    res = output_shift_is(*assertions)
    output.size.should eql(0)
    res
  end
  def prepare_local_conf_dir
    TMPDIR.prepare.mkdir(TanMan::API.local_conf_dirname)
  end
  attr_accessor :result
  end
end

RSpec::Matchers.define(:be_trueish) { match { |actual| actual } }

RSpec::Matchers.define(:be_gte) { |expected| match { |actual| actual >= expected } }

