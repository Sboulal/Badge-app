/**
 * Badge Management System - Electron Main Process (FIXED)
 * Gère la fenêtre, le serveur Flask et l'intégration système
 */

const { app, BrowserWindow, ipcMain, Menu, Tray, dialog, shell, nativeImage } = require('electron');
const path = require('path');
const { spawn } = require('child_process');
const fs = require('fs');
const Store = require('electron-store');

// Configuration store
const store = new Store();

// Variables globales
let mainWindow = null;
let tray = null;
let flaskProcess = null;
const FLASK_PORT = 5000;
const isDev = !app.isPackaged;

// Chemin vers Python et le script Flask
function getPythonPath() {
    if (process.platform === 'win32') {
        return 'python';
    }
    return 'python3';
}

function getFlaskScriptPath() {
    const scriptPath = path.join(__dirname, 'api_server.py');
    console.log(`Checking Flask script at: ${scriptPath}`);
    console.log(`File exists: ${fs.existsSync(scriptPath)}`);
    return scriptPath;
}

// Créer la fenêtre principale
function createWindow() {
    let windowIcon = null;
    const iconPath = path.join(__dirname, 'assets', 'icon.png');
    
    if (fs.existsSync(iconPath)) {
        windowIcon = iconPath;
    }

    mainWindow = new BrowserWindow({
        width: 1400,
        height: 900,
        minWidth: 1000,
        minHeight: 700,
        icon: windowIcon,
        webPreferences: {
            preload: path.join(__dirname, 'preload.js'),
            nodeIntegration: false,
            contextIsolation: true,
            enableRemoteModule: false
        },
        backgroundColor: '#667eea',
        show: false,
        frame: true,
        titleBarStyle: 'default'
    });

    const htmlPath = path.join(__dirname, 'renderer.html');
    if (fs.existsSync(htmlPath)) {
        mainWindow.loadFile(htmlPath);
    } else {
        console.error(`renderer.html not found at: ${htmlPath}`);
        mainWindow.loadURL('data:text/html,<h1>Error: renderer.html not found</h1>');
    }

    mainWindow.once('ready-to-show', () => {
        mainWindow.show();
        if (isDev) {
            mainWindow.webContents.openDevTools();
        }
    });

    mainWindow.on('close', (event) => {
        if (!app.isQuitting) {
            event.preventDefault();
            mainWindow.hide();
        }
    });

    mainWindow.on('closed', () => {
        mainWindow = null;
    });

    createMenu();
}

/**
 * Afficher la boîte de dialogue de configuration d'imprimante
 */
