module Skylab::Face

  class CLI

    class API_Integration::OP_

      MetaHell::Funcy[ self ]

      MetaHell::FUN.fields[ self,
                            :op, :field_box, :expression_agent, :param_h ]

      def execute
        @short_h = { }
        @opt_box = Services::Basic::Box.new
        @field_box.each do |fld|
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
        elsif TAKES_ARG_H_[ fld.some_argument_arity_value ]
          opt.append_arg Normal2arg_[ i ]
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

      TAKES_ARG_H_ = { :zero => false, :one => true }.tap do |h|
        h.default_proc = -> _h, k do
          raise ::ArgumentError, "unsupported argument arity - #{ k }"
        end
        h.freeze
      end

      Normal2arg_ = -> i do
        s = i.to_s
        stem = s[ ( (( i = s.rindex '_' )) ? i + 1 : 0 ) .. -1 ]
        " <#{ stem }>"
      end

      def add_desc opt, fld
        y = [ ]
        @expression_agent.instance_exec y, & fld.desc_value
        opt.set_desc_a y
        nil
      end

      def build_proc fld  # assume has arity_o b.c assume is not required b.c
        name_i = fld.local_normal_name  # assume all opts are not required
        if fld.arity_o.is_unbounded
          if fld.some_argument_arity_value_is_zero
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
        elsif fld.some_argument_arity_value_is_zero
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
        if (( v = @param_h[ name_i ] )).respond_to? :numerator
          @param_h[ name_i ] = v + 1
        else
          @param_h[ name_i ] = 2
        end
        nil
      end

      Option = Face::Services::Headless::CLI::Option::Model_
    end
  end
end
