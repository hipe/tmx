module Skylab::TestSupport

  module Regret

    module Anchor_ModuleMethods

      def tmpdir
        @tmpdir ||= bld_tmpdir
      end

      def bld_tmpdir
        TestSupport_::Lib_::Tmpdir[].new(
          :path, tmpdir_pathname,
          :max_mkdirs, ( count_to_top + 1 ) )  # one for tmp/your-sub-product
      end

      attr_writer :tmpdir_pathname

      remove_method :set_tmpdir_pathname
      private def set_tmpdir_pathname &blk  # IMPORTANT name
        const_defined?( :TMPDIR_PN_P_, false ) and raise "sanity"
        const_set :TMPDIR_PN_P_, blk
        nil
      end

      def tmpdir_pathname
        @tmpdir_pathname ||= produce_tmpdir_pathname
      end

    private

      def produce_tmpdir_pathname
        if const_defined? :TMPDIR_PN_P_, false
          self::TMPDIR_PN_P_.call
        else
          build_tmpdir_pathname
        end
      end

      def build_tmpdir_pathname
        pam = parent_anchor_module
        if pam
          tdpn = pam.tmpdir_pathname
          tdpn and begin
            bld_tmpdir_pathname_via_parent_tmpdir_pathname tdpn
          end
        else
          tmpdir_pn_when_no_parent_anchor_module
        end
      end

      def bld_tmpdir_pathname_via_parent_tmpdir_pathname tdpn
        name_s = name
        _tail_const = name_s[ name_s.rindex( ':' ) + 1 .. -1 ]
        _dir = Lib_::Name_from_const_to_path[ _tail_const ]
        tdpn.join _dir
      end

      def tmpdir_pn_when_no_parent_anchor_module
        raise errmsg "set @tmpdir_pathname"
      end
    end

    module Extensions_
      module Tmpdir_
        def self.load ; end
      end
    end
  end
end
