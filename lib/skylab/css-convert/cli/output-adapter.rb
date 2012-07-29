require 'skylab/pub-sub/emitter'

module Skylab::CssConvert
  class CLI::OutputAdapter
    extend ::Skylab::PubSub::Emitter
    emits :error, :help, :info, :invite, :payload, :usage
    def initialize stdout=nil, stderr=nil
      out = stdout || $stdout
      err = stderr || $stderr
      on_error    { |e| err.puts e }
      on_help     { |e| err.puts e }
      on_info     { |e| err.puts e }
      on_invite   { |e| err.puts e }
      on_payload  { |e| out.puts e }
      on_usage    { |e| err.puts e }
      @stderr = ->{     err        }
    end
    def standard_err_stream
      @stderr.call
    end
  end
end
