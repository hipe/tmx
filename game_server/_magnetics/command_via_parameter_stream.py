class SELF:  # :[#011]

    __slots__ = (
      'name',
      'has_parameters',
    )

    def __init__(self,
      name,
      parameter_stream,
    ):

        for cmd in parameter_stream:
            cover_me()

        self.name = name
        self.has_parameters = False

# #born. (minimal)
