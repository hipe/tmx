module Skylab::MetaHell

  module FUN::Parse

    class Field_

      def initialize
        @normal_parse_p = nil
      end

      def looks_like_default?
        ! looks_like_particular_field
      end

      def merge_defaults! dflt
        p = dflt.monikate_p and ( @monikate_p ||= p )
        nil
      end

      attr_reader :monikate_p

      def normal_token_proc  # assumes `token_scanner`
        @ntp ||= begin
          -> tok do
            x = @token_scanner_p[ tok ]
            if ! x.nil?
              [ true, x ]
            end
          end
        end
      end

      def get_monikers_proc
        me = self
        -> { [ me.get_moniker ] }
      end

      def get_moniker
        ( @monikate_p || Mkt_p_ )[ @moniker ]
      end
      Mkt_p_ = -> s { "<<**#{ s }**>>" }

      def get_agent
        @agent_p.call
      end

      attr_reader :looks_like_particular_field

      def any_context
        if @last_x
          " after \"#{ @last_x }\""
        else
          " at beginning of field sub-parse"
        end
      end

    private

      def normal_parse memo, argv
        instance_exec memo, argv, & @normal_parse_p
      end

      def ivar_mutex ivar, a
        instance_variable_defined? ivar and raise "sanity - can have only #{
          }one #{ Hack_label_[ ivar ] } for now"
        instance_variable_set ivar, a.fetch( 0 ) ; a.shift
        nil
      end

    MetaHell_::Fields::From.methods(
      :destructive, :argful, :passive, :absorber, :absorb_iambic_passively
    ) do  # borrow 1 indent

      def monikate a
        @monikate_p = a.shift
        nil
      end

      def moniker a
        @looks_like_particular_field = true
        @moniker = a.shift
        nil
      end

      def token_scanner a
        @looks_like_particular_field = true
        @token_scanner_p = a.shift
        nil
      end

      def parse a
        @looks_like_particular_field = true
        @normal_parse_p = a.fetch 0 ; a.shift
        nil
      end

      def agent a
        p = a.fetch 0 ; a.shift ; p.respond_to?( :call ) or raise "proc? #{ p }"
        @agent_p = p
        nil
      end
    end  # (pay 1 back)
    end
  end
end
