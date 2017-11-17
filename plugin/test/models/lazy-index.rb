module Skylab::Plugin::TestSupport

  module Models::Lazy_Index

    class << self
      def [] tcc
        tcc.include InstanceMethods___
      end
    end  # >>

    module InstanceMethods___

      define_singleton_method :shared_subject, TestSupport_::DANGEROUS_MEMOIZE

      def loadable_reference_from_state_two_
        tuple_from_state_two_.fetch 1
      end

      def plugin_offset_from_state_two_
        tuple_from_state_two_.fetch 0
      end

      shared_subject :tuple_from_state_two_ do

        subj, ob = tuple_from_state_one_

        # (pretend that the feature branch produced the loadable reference (in
        # this branch's case an asset reference) through streaming or whatever)

        _k = this_one_natural_key_

        mod = ob.module

        _aref = mod.entry_tree.asset_reference_via_entry_group_head _k

        _this_class = Home_.lib_.zerk::ArgumentScanner::
            FeatureBranch_via_AutoloaderizedModule::
              LoadableReferenceIsh___  # [ze]:TESTPOINT1

        _trueish_x = _this_class.define do |o|
          o.asset_reference = _aref
          o.module = mod
          o.sub_branch_const = :Actions
        end

        _d = subj.offset_of_touched_plugin_via_user_value _trueish_x

        [ _d, _trueish_x ]
      end

      def subject_from_state_one_
        tuple_from_state_one_.fetch 0
      end

      define_method :this_one_natural_key_, Lazy_.call(){ "bundle".freeze }

      shared_subject :tuple_from_state_one_ do

        ob = Build_real_feature_branch___[]

        subj = subject_module_.define do |o|

          o.feature_branch = ob

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

    Build_real_feature_branch___ = -> do
      Zerk_lib_[]::ArgumentScanner::FeatureBranch_via_AutoloaderizedModule.define do |o|
        o.module = Home_
        o.sub_branch_const = :Actions
      end
    end

    # ==
  end
end
