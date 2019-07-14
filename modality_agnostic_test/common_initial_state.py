class BooleanReference:  # :[#510.5] (again)
    def __init__(self):
        self.value = False

    def see(self):
        self.value = True


class MutexingReference:  # :[#510.5] (again)
    def __init__(self):
        self._is_first_call = True

    def receive_value(self, x):
        assert(self._is_first_call)
        self._is_first_call = False
        self.value = x

# #born.