function showPrinterConfigDialog() {
    const currentConfig = store.get('printer', {
        model: 'Brother QL-820NWB',
        identifier: 'USB',
        labelSize: '62mm',
        port: 'USB001',
        dpi: 300
    });
    
    const configWindow = new BrowserWindow({
        width: 500,
        height: 650,
        parent: mainWindow,
        modal: true,
        resizable: false,
        minimizable: false,
        maximizable: false,
        title: 'Configuration de l\'imprimante',
        webPreferences: {
            nodeIntegration: true,
            contextIsolation: false
        }
    });

    const configHTML = `
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
                font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
                padding: 20px;
                background: #f5f5f5;
            }
            .container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            }
            h1 {
                color: #667eea;
                margin-bottom: 30px;
                font-size: 24px;
            }
            .form-group {
                margin-bottom: 20px;
            }
            label {
                display: block;
                margin-bottom: 8px;
                color: #333;
                font-weight: 500;
            }
            input, select {
                width: 100%;
                padding: 10px;
                border: 2px solid #e0e0e0;
                border-radius: 5px;
                font-size: 14px;
                transition: border-color 0.3s;
            }
            input:focus, select:focus {
                outline: none;
                border-color: #667eea;
            }
            .button-group {
                display: flex;
                gap: 10px;
                margin-top: 30px;
            }
            button {
                flex: 1;
                padding: 12px;
                border: none;
                border-radius: 5px;
                font-size: 14px;
                font-weight: 500;
                cursor: pointer;
                transition: all 0.3s;
            }
            .btn-primary {
                background: #667eea;
                color: white;
            }
            .btn-primary:hover {
                background: #5568d3;
            }
            .btn-secondary {
                background: #e0e0e0;
                color: #333;
            }
            .btn-secondary:hover {
                background: #d0d0d0;
            }
            .info-box {
                background: #e8eaf6;
                padding: 15px;
                border-radius: 5px;
                margin-top: 20px;
                font-size: 13px;
                color: #555;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>⚙️ Configuration de l'imprimante</h1>
            
            <form id="printerForm">
                <div class="form-group">
                    <label for="model">Modèle d'imprimante</label>
                    <select id="model">
                        <option value="Brother QL-820NWB">Brother QL-820NWB</option>
                        <option value="Brother QL-800">Brother QL-800</option>
                        <option value="Brother QL-700">Brother QL-700</option>
                        <option value="Zebra ZD410">Zebra ZD410</option>
                        <option value="Dymo LabelWriter 450">Dymo LabelWriter 450</option>
                        <option value="Autre">Autre</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="identifier">Type de connexion</label>
                    <select id="identifier">
                        <option value="USB">USB</option>
                        <option value="Network">Réseau</option>
                        <option value="Bluetooth">Bluetooth</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="port">Port / Adresse</label>
                    <input type="text" id="port" placeholder="Ex: USB001 ou 192.168.1.100">
                </div>

                <div class="form-group">
                    <label for="labelSize">Taille d'étiquette</label>
                    <select id="labelSize">
                        <option value="62mm">62mm (standard)</option>
                        <option value="29mm">29mm (petite)</option>
                        <option value="102mm">102mm (grande)</option>
                        <option value="12mm">12mm (très petite)</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="dpi">Résolution (DPI)</label>
                    <select id="dpi">
                        <option value="203">203 DPI</option>
                        <option value="300">300 DPI</option>
                        <option value="600">600 DPI</option>
                    </select>
                </div>

                <div class="info-box">
                    💡 <strong>Astuce :</strong> Pour les imprimantes Brother QL, utilisez USB et 300 DPI pour une qualité optimale.
                </div>

                <div class="button-group">
                    <button type="button" class="btn-secondary" onclick="window.close()">
                        Annuler
                    </button>
                    <button type="submit" class="btn-primary">
                        Enregistrer
                    </button>
                </div>
            </form>
        </div>

        <script>
            const { ipcRenderer } = require('electron');
            const config = ${JSON.stringify(currentConfig)};
            
            document.getElementById('model').value = config.model;
            document.getElementById('identifier').value = config.identifier;
            document.getElementById('port').value = config.port;
            document.getElementById('labelSize').value = config.labelSize;
            document.getElementById('dpi').value = config.dpi;

            document.getElementById('printerForm').addEventListener('submit', (e) => {
                e.preventDefault();
                
                const newConfig = {
                    model: document.getElementById('model').value,
                    identifier: document.getElementById('identifier').value,
                    port: document.getElementById('port').value,
                    labelSize: document.getElementById('labelSize').value,
                    dpi: parseInt(document.getElementById('dpi').value)
                };

                ipcRenderer.send('save-printer-config', newConfig);
            });
        </script>
    </body>
    </html>
    `;

    configWindow.loadURL('data:text/html;charset=utf-8,' + encodeURIComponent(configHTML));
}

/**
 * Afficher la configuration actuelle de l'imprimante
 */
function showCurrentPrinterConfig() {
    const config = store.get('printer', {
        model: 'Non configuré',
        identifier: 'N/A',
        labelSize: 'N/A',
        port: 'N/A',
        dpi: 0
    });

    dialog.showMessageBox(mainWindow, {
        type: 'info',
        title: 'Configuration actuelle',
        message: 'Configuration de l\'imprimante',
        detail: `📌 Modèle: ${config.model}\n🔌 Connexion: ${config.identifier}\n📍 Port: ${config.port}\n📏 Taille étiquette: ${config.labelSize}\n🎨 Résolution: ${config.dpi} DPI`,
        buttons: ['OK', 'Modifier'],
        defaultId: 0
    }).then(result => {
        if (result.response === 1) {
            showPrinterConfigDialog();
        }
    });
}

