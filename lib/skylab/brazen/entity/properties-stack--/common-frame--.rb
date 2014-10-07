module Skylab::Brazen

  module Entity

    module Properties_Stack__

      # ~ visiting
      class << self

        def common_frame * a
          if a.length.zero?
            self::Common_Frame__
          else
            self::Common_Frame__.via_arglist a
          end
        end
      end
      # ~

      # use its memoized and non-memoized procs and inline methods
      # like so:
      #
      #     class Foo
      #       Brazen_.properties_stack.common_frame self,
      #         :proc, :foo, -> do
      #            d = 0
      #            -> { d += 1 }
      #         end.call,
      #         :memoized, :proc, :bar, -> do
      #           d = 0
      #           -> { d += 1 }
      #         end.call,
      #         :inline_method, :bif, -> do
      #           "_#{ foo }_"
      #         end,
      #         :memoized, :inline_method, :baz, -> do
      #           "<#{ foo }>"
      #         end
      #     end
      #
      #     # one chunk #until:[#ts-032]
      #
      #     foo = Foo.new
      #     foo.foo  # => 1
      #     foo.foo  # => 2
      #     foo.bar  # => 1
      #     foo.bar  # => 1
      #     foo.bif  # => "_3_"
      #     foo.bif  # => "_4_"
      #     foo.baz  # => "<5>"
      #     foo.baz  # => "<5>"
      #     foo.baz.object_id  # => foo.baz.object_id


      Common_Frame__ = Entity[ -> do

        class << self  # "LIB" only (this node only)
          def call * a
            via_arglist a
          end
        end

        o :meta_property, :read_technique_i,

          :enum, [ :method, :inline_method, :proc, :reader, :no_reader ],

          :entity_class_hook, -> prop, cls do
            prop.write_to_reader cls
          end,

        :meta_property, :is_memoized,

        :meta_property, :external_read_proc

        property_class_for_write  # flush the above so we get the below

        class self::Property

          def initialize( * )
            @reader_p_a = @read_technique_i = nil
            super
          end

          def freeze
            if ! @read_technique_i  # e.g in conjunction w/ pure Entity extension
              @read_technique_i = :no_reader
            end
            execute
            @reader_p_a and @reader_p_a.freeze
            super
          end

          o do

            o :iambic_writer_method_name_suffix, :'='

            def memoized=
              @is_memoized = true
            end

            def method=
              @read_technique_i = :method
              @scanner.puts_with :property
            end

            def inline_method=
              name_i = iambic_property
              @literal_proc = iambic_property
              @read_technique_i = :inline_method
              @scanner.puts_with :property, name_i
            end

            def proc=
              name_i = iambic_property
              @literal_proc = iambic_property
              @read_technique_i = :proc
              @scanner.puts_with :property, name_i
            end
          end

          def execute
            send :"when_read_technique_is_#{ @read_technique_i }"
          end

          # ~ proc

          def when_read_technique_is_proc
            _METH_I_ = @name.as_variegated_symbol
            _MONADIC_P_ = if is_memoized
              Callback_.memoize @literal_proc
            else
              @literal_proc
            end
            reader_p_a.push( -> cls do
              cls.send :define_method, _METH_I_, _MONADIC_P_
            end )
            init_external_read_proc_to_use_eponymous_method
          end

          # ~ inline method

          def when_read_technique_is_inline_method
            if is_memoized
              when_read_technique_is_memoized_inline_method
            else
              when_read_technique_is_non_memoized_inline_method
            end
          end

          def when_read_technique_is_non_memoized_inline_method
            _METH_I_ = @name.as_variegated_symbol
            reader_p_a.push( -> cls do
              cls.send :define_method, _METH_I_, @literal_proc
            end )
            init_external_read_proc_to_use_eponymous_method
          end

          def when_read_technique_is_memoized_inline_method  # (was: [#062] "i just blue myself")
            _METH_I = :"__NON_MEMOIZED_#{ @name.as_variegated_symbol }"
            _METH_I_ = @name.as_variegated_symbol
            _IVAR = :"@use_memoized_#{ @name.as_variegated_symbol }"
            _IVAR_ = @name.as_ivar
            _METH_P = -> do
              if instance_variable_defined?( _IVAR ) and instance_variable_get( _IVAR )
                instance_variable_get _IVAR_
              else
                instance_variable_set _IVAR, true
                instance_variable_set _IVAR_, send( _METH_I )
              end
            end
            reader_p_a.push( -> cls do
              cls.send :define_method, _METH_I, @literal_proc
              cls.send :define_method, _METH_I_, _METH_P
            end )
            init_external_read_proc_to_use_eponymous_method
          end

          # ~ method

          def when_read_technique_is_method
            if is_memoized
              raise ::ArgumentError, say_no_memo_meth
            else
              init_external_read_proc_to_use_eponymous_method ; nil
            end
          end

          def say_no_memo_meth
            "pre-existing methods cannot be memoized - won't overwrite #{
             }original mehtod and won't allow original method and reader #{
              }proc to have different behavior."
          end

        # ~ support

          def write_to_reader cls
            if @reader_p_a
              cls.ignore_added_methods do
                @reader_p_a.each do |p|
                  p[ cls ]
                end
              end
            end ; nil
          end

        private

          def init_external_read_proc_to_use_eponymous_method
            _METH_I = @name.as_variegated_symbol
            @external_read_proc = -> entity do
              entity.__send__ _METH_I
            end ; nil
          end

          def reader_p_a
            @reader_p_a ||= []
          end
        end
      end ]

    # [ `required` ] `field`s -
    #
    # failing to provide a required field triggers an argument error
    #
    #     class Foo
    #       Brazen_.properties_stack.common_frame self,
    #         :globbing, :processor, :initialize,
    #         :required, :readable, :field, :foo,
    #         :readable, :field, :bar
    #     end
    #
    #     Foo.new  # => ArgumentError: missing required field - 'foo'
    #
    # passing nil is considered the same as not passing an argument
    #
    #     Foo.new( :foo, nil )  # => ArgumentError: missing required field - 'foo'
    #
    # passing false is not the same as passing nil, passing false is valid.
    #
    #     Foo.new( :foo, false ).foo  # => false
    #
    # you can of course pass nil as the value for a non-required field
    #
    #     Foo.new( :foo, :x, :bar, nil ).bar  # => nil
    #

      module Common_Frame__

        def property_value name_i
          prop = self.class.properties.fetch name_i
          p = prop.external_read_proc
          if p
            p[ self ]
          else
            property_value_when_prop_not_readable prop
          end
        end

      private

        def val_via_prop prop
          p = prop.external_read_proc
          if p
            p[ self ]
          else
            prop.internal_read_proc[ self ]
          end
        end

        def property_value_when_prop_not_readable prop
          _ev = build_not_OK_event_with :property_is_not_readable, :property, prop
          send_event _ev
        end

        def build_not_OK_event_with * x_a, & p
          x_a.push :ok, false
          p ||= Entity.event::Inferred_Message.to_proc
          Entity.event.inline_via_iambic_and_message_proc x_a, p
        end

        def send_event ev
          ev.render_all_lines_into_under y=[], Brazen_::API.expression_agent_instance
          _e_cls = if ev.has_tag :error_category
            _name = Callback_::Name.from_variegated_symbol ev.error_category
            ::Object.const_get _name.as_camelcase_const
          else
            ::RuntimeError
          end
          raise _e_cls, y * SPACE_
        end
      end

      module Common_Frame__

        Entity[ self, -> do

          o :meta_property, :parameter_arity,

            :enum, [ :zero_or_one, :one ],

            :default, :zero_or_one,

            :entity_class_hook, -> prop, cls do
              if :one == prop.parameter_arity
                cls.include When_Parameter_Arity_Of_One_Instance_Methods__  # might occur multiple times
              end
            end,

          :ad_hoc_processor, :globbing, -> scan do
            Processor__.via_scan scan
          end,

          :ad_hoc_processor, :processor, -> scan do
            Processor__.via_scan scan
          end,

          :ad_hoc_processor, :actoresque, -> scan do
            Actoresque__[ scan ]
          end

        end ]

        class self::Property

          o do

            o :iambic_writer_method_name_suffix, :'='

            def readable=
              @read_technique_i = :reader
            end

            def required=
              @parameter_arity = :one
            end

            def field=
              if @read_technique_i.nil?
                @read_technique_i = :no_reader
              end
              @scanner.puts_with :property
            end
          end

          attr_reader :internal_read_proc

          def is_required
            :one == @parameter_arity
          end

          def when_read_technique_is_reader
            _PROP_ = self
            _METH_P = -> do
              field_value_via_property _PROP_
            end
            _METH_I = @name.as_variegated_symbol
            reader_p_a.push( -> cls do
              cls.send :define_method, _METH_I, _METH_P
            end )
            init_external_read_proc_to_use_eponymous_method
          end

          def when_read_technique_is_no_reader
            @internal_read_proc = -> entity do
              entity.field_value_via_property self
            end ; nil
          end
        end

        def field_value_via_property prop
          if instance_variable_defined? prop.as_ivar
            instance_variable_get prop.as_ivar
          end
        end

      private

        def normalize_and_validate x
          x
        end

        module When_Parameter_Arity_Of_One_Instance_Methods__

          def normalize_and_validate x

            miss_prop_a = self.class.properties.reduce_by do |prop|
              prop.is_required or next
              val_via_prop( prop ).nil?
            end.to_a

            if miss_prop_a.length.zero?
              super
            else
              normalize_and_validate_when_missing_requireds miss_prop_a, x
            end
          end

          def normalize_and_validate_when_missing_requireds miss_prop_a, x
            _ev = build_not_OK_event_with :missing_required_properties,
                :error_category, :argument_error,
                :miss_a, miss_prop_a do |y, o|

              s_a = o.miss_a.map do |prop|
                par prop
              end

              1 == s_a.length or ( op, cp = %w[ ( ) ] )

              _x = "#{ op }#{ s_a * ', ' }#{ cp }"

              y << "missing required field#{ s s_a } - #{ _x }"
            end
            send_event _ev
          end
        end

        class Actoresque__

          Callback_::Actor[ self, :properties, :scan ]

          def execute

            @reader = @scan.reader

            @reader.send :define_singleton_method, :[] do | * x_a |
              new( x_a ).execute  # is `funcy_globless`
            end

            scanner = @scan.scanner
            scanner.advance_one
            scanner.puts_with :processor, :initialize

          end
        end

        class Processor__  # rewrite of [#mh-060]

          class << self

            def via_scan scan
              new( scan ).execute
            end
          end

          Entity[ self, -> do

            def globbing
              @is_globbing = true
            end

            def processor
              @is_complete = true
              @method_i = iambic_property
            end
          end ]

          include Entity.via_scanner_iambic_methods

          def initialize scan
            @reader = scan.reader
            @scanner = scan.scanner
            @is_complete = false
            @is_globbing = false
          end

          def execute
            process_iambic_passively
            if @is_complete
              via_reader_write
            else
              when_not_complete
            end
          end

          def when_not_complete
            raise ::ArgumentError, say_incomplete
          end

          def say_incomplete
            if unparsed_iambic_exists
              i = current_iambic_token
              if i.respond_to? :id2name
                context_s = " (near '#{ i }')"
              end
            end
            "'processor' term is incomplete#{ context_s }"
          end

          def via_reader_write
            if @is_globbing
              @reader.send :define_method, @method_i do |*x_a|
                @error_count ||= 0
                x = process_iambic_fully x_a
                if @error_count.zero?
                  x = normalize_and_validate x
                end
                x
              end
            else
              @reader.send :define_method, @method_i do |x_a|
                @error_count ||= 0
                x = process_iambic_fully x_a
                if @error_count.zero?
                  x = normalize_and_validate x
                end
                x
              end
            end
          end
        end
      end
    end
  end
end
