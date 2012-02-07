module Skylab::Issue
  class Models::Issues::Manifest
    include FileUtils

    def each_issue_flyweight &b
      path_resolved? or return false # bad, no folder
      path.exist? or return true # ok, no issues, no file
      require "#{ROOT}/models/issue"
      issue_flyweight = Models::Issue.build_flyweight
      num = 0
      file.each_line do |line|
        issue_flyweight.line = line
        num += 1
        b.call issue_flyweight
      end
      num
    end

    def file
      @file ||= begin
        path.exist? or fail("Don't access file unless it exists (path_resolved?)")
        require File.expand_path('../file', __FILE__)
        Models::Issues::File.new(path)
      end
    end

    def emit type, msg
      @emitter.emit(type, msg)
    end ; protected :emit

    attr_accessor :emitter # this is the single worst architecture smell to date here

    def error msg
      emit(:error, msg) ; false
    end ; protected :error

    def initialize basename
      @basename = Pathname.new(basename)
      @basename.absolute? and
        fail("#{self.class} for now must be build w/ relative pathnames, not #{basename}")
      @dirname = Pathname.new('.').expand_path
    end

    def message_valid? message
      /\A[[:space:]]*\z/ =~ message and return error("Message was blank.")
      /\n/ =~ message and return error("Message cannot contain newlines.")
      /\\n/ =~ message and return error("Message cannot contain (escaped or unescaped) newlines.")
      true
    end

    def numbers &b
      each_issue_flyweight { |issue| b.call issue.identifier }
    end

    attr_reader :path

    def path_resolved?
      loop do # careful
        if (p = @dirname.join(@basename)).dirname.exist?
          @path = p # this should be the only place path is set
          return true
        end
        if @dirname.root?
          return error "#{@basename.dirname.to_s.inspect} not found here or in any parent directory."
        end
        @dirname = @dirname.dirname
      end
    end
  end
end

