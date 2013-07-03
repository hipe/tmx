module Skylab::MetaHell

  module FUN::Parse

    class Field_

      def initialize
        @monikizer_p = @moniker = nil
      end

      define_method :absorb_notify, & FUN::Parse::Absorb_notify_

      def looks_like_default?
        ! looks_like_particular_field
      end

      def merge_defaults! dflt
        p = dflt.monikizer_p and ( @monikizer_p ||= p )
        nil
      end

      attr_reader :monikizer_p

      def normal_token_proc
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

      Mnkzr_p_ = -> s { "<<**#{ s }**>>" }

      def get_moniker
        ( @monikizer_p || Mnkzr_p_ )[ @moniker ]
      end

    protected

      attr_reader :looks_like_particular_field

      def op_h
        self.class.const_get :OP_H_, false
      end

    private

      def monikizer a
        @monikizer_p = a.shift
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

      OP_H_ = FUN::Parse::Op_h_via_private_instance_methods_[ self ]
    end
  end
end
