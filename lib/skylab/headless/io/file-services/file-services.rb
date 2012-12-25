fail 'NO' # this is just a sketch - really old scraps possiblly for [#hl-022]
require File.expand_path('../file-services/write-event-knob', __FILE__)

module Skylab::CodeMolester
  module FileServices
    def write
      yield(e = WriteEventKnob.new)
      valid? or return e[:invalid, invalid_reason]
      '' == (content = self.content) and return e[:empty_contents]
      if exist?
        content == read and return e[:no_change]
        writable? or return e[:not_writable]
        e[:rewrite_start]
        do_write = true
      elsif dirname.exist?
        e[:write_start]
        do_write = true
      else
        return e[:dirname_not_found, dirname.to_s]
      end
      bytes = nil
      if do_write
        File.open(to_s, 'w+') { |fh| bytes = fh.write(content) }
        e[:write_rewrite_end, bytes]
      end
      bytes
    end
  end
end
