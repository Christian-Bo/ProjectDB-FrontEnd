// ============================================
// BODEGAS.JS - Gestión de Bodegas
// ============================================

(function() {
    'use strict';

    // Configuración API
    const API_BASE = document.querySelector('meta[name="api-base"]')?.content || 'http://localhost:8080';
    const API_URL = `${API_BASE}/api/bodegas`;

    // Referencias DOM
    let tblBodegas, txtSearch, chkSoloActivos, btnBuscar, btnOpenCreate;
    let mdlUpsert, mdlView, mdlDelete, frmUpsert;
    let toastStack;

    // Estado
    let bodegas = [];
    let bodegaEditando = null;

    // ============================================
    // INICIALIZACIÓN
    // ============================================
    document.addEventListener('DOMContentLoaded', init);

    function init() {
        // Referencias DOM
        tblBodegas = document.getElementById('tblBodegas');
        txtSearch = document.getElementById('txtSearch');
        chkSoloActivos = document.getElementById('chkSoloActivos');
        btnBuscar = document.getElementById('btnBuscar');
        btnOpenCreate = document.getElementById('btnOpenCreate');
        frmUpsert = document.getElementById('frmUpsert');
        toastStack = document.getElementById('toastStack');

        // Modales
        mdlUpsert = new bootstrap.Modal(document.getElementById('mdlUpsert'));
        mdlView = new bootstrap.Modal(document.getElementById('mdlView'));
        mdlDelete = new bootstrap.Modal(document.getElementById('mdlDelete'));

        // Event Listeners
        btnBuscar.addEventListener('click', cargarBodegas);
        btnOpenCreate.addEventListener('click', abrirModalCrear);
        frmUpsert.addEventListener('submit', guardarBodega);
        txtSearch.addEventListener('keyup', (e) => {
            if (e.key === 'Enter') cargarBodegas();
        });

        // Cargar datos inicial
        cargarBodegas();
    }

    // ============================================
    // API CALLS
    // ============================================

    async function cargarBodegas() {
        try {
            showLoading();
            const response = await fetch(API_URL);
            
            if (!response.ok) {
                throw new Error('Error al cargar bodegas');
            }

            bodegas = await response.json();
            filtrarYRenderizar();
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al cargar las bodegas', 'danger');
            tblBodegas.innerHTML = '<tr><td colspan="8" class="text-center text-danger py-4">Error al cargar datos</td></tr>';
        }
    }

    async function obtenerBodegaPorId(id) {
        try {
            const response = await fetch(`${API_URL}/${id}`);
            if (!response.ok) throw new Error('Bodega no encontrada');
            return await response.json();
        } catch (error) {
            console.error('Error:', error);
            showToast('Error al obtener la bodega', 'danger');
            return null;
        }
    }

    async function crearBodega(data) {
        try {
            const response = await fetch(API_URL, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await response.json();
            
            if (response.ok && result.success) {
                showToast(result.message || 'Bodega creada exitosamente', 'success');
                return result.data;
            } else {
                throw new Error(result.message || 'Error al crear la bodega');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message, 'danger');
            return null;
        }
    }

    async function actualizarBodega(id, data) {
        try {
            const response = await fetch(`${API_URL}/${id}`, {
                method: 'PUT',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(data)
            });

            const result = await response.json();
            
            if (response.ok && result.success) {
                showToast(result.message || 'Bodega actualizada exitosamente', 'success');
                return result.data;
            } else {
                throw new Error(result.message || 'Error al actualizar la bodega');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message, 'danger');
            return null;
        }
    }

    async function eliminarBodega(id) {
        try {
            const response = await fetch(`${API_URL}/${id}`, {
                method: 'DELETE'
            });

            const result = await response.json();
            
            if (response.ok && result.success) {
                showToast(result.message || 'Bodega desactivada exitosamente', 'success');
                return true;
            } else {
                throw new Error(result.message || 'Error al desactivar la bodega');
            }
        } catch (error) {
            console.error('Error:', error);
            showToast(error.message, 'danger');
            return false;
        }
    }

    // ============================================
    // RENDERIZADO
    // ============================================

    function filtrarYRenderizar() {
        const searchTerm = txtSearch.value.toLowerCase();
        const soloActivos = chkSoloActivos.checked;

        let bodegasFiltradas = bodegas.filter(b => {
            const matchSearch = !searchTerm || 
                b.nombre?.toLowerCase().includes(searchTerm) ||
                b.direccion?.toLowerCase().includes(searchTerm) ||
                b.telefono?.toLowerCase().includes(searchTerm);
            
            const matchActivo = !soloActivos || b.activo === true;
            
            return matchSearch && matchActivo;
        });

        renderizarTabla(bodegasFiltradas);
        actualizarResumen(bodegasFiltradas.length, bodegas.length);
    }

    function renderizarTabla(data) {
        if (data.length === 0) {
            tblBodegas.innerHTML = '<tr><td colspan="8" class="text-center text-muted py-4">No hay bodegas para mostrar</td></tr>';
            return;
        }

        tblBodegas.innerHTML = data.map(b => `
            <tr>
                <td><strong>${b.id}</strong></td>
                <td><strong>${b.nombre}</strong></td>
                <td>${b.direccion || '-'}</td>
                <td>${b.telefono || '-'}</td>
                <td>${b.email || '-'}</td>
                <td>${getBadgeEstado(b.activo)}</td>
                <td>${b.responsableNombre || '-'}</td>
                <td class="text-end">
                    <div class="btn-group btn-group-sm">
                        <button class="btn btn-outline-primary" onclick="window.bodegasApp.verDetalle(${b.id})" title="Ver">
                            <i class="bi bi-eye"></i>
                        </button>
                        <button class="btn btn-outline-warning" onclick="window.bodegasApp.editar(${b.id})" title="Editar">
                            <i class="bi bi-pencil"></i>
                        </button>
                        <button class="btn btn-outline-danger" onclick="window.bodegasApp.confirmarEliminar(${b.id}, '${b.nombre}')" title="Desactivar">
                            <i class="bi bi-trash"></i>
                        </button>
                    </div>
                </td>
            </tr>
        `).join('');
    }

    function showLoading() {
        tblBodegas.innerHTML = '<tr><td colspan="8" class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></td></tr>';
    }

    function actualizarResumen(filtrados, total) {
        document.getElementById('lblResumen').textContent = 
            `Mostrando ${filtrados} de ${total} bodega(s)`;
    }

    function getBadgeEstado(activo) {
        return activo 
            ? '<span class="badge bg-success">Activa</span>' 
            : '<span class="badge bg-secondary">Inactiva</span>';
    }

    // ============================================
    // MODALES
    // ============================================

    function abrirModalCrear() {
        bodegaEditando = null;
        frmUpsert.reset();
        frmUpsert.classList.remove('was-validated');
        document.getElementById('mdlUpsertTitle').innerHTML = '<i class="bi bi-plus-circle"></i> Nueva Bodega';
        document.getElementById('bodega_activo').checked = true;
        mdlUpsert.show();
    }

    async function editar(id) {
        const bodega = await obtenerBodegaPorId(id);
        if (!bodega) return;

        bodegaEditando = bodega;
        document.getElementById('mdlUpsertTitle').innerHTML = '<i class="bi bi-pencil-square"></i> Editar Bodega';
        document.getElementById('bodega_id').value = bodega.id;
        document.getElementById('bodega_nombre').value = bodega.nombre;
        document.getElementById('bodega_direccion').value = bodega.direccion || '';
        document.getElementById('bodega_telefono').value = bodega.telefono || '';
        document.getElementById('bodega_email').value = bodega.email || '';
        document.getElementById('bodega_responsable_id').value = bodega.responsableId || '';
        document.getElementById('bodega_activo').checked = bodega.activo;

        frmUpsert.classList.remove('was-validated');
        mdlUpsert.show();
    }

    async function verDetalle(id) {
        const bodega = await obtenerBodegaPorId(id);
        if (!bodega) return;

        const content = document.getElementById('viewContent');
        content.innerHTML = `
            <dt class="col-sm-4">ID:</dt>
            <dd class="col-sm-8">${bodega.id}</dd>
            
            <dt class="col-sm-4">Nombre:</dt>
            <dd class="col-sm-8"><strong>${bodega.nombre}</strong></dd>
            
            <dt class="col-sm-4">Dirección:</dt>
            <dd class="col-sm-8">${bodega.direccion || '-'}</dd>
            
            <dt class="col-sm-4">Teléfono:</dt>
            <dd class="col-sm-8">${bodega.telefono || '-'}</dd>
            
            <dt class="col-sm-4">Email:</dt>
            <dd class="col-sm-8">${bodega.email || '-'}</dd>
            
            <dt class="col-sm-4">Estado:</dt>
            <dd class="col-sm-8">${getBadgeEstado(bodega.activo)}</dd>
            
            <dt class="col-sm-4">Responsable:</dt>
            <dd class="col-sm-8">${bodega.responsableId ? `ID: ${bodega.responsableId}` : '-'}</dd>
            
            <dt class="col-sm-4">Fecha Creación:</dt>
            <dd class="col-sm-8">${bodega.fechaCreacion ? formatearFecha(bodega.fechaCreacion) : '-'}</dd>
        `;

        mdlView.show();
    }

    function confirmarEliminar(id, nombre) {
        document.getElementById('delNombre').textContent = nombre;
        document.getElementById('btnConfirmDelete').onclick = async () => {
            const success = await eliminarBodega(id);
            if (success) {
                mdlDelete.hide();
                cargarBodegas();
            }
        };
        mdlDelete.show();
    }

    // ============================================
    // GUARDAR
    // ============================================

    async function guardarBodega(e) {
        e.preventDefault();
        
        if (!frmUpsert.checkValidity()) {
            frmUpsert.classList.add('was-validated');
            return;
        }

        const data = {
            nombre: document.getElementById('bodega_nombre').value.trim(),
            direccion: document.getElementById('bodega_direccion').value.trim() || null,
            telefono: document.getElementById('bodega_telefono').value.trim() || null,
            email: document.getElementById('bodega_email').value.trim() || null,
            responsableId: document.getElementById('bodega_responsable_id').value || null,
            activo: document.getElementById('bodega_activo').checked
        };

        let result;
        if (bodegaEditando) {
            result = await actualizarBodega(bodegaEditando.id, data);
        } else {
            result = await crearBodega(data);
        }

        if (result) {
            mdlUpsert.hide();
            cargarBodegas();
        }
    }

    // ============================================
    // UTILIDADES
    // ============================================

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
        return d.toLocaleDateString('es-GT') + ' ' + d.toLocaleTimeString('es-GT');
    }

    // ============================================
    // EXPORTAR FUNCIONES PÚBLICAS
    // ============================================

    window.bodegasApp = {
        editar,
        verDetalle,
        confirmarEliminar
    };

})();