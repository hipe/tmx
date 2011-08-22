require 'json'
require File.expand_path('../../face/path-tools', __FILE__)

module Skylab; end

module Skylab::CodeMolester
  class JsonFile
    def initialize path
      @path = path
      if File.exist?(@path)
        _data = nil
        begin
          _data = JSON.parse(File.read(@path))
          @data = _data
        rescue JSON::ParserError => e
          @last_parser_error = e
        end
      else
        @data = nil
      end
    end
    attr_reader :path
    def data
      valid? or fail("Cannot request data from an invalid json file: #{@last_validation_error}")
      @data
    end
    def exists?
      File.exist?(@path)
    end
    def pretty_path
      Skylab::Face::PathTools.pretty_path(@path)
    end
    def write
      bytes = nil
      str = @data.to_json
      len = str.length
      len == 0 and return 0 # don't create empty files (for now)
      str =~ /\n\Z/ or str = "#{str}\n" # add newline to end of file if necessary
      File.open(@path, 'w+') do |fh|
        fh.write str
        bytes = len
      end
      bytes
    end
    def valid?
      if @last_parser_error
        @invalid_reason = @last_parse_error.to_s
        return false
      end
      true # for now
    end
    attr_reader :invalid_reason
  end
end
