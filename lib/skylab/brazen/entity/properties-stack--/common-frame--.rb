module Skylab::Brazen

  module Entity

    class Properties_Stack__

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
      #     foo = Foo.new {}
      #     foo.foo  # => 1
      #     foo.foo  # => 2
      #     foo.bar  # => 1
      #     foo.bar  # => 1
      #     foo.bif  # => "_3_"
      #     foo.bif  # => "_4_"
      #     foo.baz  # => "<5>"
      #     foo.baz  # => "<5>"
      #     foo.baz.object_id  # => foo.baz.object_id


      Common_Frame__ = Entity_.call do

        class << self

          def via_arglist x_a
            st = Callback_::Iambic_Stream_.new 0, x_a
            client_cls = st.gets_one
            self[ client_cls ]
            client_cls.entity_edit_sess do |sess|
              sess.receive_edit st  # on success result is client class
            end  # result is same
            nil
          end
        end

        o :ad_hoc_processor, :globbing, -> pc do
            Properties_Stack__::Define_process_method_.new( pc ).execute
          end,

          :ad_hoc_processor, :processor, -> pc do
            Properties_Stack__::Define_process_method_.new( pc ).execute
          end

        entity_property_class_for_write

      end  # end the edit sesson of the extension module

      module Common_Frame__  # open it with lexical scope and no edit session

        def any_all_names
          all_names
        end

        def members  # :+[#br-061]
          all_names
        end

        def all_names
          self.class.entity_formal_property_method_names_box_for_rd.get_names
        end

        def any_proprietor_of i
          if self.class.entity_formal_property_method_names_box_for_rd.has_name i
            self
          end
        end

        def property_value_via_symbol name_i
          prop = self.class.property_via_symbol name_i
          p = prop.external_read_proc
          if p
            p[ self, prop ]
          else
            prp_val_when_property_not_readable prop
          end
        end

      private

        def prp_val_when_property_not_readable prop
          maybe_send_event :error, :property_is_not_readable do
            build_not_OK_event_with :property_is_not_readable, :property, prop
          end
        end

        def set_val_of_property x, prop
          instance_variable_set prop.as_ivar, x
          ACHIEVED_
        end

        def maybe_send_event *, & ev_p  # here for now..
          raise ev_p[].to_exception
        end

        class Entity_Property

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
            read_name
          end

          def inline_method=
            @reader_classification = :inline_method
            read_name
            @literal_proc = iambic_property
            STOP_PARSING_
          end

          def memoized=
            @is_memoized = true
            KEEP_PARSING_
          end

          def method=
            @reader_classification = :method
            read_name
          end

          def proc=
            @reader_classification = :proc
            read_name
            @literal_proc = iambic_property
            STOP_PARSING_
          end

          def readable=
            @reader_classification = :reader
            KEEP_PARSING_
          end

          def read_name
            @name = Callback_::Name.via_variegated_symbol iambic_property
            STOP_PARSING_
          end

          def required=
            @parameter_arity = :one
            @did_hack_for_required_check ||= begin
              during_apply do
                include When_Parameter_Arity_Of_One_Instance_Methods__
                p_a = normz_for_wrt
                p = Missing_required_check_do_this_once__
                if ! p_a.include? p
                  define_singleton_method :reqrd_prop_a, REQUIRED_PROP_METHOD__
                  p_a.push p
                end
                KEEP_PARSING_
              end
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

          attr_reader :against_EC_p_a  # #hook-over

          def during_apply & p
            ( @against_EC_p_a ||= [] ).push p ; nil
          end

          def set_argument_arity x
            @argument_arity = x ; nil
          end

          attr_reader :external_read_proc

          def external_read & p
            @external_read_proc = p ; nil
          end

          def set_iambic_writer_method_name x
            @iwmn = x ; nil
          end

          def set_iambic_writer_method_proc_is_generated x
            @iambic_writer_method_proc_is_generated = x ; nil
          end

          def set_iambic_writer_method_proc_proc x
            @iambic_writer_method_proc_proc = x ; nil
          end

          def set_internal_read_proc & p
            @internal_read_proc = p ; nil
          end

          attr_reader :internal_read_proc

          attr_reader :is_memoized

          attr_reader :literal_proc

          attr_reader :reader_classification

        end  # end of the properry class


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

        Common_Methods__ = ::Module.new

        READER_TECHNIQUE__ = {}

        # ~ inline method

        module Read_via_Inline_Method__ extend Common_Methods__

          READER_TECHNIQUE__[ :inline_method ] = self

          class << self

            def [] prop
              common_setup prop
              if prop.is_memoized
                when_memoized prop
              else
                when_not_memoized prop
              end
            end

            def when_not_memoized prop
              Read_via_Method_.write_external_read_proc prop
              prop.during_apply do | prop_ |
                @active_entity_edit_session.while_ignoring_method_added do
                  define_method prop_.name_i, prop_.literal_proc ; nil
                end
                ACHIEVED_
              end
              ACHIEVED_
            end

            def when_memoized prop  # (was: [#062] "i just blue myself")
              _METH_I_ = prop.name_i
              _METHOD_NAME = :"__NON_MEMOIZED_#{ _METH_I_ }"
              _IVAR = :"@use_memoized_#{ _METH_I_  }"
              _IVAR_ = prop.as_ivar
              _METH_P = -> do
                if instance_variable_defined?( _IVAR ) and instance_variable_get( _IVAR )
                  instance_variable_get _IVAR_
                else
                  instance_variable_set _IVAR, true
                  instance_variable_set _IVAR_, send( _METHOD_NAME )
                end
              end
              prop.during_apply do | prop_ |
                @active_entity_edit_session.while_ignoring_method_added do
                  define_method _METHOD_NAME, prop_.literal_proc
                  define_method _METH_I_, _METH_P
                end
                ACHIEVED_
              end
              Read_via_Method_.write_external_read_proc prop
            end
          end
        end

        # ~ method

        module Read_via_Method_ extend Common_Methods__

          READER_TECHNIQUE__[ :method ] = self

          class << self

            def [] prop
              common_setup prop
              if prop.is_memoized
                raise ::ArgumentError, say_no_memo_meth
              else
                write_external_read_proc prop
                ACHIEVED_
              end
            end

            def say_no_memo_meth
              "pre-existing methods cannot be memoized - won't overwrite #{
               }original mehtod and won't allow original method and reader #{
                }proc to have different behavior."
            end

            def write_external_read_proc prop
              _READ_METHOD_NAME = prop.name_i
              prop.external_read do | entity |
                entity.__send__ _READ_METHOD_NAME
              end
              ACHIEVED_
            end
          end
        end

        # ~ proc

        READER_TECHNIQUE__[ :proc ] = -> _PROP do

          COMMON_SETUP_[ _PROP ]

          _MONADIC_P_ = if _PROP.is_memoized
            Callback_.memoize _PROP.literal_proc
          else
            _PROP.literal_proc
          end

          _PROP.during_apply do
            @active_entity_edit_session.while_ignoring_method_added do
              define_method _PROP.name_i, _MONADIC_P_
            end
            ACHIEVED_
          end

          Read_via_Method_.write_external_read_proc _PROP
        end

        # ~ [no] reader

        READER_TECHNIQUE__[ :reader ] = -> prop do

          COMMON_SETUP_[ prop ]

          _WRITER_METHOD_NAME = prop.via_name_build_internal_iambic_writer_meth_nm

          prop.during_apply do | prop_ |

            @active_entity_edit_session.while_ignoring_method_added do

              define_method prop_.name_i do
                any_property_value_via_property prop_
              end

              define_method _WRITER_METHOD_NAME do
                set_val_of_property iambic_property, prop_
              end

            end
            ACHIEVED_
          end

          prop.set_iambic_writer_method_name _WRITER_METHOD_NAME

          Read_via_Method_.write_external_read_proc prop
        end

        READER_TECHNIQUE__[ :no_reader ] = -> prop do
          COMMON_SETUP_[ prop ]
          prop.set_internal_read_proc do | entity, prop_ |
            entity.any_property_value_via_property prop_
          end

          _WRITER_METHOD_NAME = prop.via_name_build_internal_iambic_writer_meth_nm

          prop.during_apply do | prop_ |

            @active_entity_edit_session.while_ignoring_method_added do

              define_method _WRITER_METHOD_NAME do
                set_val_of_property iambic_property, prop_
              end
            end
          end

          prop.set_iambic_writer_method_name _WRITER_METHOD_NAME

          ACHIEVED_
        end

        # ~ support

        COMMON_SETUP_ = -> prop do
          prop.set_argument_arity :_not_applicable_
          prop.set_iambic_writer_method_proc_is_generated false
          prop.set_iambic_writer_method_proc_proc nil
          nil
        end

        module Common_Methods__
          define_method :common_setup, COMMON_SETUP_
        end

        Missing_required_check_do_this_once__ = -> entity do
          _prop_a = entity.class.reqrd_prop_a
          miss_a = _prop_a.reduce nil do | m, prop |
            x = entity.val_via_prop prop
            if x.nil?
              ( m ||= [] ).push prop
            end
            m
          end
          if miss_a
            entity.receive_missing_required_props miss_a
          else
            KEEP_PARSING_
          end
        end

        REQUIRED_PROP_METHOD__ = -> do
          @reqd_prop_a ||= properties.reduce_by( & :is_required ).to_a.freeze
        end

        module When_Parameter_Arity_Of_One_Instance_Methods__

          def val_via_prop prop
            p = prop.external_read_proc
            if p
              p[ self, prop ]
            else
              prop.internal_read_proc[ self, prop ]
            end
          end

          def receive_missing_required_props miss_prop_a
            maybe_send_event :error, :missing_required_properties do
              bld_missing_required_properties_event miss_prop_a
            end
          end

        private

          def bld_missing_required_properties_event miss_prop_a
            build_not_OK_event_with :missing_required_properties,
                :error_category, :argument_error,
                :miss_a, miss_prop_a do |y, o|

              s_a = o.miss_a.map do |prop|
                par prop
              end

              1 == s_a.length or ( op, cp = %w[ ( ) ] )

              _x = "#{ op }#{ s_a * ', ' }#{ cp }"

              y << "missing required field#{ s s_a } - #{ _x }"
            end
          end

          def build_not_OK_event_with * i_a, & msg_p
            Entity_.event.inline_not_OK_via_mutable_iambic_and_message_proc i_a, msg_p
          end
        end
      end
    end
  end
end
