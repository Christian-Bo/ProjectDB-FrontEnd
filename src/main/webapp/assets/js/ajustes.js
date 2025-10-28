// ============================================
// AJUSTES.JS - Ajustes de Inventario
// ============================================

(function() {
    'use strict';

    // Configuración API
    const API_BASE = document.querySelector('meta[name="api-base"]')?.content || 'http://localhost:8080';
    const API_URL = `${API_BASE}/api/ajustes`;
    const API_BODEGAS = `${API_BASE}/api/bodegas`;

    // Referencias DOM
    let toastStack, mdlDetalle, mdlCrear, frmCrear;
    let bodegas = [];

    // ============================================
    // INICIALIZACIÓN
    // ============================================
    document.addEventListener('DOMContentLoaded', init);

    function init() {
        toastStack = document.getElementById('toastStack');
        mdlDetalle = new bootstrap.Modal(document.getElementById('mdlDetalle'));
        mdlCrear = new bootstrap.Modal(document.getElementById('mdlCrear'));
        frmCrear = document.getElementById('frmCrear');

        // Event Listeners
        document.getElementById('btnBuscar')?.addEventListener('click', cargarAjustes);
        document.getElementById('btnNuevoAjuste')?.addEventListener('click', abrirModalCrear);
        document.getElementById('btnAgregarProducto')?.addEventListener('click', agregarProducto);
        frmCrear?.addEventListener('submit', crearAjuste);

        // Establecer fecha de hoy por defecto
        const hoy = new Date().toISOString().split('T')[0];
        const inputFecha = document.getElementById('crear_fecha');
        if (inputFecha) inputFecha.value = hoy;

        // Cargar datos
        cargarBodegas();
        cargarAjustes();
    }

    // ============================================
    // CARGAR BODEGAS
    // ============================================
    async function cargarBodegas() {
        try {
            const response = await fetch(API_BODEGAS);
            if (!response.ok) throw new Error('Error al cargar bodegas');
            
            bodegas = await response.json();
            
            // Llenar selects
            const selectFiltro = document.getElementById('filtroBodega');
            const selectCrear = document.getElementById('crear_bodega');

            [selectFiltro, selectCrear].forEach(select => {
                if (select) {
                    bodegas.forEach(b => {
                        const option = document.createElement('option');
                        option.value = b.id;
                        option.textContent = b.nombre;
                        select.appendChild(option.cloneNode(true));
                    });
                }
            });
        } catch (error) {
            console.error('Error cargando bodegas:', error);
            showToast('Error al cargar bodegas', 'danger');
        }
    }

    // ============================================
    // CARGAR AJUSTES
    // ============================================
    async function cargarAjustes() {
        const bodegaId = document.getElementById('filtroBodega')?.value || '';
        const tipoAjuste = document.getElementById('filtroTipo')?.value || '';
        const fechaDesde = document.getElementById('filtroFechaDesde')?.value || '';
        const fechaHasta = document.getElementById('filtroFechaHasta')?.value || '';

        try {
            showLoading();
            
            let url = API_URL;
            const params = new URLSearchParams();
            if (bodegaId) params.append('bodegaId', bodegaId);
            if (tipoAjuste) params.append('tipoAjuste', tipoAjuste);
            if (fechaDesde) params.append('fechaDesde', fechaDesde);
            if (fechaHasta) params.append('fechaHasta', fechaHasta);
            if (params.toString()) url += '?' + params.toString();

            const response = await fetch(url);
            if (!response.ok) throw new Error('Error al cargar ajustes');

            const ajustes = await response.json();
            renderizarTabla(ajustes);
            document.getElementById('lblResumen').textContent = 
                `Mostrando ${ajustes.length} ajuste(s)`;
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar ajustes', 'danger');
            document.getElementById('tblAjustes').innerHTML = 
                '<tr><td colspan="8" class="text-center text-danger py-4">Error al cargar datos</td></tr>';
        }
    }

    function renderizarTabla(data) {
        const tbody = document.getElementById('tblAjustes');
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="8" class="text-center text-muted py-4">No hay ajustes registrados</td></tr>';
            return;
        }

        tbody.innerHTML = data.map(a => `
            <tr>
                <td><strong>${a.numeroAjuste}</strong></td>
                <td>${formatearFecha(a.fechaAjuste)}</td>
                <td><small>${a.bodegaNombre}</small></td>
                <td>${getBadgeTipo(a.tipoAjuste, a.tipoAjusteDescripcion)}</td>
                <td><small>${a.motivo}</small></td>
                <td><small>${a.responsableNombre || 'N/A'}</small></td>
                <td><small>${a.observaciones || '-'}</small></td>
                <td class="text-end">
                    <button class="btn btn-sm btn-outline-primary" onclick="window.ajustesApp.verDetalle(${a.id})" title="Ver">
                        <i class="bi bi-eye"></i>
                    </button>
                </td>
            </tr>
        `).join('');
    }

    function getBadgeTipo(tipo, descripcion) {
        const badges = {
            'I': 'bg-success',
            'D': 'bg-danger',
            'C': 'bg-warning'
        };
        return `<span class="badge ${badges[tipo] || 'bg-secondary'}">${descripcion || tipo}</span>`;
    }

    // ============================================
    // VER DETALLE
    // ============================================
    async function verDetalle(id) {
        try {
            const response = await fetch(`${API_URL}/${id}`);
            if (!response.ok) throw new Error('Ajuste no encontrado');

            const ajuste = await response.json();
            
            // Llenar información general
            document.getElementById('detNumero').textContent = ajuste.numeroAjuste;
            document.getElementById('detFecha').textContent = formatearFecha(ajuste.fechaAjuste);
            document.getElementById('detTipo').innerHTML = getBadgeTipo(ajuste.tipoAjuste, ajuste.tipoAjusteDescripcion);
            document.getElementById('detBodega').textContent = ajuste.bodegaNombre;
            document.getElementById('detMotivo').textContent = ajuste.motivo;
            document.getElementById('detResponsable').textContent = ajuste.responsableNombre || 'N/A';
            document.getElementById('detObservaciones').textContent = ajuste.observaciones || '-';

            // Llenar tabla de productos
            const tbody = document.getElementById('tblDetalleProductos');
            if (ajuste.detalles && ajuste.detalles.length > 0) {
                tbody.innerHTML = ajuste.detalles.map(d => `
                    <tr>
                        <td><code>${d.productoCodigo}</code></td>
                        <td><strong>${d.productoNombre}</strong></td>
                        <td class="text-center">${d.cantidadAntes || 0}</td>
                        <td class="text-center ${d.cantidadAjuste > 0 ? 'text-success' : 'text-danger'}">
                            <strong>${d.cantidadAjuste > 0 ? '+' : ''}${d.cantidadAjuste}</strong>
                        </td>
                        <td class="text-center"><strong>${d.cantidadDespues || 0}</strong></td>
                        <td>${d.costoUnitario ? formatearMoneda(d.costoUnitario) : '-'}</td>
                    </tr>
                `).join('');
            } else {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted">Sin productos</td></tr>';
            }

            mdlDetalle.show();
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar el detalle', 'danger');
        }
    }

    // ============================================
    // CREAR AJUSTE
    // ============================================
    function abrirModalCrear() {
        frmCrear.reset();
        frmCrear.classList.remove('was-validated');
        
        // Restablecer fecha de hoy
        const hoy = new Date().toISOString().split('T')[0];
        document.getElementById('crear_fecha').value = hoy;

        // Limpiar productos excepto el primero
        const container = document.getElementById('productosContainer');
        container.innerHTML = `
            <div class="producto-item row g-2 mb-2">
                <div class="col-md-2">
                    <input type="number" class="form-control producto-id" placeholder="ID Producto" required>
                </div>
                <div class="col-md-5">
                    <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
                </div>
                <div class="col-md-2">
                    <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" required>
                </div>
                <div class="col-md-3">
                    <input type="number" step="0.01" class="form-control producto-costo" placeholder="Costo" required>
                </div>
            </div>
        `;

        mdlCrear.show();
    }

    function agregarProducto() {
        const container = document.getElementById('productosContainer');
        const newItem = document.createElement('div');
        newItem.className = 'producto-item row g-2 mb-2';
        newItem.innerHTML = `
            <div class="col-md-2">
                <input type="number" class="form-control producto-id" placeholder="ID Producto" required>
            </div>
            <div class="col-md-5">
                <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
            </div>
            <div class="col-md-2">
                <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" required>
            </div>
            <div class="col-md-3">
                <input type="number" step="0.01" class="form-control producto-costo" placeholder="Costo" required>
            </div>
        `;
        container.appendChild(newItem);
    }

    async function crearAjuste(e) {
        e.preventDefault();
        
        if (!frmCrear.checkValidity()) {
            frmCrear.classList.add('was-validated');
            return;
        }

        // Recopilar datos
        const data = {
            numeroAjuste: document.getElementById('crear_numero').value.trim(),
            fechaAjuste: document.getElementById('crear_fecha').value,
            bodegaId: parseInt(document.getElementById('crear_bodega').value),
            tipoAjuste: document.getElementById('crear_tipo').value,
            motivo: document.getElementById('crear_motivo').value.trim(),
            responsableId: parseInt(document.getElementById('crear_responsable').value),
            observaciones: document.getElementById('crear_observaciones').value.trim() || null,
            detalles: []
        };

        // Recopilar productos
        const productosItems = document.querySelectorAll('.producto-item');
        productosItems.forEach(item => {
            const productoId = item.querySelector('.producto-id').value;
            const cantidad = item.querySelector('.producto-cantidad').value;
            const costo = item.querySelector('.producto-costo').value;
            if (productoId && cantidad && costo) {
                data.detalles.push({
                    productoId: parseInt(productoId),
                    cantidadAjuste: parseInt(cantidad),
                    costoUnitario: parseFloat(costo)
                });
            }
        });

        if (data.detalles.length === 0) {
            showToast('Debe agregar al menos un producto', 'warning');
            return;
        }

        try {
            const response = await fetch(API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await response.json();
            
            if (response.ok && result.success) {
                showToast(result.message || 'Ajuste creado exitosamente', 'success');
                mdlCrear.hide();
                cargarAjustes();
            } else {
                throw new Error(result.message || 'Error al crear el ajuste');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message, 'danger');
        }
    }

    // ============================================
    // UTILIDADES
    // ============================================

    function showLoading() {
        document.getElementById('tblAjustes').innerHTML = 
            '<tr><td colspan="8" class="text-center py-4"><div class="spinner-border text-primary"></div></td></tr>';
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

    function formatearFecha(fecha) {
        if (!fecha) return '-';
        const d = new Date(fecha);
        return d.toLocaleDateString('es-GT');
    }

    function formatearMoneda(valor) {
        if (!valor) return '-';
        return new Intl.NumberFormat('es-GT', {
            style: 'currency',
            currency: 'GTQ'
        }).format(valor);
    }

    // ============================================
    // EXPORTAR FUNCIONES PÚBLICAS
    // ============================================

    window.ajustesApp = {
        verDetalle
    };

})();