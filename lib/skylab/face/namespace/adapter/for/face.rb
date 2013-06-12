module Skylab::Face

  module Face::Namespace::Adapter::For::Face

    module Of

      Hot = -> higher_sheet, lower_ns_cls do
        -> higher_svcs, slug_frag=nil do  # this is `hot` being claled
          lower_ns_cls.new(
            Ouroboros_Sheet[ higher_sheet, lower_ns_cls.story ],
            higher_svcs, slug_frag
          ).instance_variable_get( :@mechanics )
        end
      end
    end

    Ouroboros_Sheet_ = MetaHell::Proxy::Nice.new :name, :set_a, :is_ok,
      :do_include, :is_prenatal, :all_aliases,
      :desc_proc_a, :command_tree, :option_sheet_a,
      :has_default_argv, :has_option_sheets, :fetch_constituent,
      :default_argv_value, :defers_invisibility

    class Ouroboros_Sheet < Ouroboros_Sheet_

      def self.[] hi, lo
                                       # in several places note that
                                       # top trumps bottom (overwrites)
        new(
                           name: -> do hi.name end,
                          set_a: -> do C[ lo.set_a, hi.set_a ] end,
                          is_ok: -> do hi.is_ok && lo.is_ok end,
                     do_include: -> do hi.do_include && lo.do_include end,
                    is_prenatal: -> do hi.is_prenatal end,  # shudders
                    all_aliases: -> do hi.all_aliases | lo.all_aliases end,
                    desc_proc_a: -> do C[ lo.desc_proc_a, hi.desc_proc_a ] end,
                   command_tree: -> do lo.command_tree end,
                 option_sheet_a: -> do lo.option_sheet_a end,
               has_default_argv: -> do hi.has_default_argv || lo.has_default_argv end,
              has_option_sheets: -> do lo.has_option_sheets end,
              fetch_constituent: -> *a, &b do lo.fetch_constituent( *a, &b ) end,
             default_argv_value: -> do ( hi.has_default_argv ? hi : lo ).default_argv_value end,
            defers_invisibility: -> do hi.defers_invisibility end,
        )
      end

      def initialize h
        super
        @hotm = nil
      end
      attr_accessor :hotm
      def hot psvcs, slu=nil
        if @hotm
          @hotm[ psvcs, slu ]
        end
      end
    end
    C = Face::FUN.concat_2  # in cli for now :/
  end
end
