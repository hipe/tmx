require File.expand_path('../../face/path-tools', __FILE__)
require 'strscan'

module Skylab; end

module Skylab::CodeMolester
  class SshConfig
    def initialize path
      @path = path
      @valid = @data = @invalid_reason = nil
      if File.exist?(@path)
        @data = _parse(File.read(@path)) and @valid = true
      end
    end
    attr_reader :path
    attr_reader :valid
    alias_method :valid?, :valid
    attr_reader :invalid_reason
    def data
      false == @valid and fail("Cannot request data for an invalid file: #{@invalid_reason.inspect}")
      @data
    end
    def exists?
      File.exist?(@path)
    end
    def pretty_path
      Skylab::Face::PathTools.pretty_path(@path)
    end
    def _parse string
      hosts = []
      scn = StringScanner.new(string)
      scn.skip(/[[:space:]]+/)
      loop do
      ok = scn.scan(/Host  */) or return _fail("expected: \"Host\" had: #{scn.peek(20).inspect}")
        name = scn.scan(/[-a-zA-Z0-9_]+/) or return _fail("expected a valid name, had: #{scn.peek(20).inspect}")
        host = { :type => :host, :name => name }
        scn.skip(/[ \t]+/)
        while line = scn.scan(/\n? +[A-Za-z]+ +[^\n]+/)
          name, value = line.strip.split(/ +/)
          host[name.gsub(/([a-z])([A-Z])/){ "#{$1}_#{$2}" }.downcase.intern] = value
        end
        hosts.push host
        scn.skip(/[[:space:]]+/)
        scn.eos? and break
      end
      hosts
    end
    def _fail msg
      @valid = false
      @invalid_reason = msg || "Parsing failed (reason unknown)."
      false
    end
  end
end