/**
 * Tester l'imprimante
 */
function testPrinter() {
    const config = store.get('printer');
    
    if (!config) {
        dialog.showMessageBox(mainWindow, {
            type: 'warning',
            title: 'Aucune configuration',
            message: 'Veuillez d\'abord configurer votre imprimante',
            buttons: ['OK', 'Configurer maintenant']
        }).then(result => {
            if (result.response === 1) {
                showPrinterConfigDialog();
            }
        });
        return;
    }

    dialog.showMessageBox(mainWindow, {
        type: 'info',
        title: 'Test d\'impression',
        message: 'Test de l\'imprimante',
        detail: `Une page de test va être envoyée à:\n${config.model} (${config.identifier})\n\nAssurez-vous que l'imprimante est allumée et connectée.`,
        buttons: ['Annuler', 'Imprimer la page de test']
    }).then(result => {
        if (result.response === 1) {
            if (mainWindow) {
                mainWindow.webContents.send('print-test-page', config);
            }
        }
    });
}

// Créer le menu de l'application
function createMenu() {
    const template = [
        {
            label: 'Fichier',
            submenu: [
                {
                    label: 'Nouveau Badge',
                    accelerator: 'CmdOrCtrl+N',
                    click: () => {
                        if (mainWindow) {
                            mainWindow.webContents.send('menu-action', 'new-badge');
                        }
                    }
                },
                {
                    label: 'Importer Excel',
                    accelerator: 'CmdOrCtrl+I',
                    click: () => {
                        if (mainWindow) {
                            mainWindow.webContents.send('menu-action', 'import-excel');
                        }
                    }
                },
                {
                    label: 'Exporter Excel',
                    accelerator: 'CmdOrCtrl+E',
                    click: () => {
                        if (mainWindow) {
                            mainWindow.webContents.send('menu-action', 'export-excel');
                        }
                    }
                },
                { type: 'separator' },
                {
                    label: 'Quitter',
                    accelerator: 'CmdOrCtrl+Q',
                    click: () => {
                        app.isQuitting = true;
                        app.quit();
                    }
                }
            ]
        },
        {
            label: 'Édition',
            submenu: [
                { role: 'undo', label: 'Annuler' },
                { role: 'redo', label: 'Rétablir' },
                { type: 'separator' },
                { role: 'cut', label: 'Couper' },
                { role: 'copy', label: 'Copier' },
                { role: 'paste', label: 'Coller' },
                { role: 'selectAll', label: 'Tout sélectionner' }
            ]
        },
        {
            label: 'Affichage',
            submenu: [
                {
                    label: 'Actualiser',
                    accelerator: 'F5',
                    click: () => {
                        if (mainWindow) {
                            mainWindow.webContents.send('menu-action', 'refresh');
                        }
                    }
                },
                { type: 'separator' },
                { role: 'resetZoom', label: 'Zoom par défaut' },
                { role: 'zoomIn', label: 'Zoom +' },
                { role: 'zoomOut', label: 'Zoom -' },
                { type: 'separator' },
                { role: 'togglefullscreen', label: 'Plein écran' }
            ]
        },
        {
            label: 'Imprimante',
            submenu: [
                {
                    label: 'Configurer l\'imprimante',
                    accelerator: 'CmdOrCtrl+P',
                    click: () => {
                        showPrinterConfigDialog();
                    }
                },
                {
                    label: 'Voir la configuration',
                    click: () => {
                        showCurrentPrinterConfig();
                    }
                },
                { type: 'separator' },
                {
                    label: 'Tester l\'imprimante',
                    click: () => {
                        testPrinter();
                    }
                }
            ]
        },
        {
            label: 'Aide',
            submenu: [
                {
                    label: 'Documentation',
                    click: () => {
                        shell.openExternal('https://github.com/your-repo');
                    }
                },
                {
                    label: 'Ouvrir les logs',
                    click: () => {
                        const logPath = path.join(app.getPath('userData'), 'logs');
                        shell.openPath(logPath);
                    }
                },
                { type: 'separator' },
                {
                    label: 'À propos',
                    click: () => {
                        dialog.showMessageBox(mainWindow, {
                            type: 'info',
                            title: 'À propos',
                            message: 'Badge Management System',
                            detail: `Version: ${app.getVersion()}\nElectron: ${process.versions.electron}\nNode: ${process.versions.node}\nChrome: ${process.versions.chrome}`
                        });
                    }
                }
            ]
        }
    ];

    if (isDev) {
        template.push({
            label: 'Développeur',
            submenu: [
                { role: 'reload', label: 'Recharger' },
                { role: 'forceReload', label: 'Forcer le rechargement' },
                { role: 'toggleDevTools', label: 'Outils de développement' }
            ]
        });
    }

    const menu = Menu.buildFromTemplate(template);
    Menu.setApplicationMenu(menu);
}

