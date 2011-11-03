module Skylab::Dependency
  class Graph < Task
    # The way you determine all of the children of a graph node is 
    # you get the distinct list of names of all of its elses (fallbacks) and all
    # of its dependencies and etc.
    #
    # (previous to the first commit of this file it was done a different way)
    #
    # This is done here in a seperate file because this features is needed only
    # for a graphing/visualization utility, not for day to day use.
    def _inflate_children
      node, is_err = target_node
      node or return []
      names = ['target']
      node.else     and names |= node.else.kind_of?(Array)     ? node.else     : [node.else]
      node.requires and names |= node.requires.kind_of?(Array) ? node.requires : [node.requires]
      names.map { |name| self.node name }
    end
  end
end

