module Skylab::BeautySalon

  module Models_::Text

    module Modalities::CLI

      Inject_and_deinject_associations = nil
      Inject_resources = nil
    end

    Actions.const_get :Wrap, false  # ..

    class Actions::Wrap
      Modalities = ::Module.new
    end

    module Actions::Wrap::Modalities::CLI

      Inject_and_deinject_associations = -> o do

        # ([gi] will do something similar)

        # take this association out of the UI. assign this value instead.
        k = :informational_downstream
        o.deinject_association k
        o.assign k do |rsx|
          rsx.stderr
        end

        # take this association out of the UI. assign this value instead.
        k = :output_bytestream
        o.deinject_association k
        o.assign k do |rsx|
          rsx.stdout
        end

        # basically add a bunch of stuff to a selfsame association
        k = :upstream
        o.deinject_association k
        o.inject_association_via_definition(
          :required,
          :property,
          k,
          :description, -> y do
            y << 'if `-`, non-interactive STDIN is expected'
          end,
          :normalize_by, -> qkn, & p do

            rsx = @invo_resources_  # :COVERPOINT2.2:[fi] (an experimental massive hack just for us)
            _stdin = rsx.stdin
            _fs = rsx.filesystem

            _kn = Home_.lib_.system_lib::Filesystem::Normalizations::Upstream_IO.via(

              :qualified_knownness_of_path, qkn,
              :stdin, _stdin,
              :recognize_common_string_patterns,
              :dash_means, :stdin,
              :filesystem, _fs,
              & p )

            _kn  # hi. #todo
          end,
        )
        NIL
      end

      Inject_resources = -> op, cli do
        cli.redefine do |o|
          o.expression_agent_by do
            Expag___[ op, cli ]
          end
        end
      end

      Expag___ = -> op, cli do  # copy-paste

        _class = ::Skylab::Zerk::CLI::InterfaceExpressionAgent::THE_LEGACY_CLASS

        if false
        _class.proc_based_by do |o|
          o.render_property_by do |asc, expag|
            "«#{ asc.name_symbol.id2name.gsub UNDERSCORE_, DASH_ }»"  # #guillemets
          end
        end
        end  # if false #todo

        _class.via_expression_agent_injection MyInjection___.new( op, cli )
      end

      class MyInjection___

        def initialize op, cli
          @operation = op
          @CLI = cli
        end

        def dereference_association sym
          @operation._associations_.fetch sym
        end

        def expression_strategy_for_property _asc
          :render_property_in_black_and_white_customly
        end

        def render_property_in_black_and_white_customly asc, expag
          "«#{ asc.name_symbol.id2name.gsub UNDERSCORE_, DASH_ }»"  # #guillemets
        end
      end

      # ==
      # ==
    end
  end
end
# #history-A.1: full rewrite during matryoshka wean
