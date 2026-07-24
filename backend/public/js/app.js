// ═══════════════════════════════════════════════════
// Grosirun App — Main JS (CDN-based, no bundler)
// All libraries loaded via CDN in layout <head>
// This file registers Alpine.js components globally
// ═══════════════════════════════════════════════════

document.addEventListener('alpine:init', () => {

    // ─── Offline Detection ───
    Alpine.data('offlineDetector', () => ({
        isOffline: !navigator.onLine,
        init() {
            window.addEventListener('online', () => this.isOffline = false);
            window.addEventListener('offline', () => this.isOffline = true);
        },
    }));

    // ─── Sidebar ───
    Alpine.data('sidebar', () => ({
        open: window.innerWidth >= 992,
        init() {
            window.addEventListener('resize', () => {
                this.open = window.innerWidth >= 992;
            });
            this.$watch('open', val => {
                const wrapper = document.getElementById('main-wrapper');
                const sidebar = document.getElementById('gr-sidebar');
                if (!sidebar || !wrapper) return;
                if (val) {
                    sidebar.classList.remove('mobile-open');
                    if (window.innerWidth >= 992) wrapper.classList.remove('sidebar-collapsed');
                } else {
                    if (window.innerWidth >= 992) wrapper.classList.add('sidebar-collapsed');
                    sidebar.classList.remove('mobile-open');
                }
            });
        },
        toggleSidebar() {
            this.open = !this.open;
            const sidebar = document.getElementById('gr-sidebar');
            const wrapper = document.getElementById('main-wrapper');
            if (!sidebar) return;
            if (window.innerWidth < 992) {
                sidebar.classList.toggle('mobile-open', this.open);
            } else {
                if (this.open) {
                    wrapper && wrapper.classList.remove('sidebar-collapsed');
                } else {
                    wrapper && wrapper.classList.add('sidebar-collapsed');
                }
            }
        },
        closeMobile() {
            if (window.innerWidth < 992) {
                this.open = false;
                const sidebar = document.getElementById('gr-sidebar');
                sidebar && sidebar.classList.remove('mobile-open');
            }
        },
    }));

    // ─── CSRF-aware API Helper ───
    Alpine.data('api', () => ({
        loading: false,
        error: null,
        async post(url, data = {}) {
            this.loading = true; this.error = null;
            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.content;
                const res = await fetch(url, {
                    method: 'POST',
                    headers: { 'X-CSRF-TOKEN': token, 'Content-Type': 'application/json', 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' },
                    body: JSON.stringify(data)
                });
                const result = await res.json();
                if (!res.ok) throw new Error(result.message || 'Terjadi kesalahan');
                return result;
            } catch(e) { this.error = e.message; window.notyf?.error(e.message); throw e; }
            finally { this.loading = false; }
        },
        async delete(url) {
            this.loading = true; this.error = null;
            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.content;
                const res = await fetch(url, {
                    method: 'DELETE',
                    headers: { 'X-CSRF-TOKEN': token, 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' }
                });
                const result = await res.json();
                if (!res.ok) throw new Error(result.message || 'Gagal menghapus');
                return result;
            } catch(e) { this.error = e.message; window.notyf?.error(e.message); throw e; }
            finally { this.loading = false; }
        },
    }));

    // ─── Optimistic Toggle ───
    Alpine.data('optimisticToggle', (initialState = false, url = '') => ({
        value: initialState, saving: false, originalValue: initialState,
        async toggle() {
            this.originalValue = this.value; this.value = !this.value; this.saving = true;
            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.content;
                const res = await fetch(url, { method: 'POST', headers: { 'X-CSRF-TOKEN': token, 'Accept': 'application/json', 'X-Requested-With': 'XMLHttpRequest' } });
                if (!res.ok) { this.value = this.originalValue; window.notyf?.error('Gagal memperbarui'); }
                else window.notyf?.success('Status diperbarui');
            } catch { this.value = this.originalValue; window.notyf?.error('Koneksi gagal'); }
            finally { this.saving = false; }
        },
    }));

    // ─── Image Preview ───
    Alpine.data('imagePreview', () => ({
        preview: null, fileName: '', fileSize: '', error: '',
        handleFile(event) {
            const file = event.target.files[0]; this.error = '';
            if (!file) { this.preview = null; return; }
            if (!['image/jpeg', 'image/png', 'image/jpg'].includes(file.type)) {
                this.error = 'Format harus JPG atau PNG'; this.preview = null; event.target.value = ''; return;
            }
            if (file.size > 2 * 1024 * 1024) {
                this.error = 'Ukuran file maksimal 2MB'; this.preview = null; event.target.value = ''; return;
            }
            this.fileName = file.name; this.fileSize = (file.size / 1024).toFixed(0) + ' KB';
            const reader = new FileReader();
            reader.onload = (e) => this.preview = e.target.result;
            reader.readAsDataURL(file);
        },
        clear() { this.preview = null; this.fileName = ''; this.fileSize = ''; this.error = ''; },
    }));

    // ─── Bulk Select ───
    Alpine.data('bulkSelect', () => ({
        selected: [], selectAll: false,
        toggle(id) { const i = this.selected.indexOf(id); i > -1 ? this.selected.splice(i, 1) : this.selected.push(id); this.selectAll = false; },
        toggleAll(ids) { if (this.selectAll) { this.selected = []; this.selectAll = false; } else { this.selected = [...ids]; this.selectAll = true; } },
        isSelected(id) { return this.selected.includes(id); },
        get count() { return this.selected.length; },
    }));

    // ─── Countdown ───
    Alpine.data('countdown', (deadline) => ({
        remaining: '', isUrgent: false, isExpired: false,
        init() { this.update(); setInterval(() => this.update(), 60000); },
        update() {
            const diff = new Date(deadline) - new Date();
            if (diff <= 0) { this.remaining = 'Sudah berakhir'; this.isExpired = true; return; }
            const h = Math.floor(diff / 3600000), d = Math.floor(h / 24);
            this.remaining = d > 0 ? `Sisa ${d} hari ${h % 24} jam` : `Sisa ${h} jam ${Math.floor((diff % 3600000) / 60000)} menit`;
            this.isUrgent = h < 24;
        },
    }));

    // ─── Tom Select Wrapper ───
    Alpine.data('tomSelectWrapper', (options = {}) => ({
        select: null,
        init() {
            const el = this.$refs.select;
            if (!el || !window.TomSelect) return;
            this.select = new TomSelect(el, {
                create: options.create || false,
                maxItems: options.maxItems || null,
                plugins: options.plugins || ['clear_button', 'remove_button'],
                placeholder: options.placeholder || 'Pilih...',
                ...options,
            });
        },
        destroy() { if (this.select) this.select.destroy(); },
    }));

});

// ─── Init Lucide icons after DOM ready ───
document.addEventListener('DOMContentLoaded', () => {
    if (window.lucide) lucide.createIcons();
});

// Re-init Lucide on DOM changes (e.g. after Alpine renders)
const lucideObserver = new MutationObserver(() => {
    if (window.lucide) lucide.createIcons();
});
document.addEventListener('DOMContentLoaded', () => {
    lucideObserver.observe(document.body, { childList: true, subtree: true });
});

// ─── Init Notyf ───
document.addEventListener('DOMContentLoaded', () => {
    if (window.Notyf) {
        window.notyf = new Notyf({
            duration: 4000,
            position: { x: 'right', y: 'top' },
            types: [
                { type: 'warning', background: '#f59e0b', icon: false },
                { type: 'info', background: '#3b82f6', icon: false }
            ]
        });
    }
});
