// ============================================
// TRANSFERENCIAS.JS - Gestión de Transferencias
// ============================================

(function() {
    'use strict';

    // Configuración API
    const API_BASE = document.querySelector('meta[name="api-base"]')?.content || 'http://localhost:8080';
    const API_URL = `${API_BASE}/api/transferencias`;
    const API_BODEGAS = `${API_BASE}/api/bodegas`;

    // Referencias DOM
    let toastStack, mdlDetalle, mdlCrear, frmCrear;
    let bodegas = [];
    let transferencias = [];

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
        document.getElementById('btnBuscar')?.addEventListener('click', cargarTransferencias);
        document.getElementById('btnNuevaTransferencia')?.addEventListener('click', abrirModalCrear);
        document.getElementById('btnAgregarProducto')?.addEventListener('click', agregarProducto);
        frmCrear?.addEventListener('submit', crearTransferencia);

        // Establecer fecha de hoy por defecto
        const hoy = new Date().toISOString().split('T')[0];
        const inputFecha = document.getElementById('crear_fecha');
        if (inputFecha) inputFecha.value = hoy;

        // Cargar datos
        cargarBodegas();
        cargarTransferencias();
    }

    // ============================================
    // CARGAR BODEGAS
    // ============================================
    async function cargarBodegas() {
        try {
            const response = await fetch(API_BODEGAS);
            if (!response.ok) throw new Error('Error al cargar bodegas');
            
            bodegas = await response.json();
            
            // Llenar selects de filtros
            const selectOrigen = document.getElementById('filtroBodegaOrigen');
            const selectDestino = document.getElementById('filtroBodegaDestino');
            const selectCrearOrigen = document.getElementById('crear_bodega_origen');
            const selectCrearDestino = document.getElementById('crear_bodega_destino');

            [selectOrigen, selectDestino, selectCrearOrigen, selectCrearDestino].forEach(select => {
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
    // CARGAR TRANSFERENCIAS
    // ============================================
    async function cargarTransferencias() {
        const bodegaOrigenId = document.getElementById('filtroBodegaOrigen')?.value || '';
        const bodegaDestinoId = document.getElementById('filtroBodegaDestino')?.value || '';
        const estado = document.getElementById('filtroEstado')?.value || '';

        try {
            showLoading();
            
            let url = API_URL;
            const params = new URLSearchParams();
            if (bodegaOrigenId) params.append('bodegaOrigenId', bodegaOrigenId);
            if (bodegaDestinoId) params.append('bodegaDestinoId', bodegaDestinoId);
            if (estado) params.append('estado', estado);
            if (params.toString()) url += '?' + params.toString();

            const response = await fetch(url);
            if (!response.ok) throw new Error('Error al cargar transferencias');

            transferencias = await response.json();
            renderizarTabla(transferencias);
            document.getElementById('lblResumen').textContent = 
                `Mostrando ${transferencias.length} transferencia(s)`;
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar transferencias', 'danger');
            document.getElementById('tblTransferencias').innerHTML = 
                '<tr><td colspan="9" class="text-center text-danger py-4">Error al cargar datos</td></tr>';
        }
    }

    function renderizarTabla(data) {
        const tbody = document.getElementById('tblTransferencias');
        
        if (data.length === 0) {
            tbody.innerHTML = '<tr><td colspan="9" class="text-center text-muted py-4">No hay transferencias registradas</td></tr>';
            return;
        }

        tbody.innerHTML = data.map(t => `
            <tr>
                <td><strong>${t.numeroTransferencia}</strong></td>
                <td>${formatearFecha(t.fechaTransferencia)}</td>
                <td><small>${t.bodegaOrigenNombre}</small></td>
                <td><small>${t.bodegaDestinoNombre}</small></td>
                <td>${getBadgeEstado(t.estado, t.estadoDescripcion)}</td>
                <td>${t.fechaEnvio ? formatearFecha(t.fechaEnvio) : '-'}</td>
                <td>${t.fechaRecepcion ? formatearFecha(t.fechaRecepcion) : '-'}</td>
                <td><small>${t.observaciones || '-'}</small></td>
                <td class="text-end">
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary" onclick="window.transferenciaApp.verDetalle(${t.id})" title="Ver">
                            <i class="bi bi-eye"></i>
                        </button>
                        ${t.estado === 'P' ? `
                        <button class="btn btn-outline-success" onclick="window.transferenciaApp.enviar(${t.id})" title="Enviar">
                            <i class="bi bi-send"></i>
                        </button>
                        <button class="btn btn-outline-danger" onclick="window.transferenciaApp.cancelar(${t.id})" title="Cancelar">
                            <i class="bi bi-x-circle"></i>
                        </button>
                        ` : ''}
                        ${t.estado === 'E' ? `
                        <button class="btn btn-outline-info" onclick="window.transferenciaApp.recibir(${t.id})" title="Recibir">
                            <i class="bi bi-box-arrow-in-down"></i>
                        </button>
                        ` : ''}
                    </div>
                </td>
            </tr>
        `).join('');
    }

    function getBadgeEstado(estado, descripcion) {
        const badges = {
            'P': 'bg-warning',
            'E': 'bg-info',
            'R': 'bg-success',
            'C': 'bg-danger'
        };
        return `<span class="badge ${badges[estado] || 'bg-secondary'}">${descripcion || estado}</span>`;
    }

    // ============================================
    // VER DETALLE
    // ============================================
    async function verDetalle(id) {
        try {
            const response = await fetch(`${API_URL}/${id}`);
            if (!response.ok) throw new Error('Transferencia no encontrada');

            const transferencia = await response.json();
            
            // Llenar información general
            document.getElementById('detNumero').textContent = transferencia.numeroTransferencia;
            document.getElementById('detFecha').textContent = formatearFecha(transferencia.fechaTransferencia);
            document.getElementById('detEstado').innerHTML = getBadgeEstado(transferencia.estado, transferencia.estadoDescripcion);
            document.getElementById('detOrigen').textContent = transferencia.bodegaOrigenNombre;
            document.getElementById('detDestino').textContent = transferencia.bodegaDestinoNombre;
            document.getElementById('detObservaciones').textContent = transferencia.observaciones || '-';

            // Llenar tabla de productos
            const tbody = document.getElementById('tblDetalleProductos');
            if (transferencia.detalles && transferencia.detalles.length > 0) {
                tbody.innerHTML = transferencia.detalles.map(d => `
                    <tr>
                        <td><code>${d.productoCodigo}</code></td>
                        <td><strong>${d.productoNombre}</strong></td>
                        <td class="text-center">${d.cantidadSolicitada}</td>
                        <td class="text-center">${d.cantidadEnviada || 0}</td>
                        <td class="text-center">${d.cantidadRecibida || 0}</td>
                    </tr>
                `).join('');
            } else {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Sin productos</td></tr>';
            }

            mdlDetalle.show();
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar el detalle', 'danger');
        }
    }

    // ============================================
    // CREAR TRANSFERENCIA
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
                    <input type="number" class="form-control producto-id" placeholder="Producto ID" required>
                </div>
                <div class="col-md-8">
                    <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
                </div>
                <div class="col-md-2">
                    <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" min="1" required>
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
                <input type="number" class="form-control producto-id" placeholder="Producto ID" required>
            </div>
            <div class="col-md-8">
                <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
            </div>
            <div class="col-md-2">
                <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" min="1" required>
            </div>
        `;
        container.appendChild(newItem);
    }

    async function crearTransferencia(e) {
        e.preventDefault();
        
        if (!frmCrear.checkValidity()) {
            frmCrear.classList.add('was-validated');
            return;
        }

        // Recopilar datos
        const data = {
            numeroTransferencia: document.getElementById('crear_numero').value.trim(),
            fechaTransferencia: document.getElementById('crear_fecha').value,
            bodegaOrigenId: parseInt(document.getElementById('crear_bodega_origen').value),
            bodegaDestinoId: parseInt(document.getElementById('crear_bodega_destino').value),
            solicitadoPor: parseInt(document.getElementById('crear_solicitado').value),
            observaciones: document.getElementById('crear_observaciones').value.trim() || null,
            detalles: []
        };

        // Validar bodegas diferentes
        if (data.bodegaOrigenId === data.bodegaDestinoId) {
            showToast('La bodega origen y destino deben ser diferentes', 'warning');
            return;
        }

        // Recopilar productos
        const productosItems = document.querySelectorAll('.producto-item');
        productosItems.forEach(item => {
            const productoId = item.querySelector('.producto-id').value;
            const cantidad = item.querySelector('.producto-cantidad').value;
            if (productoId && cantidad) {
                data.detalles.push({
                    productoId: parseInt(productoId),
                    cantidadSolicitada: parseInt(cantidad)
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
                showToast(result.message || 'Transferencia creada exitosamente', 'success');
                mdlCrear.hide();
                cargarTransferencias();
            } else {
                throw new Error(result.message || 'Error al crear la transferencia');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message, 'danger');
        }
    }

    // ============================================
    // CAMBIAR ESTADO
    // ============================================
    async function enviar(id) {
        if (!confirm('¿Desea marcar esta transferencia como ENVIADA?')) return;
        await cambiarEstado(id, 'E');
    }

    async function recibir(id) {
        if (!confirm('¿Desea marcar esta transferencia como RECIBIDA?')) return;
        await cambiarEstado(id, 'R');
    }

    async function cancelar(id) {
        if (!confirm('¿Desea CANCELAR esta transferencia?')) return;
        await cambiarEstado(id, 'C');
    }

    async function cambiarEstado(id, nuevoEstado) {
        try {
            const response = await fetch(`${API_URL}/${id}/estado`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    nuevoEstado: nuevoEstado,
                    empleadoId: 1 // Hardcoded, en producción vendría de la sesión
                })
            });

            const result = await response.json();
            
            if (response.ok && result.success) {
                showToast(result.message || 'Estado actualizado', 'success');
                cargarTransferencias();
            } else {
                throw new Error(result.message || 'Error al cambiar el estado');
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
        document.getElementById('tblTransferencias').innerHTML = 
            '<tr><td colspan="9" class="text-center py-4"><div class="spinner-border text-primary"></div></td></tr>';
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

    // ============================================
    // EXPORTAR FUNCIONES PÚBLICAS
    // ============================================

    window.transferenciaApp = {
        verDetalle,
        enviar,
        recibir,
        cancelar
    };

})();