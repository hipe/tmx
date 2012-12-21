require_relative 'core'

module Skylab::Permute
  class CLI < ::Skylab::Porcelain::Bleeding::Runtime
    desc "minimal permutations generator."
    def self.build_client_instance rt, tok # @compat
     app = new
     app.parent = rt
     app.program_name = "#{rt.program_name} #{tok}"
     app
    end
    def self.porcelain ; self end # @compat
  end
  class CLI::Action
    extend ::Skylab::Porcelain::Bleeding::Action
    extend ::Skylab::PubSub::Emitter
    emits syntax_error: :info
    def self.build runtime
      action = new
      action.parent = runtime
      action.on_info    { |e| runtime.emit(e.type, e) }
      action.on_payload { |e| runtime.emit(e.type, e) }
      action
    end
  end
  module CLI::Actions
  end
  class HackParse
    attr_accessor :action
    def any?
      true
    end
    def help line
      str = action.instance_exec do
        "#{ hdr 'syntax:' } for now, the namespace of options is only #{
          }for your attributes."
      end
      line[ str ]
      nil
    end
    class AttributeSet < Struct.new(:name, :values)
      def length ; values.length end
      def sym    ; name.intern   end
    end
    def parse argv, args, help, error
      _ = ->() { Hash.new(0) }
      extent = argv.reduce(Struct.new(:long, :short, :short_of_long).new(_[], _[], _[])) do |e, s|
        case s
        when /^--(?!help)(([-a-zA-Z0-9])[-a-zA-Z0-9]*)/ ; e.long[$1]  += 1 ; e.short_of_long[$2] += 1
        when /^-(?!h)([a-zA-Z0-9])/                     ; e.short[$1] += 1
        end
        e
      end
      list = [] ; hash = Hash.new { |h, k| list.push(x = AttributeSet.new(k, [])) ; h[k] = x }
      up = true ; result = nil
      op = ::OptionParser.new do |o|
        b = ->(name) { ->(value) { hash[name].values.push value } }
        if 0 == (extent.short.keys - extent.short_of_long.keys).length
          extent.long.keys.each { |n| o.on("-#{n[0,1]}<VALUE>", "--#{n} <VALUE>", "a value of #{n}", &b[n])}
        else
          extent.long.keys.each { |n| o.on("--#{n} <VALUE>", "a value of #{n}", &(b[n])) }
          extent.short.keys.each { |n| o.on("-#{n}<VALUE>", "a value of #{n}", &(b[n])) }
        end
        o.on('-h', '--help') do
          # result = action.help(full: true)
          result = help[]
          up = false
        end
      end
      begin
        op.parse!(argv)
      rescue ::OptionParser::ParseError => e
        error[ e ]
        #  result = action.help(message: e)
        up = false
      end
      if up
        if list.empty?
          # result = action.help(message: 'please provide one or more --attribute values.')
          result = error[ 'please provide one or more --atribute values.' ]
          up = false
        else
          args.push list
          result = true
        end
      end
      result
    end
    def string
      "--attr-a <val1> -a<v2> --b-attr <val3> -b<v4> [..]"
    end
  end


  class CLI::Actions::Generate < CLI::Action

    desc "generate permutations."

    emits :payload, :info, help: :info

    include Porcelain::Table::RenderTable

    opt_syn = ->() do # hacklund
      op = HackParse.new
      (opt_syn = ->{ op }).call
    end

    singleton_class.send(:define_method, :option_syntax) { opt_syn.call }

    define_method :option_syntax do
      hack = opt_syn.call
      hack.action = self # so so bad
      hack
    end

    def invoke set
      Permute::API::Actions::Generate.new(set) do |o|
        rows = []
        o.on_header { |e| rows.push( e.payload.map { |_, s| hdr s } ) }
        o.on_row { |e| rows.push( e.payload.map { |_, s| s } ) }
        o.on_end do
          render_table(rows) do |oo|
            oo.on_info { |e| emit(:info, e) }
            oo.on_row  { |e| emit(:payload,  e) }
          end
        end
      end.execute
    end
  end
end
