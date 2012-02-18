
module Skylab::Tmx::Bleed::Api
  class Actions::Init < Action
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
      if false == b
        emit :info, "couldn't write #{config.pretty} - see above errors."
        false
      else
        emit :info, "wrote: #{config.pretty} (#{b} bytes.)"
      end
    end
  end
end

