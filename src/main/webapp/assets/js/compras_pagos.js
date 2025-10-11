/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// compras_pagos.js — Pagos de Compras (CORREGIDO)
// - Requiere: assets/js/common.js (define window.API)
// - Endpoints usados (desde ComprasPagosController):
//     GET    /api/compras/pagos?compraId=&texto=
//     POST   /api/compras/pagos
//     PUT    /api/compras/pagos/{id}
//     DELETE /api/compras/pagos/{id}

(function () {
  // ===== Helpers DOM =====
  const q  = (s, r=document) => r.querySelector(s);
  const qa = (s, r=document) => Array.from(r.querySelectorAll(s));
  const fmtMonto = (v) => Number(v ?? 0).toFixed(2);

  // ===== Estado de filtros (soporta ?compraId= en URL) =====
  let COMPRA_ID = null;
  const params = new URLSearchParams(location.search);
  if (params.get('compraId')) COMPRA_ID = Number(params.get('compraId'));

  // ===== Referencias =====
  let $tblBody, $filtroTexto, $filtroCompraId, $btnBuscar, $btnNuevo;
  let modalEl, bsModal, $form, $id, $compraId, $formaPago, $monto, $referencia, $btnGuardar;

  // ===== Render de tabla =====
  function renderTabla(rows) {
    $tblBody.innerHTML = '';
    if (!rows.length) {
      $tblBody.innerHTML = `<tr><td colspan="6" class="text-center text-muted">Sin registros</td></tr>`;
      return;
    }
    for (const r of rows) {
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${r.id}</td>
        <td>${r.compra_id ?? '-'}</td>
        <td><span class="badge bg-primary-subtle text-primary badge-forma">${(r.forma_pago||'').toUpperCase()}</span></td>
        <td class="text-end">Q ${fmtMonto(r.monto)}</td>
        <td>${r.referencia ?? ''}</td>
        <td class="text-end">
          <button class="btn btn-sm btn-outline-secondary me-2 btn-edit" data-id="${r.id}">
            <i class="bi bi-pencil"></i> Editar
          </button>
          <button class="btn btn-sm btn-outline-danger btn-del" data-id="${r.id}">
            <i class="bi bi-trash"></i> Eliminar
          </button>
        </td>`;
      $tblBody.appendChild(tr);
    }
    // Bind acciones
    qa('.btn-edit').forEach(b => b.addEventListener('click', onEditarClick));
    qa('.btn-del').forEach(b => b.addEventListener('click', onEliminarClick));
  }

  // ===== Lógica de datos =====
  async function cargar() {
    const texto = $filtroTexto.value.trim() || null;
    const compraId = ($filtroCompraId.value || COMPRA_ID || '').toString().trim() || null;
    const qs = [];
    if (compraId) qs.push(`compraId=${encodeURIComponent(compraId)}`);
    if (texto) qs.push(`texto=${encodeURIComponent(texto)}`);
    const url = `/api/compras/pagos${qs.length ? '?' + qs.join('&') : ''}`;
    try {
      const data = await API.request(url, { method: 'GET' });
      renderTabla(data || []);
    } catch (e) {
      API.toast(`Error al listar pagos: ${e.message}`, 'danger');
    }
  }

  function abrirCrear() {
    $form.reset();
    $id.value = '';
    $compraId.value = COMPRA_ID || $filtroCompraId.value || '';
    $btnGuardar.dataset.mode = 'create';
    q('#modalPagoLabel').textContent = 'Nuevo pago de compra';
    bsModal.show();
  }

  function abrirEditar(row) {
    $form.reset();
    $id.value = row.id;
    $compraId.value = row.compra_id;
    $formaPago.value = row.forma_pago;
    $monto.value = row.monto;
    $referencia.value = row.referencia || '';
    $btnGuardar.dataset.mode = 'edit';
    q('#modalPagoLabel').textContent = `Editar pago #${row.id}`;
    bsModal.show();
  }

  function rowDesdeTr(tr, id) {
    return {
      id,
      compra_id: Number(tr.children[1].textContent.trim()) || null,
      forma_pago: tr.querySelector('.badge-forma').textContent.trim().toLowerCase(),
      monto: tr.children[3].textContent.replace(/[^\d.]/g,''),
      referencia: tr.children[4].textContent.trim() || null
    };
  }

  async function onEditarClick(ev) {
    const id = Number(ev.currentTarget.dataset.id);
    const tr = ev.currentTarget.closest('tr');
    abrirEditar(rowDesdeTr(tr, id));
  }

  async function onEliminarClick(ev) {
    const id = Number(ev.currentTarget.dataset.id);
    if (!confirm(`¿Eliminar el pago #${id}?`)) return;
    try {
      await API.request(`/api/compras/pagos/${id}`, { method: 'DELETE' });
      API.toast('Pago eliminado.', 'success');
      cargar();
    } catch (e) {
      API.toast(`Error eliminando: ${e.message}`, 'danger');
    }
  }

  async function onSubmit(ev) {
    ev.preventDefault();
    const mode = $btnGuardar.dataset.mode;
    const payloadCreate = {
      compra_id: Number($compraId.value),
      forma_pago: $formaPago.value.trim(),
      monto: Number($monto.value),
      referencia: $referencia.value.trim() || null
    };
    const payloadEdit = {
      forma_pago: $formaPago.value.trim(),
      monto: Number($monto.value),
      referencia: $referencia.value.trim() || null
    };

    try {
      if (mode === 'create') {
        await API.request('/api/compras/pagos', { method: 'POST', json: payloadCreate });
        API.toast('Pago creado.', 'success');
      } else {
        const id = Number($id.value);
        await API.request(`/api/compras/pagos/${id}`, { method: 'PUT', json: payloadEdit });
        API.toast('Pago actualizado.', 'success');
      }
      bsModal.hide();
      cargar();
    } catch (e) {
      API.toast(`Error guardando: ${e.message}`, 'danger');
    }
  }

  // ===== Init (espera DOM listo) =====
  window.addEventListener('DOMContentLoaded', () => {
    // Refs
    $tblBody = q('#pagos-tbody');
    $filtroTexto = q('#filtro-texto');
    $filtroCompraId = q('#filtro-compra-id');
    $btnBuscar = q('#btn-buscar');
    $btnNuevo  = q('#btn-nuevo');

    modalEl = q('#modalPago');
    bsModal = new bootstrap.Modal(modalEl);
    $form = q('#form-pago');
    $id = q('#pago-id');
    $compraId = q('#compra_id');
    $formaPago = q('#forma_pago');
    $monto = q('#monto');
    $referencia = q('#referencia');
    $btnGuardar = q('#btn-guardar');

    // Eventos
    $btnBuscar.addEventListener('click', cargar);
    $btnNuevo.addEventListener('click', abrirCrear);
    $form.addEventListener('submit', onSubmit);

    // Filtro por querystring
    if (COMPRA_ID) $filtroCompraId.value = String(COMPRA_ID);

    // Carga inicial
    cargar();
  });
})();