// Créer l'icône dans le system tray
function createTray() {
    try {
        let trayIcon = null;
        const iconPath = path.join(__dirname, 'assets', 
            process.platform === 'win32' ? 'icon.ico' : 'icon.png'
        );
        
        if (fs.existsSync(iconPath)) {
            trayIcon = nativeImage.createFromPath(iconPath);
        } else {
            console.log('Icon file not found, using fallback');
            trayIcon = nativeImage.createEmpty();
        }
        
        tray = new Tray(trayIcon);
        
        const contextMenu = Menu.buildFromTemplate([
            {
                label: 'Afficher',
                click: () => {
                    if (mainWindow) {
                        mainWindow.show();
                    }
                }
            },
            {
                label: 'Nouveau Badge',
                click: () => {
                    if (mainWindow) {
                        mainWindow.show();
                        mainWindow.webContents.send('menu-action', 'new-badge');
                    }
                }
            },
            { type: 'separator' },
            {
                label: 'Configuration Imprimante',
                click: () => {
                    showPrinterConfigDialog();
                }
            },
            { type: 'separator' },
            {
                label: 'Quitter',
                click: () => {
                    app.isQuitting = true;
                    app.quit();
                }
            }
        ]);
        
        tray.setToolTip('Badge Management System');
        tray.setContextMenu(contextMenu);
        
        tray.on('double-click', () => {
            if (mainWindow) {
                mainWindow.show();
            }
        });
        
        console.log('System tray created successfully');
    } catch (error) {
        console.error('Error creating tray:', error);
    }
}

// Démarrer le serveur Flask
function startFlaskServer() {
    return new Promise((resolve, reject) => {
        const pythonPath = getPythonPath();
        const scriptPath = getFlaskScriptPath();
        
        console.log(`Démarrage du serveur Flask...`);
        console.log(`Python: ${pythonPath}`);
        console.log(`Script: ${scriptPath}`);
        
        if (!fs.existsSync(scriptPath)) {
            const error = new Error(`Script Flask introuvable: ${scriptPath}`);
            console.error(error.message);
            reject(error);
            return;
        }
        
        flaskProcess = spawn(pythonPath, [scriptPath], {
            cwd: path.dirname(scriptPath),
            env: {
                ...process.env,
                FLASK_PORT: FLASK_PORT.toString(),
                FLASK_HOST: '127.0.0.1',
                FLASK_DEBUG: 'False'
            }
        });
        
        let serverStarted = false;
        
        flaskProcess.stdout.on('data', (data) => {
            const output = data.toString();
            console.log(`[Flask] ${output}`);
            
            if (output.includes('Running on') || output.includes('Serving Flask')) {
                if (!serverStarted) {
                    serverStarted = true;
                    resolve();
                }
            }
        });
        
        flaskProcess.stderr.on('data', (data) => {
            console.error(`[Flask Error] ${data.toString()}`);
        });
        
        flaskProcess.on('error', (error) => {
            console.error('Erreur Flask:', error);
            if (!serverStarted) {
                reject(error);
            }
        });
        
        flaskProcess.on('close', (code) => {
            console.log(`Serveur Flask arrêté avec le code ${code}`);
            flaskProcess = null;
        });
        
        setTimeout(() => {
            if (!serverStarted) {
                console.log('Timeout: continuation sans confirmation Flask');
                resolve();
            }
        }, 15000);
    });
}

