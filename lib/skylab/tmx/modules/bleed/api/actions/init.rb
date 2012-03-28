require 'skylab'
require 'skylab/code-molester/config'


module Skylab::Tmx::Bleed::Api
  class Actions::Init < Action
    include ::Skylab::Face::PathTools
    def config
      @config ||= begin
        ::Skylab::CodeMolester::Config.new(File.join(ENV['HOME'], '.tmxconfig')) do |o|
          o.on_info  { |e| emit(:info, e)  }
          o.on_error { |e| emit(:error, e) }
        end
      end
    end
    def invoke
      if config.exist?
        emit :info, "exists, won't overwrite: #{config.pretty}"
        return nil
      end
      root = ::Skylab::ROOT.to_s.gsub(
        %r{^#{Regexp.escape ENV['HOME']}/}, '~/')
      config.content = <<-HAHA.gsub(/^ {8}/, '')
        [bleed]
          root = #{root}
      HAHA
      b = config.write
      emit :info, "wrote: #{config.pretty} (#{b} bytes.)"
    end
  end
end

