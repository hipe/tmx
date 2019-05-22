import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var helloLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func sayButtonClicked(_ sender: Any) {
        var name = nameField.stringValue
        if name.isEmpty {
            name = "World"
        }
        let api = _BUILD_PYTHON_BACKEND()
        let greeting = "\(api.say_hello(name))"  // sneak we don't know how to cast
        helloLabel.stringValue = greeting
    }

    func _BUILD_PYTHON_BACKEND() -> PythonObject {
        let sys = Python.import("sys")  // was " = try"

        // insanity ensues
        let os = Python.import("os")
        let dn = os.path.dirname
        let path = dn(dn(dn(#file)))
        // end

        sys.path.insert(0, path)

        return Python.import("pho.backend")
    }
}
/*
#history-A.1: moved PythonKit code from visual test CLI to here
#born.
*/