// Arrêter le serveur Flask
function stopFlaskServer() {
    if (flaskProcess) {
        console.log('Arrêt du serveur Flask...');
        flaskProcess.kill();
        flaskProcess = null;
    }
}

// Vérifier si le port est disponible
function isPortAvailable(port) {
    return new Promise((resolve) => {
        const net = require('net');
        const server = net.createServer();
        
        server.once('error', () => {
            resolve(false);
        });
        
        server.once('listening', () => {
            server.close();
            resolve(true);
        });
        
        server.listen(port, '127.0.0.1');
    });
}

// IPC Handlers
ipcMain.handle('get-app-path', () => {
    return app.getPath('userData');
});

ipcMain.handle('open-file-dialog', async (event, options) => {
    const result = await dialog.showOpenDialog(mainWindow, options);
    return result;
});

ipcMain.handle('save-file-dialog', async (event, options) => {
    const result = await dialog.showSaveDialog(mainWindow, options);
    return result;
});

ipcMain.handle('show-message', (event, options) => {
    return dialog.showMessageBox(mainWindow, options);
});

ipcMain.handle('get-printer-config', () => {
    return store.get('printer', null);
});

ipcMain.on('save-printer-config', (event, config) => {
    try {
        store.set('printer', config);
        
        dialog.showMessageBox(BrowserWindow.getFocusedWindow(), {
            type: 'info',
            title: 'Configuration enregistrée',
            message: 'La configuration de l\'imprimante a été enregistrée avec succès !',
            buttons: ['OK']
        }).then(() => {
            const focusedWindow = BrowserWindow.getFocusedWindow();
            if (focusedWindow && focusedWindow !== mainWindow) {
                focusedWindow.close();
            }
            
            if (mainWindow) {
                mainWindow.webContents.send('printer-config-updated', config);
            }
        });
    } catch (error) {
        dialog.showErrorBox('Erreur', 'Impossible d\'enregistrer la configuration: ' + error.message);
    }
});

// Événements de l'application
app.whenReady().then(async () => {
    console.log('='.repeat(60));
    console.log('Application Badge Management System');
    console.log('='.repeat(60));
    console.log(`Mode: ${isDev ? 'DÉVELOPPEMENT' : 'PRODUCTION'}`);
    console.log(`Plateforme: ${process.platform}`);
    console.log(`__dirname: ${__dirname}`);
    console.log('='.repeat(60));
    
    const portAvailable = await isPortAvailable(FLASK_PORT);
    if (!portAvailable) {
        dialog.showErrorBox(
            'Port occupé',
            `Le port ${FLASK_PORT} est déjà utilisé.\nFermez toute autre instance de l'application.`
        );
        app.quit();
        return;
    }
    
    try {
        console.log('Démarrage du serveur Flask...');
        await startFlaskServer();
        console.log('✓ Serveur Flask démarré avec succès');
    } catch (error) {
        console.error('✗ Erreur au démarrage de Flask:', error);
        
        const choice = dialog.showMessageBoxSync({
            type: 'error',
            title: 'Erreur de démarrage',
            message: 'Impossible de démarrer le serveur Flask',
            detail: `${error.message}\n\nVérifiez que Python et les dépendances sont installés.`,
            buttons: ['Quitter', 'Continuer sans serveur']
        });
        
        if (choice === 0) {
            app.quit();
            return;
        }
    }
    
    createWindow();
    createTray();
    
    app.on('activate', () => {
        if (BrowserWindow.getAllWindows().length === 0) {
            createWindow();
        } else if (mainWindow) {
            mainWindow.show();
        }
    });
});

app.on('before-quit', () => {
    app.isQuitting = true;
    stopFlaskServer();
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit();
    }
});

process.on('uncaughtException', (error) => {
    console.error('Uncaught Exception:', error);
    dialog.showErrorBox('Erreur critique', error.message);
});

process.on('unhandledRejection', (reason, promise) => {
    console.error('Unhandled Rejection at:', promise, 'reason:', reason);
});

console.log('Badge Management System - Main process loaded');