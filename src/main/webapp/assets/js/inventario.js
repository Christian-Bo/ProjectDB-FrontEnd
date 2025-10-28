// ============================================
// INVENTARIO.JS - Control de Inventario
// ============================================

(function() {
    'use strict';

    // Configuración API
    const API_BASE = document.querySelector('meta[name="api-base"]')?.content || 'http://localhost:8080';
    const API_URL = `${API_BASE}/api/inventario`;
    const API_BODEGAS = `${API_BASE}/api/bodegas`;

    // Referencias DOM
    let toastStack;
    let bodegas = [];

    // ============================================
    // INICIALIZACIÓN
    // ============================================
    document.addEventListener('DOMContentLoaded', init);

    function init() {
        toastStack = document.getElementById('toastStack');

        // Event Listeners
        document.getElementById('btnBuscarStock')?.addEventListener('click', cargarStock);
        document.getElementById('btnBuscarMov')?.addEventListener('click', cargarMovimientos);
        document.getElementById('btnBuscarAlert')?.addEventListener('click', cargarAlertas);

        // Búsqueda con Enter
        document.getElementById('txtSearchStock')?.addEventListener('keyup', (e) => {
            if (e.key === 'Enter') cargarStock();
        });

        // Al cambiar de tab
        document.querySelectorAll('#inventarioTabs button[data-bs-toggle="tab"]').forEach(tab => {
            tab.addEventListener('shown.bs.tab', (e) => {
                const target = e.target.getAttribute('data-bs-target');
                if (target === '#stock') cargarStock();
                if (target === '#movimientos') cargarMovimientos();
                if (target === '#alertas') cargarAlertas();
            });
        });

        // Cargar datos iniciales
        cargarBodegas();
        cargarStock();
    }

    // ============================================
    // CARGAR BODEGAS (PARA FILTROS)
    // ============================================
    async function cargarBodegas() {
        try {
            const response = await fetch(API_BODEGAS);
            if (!response.ok) throw new Error('Error al cargar bodegas');
            
            bodegas = await response.json();
            
            // Llenar selects
            const selects = [
                document.getElementById('filtroBodegaStock'),
                document.getElementById('filtroBodegaMov'),
                document.getElementById('filtroBodegaAlert')
            ];

            selects.forEach(select => {
                if (select) {
                    bodegas.forEach(b => {
                        const option = document.createElement('option');
                        option.value = b.id;
                        option.textContent = b.nombre;
                        select.appendChild(option);
                    });
                }
            });
        } catch (error) {
            console.error('Error cargando bodegas:', error);
        }
    }

    // ============================================
    // STOCK
    // ============================================
    async function cargarStock() {
        const bodegaId = document.getElementById('filtroBodegaStock')?.value || '';
        const searchTerm = document.getElementById('txtSearchStock')?.value || '';

        try {
            showLoading('tblStock', 9);
            
            let url = API_URL;
            const params = new URLSearchParams();
            if (bodegaId) params.append('bodegaId', bodegaId);
            if (params.toString()) url += '?' + params.toString();

            const response = await fetch(url);
            if (!response.ok) throw new Error('Error al cargar inventario');

            let inventarios = await response.json();

            // Filtrar por búsqueda local
            if (searchTerm) {
                const term = searchTerm.toLowerCase();
                inventarios = inventarios.filter(i => 
                    i.productoNombre?.toLowerCase().includes(term) ||
                    i.productoCodigo?.toLowerCase().includes(term)
                );
            }

            renderizarStock(inventarios);
            document.getElementById('lblResumenStock').textContent = 
                `Mostrando ${inventarios.length} producto(s) en inventario`;
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar el inventario', 'danger');
            document.getElementById('tblStock').innerHTML = 
                '<tr><td colspan="9" class="text-center text-danger py-4">Error al cargar datos</td></tr>';
        }
    }

    function renderizarStock(data) {
        const tbody = document.getElementById('tblStock');
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted py-4">No hay datos de inventario</td></tr>';
            return;
        }

        tbody.innerHTML = data.map(i => `
            <tr>
                <td><code>${i.productoCodigo || 'N/A'}</code></td>
                <td><strong>${i.productoNombre || 'N/A'}</strong></td>
                <td>${i.bodegaNombre || 'N/A'}</td>
                <td><strong class="text-success">${i.cantidadDisponible || 0}</strong></td>
                <td>${i.cantidadReservada || 0}</td>
                <td>${i.cantidadEnTransito || 0}</td>
                <td><strong>${i.cantidadActual || 0}</strong></td>
                <td>${i.ultimoCosto ? formatearMoneda(i.ultimoCosto) : '-'}</td>
                <td>${getBadgeStock(i.cantidadDisponible)}</td>
            </tr>
        `).join('');
    }

    function getBadgeStock(disponible) {
        if (disponible === 0) {
            return '<span class="badge bg-danger">Sin Stock</span>';
        } else if (disponible <= 5) {
            return '<span class="badge bg-warning">Bajo</span>';
        } else {
            return '<span class="badge bg-success">OK</span>';
        }
    }

    // ============================================
    // MOVIMIENTOS (KARDEX)
    // ============================================
    async function cargarMovimientos() {
        const bodegaId = document.getElementById('filtroBodegaMov')?.value || '';
        const fechaDesde = document.getElementById('filtroFechaDesde')?.value || '';
        const fechaHasta = document.getElementById('filtroFechaHasta')?.value || '';

        try {
            showLoading('tblMovimientos', 9);
            
            let url = `${API_URL}/movimientos`;
            const params = new URLSearchParams();
            if (bodegaId) params.append('bodegaId', bodegaId);
            if (fechaDesde) params.append('fechaDesde', fechaDesde);
            if (fechaHasta) params.append('fechaHasta', fechaHasta);
            if (params.toString()) url += '?' + params.toString();

            const response = await fetch(url);
            if (!response.ok) throw new Error('Error al cargar movimientos');

            const movimientos = await response.json();
            renderizarMovimientos(movimientos);
            document.getElementById('lblResumenMov').textContent = 
                `Mostrando ${movimientos.length} movimiento(s)`;
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar movimientos', 'danger');
            document.getElementById('tblMovimientos').innerHTML = 
                '<tr><td colspan="9" class="text-center text-danger py-4">Error al cargar datos</td></tr>';
        }
    }

    function renderizarMovimientos(data) {
        const tbody = document.getElementById('tblMovimientos');
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted py-4">No hay movimientos registrados</td></tr>';
            return;
        }

        tbody.innerHTML = data.map(m => `
            <tr>
                <td>${formatearFechaHora(m.fechaMovimiento)}</td>
                <td>${getBadgeTipoMovimiento(m.tipoMovimiento, m.tipoMovimientoDescripcion)}</td>
                <td><strong>${m.productoNombre}</strong><br><small class="text-muted">${m.productoCodigo}</small></td>
                <td>${m.bodegaNombre}</td>
                <td><strong class="${m.cantidad > 0 ? 'text-success' : 'text-danger'}">${m.cantidad > 0 ? '+' : ''}${m.cantidad}</strong></td>
                <td>${m.cantidadAnterior}</td>
                <td><strong>${m.cantidadNueva}</strong></td>
                <td><small>${m.empleadoNombre || 'N/A'}</small></td>
                <td><small>${m.motivo || '-'}</small></td>
            </tr>
        `).join('');
    }

    function getBadgeTipoMovimiento(tipo, descripcion) {
        const badges = {
            'E': 'bg-success',
            'S': 'bg-danger',
            'T': 'bg-info',
            'A': 'bg-warning'
        };
        return `<span class="badge ${badges[tipo] || 'bg-secondary'}">${descripcion || tipo}</span>`;
    }

    // ============================================
    // ALERTAS
    // ============================================
    async function cargarAlertas() {
        const bodegaId = document.getElementById('filtroBodegaAlert')?.value || '';
        const tipoAlerta = document.getElementById('filtroTipoAlert')?.value || '';

        try {
            showLoading('tblAlertas', 7);
            
            let url = `${API_URL}/alertas`;
            const params = new URLSearchParams();
            if (bodegaId) params.append('bodegaId', bodegaId);
            if (tipoAlerta) params.append('tipoAlerta', tipoAlerta);
            params.append('activa', 'true');
            url += '?' + params.toString();

            const response = await fetch(url);
            if (!response.ok) throw new Error('Error al cargar alertas');

            const alertas = await response.json();
            renderizarAlertas(alertas);
            document.getElementById('lblResumenAlert').textContent = 
                `${alertas.length} alerta(s) activa(s)`;
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar alertas', 'danger');
            document.getElementById('tblAlertas').innerHTML = 
                '<tr><td colspan="7" class="text-center text-danger py-4">Error al cargar datos</td></tr>';
        }
    }

    function renderizarAlertas(data) {
        const tbody = document.getElementById('tblAlertas');
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center text-success py-4"><i class="bi bi-check-circle"></i> No hay alertas activas</td></tr>';
            return;
        }

        tbody.innerHTML = data.map(a => `
            <tr>
                <td>${formatearFechaHora(a.fechaAlerta)}</td>
                <td>${getBadgeTipoAlerta(a.tipoAlerta, a.tipoAlertaDescripcion)}</td>
                <td><strong>${a.productoNombre}</strong><br><small class="text-muted">${a.productoCodigo}</small></td>
                <td>${a.bodegaNombre}</td>
                <td><strong class="${a.cantidadActual === 0 ? 'text-danger' : 'text-warning'}">${a.cantidadActual || 0}</strong></td>
                <td>${a.stockMinimo || '-'}</td>
                <td><small>${a.mensaje || '-'}</small></td>
            </tr>
        `).join('');
    }

    function getBadgeTipoAlerta(tipo, descripcion) {
        const badges = {
            'M': 'bg-warning',
            'S': 'bg-danger',
            'A': 'bg-info'
        };
        return `<span class="badge ${badges[tipo] || 'bg-secondary'}">${descripcion || tipo}</span>`;
    }

    // ============================================
    // UTILIDADES
    // ============================================

    function showLoading(tbodyId, colSpan) {
        const tbody = document.getElementById(tbodyId);
        if (tbody) {
            tbody.innerHTML = `<tr><td colspan="${colSpan}" class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></td></tr>`;
        }
    }

    function showToast(message, type = 'info') {
        const toast = document.createElement('div');
        toast.className = `toast align-items-center text-white bg-${type} border-0`;
        toast.setAttribute('role', 'alert');
        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">${message}</div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
            </div>
        `;
        toastStack.appendChild(toast);
        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
        toast.addEventListener('hidden.bs.toast', () => toast.remove());
    }

    function formatearFechaHora(fecha) {
        if (!fecha) return '-';
        const d = new Date(fecha);
        return d.toLocaleDateString('es-GT', { 
            year: 'numeric', 
            month: '2-digit', 
            day: '2-digit',
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    function formatearMoneda(valor) {
        if (!valor) return '-';
        return new Intl.NumberFormat('es-GT', {
            style: 'currency',
            currency: 'GTQ'
        }).format(valor);
    }

})();