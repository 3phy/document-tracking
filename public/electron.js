const { app, BrowserWindow, Menu, shell, dialog } = require('electron');
const path = require('path');
const fs = require('fs');

// Check if we're in development mode
const isDev = process.env.NODE_ENV === 'development' || process.env.npm_lifecycle_event === 'electron-dev';

let mainWindow;
let loadingWindow;

// Prevent multiple instances
const gotTheLock = app.requestSingleInstanceLock();

if (!gotTheLock) {
  app.quit();
} else {
  app.on('second-instance', () => {
    // Someone tried to run a second instance, focus our window instead
    if (mainWindow) {
      if (mainWindow.isMinimized()) mainWindow.restore();
      mainWindow.focus();
    }
  });
}

// Check dependencies
function checkDependencies() {
  return new Promise((resolve) => {
    const checks = [];
    
    // Check if node_modules exists
    const nodeModulesPath = path.join(__dirname, '../node_modules');
    if (!fs.existsSync(nodeModulesPath)) {
      checks.push('Node modules not found');
    }
    
    // Check if build directory exists (for production)
    if (!isDev) {
      const buildPath = path.join(__dirname, '../build');
      if (!fs.existsSync(buildPath)) {
        checks.push('Build directory not found');
      }
    }
    
    // Simulate dependency check delay
    setTimeout(() => {
      resolve(checks.length === 0);
    }, 1000);
  });
}

// Create loading window
function createLoadingWindow() {
  loadingWindow = new BrowserWindow({
    width: 400,
    height: 300,
    frame: false,
    transparent: true,
    alwaysOnTop: true,
    skipTaskbar: false,
    resizable: false,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
    },
  });

  // Create loading HTML
  const loadingHTML = `
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
        }
        body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          height: 100vh;
          color: white;
          overflow: hidden;
        }
        .logo {
          font-size: 2rem;
          font-weight: bold;
          margin-bottom: 2rem;
        }
        .spinner {
          border: 4px solid rgba(255, 255, 255, 0.3);
          border-top: 4px solid white;
          border-radius: 50%;
          width: 50px;
          height: 50px;
          animation: spin 1s linear infinite;
          margin-bottom: 1.5rem;
        }
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
        .status {
          font-size: 1.1rem;
          font-weight: 500;
          opacity: 0.9;
        }
      </style>
    </head>
    <body>
      <div class="logo">Document Tracking System</div>
      <div class="spinner"></div>
      <div class="status" id="status">Initializing system...</div>
      <script>
        const statusEl = document.getElementById('status');
        const statuses = [
          'Initializing system...',
          'Checking dependencies...',
          'Starting services...',
          'Loading application...'
        ];
        let currentStatus = 0;
        setInterval(() => {
          currentStatus = (currentStatus + 1) % statuses.length;
          statusEl.textContent = statuses[currentStatus];
        }, 1500);
      </script>
    </body>
    </html>
  `;

  loadingWindow.loadURL(`data:text/html;charset=utf-8,${encodeURIComponent(loadingHTML)}`);
  
  return loadingWindow;
}

function createWindow() {
  // Create the browser window
  mainWindow = new BrowserWindow({
    width: 1400,
    height: 900,
    minWidth: 1200,
    minHeight: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      webSecurity: true,
      devTools: isDev, // Only allow dev tools in development
    },
    icon: path.join(__dirname, 'icon.png'),
    show: false,
    titleBarStyle: 'default',
    autoHideMenuBar: true,
    backgroundColor: '#667eea',
  });

  // Security: Disable refresh shortcut (Ctrl+R, F5)
  mainWindow.webContents.on('before-input-event', (event, input) => {
    if (!isDev) {
      if (input.key === 'F5' || (input.key === 'r' && input.control)) {
        event.preventDefault();
      }
    }
  });

  // Security: Disable right-click in production
  if (!isDev) {
    mainWindow.webContents.on('context-menu', (event) => {
      event.preventDefault();
    });
  }

  // Load the app
  const startUrl = isDev 
    ? 'http://localhost:3000' 
    : `file://${path.join(__dirname, '../build/index.html')}`;
  
  mainWindow.loadURL(startUrl);

  // Show window when ready and close loading window
  mainWindow.once('ready-to-show', () => {
    if (loadingWindow) {
      loadingWindow.close();
      loadingWindow = null;
    }
    mainWindow.show();
    
    // Only open dev tools in development mode
    if (isDev) {
      mainWindow.webContents.openDevTools();
    }
  });

  // Handle window closed
  mainWindow.on('closed', () => {
    mainWindow = null;
  });

  // Handle external links
  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url);
    return { action: 'deny' };
  });

  // Prevent navigation to external URLs
  mainWindow.webContents.on('will-navigate', (event, navigationUrl) => {
    const parsedUrl = new URL(navigationUrl);
    
    if (parsedUrl.origin !== 'http://localhost:3000' && parsedUrl.origin !== 'file://') {
      event.preventDefault();
    }
  });
}

// This method will be called when Electron has finished initialization
app.whenReady().then(async () => {
  // Show loading window first
  createLoadingWindow();
  
  // Check dependencies
  const depsReady = await checkDependencies();
  
  if (!depsReady && !isDev) {
    dialog.showErrorBox(
      'Dependencies Missing',
      'Required dependencies are missing. Please ensure node_modules and build directory exist.'
    );
    app.quit();
    return;
  }
  
  // Create main window
  createWindow();

  // Remove the application menu (File, Edit, View, Window)
  Menu.setApplicationMenu(null);
});

// Quit when all windows are closed
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});

// Security: Prevent new window creation
app.on('web-contents-created', (event, contents) => {
  contents.on('new-window', (event, navigationUrl) => {
    event.preventDefault();
  });
});

// Security: Prevent navigation to external URLs
app.on('web-contents-created', (event, contents) => {
  contents.on('will-navigate', (event, navigationUrl) => {
    const parsedUrl = new URL(navigationUrl);
    if (parsedUrl.origin !== 'http://localhost:3000' && parsedUrl.origin !== 'file://') {
      event.preventDefault();
    }
  });
});
