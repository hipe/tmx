const { app, BrowserWindow } = require('electron');

const { PythonShell } = require('python-shell');

const path = require('path');

const _options = {
  args: ['aa', 'bb', 'cc'],
  scriptPath: path.resolve(path.join(__dirname, '..')),
  pythonPath: 'python3',  // ..
  pythonOptions: ['-u'],  // stdin, stdout & stderr unbuffered
  mode: 'text'
};

const pyshell = new PythonShell('../backend.py', _options);

// pyshell.send('some user data')

pyshell.on('message', (message) => {
  console.log('receceived message: ' + message);
})

pyshell.end((err, code, signal) => {
  if (err) throw err;
  console.log('the exit code was: ' + code);
  console.log('the exit signal was ' + signal);
  console.log('finished with thing.');
});

// Handle creating/removing shortcuts on Windows when installing/uninstalling.
if (require('electron-squirrel-startup')) { // eslint-disable-line global-require
  app.quit();
}

const createWindow = () => {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: true,
      enableRemoteModule: true,
    }
  });

  // and load the index.html of the app.
  mainWindow.loadFile(path.join(__dirname, 'index.html'));

  // Open the DevTools.
  mainWindow.webContents.openDevTools();

  // (on window closed, we used to dereference a global before #history-A.1)
};

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow);

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and import them here.
/*
# #history-A.1: merge-in electron-forge-generated starter app
# #born.
*/
