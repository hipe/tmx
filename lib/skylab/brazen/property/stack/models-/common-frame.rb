module Skylab::Brazen

  class Property::Stack

      # enhance a class as a `common_frame`
      # you can define [non-]memoized { proc | inline } methods
      #
      #     class Foo
      #       Brazen_::Property::Stack.common_frame self,
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
      #     foo = Foo.new { }
      #
      #
      # accessing a field's value when it is an ordinary proc
      #
      #     foo.foo  # => 1
      #     foo.foo  # => 2
      #
      #
      # accessing a field's value when it is a memoized proc
      #
      #     foo.bar  # => 1
      #     foo.bar  # => 1
      #
      #
      # accessing a field's value when it is an "inline method"
      #
      #     foo.bif  # => "_3_"
      #     foo.bif  # => "_4_"
      #
      #
      # accessing a field's value when it is a memoized inline method
      #
      #     foo.baz  # => "<5>"
      #     foo.baz  # => "<5>"
      #     foo.baz.object_id  # => foo.baz.object_id

      Models_::Common_Frame = Brazen_::Entity.call do

        # (really we want the below thing to be its own nonterminal mixed
        # in with the other nonterminals of the session, but we don't have
        # an API for that yet..)

        o(
          :ad_hoc_processor, :globbing, -> sess do
            sess.upstream.backtrack_one
            Pstack_::Actors_::Define_process_method[ sess ]
          end,

          :ad_hoc_processor, :processor, -> sess do
            sess.upstream.backtrack_one
            Pstack_::Actors_::Define_process_method[ sess ]
          end
        )
      end

      module Models_::Common_Frame

        class << self

          def call_via_arglist x_a

            st = Callback_::Polymorphic_Stream.via_array x_a

            cls = st.gets_one

            cls.class_exec do

              define_singleton_method :receive_entity_property, RP_METH___

              define_method :normalize, NORMALIZE_METH___

              define_method :receive_missing_required_properties_array,
                RMRP_METH___
            end

            Entity::Edit_client_class_via_polymorphic_stream_over_extmod[
              cls, st, self ]

            NIL_
          end
        end  # >>

        self::Property = ::Class.new Brazen_::Entity::Property

        RP_METH___ = -> prp do

          p_a = prp._against_EC_p_a

          if p_a
            kp = true
            p_a.each do | p |
              kp = class_exec prp, & p
              kp or break
            end
            kp
          else
            KEEP_PARSING_
          end
        end

        def any_all_names
          all_names
        end

        def members  # :+[#br-061]
          all_names
        end

        def all_names
          self.class.properties.get_names
        end

        def any_proprietor_of i
          if self.class.properties.has_name i
            self
          end
        end

        def property_value_via_symbol name_i

          prp = self.class.properties.fetch name_i

          p = prp.external_read_proc
          if p
            p[ self, prp ]
          else
            __property_value_when_property_not_readable prp
          end
        end

        def __property_value_when_property_not_readable prp

          maybe_send_event :error, :property_is_not_readable do

            Callback_::Event.inline_not_OK_with(
              :property_is_not_readable,
              :property, prp,
              :error_category, :name_error )
          end
        end

        define_method :knownness_via_property_, KNOWNNESS_VIA_IVAR_METHOD_

        def _set_value_of_property x, prp
          instance_variable_set prp.as_ivar, x
          ACHIEVED_
        end

        def maybe_send_event *, & ev_p  # here for now..
          raise ev_p[].to_exception
        end

        class Property

          def initialize
            @is_memoized = false
            @reader_classification = nil
            super
          end

        private

          def field=
            if @reader_classification.nil?
              @reader_classification = :no_reader
            end
            _read_name
          end

          def inline_method=
            @reader_classification = :inline_method
            _read_name
            @literal_proc = gets_one_polymorphic_value
            STOP_PARSING_
          end

          def memoized=
            @is_memoized = true
            KEEP_PARSING_
          end

          def method=
            @reader_classification = :method
            _read_name
          end

          def proc=
            @reader_classification = :proc
            _read_name
            @literal_proc = gets_one_polymorphic_value
            STOP_PARSING_
          end

          def readable=
            @reader_classification = :reader
            KEEP_PARSING_
          end

          def _read_name
            @name = Callback_::Name.via_variegated_symbol gets_one_polymorphic_value
            STOP_PARSING_
          end

          def required=

            @parameter_arity = :one

            @___did_add_required_check ||= __add_required_check
            KEEP_PARSING_
          end

          def __add_required_check

            _during_apply do

              if const_defined? NORM_BOX__
                nb = const_get NORM_BOX__
                if ! const_defined? NORM_BOX__, false
                  const_set NORM_BOX__, nb.dup
                end
              else
                nb = Callback_::Box.new
                const_set NORM_BOX__, nb
              end

              nb.touch :__check_for_missing_requireds__ do
                Check_for_missing_requireds___
              end

              KEEP_PARSING_
            end
            KEEP_PARSING_
          end

          def normalize_property
            if @reader_classification
              _ok = READER_TECHNIQUE__.fetch( @reader_classification )[ self ]
              _ok and super
            else
              super
            end
          end

        public  # ~ internal

          attr_reader :_against_EC_p_a

          def _during_apply & p
            ( @_against_EC_p_a ||= [] ).push p ; nil
          end

          def __set_argument_arity x
            @argument_arity = x ; nil
          end

          attr_reader :external_read_proc

          def __external_read & p
            @external_read_proc = p ; nil
          end

          def __set_polymorphic_writer_method_proc_is_generated x

            @has_custom_polymorphic_writer_method = ! x
            NIL_
          end

          def __set_internal_read_proc & p
            @internal_read_proc = p ; nil
          end

          attr_reader :internal_read_proc

          attr_reader :is_memoized

          attr_reader :literal_proc

          attr_reader :reader_classification

        end  # end of the properry class


    # [ `required` ] `field`s -
    #
    #     class Bar
    #       Brazen_:Property::Stack.common_frame self,
    #         :globbing, :processor, :initialize,
    #         :required, :readable, :field, :foo,
    #         :readable, :field, :bar
    #     end
    #
    #
    # failing to provide a required field triggers an argument error
    #
    #     Bar.new  # => ArgumentError: missing required field - 'foo'
    #
    #
    # passing nil is considered the same as not passing an argument
    #
    #     Bar.new( :foo, nil )  # => ArgumentError: missing required field - 'foo'
    #
    #
    # passing false is not the same as passing nil, passing false is valid.
    #
    #     Bar.new( :foo, false ).foo  # => false
    #
    #
    # you can of course pass nil as the value for a non-required field
    #
    #     Bar.new( :foo, :x, :bar, nil ).bar  # => nil
    #

        READER_TECHNIQUE__ = {}

        # ~ inline method

        module Read_via_Inline_Method__

          READER_TECHNIQUE__[ :inline_method ] = self

          class << self

            def [] prp
              Edit_property_common__[ prp ]
              if prp.is_memoized
                when_memoized prp
              else
                when_not_memoized prp
              end
            end

            def when_not_memoized prp

              Read_via_Method_.write_external_read_proc prp

              prp._during_apply do | prp_ |

                define_method prp_.name_symbol, prp_.literal_proc
                KEEP_PARSING_
              end

              ACHIEVED_
            end

            def when_memoized prp  # (was: [#062] "i just blue myself")
              _METH_I_ = prp.name_symbol
              _METHOD_NAME = :"__NON_MEMOIZED_#{ _METH_I_ }"
              _IVAR = :"@use_memoized_#{ _METH_I_  }"
              _IVAR_ = prp.as_ivar
              _METH_P = -> do
                if instance_variable_defined?( _IVAR ) and instance_variable_get( _IVAR )
                  instance_variable_get _IVAR_
                else
                  instance_variable_set _IVAR, true
                  instance_variable_set _IVAR_, send( _METHOD_NAME )
                end
              end
              prp._during_apply do | prp_ |

                define_method _METHOD_NAME, prp_.literal_proc

                define_method _METH_I_, _METH_P

                KEEP_PARSING_
              end
              Read_via_Method_.write_external_read_proc prp
            end
          end
        end

        # ~ method

        module Read_via_Method_

          READER_TECHNIQUE__[ :method ] = self

          class << self

            def [] prp
              Edit_property_common__[ prp ]
              if prp.is_memoized
                raise ::ArgumentError, __say_no_memo_meth
              else
                write_external_read_proc prp
                ACHIEVED_
              end
            end

            def __say_no_memo_meth
              "pre-existing methods cannot be memoized - won't overwrite #{
               }original method and won't allow original method and reader #{
                }proc to have different behavior."
            end

            def write_external_read_proc prp

              _READ_METHOD_NAME = prp.name_symbol

              prp.__external_read do | entity |

                entity.__send__ _READ_METHOD_NAME
              end

              ACHIEVED_
            end
          end
        end

        # ~ proc

        READER_TECHNIQUE__[ :proc ] = -> _PROP do

          Edit_property_common__[ _PROP ]

          _MONADIC_P_ = if _PROP.is_memoized
            Callback_.memoize( & _PROP.literal_proc )
          else
            _PROP.literal_proc
          end

          _PROP._during_apply do
            define_method _PROP.name_symbol, _MONADIC_P_
            KEEP_PARSING_
          end

          Read_via_Method_.write_external_read_proc _PROP
        end

        # ~ [no] reader

        READER_TECHNIQUE__[ :reader ] = -> prp do

          Edit_property_common__[ prp ]

          _WRITER_METHOD_NAME = prp.conventional_polymorphic_writer_method_name

          prp._during_apply do | prp_ |

            define_method prp_.name_symbol do

              kn = self.knownness_via_property_ prp_

              if kn.is_known
                kn.value_x
              end
            end

            define_method _WRITER_METHOD_NAME do
              _set_value_of_property gets_one_polymorphic_value, prp_
            end

            KEEP_PARSING_
          end

          prp.set_polymorphic_writer_method_name _WRITER_METHOD_NAME

          Read_via_Method_.write_external_read_proc prp
        end

        READER_TECHNIQUE__[ :no_reader ] = -> prp do

          Edit_property_common__[ prp ]

          prp.__set_internal_read_proc do | entity, prp_ |

            kn = entity.knownness_via_property_ prp

            if kn.is_known
              known.value_x
            end
          end

          _WRITER_METHOD_NAME = prp.conventional_polymorphic_writer_method_name

          prp._during_apply do | prp_ |

            define_method _WRITER_METHOD_NAME do
              _set_value_of_property gets_one_polymorphic_value, prp_
            end
          end

          prp.set_polymorphic_writer_method_name _WRITER_METHOD_NAME

          KEEP_PARSING_
        end

        # ~ support

        Edit_property_common__ = -> prp do

          prp.__set_argument_arity :_not_applicable_
          prp.__set_polymorphic_writer_method_proc_is_generated false

          NIL_
        end

        NORMALIZE_METH___ = -> do

          cls = self.class
          if cls.const_defined? NORM_BOX__
            nb = cls.const_get NORM_BOX__
          end

          kp = true
          if nb
            nb.each_value do | p |
              kp = p[ self ]
              kp or break
            end
          end
          kp
        end

        NORM_BOX__ = :NORM_BOX___

        Check_for_missing_requireds___ = -> entity do  # near [#087]

          miss_a = nil

          entity.class.properties.each_value do | prp |

            prp.is_required or next

            kn = entity.knownness_via_property_ prp

            __is_unknown = if kn.is_known
              kn.value_x.nil?
            else
              true
            end

            if __is_unknown
              ( miss_a ||= [] ).push prp
            end
          end

          if miss_a
            entity.receive_missing_required_properties_array miss_a
          else
            KEEP_PARSING_
          end
        end

        RMRP_METH___ = -> miss_a do  # `receive_missing_required_properties_array` etc

          _ev = Build_missing_requireds_event___[ miss_a ]
          raise _ev.to_exception
          # maybe_send_event # :error, :missing_required_properties do
        end

        Build_missing_requireds_event___ = -> miss_prp_a do

          Callback_::Event.inline_not_OK_with(

            :missing_required_properties,
            :error_category, :argument_error,
            :miss_a, miss_prp_a

          ) do | y, o |

            s_a = o.miss_a.map do |prp|
              par prp
            end

            1 == s_a.length or ( op, cp = %w[ ( ) ] )

            _x = "#{ op }#{ s_a * ', ' }#{ cp }"

            y << "missing required field#{ s s_a } - #{ _x }"
          end
        end

        REQUIRED_PROP_METHOD__ = -> do
          @reqd_prop_a ||= properties.reduce_by( & :is_required ).to_a.freeze
        end

        CF_ = self
      end

      # <-
  end
end
