/**
 * Preload Script - Bridge sécurisé entre Electron et le Renderer
 * Expose les APIs Electron de manière contrôlée
 */

const { contextBridge, ipcRenderer } = require('electron');

// Exposer les APIs de manière sécurisée
contextBridge.exposeInMainWorld('electronAPI', {
    // Chemins de l'application
    getAppPath: () => ipcRenderer.invoke('get-app-path'),
    
    // Dialogs
    openFileDialog: (options) => ipcRenderer.invoke('open-file-dialog', options),
    saveFileDialog: (options) => ipcRenderer.invoke('save-file-dialog', options),
    showMessage: (options) => ipcRenderer.invoke('show-message', options),
    
    // Événements du menu
    onMenuAction: (callback) => {
        ipcRenderer.on('menu-action', (event, action) => callback(action));
    },
    
    // Informations système
    platform: process.platform,
    versions: {
        node: process.versions.node,
        chrome: process.versions.chrome,
        electron: process.versions.electron
    },
    
    // Stockage local (alternative à localStorage pour Electron)
    storage: {
        get: (key) => {
            const value = localStorage.getItem(key);
            return value ? JSON.parse(value) : null;
        },
        set: (key, value) => {
            localStorage.setItem(key, JSON.stringify(value));
        },
        remove: (key) => {
            localStorage.removeItem(key);
        },
        clear: () => {
            localStorage.clear();
        }
    }
});

console.log('Preload script chargé - Electron API exposée');