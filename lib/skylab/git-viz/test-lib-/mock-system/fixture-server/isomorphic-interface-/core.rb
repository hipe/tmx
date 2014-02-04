module Skylab::GitViz

  module Test_Lib_::Mock_System

    class Fixture_Server

      class Isomorphic_Interface_  # [#hl-077]:#what-is-meant-by-isomorphic-interface

        def self.[] mod, * x_a
          new( mod, x_a ).execute ; nil
        end

        def initialize mod, x_a
          @mod = mod ; @x_a = x_a
        end

        def execute
          @mod.extend Module_Methods__
          @mod.include Instance_Methods__
          parse_preamble
          @mod.const_set :PARAM_I_A__, []
          @term_parse = Term_Parse__.curry self, @x_a
          begin
            @term_parse.curry.parse_term
          end while @x_a.length.nonzero?
          @mod.const_get( :PARAM_I_A__, false ).freeze ; nil
        end

      private

        def parse_preamble
          while :use == @x_a.first
            @x_a.shift
            _c = @x_a.shift.to_s.gsub( %r((?<=_|^)([a-z])) ) { $1.upcase }
            _mod = Isomorphic_Interface_.const_get( _c, false )
            _mod.apply_iambic_on_client @x_a, @mod
          end ; nil
        end

      public
        def accept_param param
          i = :"lookup_#{ param.param_i }_parameter"
          @mod.module_exec do
            const_get( :PARAM_I_A__, false ) << i
            define_singleton_method i do param end
          end ; nil
        end
      private

        module Module_Methods__
          def lookup_parameter i
            send :"lookup_#{ i }_parameter"
          end
          def get_parameters
            const_get( :PARAM_I_A__, false ).map do |i|
              send i
            end
          end
        end

        module Instance_Methods__
          def initialize( * _ )
            self.class.get_parameters.each do |param|
              instance_variable_set param.ivar,
                ( [] if param.takes_multiple_arguments && ! param.is_required )
            end
            super
          end
        end

        class Term_Parse__
          class << self
            def curry listener, x_a
              new listener, x_a
            end
            private :new
          end
          def initialize_copy otr
            initialize otr.listener, otr.x_a
          end
          def initialize listener, x_a
            @listener = listener ; @x_a = x_a ; nil
          end
          def curry
            dup
          end
          def parse_term
            send :"#{ @x_a.shift }=" ; nil
          end
        protected
          attr_reader :listener, :x_a
        private
          def required=
            _param = Parameter__.new do |p|
              p.is_required = true
              p.absorb_iambic_from_argument @x_a
            end
            accpt_param _param ; nil
          end
          def argument=
            _param = Parameter__.new do |p|
              p.takes_at_least_one_argument_notify
              p.absorb_iambic_from_name @x_a
            end
            accpt_param _param ; nil
          end
          def flag=
            _param = Parameter__.new do |p|
              p.absorb_iambic_from_name @x_a
            end
            accpt_param _param ; nil
          end

          def accpt_param param
            @listener.accept_param param ; nil
          end
        end

        class Parameter__
          def initialize
            @_aa_ = Argument_Arity_.new nil, nil  # volatile ivar in a frozen.
            yield self
            freeze
          end
          def param_i
            @param_i
          end
          attr_accessor :is_required
          attr_reader :attr_reader_method_name, :CLI_moniker_s, :ivar
          attr_reader :takes_exactly_one_argument, :takes_multiple_arguments

          def absorb_iambic_from_argument x_a
            absorb_iambic x_a do
              scan_any_accumulating
              scan_argument
            end
          end
          def absorb_iambic_from_name x_a
            absorb_iambic x_a do scan_name end
          end
          def takes_at_least_one_argument_notify
            takes_at_least_one_arg_notify
          end
          def as_human_moniker  # in lieu of expression agents
            "#{ @param_i.to_s.gsub '_', ' ' }"
          end
        private
          def absorb_iambic x_a, & p
            @x_a = x_a ; yield ; @x_a = nil
          end
          def scan_any_accumulating
            if scan_any_keyword :accumulating
              takes_many_args_notify
            end ; nil
          end
          def scan_argument
            scan_keyword :argument
            takes_at_least_one_arg_notify
            scan_name
          end
          def takes_at_least_one_arg_notify
            @_aa_.begin = :one ; nil
          end
          def takes_many_args_notify
            @_aa_.end = :many ; nil
          end
          def scan_name
            @x_a.length.zero? and raise ::ArgumentError, say_expecting_name
            @param_i = @x_a.shift
            nil
          end
          UNDERSCORE__ = '_'.freeze ; DASH__ = '-'.freeze
          def say_expecting_name
            "expecting parameter name, had no more terms to parse"
          end
          def scan_any_keyword i
            if @x_a.length.nonzero? and i == @x_a.first
              @x_a.shift ; true
            end
          end
          def scan_keyword i
            @x_a.length.zero? || i != @x_a.first and
              raise ::ArgumentError, say_expecting_keyword( i )
            @x_a.shift ; nil
          end
          def say_expecting_keyword i
            "expecting '#{ i }' #{ @x_a.length.zero? ? "but had no #{
             }more terms to parse" : "had '#{ @x_a.first }'" }"
          end
          def freeze
            finalize_names
            b = @_aa_.begin || :unspecified
            e = @_aa_.end || :not_specified
            @_aa_ = nil
            send :"set_final_arity_when_begin_is_#{ b }_and_end_is_#{ e }"
            super
          end
          def finalize_names
            hungarian_i = :many == @_aa_.end ? :"#{ @param_i }_a" : @param_i
            @ivar = :"@#{ hungarian_i }"
            @attr_reader_method_name = hungarian_i
            @CLI_moniker_s =
              "--#{ @param_i.to_s.gsub UNDERSCORE__, DASH__ }".freeze ; nil
          end
          def set_final_arity_when_begin_is_one_and_end_is_not_specified
            @takes_exactly_one_argument = true
          end
          def set_final_arity_when_begin_is_one_and_end_is_many
            @takes_multiple_arguments = true
          end
        end

        class Argument_Arity_
          def initialize x, y
            @begin = @end = nil
            self.begin = x ; self.end = y ; nil
          end
          attr_reader :begin, :end
          def begin= x
            @begin and fail "can't unwrite the past"
            case x
            when nil, :one ; @begin = x
            else ; raise ::ArgumentError, "begin? \"#{ x }\""
            end ; x
          end
          def end= x
            @end and fail "can't unwrite the past"
            case x
            when nil, :many ; @end = x
            else ; raise ::ArgumentError, "end? \"#{ x }\""
            end ; x
          end
        end
      end
    end
  end
end
