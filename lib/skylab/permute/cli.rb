require_relative 'api'
require 'skylab/porcelain/bleeding'

module Skylab::Permute
  class CLI < Skylab::Porcelain::Bleeding::Runtime
    desc "minimal permutations generator."
    def self.build_client_instance rt, tok # @compat
     app = new
     app.action_init(rt)
     app.program_name = "#{rt.program_name} #{tok}"
     app
    end
    def self.porcelain ; self end # @compat
  end
  class CLI::Action
    extend Bleeding::Action
    extend Skylab::PubSub::Emitter
    def self.build runtime
      action = new(runtime)
      action.on_help { |e| runtime.emit(e.type, e) }
      action.on_info { |e| runtime.emit(e.type, e) }
      action.on_out  { |e| runtime.emit(e.type, e) }
      action
    end
  end
  module CLI::Actions
  end
  class HackParse
    def any?
      true
    end
    def help rt
      rt.emit(:help, "#{rt.hdr 'syntax:'} for now, the namespace of options is only for your attributes.")
    end
    class AttributeSet < Struct.new(:name, :values)
      def length ; values.length end
      def sym    ; name.intern   end
    end
    def parse! argv, args, action
      _ = ->() { Hash.new(0) }
      extent = argv.reduce(Struct.new(:long, :short, :short_of_long).new(_[], _[], _[])) do |e, s|
        case s
        when /^--(?!help)(([-a-zA-Z0-9])[-a-zA-Z0-9]*)/ ; e.long[$1]  += 1 ; e.short_of_long[$2] += 1
        when /^-(?!h)([a-zA-Z0-9])/                     ; e.short[$1] += 1
        end
        e
      end
      list = [] ; hash = Hash.new { |h, k| list.push(x = AttributeSet.new(k, [])) ; h[k] = x }
      op = ::OptionParser.new do |o|
        b = ->(name) { ->(value) { hash[name].values.push value } }
        if 0 == (extent.short.keys - extent.short_of_long.keys).length
          extent.long.keys.each { |n| o.on("-#{n[0,1]}<VALUE>", "--#{n} <VALUE>", "a value of #{n}", &b[n])}
        else
          extent.long.keys.each { |n| o.on("--#{n} <VALUE>", "a value of #{n}", &(b[n])) }
          extent.short.keys.each { |n| o.on("-#{n}<VALUE>", "a value of #{n}", &(b[n])) }
        end
        o.on('-h', '--help') do
          return action.help(full: true)
        end
      end
      begin
        op.parse!(argv)
      rescue ::OptionParser::ParseError => e
        return action.help(message: e)
      end
      list.empty? and return action.help(message: 'please provide one or more --attribute values.')
      args.push list
    end
    def string
      "--attr-a <val1> -a<v2> --b-attr <val3> -b<v4> [..]"
    end
  end
  class CLI::Actions::Generate < CLI::Action
    desc "generate permutations."
    emits :help, :info, :out
    include Porcelain::Table::RenderTable
    opt_syn = ->() do
      op = HackParse.new
      (opt_syn = ->{ op }).call
    end
    define_method(:option_syntax) { opt_syn.call }
    argument_syntax ''
    def execute set
      API::Actions::Generate.new(set) do |o|
        rows = []
        o.on_header { |e| rows.push( e.payload.map { |_, s| hdr s } ) }
        o.on_row { |e| rows.push( e.payload.map { |_, s| s } ) }
        o.on_end do
          render_table(rows) do |oo|
            oo.on_info { |e| emit(:info, e) }
            oo.on_row  { |e| emit(:out,  e) }
          end
        end
      end.execute
    end
  end
end

