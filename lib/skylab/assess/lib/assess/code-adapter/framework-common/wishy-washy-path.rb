require 'assess/util/strict-attr-accessors'
require 'assess/util/sexpesque'
require 'assess/code-builder'

module Hipe
  module Assess
    module FrameworkCommon
      class WishyWashyPath
        #
        # The point of a wishy-washy path is to represent the relevant
        # nodes in the filesystem in an abstract way so that the actual
        # filepath isn't determined until runtime.
        #
        # After building this i realized we probably should have subclassed
        # Pathname, because the concerns are similar.  But all things being
        # equal I don't know how much of a gain that would be at this point.
        #
        # These facilities are provided to this end:
        # 1) paths can be represented as relative to other paths in
        #    the usual way.
        # 2) Depending on how it is constructed, a wishy-washy path can
        #    indicate that it might represent a file or a folder, to
        #    be determined at runtime. (use path.might_be_folder = true)
        # 3) Depending on if the path.might_be_plural=true option is used,
        #    the path can indicate that it may or may not have an 's' after it
        # 4) with the might_have_extension='.rb' option, it indicates that
        #    the actual path may or may not use the extension.
        #
        # So, something like this:
        #
        #   root_path = WishyWashyPath.new{|p| p.absolute_path = './app'} #sic
        #   cont_path = WishyWashyPath.new do |p|
        #     p.relative_to = root_path
        #     p.relative_path = './controller'
        #     p.might_be_plural = true
        #     p.might_be_folder = true
        #     p.might_have_extension = '.rb'
        #   end
        #
        #  Now, if any of the following paths exist the path object when
        #  'resolved' will find it (in some undefined order):
        #
        #  ./app/controller/
        #  ./app/controller
        #  ./app/controllers
        #  ./app/controllers/
        #  ./app/controller.rb
        #  ./app/controllers.rb
        #
        #  You can get the resolved path of a pretty path with
        #        p.pretty_path_resolved
        #        p.absolute_path_resolved
        #
        #  pretty_path tries to use './' when possible
        #
        #  If none of the permutations is a path that exists on the
        # filesystem, one of them will still be returned (which one is
        # undefined) . use exists? to see if the path exists.
        #
        extend UberAllesArray, StrictAttrAccessors
        include CommonInstanceMethods

        attr_reader :path_id
        attr_accessor :might_have_extension
        boolean_attr_accessor :might_be_folder, :might_be_plural
        def initialize(name)
          @name_sym = name.to_sym
          @path_id = self.class.register(self)
          @might_be_plural = false
          @might_be_folder = true
          @might_have_extension = nil
          yield self if block_given?
          clear
        end
        def clear
          @relative_to_id = nil
          @absolute_path = nil
          @relative_path = nil
        end
        def ancestors
          if relative?
            relative_to.ancestors + [path_id]
          else
            [path_id]
          end
        end
        def relative_to= path
          if @relative_to_id
            fail("already relative to something else. clear first.")
          end
          anc = path.ancestors
          if anc.include? path_id
            fail("won't make circular reference!")
          end
          @relative_to_id = path.path_id
        end
        def relative_to
          if @relative_to_id.nil?
            fail("check relative? first")
          end
          WishyWashyPath.all[@relative_to_id]
        end
        def relative?
          (! @relative_to_id.nil?) # don't care about @relative_path for now
        end
        def absolute?
          @relative_to_id.nil? && @absolute_path
        end
        def relative_path?
          ! @relative_path.nil?
        end
        def relative_path
          fail("no relative path. check relative_path? first") unless
            relative_path?
          @relative_path
        end
        SansRe = %r{^\./}
        def relative_path_sans
          relative_path.gsub(SansRe,'')
        end
        def relative_path= str
          if @absolute_path
            fail("won't relative path when absolute is set. clear first.")
          end
          unless @relative_to_id
            fail("won't set relative path unless relative_to is set first.")
          end
          @relative_path = str
        end
        def absolute_path= str
          if @relative_to_id || @relative_path
            fail("won't set abs path when relative properties exist."<<
              " clear first.")
          end
          @absolute_path = str
        end
        def absolute_path
          if absolute?
            @absolute_path
          elsif relative?
            File.expand_path(
              File.join(relative_to.absolute_path, relative_path)
            )
          else
            nil
          end
        end
        def pretty_path
          if absolute?
            if ::Dir.getwd == absolute_path
              resp = '.'
            else
              resp = absolute_path
            end
          elsif relative?
            pretty_base = relative_to.pretty_path
            resp = File.join(pretty_base, relative_path_sans)
          else
            resp = nil
          end
          resp
        end
        def absolute_path_resolved
          other = resolve absolute_path
          other ? other : absolute_path
        end
        def pretty_path_resolved
          other = resolve pretty_path
          other ? other : pretty_path
        end
        def s; Sexpesque; end
        def summary
          s[ @name_sym || :path_summary,
            s[:path, pretty_path_resolved],
            s[:exists, exists? ]
          ]
        end
        def exists?
          File.exist?(absolute_path_resolved)
        end
        def single_file?
          resolved = absolute_path_resolved
          flail("model does not exist") unless File.exist?(resolved)
          if File.directory?(resolved)
            false
          else
            true
          end
        end
        def path
          unless exists?
            fail("Path does not exist.  Check exists? first")
          end
          pretty_path_resolved
        end
      private

        #
        # Try the different permuations of the path
        # @return false if not found
        # thanks rue
        #
        def resolve path
          return nil if path.nil?
          lefts = [path]
          rights = ['']
          lefts.push("#{path}s") if might_be_plural?
          rights.push(might_have_extension) if might_have_extension
          try_these = lefts.map{|x| rights.map{|y| "#{x}#{y}"}}.flatten
          try_these.each do |try|
            if File.exist?(try)
              return try
            end
          end
          return false
        end # resolve
      end # WishyWashyPath
    end # FrameworkCommon
  end # Assess
end # Hipe
