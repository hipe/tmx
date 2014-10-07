module Skylab::SubTree

  class API::Actions::My_Tree

    class Leaf_  # #stowaway
      def initialize input_line
        @subcel_a = nil
        @input_line = input_line
      end
      attr_reader :input_line

      def add_subcel str
        ( @subcel_a ||= [ ] ) << str
        nil
      end

      def any_free_cel
        if @subcel_a
          @subcel_a * SPACE_
        end
      end

      def add_attribute i, x
        (( @attribute_box ||= Lib_::Box[] )).add i, x
        nil
      end
      attr_reader :attribute_box
    end

    class Extensions_

      SubTree_::Lib_::Basic_fields[ :client, self,
        :globbing, :absorber, :initialize,
        :field_i_a, [ :arg_box, :infostream, :verbose ]]

      def is_valid_and_valid_self
        begin
          ok = load_extensions or break
        end while nil
        ok and [ ok, self ]
      end

      def has_post_notifiees
        !! post_notifiee_i_a
      end

      def any_in_notify_notify leaf
        @in_notifiee_i_a and @in_notifiee_i_a.each do |i|
          @box.fetch( i ).in_notify leaf
        end
        nil
      end

      def post_notify_notify row_a
        @post_notifiee_i_a.each do |i|
          @box.fetch( i ).post_notify row_a
        end
        nil
      end

    private

      def load_extensions
        box = @box = @arg_box ; @arg_box = nil ; _h = box._h
        @in_notifiee_i_a = nil
        box.to_a.each do |i, bf|
          val = bf.value
          x_a = [ :local_normal_name, i, :infostream, @infostream,
                :verbose, @verbose  ]
          true == val or x_a << :arg_value << val  # only when interesting
          _name = Name_.from_variegated_symbol :"#{ i }_"
          _class = self.class.const_get _name.as_const, false
          ag = _class.new x_a
          index_notifiee ag
          _h[ i ] = ag
        end
        true
      end

      def index_notifiee ag
        ( if ag.is_post_notifiee then @post_notifiee_i_a ||= [ ]
          else @in_notifiee_i_a ||= [ ] end ) << ag.local_normal_name
        nil
      end
    public
      attr_reader :in_notifiee_i_a, :post_notifiee_i_a
    end
  end
end
