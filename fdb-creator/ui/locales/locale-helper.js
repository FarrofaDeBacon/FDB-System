// Murphy Creator - Translation Helper 
// Helper functions to manage translations in NUI

let currentLocale = 'en';
let translations = {};

// Initialize translations
function initLocale(locale = 'en') {
    currentLocale = locale;
    console.log(`[murphy_creator] Locale set to: ${locale}`);
}

// Get translation by path (e.g., "ui.cancel", "charSelect.title")
function t(path, fallback = null) {
    if (!window.Locale) {
        console.error('[murphy_creator] Locale not loaded!');
        return fallback || path;
    }
    
    const keys = path.split('.');
    let value = window.Locale;
    
    for (const key of keys) {
        if (value && typeof value === 'object' && key in value) {
            value = value[key];
        } else {
            console.warn(`[murphy_creator] Translation not found for: ${path}`);
            return fallback || path;
        }
    }
    
    return value;
}

// Update all elements with data-i18n attribute
function updateTranslations() {
    // Handle text content translations
    document.querySelectorAll('[data-i18n]').forEach(element => {
        const key = element.getAttribute('data-i18n');
        const translation = t(key);
        element.textContent = translation;
    });

    // Handle placeholder translations
    document.querySelectorAll('[data-i18n-placeholder]').forEach(element => {
        const key = element.getAttribute('data-i18n-placeholder');
        const translation = t(key);
        element.placeholder = translation;
    });
}

// Load locale dynamically
function loadLocale(locale) {
    return new Promise((resolve, reject) => {
        const script = document.createElement('script');
        script.src = `./locales/${locale}.js`;
        script.onload = () => {
            initLocale(locale);
            updateTranslations();
            resolve();
        };
        script.onerror = () => {
            console.error(`[murphy_creator] Failed to load locale: ${locale}`);
            reject();
        };
        document.head.appendChild(script);
    });
}

// Export for global use
if (typeof window !== 'undefined') {
    window.t = t;
    window.initLocale = initLocale;
    window.updateTranslations = updateTranslations;
    window.loadLocale = loadLocale;

    // Auto-update translations when DOM is ready
    document.addEventListener('DOMContentLoaded', () => {
        updateTranslations();
    });
}
