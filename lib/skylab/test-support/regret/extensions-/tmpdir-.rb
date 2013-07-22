module ::Skylab::TestSupport

  module Regret

    module AnchorModuleMethods

      def tmpdir
        @tmpdir ||= begin
          Subsys::Tmpdir.new path: tmpdir_pathname,
            max_mkdirs: ( count_to_top + 1 ) # one for tmp/your-sub-product
        end
      end

      attr_writer :tmpdir_pathname

      remove_method :set_tmpdir_pathname
      def set_tmpdir_pathname &blk  # IMPORTANT name
        const_defined?( :TMPDIR_PN_P_, false ) and raise "sanity"
        const_set :TMPDIR_PN_P_, blk
        nil
      end
      private :set_tmpdir_pathname

      def tmpdir_pathname
        @tmpdir_pathname ||= begin
          if const_defined? :TMPDIR_PN_P_, false
            self::TMPDIR_PN_P_.call
          else
            build_tmpdir_pathname
          end
        end
      end

      def build_tmpdir_pathname
        (( pam = parent_anchor_module )) or raise errmsg( "set @tmpdir_pathname" )
        par = pam.tmpdir_pathname
        dir = Autoloader::FUN.pathify[
          name[ name.rindex( ':' ) + 1 .. -1 ] ]
        par.join dir
      end
      private :build_tmpdir_pathname
    end
    module Extensions_
      module Tmpdir_
        def self.load ; end
      end
    end
  end
end
