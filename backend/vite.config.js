import { defineConfig } from 'vite';
import laravel from 'laravel-vite-plugin';

export default defineConfig({
    plugins: [
        laravel({
            input: ['resources/css/app.css', 'resources/js/app.js'],
            refresh: true,
        }),
    ],
    build: {
        rollupOptions: {
            output: {
                manualChunks: {
                    'vendor-alpine': ['alpinejs', '@alpinejs/persist', '@alpinejs/collapse', '@alpinejs/focus'],
                    'vendor-charts': ['chart.js'],
                    'vendor-upload': ['filepond', 'filepond-plugin-image-preview', 'filepond-plugin-file-validate-size', 'filepond-plugin-file-validate-type'],
                    'vendor-tables': ['gridjs'],
                    'vendor-select': ['tom-select'],
                },
            },
        },
    },
});
