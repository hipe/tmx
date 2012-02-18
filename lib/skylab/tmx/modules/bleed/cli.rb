module Skylab::Tmx::Modules::Bleed
  class Cli < Skylab::Face::Cli
    namespace(:bleed) do
      default_action :load
      summary "run a bleeding edge version of tmx"
      o do |op, ctx|
        op.banner = "attempts to hack your path"
        op.separator "by invoking a bash script"
      end
      def load ctx
        # api.invoke([:load], ctx)
      end

      o do |op, ctx|
        op.banner = "Inits a ~/.tmx"
      end
      def init ctx
        api.invoke([:init], ctx)
      end

      o do |o, c|
        o.banner = "The path to bleeding edgeness"
      end
      def path c
        api.invoke([:path], c)
      end

    protected

      def api
        @api ||= begin
          require File.expand_path('../api', __FILE__)
          ::Skylab::Tmx::Bleed::Api.build do |o|
            o.on_info_head { |e| err.write "tmx: bleed: #{e}" }
            o.on_info_tail { |e| err.puts e.to_s }
            o.on_info      { |e| err.puts "tmx: bleed: #{e}" }
            o.on_error     { |e| err.puts "tmx: bleed: error: #{e}" }
            o.on_out       { |e| out.puts "tmx: bleed: #{e}" }
          end
        end
      end
    end
  end
end

