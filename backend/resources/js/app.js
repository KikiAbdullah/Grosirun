// ═══════════════════════════════════════════════════
// Grosirun App — Main JS Entry
// ═══════════════════════════════════════════════════

// ─── Alpine.js + Plugins ───
import Alpine from 'alpinejs';
import persist from '@alpinejs/persist';
import collapse from '@alpinejs/collapse';
import focus from '@alpinejs/focus';
Alpine.plugin(persist);
Alpine.plugin(collapse);
Alpine.plugin(focus);

// ─── SweetAlert2 ───
import Swal from 'sweetalert2';
window.Swal = Swal;

// ─── Notyf (toasts) ───
import { Notyf } from 'notyf';
import 'notyf/notyf.min.css';
window.notyf = new Notyf({ duration:4000, position:{x:'right',y:'top'}, types:[{type:'warning',background:'#F59E0B',icon:false},{type:'info',background:'#3B82F6',icon:false}] });

// ─── Lucide Icons ───
import { createIcons, icons } from 'lucide';
const refreshIcons = () => createIcons({ icons });

// ─── FilePond ───
import { create, registerPlugin } from 'filepond';
import FilePondImagePreview from 'filepond-plugin-image-preview';
import FilePondValidateSize from 'filepond-plugin-file-validate-size';
import FilePondValidateType from 'filepond-plugin-file-validate-type';
import 'filepond/dist/filepond.min.css';
import 'filepond-plugin-image-preview/dist/filepond-plugin-image-preview.css';
registerPlugin(FilePondImagePreview, FilePondValidateSize, FilePondValidateType);
window.FilePond = { create };

// ─── Tom Select ───
import TomSelect from 'tom-select';
import 'tom-select/dist/css/tom-select.default.min.css';
window.TomSelect = TomSelect;

// ─── DataTables (yajra server-side) ───
import 'datatables.net-bs5';
import 'datatables.net-buttons-bs5';
import 'datatables.net-select-bs5';

// ─── Chart.js ───
import Chart from 'chart.js/auto';
window.Chart = Chart;

// ─── Grid.js ───
import { Grid, html } from 'gridjs';
import 'gridjs/dist/theme/mermaid.css';
window.GridJS = { Grid, html };

