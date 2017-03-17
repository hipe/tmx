module Skylab::Fields

  module Toolkit  # :[#029.A]

    # EXPERIMENT towards E.K

    class Normalize < Common_::MagneticBySimpleModel

      # (bridge the gap between bleeding new and the more general one)

      def self.[] ent
        call_by do |o|
          o.entity = ent
        end
      end

      def initialize
        @_did = false
        super
      end

      def association_stream= x
        @_did = true ; @__as = x
      end

      attr_writer(
        :argument_scanner,
        :entity,
        :listener,
      )

      def execute

        @argument_scanner ||= @entity._argument_scanner_
        @listener ||= @entity._listener_

        Home_::Normalization.call_by do |o|  # :#spot-1-6

          if @_did
            o.association_stream_newschool = remove_instance_variable :@__as  # [sn]
          else
            o.association_stream_newschool = __formal_attribute_stream
          end

          o.arguments_to_default_proc_by = method :__args_to_default_proc_by

          o.argument_scanner = @argument_scanner
          o.read_by = @entity.method :_read_
          o.write_by = @entity.method :_write_
          o.listener = @listener
        end
      end

      def __args_to_default_proc_by _k
        [ @entity, @listener ]  # (last element is the proc to use)
      end

      def __formal_attribute_stream

        _array = @entity._definition_
        _scn = Common_::Scanner.via_array _array

        _pg = Here__.properties_grammar_
        _qual_item_st = _pg.stream_via_scanner _scn

        _qual_item_st.map_by do |qual_item|
          :_parameter_FI_ == qual_item.injection_identifier || fail
          qual_item.item
        end
      end
    end

    # ==

    # ==

    define_singleton_method :properties_grammar_, ( Lazy_.call do

      _inj = Home_::CommonAssociation::EntityKillerParameter.grammatical_injection

      Home_.lib_.parse::IambicGrammar.define do |o|

        o.add_grammatical_injection :_parameter_FI_, _inj
      end
    end )

    # ==

    Here__ = self

    # ==
    # ==
  end
end
# #history-A - repurposed file from "stack" to "toolkit"
