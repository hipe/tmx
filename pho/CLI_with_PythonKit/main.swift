import PythonKit

// sort of a test:

print("Hello I am 'CLI wth PythonKit'")

// sort of another test:

let sys = Python.import("sys")  // was " = try"

print("Python Encoding: \(sys.getdefaultencoding().upper())")

// insanity ensues

let os = Python.import("os")

let dn = os.path.dirname

let path = dn(dn(dn(#file)))

// procede

print("oh my god: \(path)")

sys.path.insert(0, path)

let omg = Python.import("pho.backend")

let text = omg.say_hello("jimbo")

print("wow we can do anything now: \(text)")

/*
#born.
*/
