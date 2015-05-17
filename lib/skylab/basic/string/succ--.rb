module Skylab::Basic

  module String

    class Succ__

      # three laws compliant

      Callback_::Actor.methodic self, :simple, :properties,

         :property, :beginning_number,
         :property, :beginning_width,

         :argument_arity, :zero, :property, :first_item_does_not_use_number,

         :polymorphic_writer_method_to_be_provided, :property, :template


      def initialize
        @first_item_does_not_use_number = false
        @template_o = nil
        super
        @beginning_number ||= 1
        @beginning_width ||= 1
        if ! @template_o
          _receive_template_string DEFAULT_TEMPLATE___
        end
      end

      DEFAULT_TEMPLATE___ = '{{ ID }}'

    private

      def template=
        _receive_template_string gets_one_polymorphic_value
        st = polymorphic_upstream
        h = @tmpl_var_bx.h_
        while st.unparsed_exists
          sym = st.gets_one.intern
          had = true
          h.fetch sym do
            had = false
          end
          if had
            @template_values_prototype[ sym ] = st.gets_one
          else
            raise ::ArgumentError.new( __say_template_variable_not_fond sym )
          end
        end
        KEEP_PARSING_
      end

      def __say_template_variable_not_fond sym
        "template variable `#{ sym }` not found. did you mean #{
          @tmpl_var_bx.get_names * ' or ' }?"
      end

    public

      def execute
        current_number = @beginning_number
        width = @beginning_width

        format = nil
        local_limit = nil

        reformat = -> do
          format = "%0#{ width }d"
          local_limit = 10 ** ( [ 1, width - 1 ].max )
          nil
        end
        reformat[]

        reformat_if_necessary = -> do
          if local_limit <= current_number
            width += 1
            reformat[]
          end
          nil
        end

        body_p = -> do
          reformat_if_necessary[]
          __result_via_identifier_string format % current_number
        end

        non_first_p = -> do
          current_number += 1
          body_p[]
        end

        p = if @first_item_does_not_use_number
          -> do
            p = non_first_p
            reformat_if_necessary[]
            __result_via_identifier_string nil
          end
        else
          -> do
            p = non_first_p
            body_p[]
          end
        end

        -> do
          p[]
        end
      end

      def __result_via_identifier_string any_s

        h = @template_values_prototype.dup
        h[ :ID ] = any_s

        @template_o.call h
      end

      def _receive_template_string s

        tvp = Values__.new
        @template_values_prototype = tvp

        o = Basic_::String.template.new_with(
          :string, s,
          :surface_pair_mapper, -> pair do
            s = pair.unparsed_surface_content_s
            if s and s.include? IF_S___
              __receive_surface_var_with_conditional pair
            end
            pair
          end )

        @template_o = o

        bx = o.to_formal_variable_stream.
          flush_to_box_keyed_to_method :name_symbol

        @tmpl_var_bx = o.formal_variable_box

        tvp.receive_all_names bx.a_

        nil
      end

      IF_S___ = ' if '  # meh

      def __receive_surface_var_with_conditional var

        md = IF_RX__.match var.unparsed_surface_content_s
        exp_s, cond_s = md.captures

        var.unparsed_surface_content_s = nil
        exp_s.strip!
        cond_s.strip!
        var.name_symbol = exp_s.intern

        @template_values_prototype.accept_conditional(
          var.name_symbol, cond_s.intern )

        var
      end

      IF_RX__ = /\A((?:(?! if )).+) if (.+)\z/

      class Values__

        def initialize
          @p_h = {}
          @x_h = {}
        end

        def initialize_copy _otr_
          @x_h = @x_h.dup
          nil
        end

        def accept_conditional name_i, cond_i

          @p_h[ name_i ] = -> x_h do
            if x_h[ cond_i ]
              x_h[ name_i ]
            else
              EMPTY_S_  # don't produce the surface variable
            end
          end
          nil
        end

        def receive_all_names sym_a
          ( sym_a - @p_h.keys ).each do | k |
            @p_h[ k ] = -> x_h do
              x_h[ k ]
            end
          end
          nil
        end

        def []= k, x
          @x_h[ k ] = x
        end

        # ~ minimal value collection #hook-outs

        def fetch k, & else_p

          p = @p_h[ k ]
          if p
            p[ @x_h ]
          elsif else_p
            else_p[]
          else
            raise ::KeyError, "no value '#{ k }' in template variables"
          end
        end
      end
    end
  end
end
