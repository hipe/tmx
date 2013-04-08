module Skylab

  class TMX::Modules::Bleed::API::Action

    extend PubSub::Emitter
    public :emits?, :on, :unhandled_event_stream_graph
      # allow external things to read/write these

    # graph set by children

    # `emits` - HACK: assumes your subclass calls `emits` only once
    # write emitter methods only for those streams that you emit on.

    def self.emits( * )
      super

      o = -> event_stream_name, method_body do
        if event_stream_graph.has? event_stream_name
          define_method event_stream_name, & method_body
        end
        nil
      end

      o[ :info, -> message_string do
        emit :info, message_string
        nil
      end ]

      o[ :notice, -> message_string do
        emit :notice, message_string
        nil
      end ]

      o[ :error, -> message_string do
        emit :error, message_string
        false
      end ]
    end

  protected

    def initialize
      yield self
    end

    [ :contract_tilde, :expand_tilde ].each do |m|
      define_method m, & Headless::CLI::PathTools::FUN[ m ]
    end

    def config_get_path
      res = nil
      begin
        if ! config.exist?
          notice "#{ config_path } not found - use `init` to create."
          break
        end
        config_read or break

        sect = config['bleed']
        if ! sect
          notice "section not found in #{ config_path } - ['bleed']"
          break
        end

        p = sect['path']
        if ! p
          notice "'path' attribute not found in [bleed'] in #{ config_path }"
          break
        end

        res = p
      end while nil
      res
    end

    def config
      @config ||= TMX::Models::Config.build
    end

    def config_path
      escape_path config.path
    end

    define_method :escape_path, & Headless::CLI::PathTools::FUN.pretty_path
      # (points for you if you see the smell)

    def config_read   # assumes config exist, emits error
      config.read do |ev|
        ev[:invalid] = -> reason_string do
          error "#{ reason_string }"
        end
        ev[:is_not_file] = -> pn, type do
          error "expected file had #{ type } - #{ pn }"
        end
        ev[:no_ent] = -> pn do
          error "config file not found - #{ pn }"
        end
        ev[:error] = method :error  # future-proof
      end
    end

    def config_write
      res = true
      config.write do |o|

        o.on_before do |e|
          emit :head, "config: #{ e.message }"
        end

        o.on_after do |e|
          emit :tail, " .. done (wrote #{ e.bytes } bytes)"
        end

        o.on_error do |e|
          error e.message
        end

        o.on_no_change do |e|
          info e.message
        end

        a = o.send( :unhandled_event_stream_graph ).names -
          [ :all, :text, :notice, :structural ]

        if a.length.nonzero?
          raise "unhandled event stream(s) - #{ a.inspect }"
        end
      end
      res
    end
  end
end
