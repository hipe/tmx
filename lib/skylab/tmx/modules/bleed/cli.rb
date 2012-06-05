module Skylab::Tmx::Modules
  module Bleed
  end
  class Bleed::Cli < Skylab::Face::Cli
    namespace(:bleed) do
      default_action :load
      summary "run a bleeding edge version of tmx"
      o do |op, ctx|
        op.banner = "attempts to hack your path"
        op.separator "by invoking a bash script"
      end
      def load ctx
        $stderr.puts "(ignoring load for now)"
        # api.invoke([:load], ctx)
      end

      o do |op, ctx|
        op.banner = "Inits a ~/.tmx"
      end
      def init ctx
        api.invoke([:init], ctx) do |o|
          o.on_head { |e| err.write "tmx-bleed: init: #{e.message}" ; e.touch! }
          o.on_tail { |e| err.puts e.message ; e.touch! }
          o.on_all  { |e| err.puts "tmx-bleed: init: #{e.message}" unless e.touched? }
        end
      end

      o do |o, c|
        o.banner = "The path to bleeding edgeness"
      end
      def path *ctx
        ctx = ctx.pop
        cli(['path'], ctx)
      end

    private

      def api
        @api ||= begin
          require_relative './api'
          Bleed::Api.build
        end
      end
    end
  end
end

