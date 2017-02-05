module Skylab::Plugin::TestSupport

  module Models::Lazy_Index

    class << self
      def [] tcc
        tcc.include InstanceMethods___
      end
    end  # >>

    module InstanceMethods___

      define_singleton_method :shared_subject, TestSupport_::DANGEROUS_MEMOIZE

      def load_ticket_from_state_two_
        tuple_from_state_two_.fetch 1
      end

      def plugin_offset_from_state_two_
        tuple_from_state_two_.fetch 0
      end

      shared_subject :tuple_from_state_two_ do

        subj, ob = tuple_from_state_one_

        # (pretend that the operator branch produced the load ticket (in
        # this branch's case an asset ticket) through streaming or whatever)

        _k = this_one_natural_key_

        _at = ob.module.entry_tree.asset_ticket_via_entry_group_head _k

        _trueish_x = EEK_TrueishItemValue___[ _at ]

        _d = subj.offset_of_touched_plugin_via_user_value _trueish_x

        [ _d, _trueish_x ]
      end

      EEK_TrueishItemValue___ = ::Struct.new :asset_ticket do

        # (in production we now have the "trueish item value" of this one
        # kind of operator branch be a custom "load ticket". (it's
        # potentially confusing: often we think of the "keys" as load tickets
        # (even when symbols) but in this case the "values" are too). because
        # that's what we're doing in production and we're in the middle of
        # debuging it, we follow suite here too. but not it's very short-lived

        def HELLO_LOAD_TICKET
          NIL
        end
      end

      def subject_from_state_one_
        tuple_from_state_one_.fetch 0
      end

      define_method :this_one_natural_key_, Lazy_.call(){ "bundle".freeze }

      shared_subject :tuple_from_state_one_ do

        ob = Build_real_operator_branch___[]

        subj = subject_module_.define do |o|

          o.operator_branch = ob

          o.construct_plugin_by = -> cls do
            cls.name.split( '::' ).last.upcase << "!"  # :#here
          end
        end

        [ subj, ob ]
      end

      # ~ pick any loadable node (i.e any node) under lib/skylab/plugin

      def subject_module_
        Home_::Models::LazyIndex
      end
    end

    # ==

    Build_real_operator_branch___ = -> do
      Zerk_lib_[]::ArgumentScanner::OperatorBranch_via_AutoloaderizedModule.define do |o|
        o.module = Home_
      end
    end

    # ==
  end
end
