require_relative 'api'

module Skylab::TMX::Modules
  class Bleed::CLI < Skylab::Face::CLI
    namespace(:bleed) do
      default_action :load
      summary "run a bleeding edge version of tmx"
      o do |op, ctx|
        op.banner = "attempts to hack your path"
        op.separator "by invoking a bash script"
      end
      def load params
        api(:load, params) { |o| o.on_bash { |e| out.puts "#{e.bash} ; " } }
      end

      o do |o, params|
        o.banner = "unbleed your path"
      end
      def unbleed params
        api(:unbleed, params) { |o| o.on_bash { |e| out.puts "#{e.bash} ; " } }
      end

      o do |op, ctx|
        op.banner = "Inits a #{Skylab::TMX::Model::Config::PATH}"
      end
      def init ctx
        api(:init, ctx) do |o|
          o.on_head { |e| err.write "tmx-bleed: init: #{e.message}" ; e.touch! }
          o.on_tail { |e| err.puts e.message ; e.touch! }
          o.on_all  { |e| err.puts "tmx-bleed: init: #{e.message}" unless e.touched? }
        end
      end

      o do |o, c|
        syntax "#{invocation_string} [opts] [<path>]"
        o.banner = "Gets or sets path to the bleeding-edge tmx codebase.\n"<<
          "(note this does not change your PATH or what the tmx executable points to (see 'load'))\n" <<
          "#{usage_string}"
      end
      def path ctx, path=nil
        ctx[:path] = path
        api(:path, ctx) do |o|
          o.on_path { |e| out.puts e.message }
          file_events('path: ', o)
          o.on_all { |e| err.puts "tmx-bleed: path: #{e.type}: #{e.message}" unless e.touched? }
        end
      end

    private

      def api *a, &b
        @api ||= Bleed::API.build
        0 < a.length ? @api.invoke(*a, &b) : @api
      end
      def file_events prefix, o
        o.on_head { |e| err.write "tmx-bleed: #{prefix}#{e.message}" ; e.touch! }
        o.on_tail { |e| err.puts e.message ; e.touch! }
      end
    end
  end
end

