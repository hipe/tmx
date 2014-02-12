module Skylab::Face

  module CLI::API_Integration

    class OP_

      Lib_::Funcy[ self ]

      Lib_::Fields[ self, :field_box, :any_expression_agent, :param_h, :op ]

      def execute
        @short_h = { }
        @opt_box = Lib_::Box[]
        @field_box.values.each do |fld|
          fld.is_required and next
          opt = build_option_with_resolved_short_and_long fld
          fld.has_desc and add_desc opt, fld
          @op.define( * opt.to_a, & build_proc( fld ) )
        end
        nil
      end

    private

      def build_option_with_resolved_short_and_long fld
        i = fld.local_normal_name
        opt = Option.new_semi_mutable_from_normal_name i
        if fld.has_argument_string
          opt.append_arg fld.argument_string_value
        elsif fld.some_argument_arity.is_one
          opt.append_arg " #{ Normal_to_opt_arg_[ i ] }"
        end
        fld.has_single_letter and opt.set_single_letter fld.single_letter_value
        single_i = opt.single_letter_i
        field, option = @short_h[ single_i ]
        if field
          if fld.has_single_letter && ! field.has_single_letter
            option.set_norm_short_str nil
            @short_h[ single_i ] = [ fld, opt ]
          else
            opt.set_norm_short_str nil
          end
        else
          @short_h[ single_i ] = [ fld, opt ]
        end
        opt
      end
      #
      Normal_to_opt_arg_ = -> i do
        # hack :foo_bar_s into "<bar>", e.g. :primary_email_s # => "<email>"
        s = Chmp_sing_ltr_sfx_[ i ]
        As_arg_raw_[ s[ ( (( i = s.rindex '_' )) ? i + 1 : 0 ) .. -1 ] ]
      end
      #
      Chmp_sing_ltr_sfx_, As_arg_raw_ = Face_::API::Procs.
        at :Chomp_single_letter_suffix, :Local_normal_name_as_argument_raw
      #
      Option = Face_::CLI::CLI_Lib_::Option_model_class[]

      def add_desc opt, fld
        y = [ ]
        @any_expression_agent.instance_exec y, & fld.desc_value
        opt.set_desc_a y
        nil
      end

      def build_proc fld
        name_i = fld.local_normal_name  # assume all opts are not required
        if fld.some_arity.is_polyadic
          if fld.some_argument_arity.is_zero
            -> _ do
              @param_h[ name_i ] ||= 0
              @param_h[ name_i ] += 1
              nil
            end
          else
            -> x do
              ( @param_h[ name_i ] ||= [ ] ) << x
              nil
            end
          end
        elsif fld.some_argument_arity.is_zero
          -> _true do
            if @param_h.key? name_i
              handle_clobber_by_upgrading_to_integer name_i
            else
              @param_h[ name_i ] = true
            end
            nil
          end
        else
          -> x do
            if @param_h.key? name_i
              handle_clobber_by_upgrading_to_array name_i, x
            else
              @param_h[ name_i ] = x
            end
            nil
          end
        end
      end

      def handle_clobber_by_upgrading_to_array name_i, x
        if (( v = @param_h[ name_i ] )).respond_to? :each_index
          v << x
        else
          @param_h[ name_i ] = [ v, x ]
        end
        nil
      end

      def handle_clobber_by_upgrading_to_integer name_i
        if (( v = @param_h[ name_i ] )).respond_to? :even?
          @param_h[ name_i ] = v + 1
        else
          @param_h[ name_i ] = 2
        end
        nil
      end

      #                  ~ helpers for integration ~

      Write_op_to_method_ = -> op do
        OP_[ :field_box, field_box,
             :any_expression_agent, any_expression_agent,
             :param_h, @param_h,
             :op, op ]
        nil
      end

      OP_ = self
    end
  end
end
