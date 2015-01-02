module Skylab::Cull

  class Models_::Report_< Model_

    class << self

      def edit_session report_sym, cfg_for_write, oes_p, & edit_p

        sess = Edit_Session___.new report_sym, cfg_for_write, & oes_p

        edit_p[ sess ]

        sess.finish

      end
    end  # >>


    class Edit_Session___

      def initialize report_sym, cfg_for_write, & oes_p
        @on_event_selectively = oes_p
        @OK = true
        @cfg = cfg_for_write
        _s = ( report_sym.id2name if report_sym )
        @section = @cfg.sections.touch_section _s, "report"
      end

      def add_function_call function_class, arg_s_a

        _fname = Callback_::Name.via_module( function_class ).as_slug

        s_a = arg_s_a
        if s_a and s_a.length.nonzero?
          fargs = "(#{ s_a * ', ' })"
        end

        _name = Callback_::Name.via_variegated_symbol( :mutation )

        _ast = @section.assignments

        ok = _ast.add_to_bag_value_string_and_name_function(
          "#{ _fname }#{ fargs }",
          _name )

        if ! ok
          @OK = ok
        end

        nil
      end

      def finish
        if @OK
          # write here or there? there.
          ACHIEVED_
        else
          @OK
        end
      end
    end
  end
end
