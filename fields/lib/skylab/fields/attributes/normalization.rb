module Skylab::Fields

  class Attributes

    class Normalization  # see [#012]

      Normalize_using_defaults_and_requireds = -> sess, & oes_p do

        attrs = sess.class::ATTRIBUTES
        if attrs
          o = self.begin( & oes_p )
          idx = attrs.index_
          sidx = idx.static_index_
          o.effectively_defaultants = sidx.effectively_defaultants
          o.ivar_store = sess
          o.lookup = idx.lookup_attribute_proc_
          o.requireds = sidx.requireds
          o.execute
        else
          ACHIEVED_
        end
      end

      class << self

        alias_method :begin, :new
        undef_method :new
      end  # >>

      def initialize & oes_p
        @_oes_p = oes_p  # can be nil
      end

      def ivar_store= ivar_store
        @store = Ivar_based_Store.new ivar_store
        ivar_store
      end

      def box_store= bx
        @store = Box_based_Store___.new bx
        bx
      end

      def use_empty_store
        @store = The_empty_store___[]
        NIL_
      end

      attr_accessor(
        :effectively_defaultants,
        :lookup,
        :requireds,
      )

      def execute

        _ok = check_for_missing_requireds
        _ok && ___apply_defaulting
      end

      def ___apply_defaulting  # near #spot-2. sometimes always, but maybe not.
        if @effectively_defaultants
          ___do_apply_defaulting
        else
          ACHIEVED_
        end
      end

      def ___do_apply_defaulting

        @effectively_defaultants.each do |k|

          atr = @lookup[ k ]

          if @store.knows atr
            was_defined = true
            x = @store.retrieve atr
          end

          if x.nil?
            p = atr.default_proc
            if p
              @store.set p[], atr
            elsif ! was_defined
              @store.set nil, atr
            end
          end
        end

        ACHIEVED_
      end

      def check_for_missing_requireds
        if @requireds
          ___do_check_for_missing_requireds
        else
          ACHIEVED_
        end
      end

      def ___do_check_for_missing_requireds

        miss_a = nil

        @requireds.each do |k|

          atr = @lookup[ k ]

          if @store.knows atr
            x = @store.retrieve atr
          end

          if x.nil?
            ( miss_a ||= [] ).push atr
          end
        end

        if miss_a
          ___when_missing_requireds miss_a
        else
          ACHIEVED_
        end
      end

      def ___when_missing_requireds miss_a

        build_event = -> do
          Home_::Events::Missing.via miss_a, 'attribute'
        end

        if @_oes_p
          @_oes_p.call :error, :missing_required_attributes do
            build_event[]
          end
          UNABLE_
        else
          _ev = build_event[]
          raise _ev.to_exception
        end
      end

      attr_reader(
        :store,
      )

      Get_parameter_controller_moniker = -> ent do  # legacy

        s_a = ent.class.name.split CONST_SEP_

        case 2 <=> s_a.length
        when -1  # long
          s_a = s_a[ -2 .. -1 ]
          has_two = true
        when 0
          has_two = true
        end

        if has_two
          if UNDERSCORE_ == s_a.first[ -1 ]  # assume Actors_::Foo
            s_a.shift
          else
            s_a.reverse!  # assume Noun::Verb -> 'verb noun'
          end
        end

        p = Common_::Name::Conversion_Functions::Pathify
        s_a.map do | s |
          p[ s ]
        end * SPACE_
      end

      class Box_based_Store___ < ::BasicObject

        def initialize bx
          @_box = bx
        end

        def knows atr
          @_box.has_name atr.name_symbol
        end

        def retrieve atr
          @_box.fetch atr.name_symbol
        end
      end

      The_empty_store___ = Lazy_.call do

        class The_Empty_Store____ < ::BasicObject
          def knows _
            false
          end
          new
        end
      end

      CONST_SEP_ = '::'
      UNDERSCORE_ = '_'
    end
  end
end
