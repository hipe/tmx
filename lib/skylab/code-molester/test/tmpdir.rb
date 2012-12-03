require 'tmpdir'

module ::Skylab::CodeMolester::TestSupport

  class Tmpdir < ::Pathname
    include ::FileUtils

    attr_writer :debug

    def debug!
      self.debug = true
    end

    def fu_output_message msg
      debug? and $stderr.puts "#{ self.class}:dbg: #{ msg }"
    end

    safety = %w(tmp T)                          # do not touch
    safety_rx = /\/(?:tmp|T)\/[-a-zA-Z0-9_]+\Z/ # do not touch

    define_method :prepare do
      result = nil
      begin
        if ! safety.include? dirname.basename.to_s
          fail "Being extra cautious for now, unsafe dirname: #{ dirname }"
          break
        end

        if ! dirname.exist?
          fail "nope: parent dir must exist: #{ dirname }"
          break
        end

        if exist?                              # does this pathname exist?
          if ::Dir[join '*'].any?              # are there any files in it?
            debug? and fu_output_message "rm -rf #{ to_s }"
            str = to_s                         # super paranoid today
            if safety_rx =~ str                # not sure why
              remove_entry_secure str          # the money shot - cross fingers
            else
              fail "sanity - woah that was close wtf"
            end
            safety_rx =~ str or raise ::Runtime
            result = _mkdir
          else
            debug? and fu_output_message "(already empty: #{ to_s }"
            result = nil
          end
        else
          result = _mkdir
        end
      end while nil
      result
    end

  protected

    def initialize p=nil
      self.debug = false
      p = p ? p.to_s : ::Dir.tmpdir
      super p
      yield self if block_given?
    end

    attr_reader :debug
    alias_method :debug?, :debug

    def _mkdir
      mkdir to_s, :verbose => true
    end

  end
end
