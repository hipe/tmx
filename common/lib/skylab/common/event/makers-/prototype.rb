module Skylab::Common

    class Event

      class Makers_::Prototype < self  # :[#012].

        class << self

          def prototype_with * i_a, & msg_p

            o = Session__.new
            o.deflist = i_a
            o.message_proc = msg_p
            o.base_class = self
            o.execute
          end

          def via_deflist_and_message_proc i_a, p

            o = Session__.new
            o.deflist = i_a
            o.message_proc = p
            o.execute
          end
        end  # >>

        class Session__

          def initialize
            @base_class = nil
          end

          attr_writer(
            :base_class,
            :deflist,
            :message_proc,
          )

          def execute
            validate
            work
          end

          def validate
            len = @deflist.length
            1 == len % 2 or raise ::ArgumentError, say_odd_number
          end

          def say_odd_number
            "#{ @deflist.length } for odd number for deflist (#{ syntax_s })"
          end

          def syntax_s
            "<term_chan> [, <name>, <val> [..]]"
          end

          def work

            st = Home_::Polymorphic_Stream.via_array @deflist

            _base_class = @base_class || Here___

            cls = ::Class.new _base_class

            msg_p = @message_proc

            cls.class_exec do

              extend Module_Methods__

              const_set :TERMINAL_CHANNEL_SYMBOL___, st.gets_one

              Process_messge_proc___[ msg_p, self ]

              Process_property_box___[ st, self ]

              self
            end
          end
        end

        Process_messge_proc___ = -> msg_p, cls do

          if msg_p

            cls.send :define_method, :message_proc do
              msg_p
            end

          end ; nil
        end

        Process_property_box___ = -> st, cls do

          _BOX_ = nil

          build_new_property = Prop__.method :new

          see_new_property = ( cls.class_exec do

            # (when we tried (send ...) for below we got weird warnings about
            # issues with private attr reader :[#sli]:IWR:3

            -> prp do
              attr_reader prp.name_symbol
            end
          end )

          if cls.respond_to? :properties  # modify a dup of an existing prop box

            _BOX_ = cls.properties.dup

            for_property = -> k, v do

              _BOX_.add_or_replace( k,
                -> do
                  prp = build_new_property[ k, v ]
                  see_new_property[ prp ]
                  prp
                end,
                -> _ do
                  build_new_property[ k, v ]
                end,
              )
            end
          else  # build the first ever property box in the chain

            _BOX_ = Home_::Box.new

            for_property = -> k, v do

              prp = build_new_property[ k, v ]
              see_new_property[ prp ]
              _BOX_.add prp.name_symbol, prp
              NIL_
            end
          end

          while st.unparsed_exists

            for_property[ st.gets_one, st.gets_one ]
          end

          _BOX_.freeze

          cls.class_exec do
            define_singleton_method :properties do _BOX_ end  # [ta]
            define_method :formal_properties do _BOX_ end
          end

          NIL_
        end

        class Prop__
          def initialize i, x
            @name_symbol = i
            @name_as_ivar = :"@#{ i }"
            @default_value = x
            freeze
          end
          attr_reader :name_symbol, :name_as_ivar, :default_value
        end

        module Module_Methods__

          def [] * x_a
            construct do
              init_via_value_list x_a
              freeze
            end
          end

          def new_mutable * x_a
            construct do
              init_via_value_list x_a
            end
          end

          def call_via_arglist a
            construct do
              init_via_value_list a
              freeze
            end
          end

          def new_with * x_a
            construct do
              process_iambic_fully x_a
              freeze
            end
          end

          # (subscriptions to a non-globbed from of above: :[#]:#A.)

          def inline_with__EXPERIMENTAL__ * x_a
            construct do
              __hack_a_different_term_chan_sym x_a
              freeze
            end
          end

          def new_via_each_pairable bx
            construct do
              __init_via_each_pairable bx
              freeze
            end
          end
        end  # end module methds

        # ~ instance methods of event class

        def terminal_channel_i
          self.class::TERMINAL_CHANNEL_SYMBOL___
        end

        def replace_some_values * value_a
          value_a.each_with_index do |x, d|
            instance_variable_set ivar_box.at_position( d ), x
          end ; nil
        end

      private

        def init_via_value_list x_a  # caller should freeze
          bx = formal_properties
          x_a.length.times do |d|
            instance_variable_set bx.at_position( d ).name_as_ivar, x_a.fetch( d )
          end
          x_a.length.upto( bx.length - 1 ) do |d|
            prop = bx.at_position d
            instance_variable_set prop.name_as_ivar, prop.default_value
          end
          NIL_
        end

        def __init_via_each_pairable bx
          fbox = formal_properties
          bx.each_pair do | k, v |
            _prp = fbox.fetch k
            instance_variable_set _prp.name_as_ivar, v
          end
          NIL_
        end

        def have * x_a
          _ok = process_iambic_fully x_a
          _ok && freeze
        end

        def process_iambic_fully x_a  # caller should freeze

          # (a custom amalgamation of the commonest two idioms: if it
          #  has a formal property, set the ivar; else call a custom
          #  iambic parsing method. also nil-out any not-set values.)

          _write_members Home_::Polymorphic_Stream.via_array x_a
        end

        def __hack_a_different_term_chan_sym x_a

          st = Home_::Polymorphic_Stream.via_array x_a
          _CUSTOM_TERM_CHAN_SYM = st.gets_one
          _write_members st
          define_singleton_method :terminal_channel_i do
            _CUSTOM_TERM_CHAN_SYM
          end
        end

        def _write_members st  # caller should freeeze

          bx = formal_properties
          ok = true

          at_end = EMPTY_P_
          did = false
          once = -> do
            did = true
            at_end = -> do
              remove_instance_variable :@_polymorphic_upstream_
            end
            @_polymorphic_upstream_ = st
            NIL_
          end

          seen_h = {}

          while st.unparsed_exists

            sym = st.gets_one

            seen_h[ sym ] = true

            prp = bx[ sym ]

            if prp
              instance_variable_set prp.name_as_ivar, st.gets_one
              next
            end

            did || once[]

            ok = send :"#{ sym }="
            ok or break

          end

          at_end[]

          if ok
            __init_defaults seen_h
          end

          ok or raise ::ArgumentError  # until this is universally normalized
        end

        def __init_defaults seen_h

          formal_properties.each_value do | prp |

            seen_h[ prp.name_symbol ] and next

            ivar = prp.name_as_ivar

            x = if instance_variable_defined? ivar
              instance_variable_get ivar
            end

            if x.nil?
              instance_variable_set ivar, prp.default_value
            end
          end
          NIL_
        end

        def gets_one_polymorphic_value  # :+#cp
          @_polymorphic_upstream_.gets_one
        end

      protected

        def init_copy_via_iambic_and_message_proc_ x_a, p

          bx = ivar_box

          x_a.each_slice 2 do | i, x |
            instance_variable_set bx.fetch( i ), x
          end

          if p  # or whtever
            define_singleton_method :message_proc do
              p
            end
          end

          self
        end

      private

        def ivar_box
          self.class.ivar_bx
        end

        class << self
          def ivar_bx
            @ivar_bx ||= bld_ivar_bx
          end
        private
          def bld_ivar_bx
            bx = Home_::Box.new
            properties.each_pair do |i, prop|
              bx.add i, prop.name_as_ivar
            end
            bx.freeze
          end
        end

        Here___ = self
      end
    end
end
