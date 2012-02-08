require 'skylab/face/path-tools'
require File.expand_path('../my-enumerator', __FILE__)

module Skylab::Issue
  class Models::Issues::Manifest
    include FileUtils
    include ::Skylab::Face::PathTools

    ISSUE_NUMBER_DIGITS = 3
    VALID_DATE = /\A\d{4}-\d{2}-\d{2}\z/

    def add_issue params
      params[:date] and VALID_DATE =~ params[:date] or
        return error("invalid date: #{params[:date].inspect}")
      message_valid?(params[:message]) or return false
      new_i = greatest_issue_integer + 1
      id = "[##{"%0#{ISSUE_NUMBER_DIGITS}d" % new_i}]"
      line = "#{id} #{params[:date]} #{params[:message]}"
      _tmpdir or return # fail early from this
      emit :info, "succeeded: #{line}"
      if dry_run?
        true
      else
        _add_line_to_top line
      end
    end

    def _add_line_to_top line
      unless path.exist?
        fail("impelement me! (create file)")
      end
      tmpdir = _tmpdir or return false
      tmpnew = tmpdir.join('issues.md.next')
      tmpold = tmpdir.join('issued.md.prev')
      if tmpnew.exist?
        rm(tmpnew.to_s, :verbose => true)
      end
      File.open(tmpnew.to_s, 'w+') do |fh|
        fh.puts line
        # reopen the file if it was opened previous (or is open currently! careful)
        file.clear.each_line { |_line| fh.puts _line }
      end
      if tmpold.exist?
        rm(tmpold.to_s, :verbose => true)
      end
      mv path.to_s, tmpold.to_s, :verbose => true
      mv tmpnew.to_s, path.to_s, :verbose => true
      true
    end

    attr_accessor :dry_run
    alias_method :dry_run?, :dry_run

    def file
      @file ||= begin
        path.exist? or fail("Don't access file unless it exists (path_resolved?)")
        require File.expand_path('../file', __FILE__)
        Models::Issues::File.new(path)
      end
    end

    def greatest_issue_integer
      greatest = issues_flyweight.reduce(-1) do |m, issue|
        m > issue.identifier.to_i ? m : issue.identifier.to_i
      end
      greatest
    end

    def emit type, msg
      @emitter.emit(type, msg)
    end ; protected :emit

    attr_accessor :emitter # this is the single worst architecture smell to date here

    def error msg
      emit(:error, msg) ; false
    end ; protected :error

    # for compatability with FileUtils
    def fu_output_message msg
      emit :info, msg
    end

    def initialize basename
      (!basename or basename.empty?) and
        raise ArgumentError.new("basename cannot be empty (had: #{basename.inspect}).")
      @basename = Pathname.new(basename.to_s)
      @basename.absolute? and
        fail("#{self.class} for now must be build w/ relative pathnames, not #{basename}")
      @dirname = Pathname.new('.').expand_path
    end

    def issues_flyweight
      path_resolved? or return false # bad, no folder
      file = if path.exist? # ok for file not to exist, just no issues
        require "#{ROOT}/models/issue"
        issue_flyweight = Models::Issue.build_flyweight
        self.file
      end
      Models::Issues::MyEnumerator.new do |yielder|
        if file
          file.each_line do |line|
            issue_flyweight.line = line
            yielder.yield issue_flyweight
          end
        end
      end
    end

    def message_valid? message
      /\A[[:space:]]*\z/ =~ message and return error("Message was blank.")
      /\n/ =~ message and return error("Message cannot contain newlines.")
      /\\n/ =~ message and return error("Message cannot contain (escaped or unescaped) newlines.")
      true
    end

    def numbers &b
      num = 0
      # each_issue_flyweight { |issue| b.call issue.identifier }
      issues_flyweight.each do |issue|
        num += 1
        b.call issue.identifier
      end
      num
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

    def _tmpdir
      unless @tmpdir
        @tmpdir = @path.dirname.dirname.join('tmp')
        unless @tmpdir.dirname.exist?
          return error("won't create more than one directory. " <<
            "Parent directory of tmpdir must exist: #{pretty_path @tmpdir}")
        end
        unless @tmpdir.exist?
          mkdir(@tmpdir.to_s, :verbose => true)
        end
      end
      @tmpdir
    end
  end
end

