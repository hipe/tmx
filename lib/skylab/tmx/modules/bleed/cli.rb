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
          head_and_tails('init: ', o)
          o.on_all  { |e| err.puts "tmx-bleed: init: #{e.message}" unless e.touched? }
        end
      end

      o do |o, c|
        syntax "#{invocation_string} [opts] [<path>]"
        o.banner = "Gets or sets path to the bleeding-edge tmx codebase.\n"<<
          "(note this does not change your PATH or what the tmx executable points to (see 'load'))\n#{usage_string}"
      end
      def path ctx, path=nil
        ctx[:path] = path
        api.invoke([:path], ctx) do |o|
          o.on_path { |e| out.puts e.message }
          file_events('path: ', o)
          o.on_all { |e| err.puts "tmx-bleed: path: #{e.type}: #{e.message}" unless e.touched? }
        end
      end

    private

      def api
        @api ||= begin
          require_relative './api'
          Bleed::Api.build
        end
      end
      def file_events prefix, o
        o.on_head { |e| err.write "tmx-bleed: #{prefix}#{e.message}" ; e.touch! }
        o.on_tail { |e| err.puts e.message ; e.touch! }
      end
    end
  end
end