// ═══════════════════════════════════════════════════
// Alpine Components (global)
// ═══════════════════════════════════════════════════
document.addEventListener('alpine:init', () => {
    refreshIcons();

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
        open: window.innerWidth >= 1024,
        mobileOpen: false,
        init() { window.addEventListener('resize', () => { if (window.innerWidth >= 1024) this.mobileOpen = false; }); },
    }));

    // ─── CSRF-aware API Helper ───
    Alpine.data('api', () => ({
        loading: false,
        error: null,
        async post(url, data = {}) {
            this.loading = true; this.error = null;
            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.content;
                const res = await fetch(url, { method:'POST', headers:{'X-CSRF-TOKEN':token,'Content-Type':'application/json','Accept':'application/json','X-Requested-With':'XMLHttpRequest'}, body:JSON.stringify(data) });
                const result = await res.json();
                if (!res.ok) throw new Error(result.message || 'Terjadi kesalahan');
                return result;
            } catch(e) { this.error = e.message; notyf.error(e.message); throw e; }
            finally { this.loading = false; }
        },
        async delete(url) {
            this.loading = true; this.error = null;
            try {
                const token = document.querySelector('meta[name="csrf-token"]')?.content;
                const res = await fetch(url, { method:'DELETE', headers:{'X-CSRF-TOKEN':token,'Accept':'application/json','X-Requested-With':'XMLHttpRequest'} });
                const result = await res.json();
                if (!res.ok) throw new Error(result.message || 'Gagal menghapus');
                return result;
            } catch(e) { this.error = e.message; notyf.error(e.message); throw e; }
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
                const res = await fetch(url, { method:'POST', headers:{'X-CSRF-TOKEN':token,'Accept':'application/json','X-Requested-With':'XMLHttpRequest'} });
                if (!res.ok) { this.value = this.originalValue; notyf.error('Gagal memperbarui'); }
                else notyf.success('Status diperbarui');
            } catch { this.value = this.originalValue; notyf.error('Koneksi gagal'); }
            finally { this.saving = false; }
        },
    }));

    // ─── Image Preview ───
    Alpine.data('imagePreview', () => ({
        preview: null, fileName: '', fileSize: '', error: '',
        handleFile(event) {
            const file = event.target.files[0]; this.error = '';
            if (!file) { this.preview = null; return; }
            if (!['image/jpeg','image/png','image/jpg'].includes(file.type)) { this.error='Format harus JPG atau PNG'; this.preview=null; event.target.value=''; return; }
            if (file.size > 2*1024*1024) { this.error='Ukuran file maksimal 2MB'; this.preview=null; event.target.value=''; return; }
            this.fileName = file.name; this.fileSize = (file.size/1024).toFixed(0)+' KB';
            const reader = new FileReader(); reader.onload = (e) => this.preview = e.target.result; reader.readAsDataURL(file);
        },
        clear() { this.preview=null; this.fileName=''; this.fileSize=''; this.error=''; },
    }));

    // ─── Bulk Select ───
    Alpine.data('bulkSelect', () => ({
        selected: [], selectAll: false,
        toggle(id) { const i=this.selected.indexOf(id); i>-1 ? this.selected.splice(i,1) : this.selected.push(id); this.selectAll=false; },
        toggleAll(ids) { if(this.selectAll){this.selected=[];this.selectAll=false;}else{this.selected=[...ids];this.selectAll=true;} },
        isSelected(id) { return this.selected.includes(id); },
        get count() { return this.selected.length; },
    }));

    // ─── Countdown ───
    Alpine.data('countdown', (deadline) => ({
        remaining:'', isUrgent:false, isExpired:false,
        init() { this.update(); setInterval(() => this.update(), 60000); },
        update() {
            const diff = new Date(deadline) - new Date();
            if(diff<=0){this.remaining='Sudah berakhir';this.isExpired=true;return;}
            const h=Math.floor(diff/3600000), d=Math.floor(h/24);
            this.remaining = d>0 ? `Sisa ${d} hari ${h%24} jam` : `Sisa ${h} jam ${Math.floor((diff%3600000)/60000)} menit`;
            this.isUrgent = h < 24;
        },
    }));

    // ─── FilePond Uploader ───
    Alpine.data('filepondUploader', (options = {}) => ({
        pond: null,
        init() {
            const el = this.$refs.pond;
            if (!el) return;
            const token = document.querySelector('meta[name="csrf-token"]')?.content;
            this.pond = FilePond.create({
                ...el,
                files: options.files || [],
                allowMultiple: options.multiple || false,
                maxFileSize: options.maxSize || '2MB',
                acceptedFileTypes: options.types || ['image/jpeg','image/png'],
                labelIdle: options.label || 'Seret file ke sini atau <span class="filepond--label-action">pilih file</span>',
                imagePreviewHeight: 170,
                server: {
                    headers: { 'X-CSRF-TOKEN': token, 'X-Requested-With': 'XMLHttpRequest' },
                    process: options.processUrl || null,
                    revert: options.revertUrl || null,
                },
                onprocessfile: (error, file) => { if (!error) notyf.success('File berhasil diupload'); },
                onerror: (error) => { if (error) notyf.error(error.message || 'Gagal upload'); },
            });
        },
        destroy() { if (this.pond) this.pond.destroy(); },
    }));

    // ─── Tom Select Wrapper ───
    Alpine.data('tomSelectWrapper', (options = {}) => ({
        select: null,
        init() {
            const el = this.$refs.select;
            if (!el) return;
            this.select = new TomSelect(el, {
                create: options.create || false,
                maxItems: options.maxItems || null,
                plugins: options.plugins || ['clear_button','remove_button'],
                placeholder: options.placeholder || 'Pilih...',
                ...options,
            });
        },
        destroy() { if (this.select) this.select.destroy(); },
    }));

    // ─── Grid.js Table ───
    Alpine.data('gridTable', (options = {}) => ({
        grid: null,
        init() {
            const el = this.$refs.grid;
            if (!el) return;
            this.grid = new Grid({
                element: el,
                columns: options.columns || [],
                data: options.data || [],
                search: options.search !== false ? { enabled: true } : false,
                sort: options.sort !== false ? { enabled: true } : false,
                pagination: options.pagination !== false ? { enabled: true, limit: options.limit || 10 } : false,
                className: { table: 'w-full text-sm' },
                ...options,
            });
        },
        updateData(data) { if (this.grid) this.grid.updateData(data); },
        destroy() { if (this.grid) this.grid.destroy(); },
    }));
});

window.Alpine = Alpine;
Alpine.start();

// Re-init Lucide on DOM changes
new MutationObserver(() => refreshIcons()).observe(document.body, { childList:true, subtree:true });
