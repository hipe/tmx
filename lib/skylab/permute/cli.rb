require_relative 'core'

module Skylab::Permute

  class CLI < Bleeding::Runtime

    desc "minimal permutations generator."

    def self.build_client_instance rt, tok # #compat
      app = new
      app.parent = rt
      app.program_name = "#{ rt.program_name } #{ tok }"
      app
    end

    def self.porcelain # #compat
      self
    end

  protected

    param_h = {
      0 => -> _, b do
        if b
          b[ self ]
        else
          # fail "block?" - egads no, testing
        end
      end,
      3 => -> a, b do
        if b
          fail "block and args?"
        else
          self.parent = Headless::CLI::IO_Adapter::Minimal.new(* a )
        end
      end
    }

    define_method :initialize do |*a, &b|      # please pardon our blood
      instance_exec a, b, & param_h.fetch( a.length )
    end
  end

  class CLI::Action

    extend Bleeding::Action

    extend PubSub::Emitter

    emits syntax_error: :info

    event_factory -> _, __, x { x }  # "datapoints"

    def self.build runtime
      act = new
      act.parent = runtime
      act.on_info do |e|
        runtime.emit :info, e
      end
      act.on_payload do |e|
        runtime.emit :payload, e
      end
      act
    end
  end

  module CLI::Actions
  end

  class HackParse

    attr_accessor :live_action

    def any?
      true
    end

    def help line
      str = @live_action.instance_exec do
        "#{ hdr 'syntax:' } for now, the namespace of all switches is only #{
          }for your aspect values."
      end
      line[ str ]
      nil
    end

    class Enum

      attr_reader :normalized_name

      attr_reader :value_a

      def length
        @value_a.length
      end

      def label
        @normalized_name.to_s
      end

      def initialize norm_name
        @value_a = []
        @normalized_name = norm_name
      end
    end

    def parse argv, args, help, error  # (unhack as needed)
      extent = argv.reduce(
        ::Struct.new( :long, :short, :short_of_long ).new(
          * 3.times.map { ::Hash.new 0 }
        )
      ) do |m, token|
        case token
        when /^--(?!help)(([-a-zA-Z0-9])[-a-zA-Z0-9]*)/
          m.long[$1]  += 1
          m.short_of_long[$2] += 1
        when /^-(?!h)([a-zA-Z0-9])/
          m.short[$1] += 1
        end
        m
      end

      list = []
      hash = ::Hash.new do |h, k|
        x = Enum.new k
        list << x
        h[k] = x
      end

      done = false ; res = nil
      op = ::OptionParser.new  # as soon as you have to nerk with this [#ps-008]
      b = -> name do
        -> value do
          hash[name.intern].value_a << value
          nil
        end
      end
      len = ( extent.short.keys - extent.short_of_long.keys ).length
      if 0 == len
        extent.long.keys.each do |n|
          op.on "-#{ n[0, 1] }<VALUE>", "--#{ n } <VALUE>",
            "a value of #{ n }", & b[n]
        end
      else
        extent.long.keys.each do |n|
          op.on "--#{ n } <VALUE>", "a value of #{ n }", & b[n]
        end
        extent.short.keys.each do |n|
          op.on "-#{ n }<VALUE>", "a value of #{ n }", & b[n]
        end
      end
      if 2 > argv.length  # omg so weird - don't process '-h' as help when..
        op.on '-h', '--help' do
          res = help[]
          done = true
        end
      end
      begin
        op.parse!(argv)
      rescue ::OptionParser::ParseError => e
        error[ e ]
        res = false
        done = true
      end
      if ! done
        if list.empty?
          res = error[ 'please provide one or more --<aspect> values.' ]
          done = false
        else
          args.push list
          res = true
        end
      end
      res
    end

    def string
      "--a-aspect <val1> -a<v2> --b-aspect <val3> -b<v4> [..]"
    end
  end

  class CLI::Actions::Generate < CLI::Action

    desc "generate permutations."

    emits :payload, :info, help: :info

    opt_syn = -> do  # hacklund
      op = HackParse.new
      opt_syn = -> { op }
      op
    end

    define_singleton_method :option_syntax do opt_syn[] end

    define_method :option_syntax do
      hack = opt_syn.call
      hack.live_action = self # so so bad
      hack
    end

    def process enum_a
      Permute::API::Actions::Generate.new enum_a do |o|
        row_a = []
        o.on_header do |pairs|
          row_a << pairs.map { |_, label| hdr label }
        end
        o.on_row do |pairs|
          row_a << pairs.map { |_, value| value }
        end
        o.on_finished do
          Headless::CLI::Table.render row_a do |oo|
            oo.on_info { |txt| emit :info, txt }
            oo.on_row  { |txt| emit :payload, txt }
          end
        end
      end.execute
    end
  end
end
