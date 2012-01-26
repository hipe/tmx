require 'stringio'

require File.expand_path('../../../../skylab', __FILE__)

require 'skylab/slake/muxer'

module Skylab
  module Dependency
  end
end

module Skylab::Dependency::TestNamespace

  TEMP_DIR = ::Skylab::ROOT.join('tmp')

  BUILD_DIR = Class.new(Pathname).class_eval do
    include FileUtils
    def initialize(*)
      @verbose = false
      super
    end
    def fu_output_message msg
      @verbose and $stderr.puts("BUILD_DIR #{msg}")
    end
    def prepare
      if directory?
        fu_output_message("removing self #{self}")
        remove_entry_secure to_s
        mkdir to_s, :verbose => true
      elsif dirname.directory?
        mkdir to_s, :verbose => true
      else
        fail("BUILD_DIR won't make more than one directory. " <<
             "Parent directory must first exist: #{dirname}")
      end
      true
    end
    attr_accessor :verbose
    self
  end.new(TEMP_DIR.join('build-dependency'))

  FILE_SERVER = Class.new.class_eval do
    %w(document_root).each do |method| # delegates
      define_method(method) { |*a, &b| @server.send(method, *a, &b) }
    end
    def initialize
      self.log_level = :info
    end
    LEVELS = ::Skylab::Slake::Muxer::COMMON_LEVELS
    attr_reader :log_level
    def log_level= lvl
      LEVELS.include?(lvl) or fail("no: #{lvl}")
      @log_level_i = LEVELS.index(@log_level = lvl)
      lvl
    end
    def run
      @server ||= begin
        require 'skylab/dependency/static-file-server'
        ::Skylab::Dependency::StaticFileServer.new(FIXTURES_DIR) do |s|
          s.on_all do |e|
            if $debug or !(l = LEVELS.index(e.type)) or (l >= @log_level_i)
              $stderr.puts "FILE_SERVER (#{e.type}): #{e}"
            end
          end
        end
      end
      @server.start_unless_running
    end
    self
  end.new

  FIXTURES_DIR = Pathname.new(File.expand_path('../fixtures', __FILE__))

  class MyStringIO < StringIO
    def to_s
      rewind ; read
    end
  end

  module CustomExpectationMatchers
    def be_including foo
      BeIncluding.new(foo)
    end
    def be_subclass_of foo
      BeSubclassOf.new(foo)
    end
  end

  class BeIncluding
    def initialize expected
      @expected = expected
    end
    def matches? target
      (@target = target).include? @expected
    end
    def failure_message
      "expected #{@target.inspect} to include #{@expected}"
    end
    def negative_failure_message
      "expected #{@target.inspect} not to include #{@expected}"
    end
  end

 class BeSubclassOf < BeIncluding
   def description
     "be subclass of #{@expected}"
   end
    def matches? foo
      super(foo.ancestors)
    end
  end
end

