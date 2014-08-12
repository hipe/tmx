module Skylab::Callback

    class Ordered_Dictionary  # read [#037]

      class << self

        alias_method :orig_new, :new

        def new * i_a
          i_a.freeze
          ::Class.new( self ).class_exec do
            class << self
              alias_method :new, :orig_new
            end
            _BOX_ = Box__[].new
            define_method :ordered_dictionary do
              _BOX_
            end
            i_a.each do |i|
              slot = Callback_Slot__.new i

              _BOX_.add i, slot

              attr_reader slot.attr_reader

              ivar = slot.ivar
              define_method :"receive_#{ i }_event" do |ev|  # [#039]
                p = instance_variable_get ivar
                p && p[ ev ]
              end
            end
            self
          end
        end
      end

      def initialize * p_a
        box = ordered_dictionary
        p_a.each_with_index do |p, d|
          instance_variable_set box.at_position( d ).ivar, p
        end
        ( p_a.length ... box.length ).each do |d|
          instance_variable_set box.at_position( d ).ivar, nil
        end ; nil
      end

      class Callback_Slot__
        def initialize i
          @attr_reader = :"#{ i }_p"
          @ivar = :"@#{ @attr_reader }"
        end
        attr_reader :attr_reader, :ivar
      end

      include( module Dictionary_Instance_Methods__
        def merge_in_other_listener_intersect lstn
          my_box = ordered_dictionary
          lstn.ordered_dictionary.each_pair do |i, cb_slot|
            my_box.has_name i or next
            p = lstn.send cb_slot.attr_reader
            p or next
            instance_variable_set cb_slot.ivar, p
          end ; nil
        end
        self
      end )

      Box__ = -> do
        Callback_::Lib_::Entity[].box
      end

      # ~

      class << self
        def inline * x_a
          inline_via_iambic x_a
        end

        def inline_via_iambic x_a
          Inline__.new x_a
        end
      end

      class Inline__

        include Dictionary_Instance_Methods__

        attr_reader :ordered_dictionary

        def initialize x_a
          sc = singleton_class
          d = -2 ; last = x_a.length - 2
          box = Box__[].new
          while d < last
            d += 2
            i = x_a.fetch d
            slot = Callback_Slot__.new i
            box.add i, slot
            sc.send :attr_reader, slot.attr_reader
            instance_variable_set slot.ivar, x_a.fetch( d + 1 )
            -> ivar do
              define_singleton_method :"receive_#{ i }_event" do |*a|
                instance_variable_get( ivar )[ *a ]
              end
            end[ slot.ivar ]
          end
          @ordered_dictionary = box ; nil
        end
      end
    end
end
