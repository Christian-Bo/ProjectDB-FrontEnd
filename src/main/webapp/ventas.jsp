<%-- 
    Document   : ventas
    Created on : 9/10/2025
    Author     : user
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="es" data-bs-theme="dark">
<head>
  <meta charset="UTF-8">
  <title>Ventas | NextTech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css">
</head>
<body>
<div class="container py-4">

  <div class="d-flex align-items-center justify-content-between mb-3">
    <h2 class="m-0">Ventas</h2>
    <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalNuevaVenta">+ Nueva venta</button>
  </div>

  <div class="card mb-3">
    <div class="card-body">
      <form id="filtros" onsubmit="buscar(event)" class="row g-3">
        <div class="col-md-3">
          <label class="form-label">Desde</label>
          <input type="date" name="desde" class="form-control"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Hasta</label>
          <input type="date" name="hasta" class="form-control"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Cliente ID</label>
          <input type="number" name="clienteId" min="1" placeholder="Ej. 1" class="form-control"/>
        </div>
        <div class="col-md-3">
          <label class="form-label">Número venta</label>
          <input type="text" name="numeroVenta" placeholder="Ej. V-0007 o 007" class="form-control"/>
        </div>
        <div class="col-12 d-flex gap-2 justify-content-end">
          <button class="btn btn-primary" type="submit">Buscar</button>
          <button class="btn btn-outline-secondary" type="button" onclick="limpiar()">Limpiar</button>
        </div>
      </form>
    </div>
  </div>

  <div class="d-flex justify-content-between align-items-center mb-2">
    <div class="d-flex align-items-center gap-2">
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(-1)">&laquo; Anterior</button>
      <div> Página <span id="pActual">1</span> </div>
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(1)">Siguiente &raquo;</button>
    </div>
    <small>Mostrando 10 por página</small>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table id="tabla" class="table table-dark table-striped table-borderless align-middle mb-0">
        <thead>
        <tr>
          <th>ID</th>
          <th>Número</th>
          <th>Fecha</th>
          <th>Cliente</th>
          <th>Total</th>
          <th>Estado</th>
          <th>Tipo pago</th>
          <th></th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
  </div>

  <!-- Toasts -->
  <div class="position-fixed bottom-0 end-0 p-3" style="z-index: 1080;">
    <div id="toastOk" class="toast align-items-center text-bg-success border-0" role="alert">
      <div class="d-flex">
        <div class="toast-body">Venta registrada correctamente.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    </div>
    <div id="toastErr" class="toast align-items-center text-bg-danger border-0 mt-2" role="alert">
      <div class="d-flex">
        <div class="toast-body" id="toastErrMsg">Ocurrió un error.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    </div>
  </div>

</div>

<!-- Modal Nueva Venta -->
<div class="modal fade" id="modalNuevaVenta" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <form id="formVenta" onsubmit="guardarVenta(event)">
        <div class="modal-header">
          <h5 class="modal-title">Registrar nueva venta</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>

        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-3">
              <label class="form-label">Cliente ID *</label>
              <input type="number" min="1" class="form-control" name="clienteId" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">Vendedor ID</label>
              <input type="number" min="1" class="form-control" name="vendedorId">
            </div>
            <div class="col-md-3">
              <label class="form-label">Cajero ID</label>
              <input type="number" min="1" class="form-control" name="cajeroId">
            </div>
            <div class="col-md-3">
              <label class="form-label">Bodega Origen ID</label>
              <input type="number" min="1" class="form-control" name="bodegaOrigenId">
            </div>
            <div class="col-md-3">
              <label class="form-label">Tipo de Pago *</label>
              <select class="form-select" name="tipoPago" required>
                <option value="C" selected>Contado</option>
                <option value="R">Crédito</option>
              </select>
            </div>
            <div class="col-12">
              <label class="form-label">Observaciones</label>
              <input type="text" class="form-control" name="observaciones" placeholder="Venta mostrador">
            </div>
          </div>

          <hr class="my-4">

          <div class="d-flex align-items-center justify-content-between mb-2">
            <h6 class="m-0">Items</h6>
            <button type="button" class="btn btn-outline-secondary btn-sm" onclick="agregarItem()">+ Agregar ítem</button>
          </div>
          <div class="table-responsive">
            <table class="table table-sm table-dark align-middle" id="tablaItems">
              <thead>
              <tr>
                <th style="width:110px;">Producto ID *</th>
                <th style="width:110px;">Bodega ID *</th>
                <th style="width:110px;">Cantidad *</th>
                <th style="width:140px;">Precio Unitario *</th>
                <th style="width:120px;">Descuento</th>
                <th style="width:160px;">Lote</th>
                <th style="width:160px;">Vence</th>
                <th style="width:60px;"></th>
              </tr>
              </thead>
              <tbody></tbody>
            </table>
          </div>
          <div class="form-text">Agrega al menos 1 ítem. Campos con * son obligatorios.</div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button type="submit" class="btn btn-primary">Guardar venta</button>
        </div>
      </form>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
const API = 'http://localhost:8080/api/ventas';
const ctx = '${pageContext.request.contextPath}';
let page = 0;
const size = 10;
let lastFilters = {};

async function cargar(params = {}) {
  const qs = new URLSearchParams({ page, size });
  if (params.desde) qs.set('desde', params.desde);
  if (params.hasta) qs.set('hasta', params.hasta);
  if (params.clienteId) qs.set('clienteId', params.clienteId);
  if (params.numeroVenta) qs.set('numeroVenta', params.numeroVenta);

  const res = await fetch(API + '?' + qs.toString());
  if (!res.ok) { showErr('Error al consultar ventas'); return; }
  const rows = await res.json();
  render(rows);
  document.getElementById('pActual').textContent = (page+1);
}

function render(rows) {
  const tbody = document.querySelector('#tabla tbody');
  tbody.innerHTML = '';
  for (const v of rows) {
    const estadoHtml = v.estado ? `<span class="badge ok">${'${'}v.estado}</span>` : '';
    const cliente = (v.clienteNombre && v.clienteNombre.trim() !== '') ? v.clienteNombre : ('ID ' + v.clienteId);
    const tipoPago = (v.tipoPago ?? '');
    const tr = document.createElement('tr');
    tr.innerHTML = `
      <td>${'${'}v.id}</td>
      <td>${'${'}v.numeroVenta}</td>
      <td>${'${'}v.fechaVenta}</td>
      <td>${'${'}cliente}</td>
      <td>${'${'}v.total}</td>
      <td>${'${'}estadoHtml}</td>
      <td>${'${'}tipoPago}</td>
      <td><a class="btn btn-sm btn-outline-secondary" href="${'${'}ctx}/venta_detalle.jsp?id=${'${'}v.id}">Ver</a></td>
    `;
    tbody.appendChild(tr);
  }
}

function buscar(e){
  e.preventDefault();
  page = 0;
  const f = e.target;
  lastFilters = {
    desde: f.desde.value,
    hasta: f.hasta.value,
    clienteId: f.clienteId.value,
    numeroVenta: f.numeroVenta.value
  };
  cargar(lastFilters);
}
function limpiar(){
  document.getElementById('filtros').reset();
  lastFilters = {};
  page = 0;
  cargar();
}
function cambiarPagina(delta){
  page = Math.max(0, page + delta);
  cargar(lastFilters);
}

function agregarItem(){
  const tbody = document.querySelector('#tablaItems tbody');
  const tr = document.createElement('tr');
  tr.innerHTML = `
    <td><input type="number" min="1" class="form-control form-control-sm" name="productoId" required></td>
    <td><input type="number" min="1" class="form-control form-control-sm" name="bodegaId" required></td>
    <td><input type="number" step="0.01" min="0.01" class="form-control form-control-sm" name="cantidad" required></td>
    <td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="precioUnitario" required></td>
    <td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="descuento"></td>
    <td><input type="text" class="form-control form-control-sm" name="lote" placeholder="S/N"></td>
    <td><input type="date" class="form-control form-control-sm" name="fechaVencimiento"></td>
    <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()">X</button></td>
  `;
  tbody.appendChild(tr);
}
function leerItems(){
  const rows = Array.from(document.querySelectorAll('#tablaItems tbody tr'));
  return rows.map(r => {
    const get = sel => r.querySelector(sel)?.value;
    const toNum = v => (v==='' || v==null) ? null : Number(v);
    const toStr = v => (v==null) ? null : String(v).trim();
    const fv = v => (v==='' ? null : v);
    return {
      productoId: toNum(get('input[name="productoId"]')),
      bodegaId: toNum(get('input[name="bodegaId"]')),
      cantidad: get('input[name="cantidad"]') ? Number(get('input[name="cantidad"]')) : null,
      precioUnitario: get('input[name="precioUnitario"]') ? Number(get('input[name="precioUnitario"]')) : null,
      descuento: get('input[name="descuento"]') ? Number(get('input[name="descuento"]')) : null,
      lote: toStr(get('input[name="lote"]')),
      fechaVencimiento: fv(get('input[name="fechaVencimiento"]'))
    };
  }).filter(it => it.productoId && it.bodegaId && it.cantidad && it.precioUnitario);
}
async function guardarVenta(e){
  e.preventDefault();
  const f = e.target;
  const items = leerItems();
  if (items.length === 0) { showErr('Agrega al menos un ítem'); return; }

  const payload = {
    usuarioId: 1,
    clienteId: Number(f.clienteId.value),
    vendedorId: f.vendedorId.value ? Number(f.vendedorId.value) : null,
    cajeroId: f.cajeroId.value ? Number(f.cajeroId.value) : null,
    bodegaOrigenId: f.bodegaOrigenId.value ? Number(f.bodegaOrigenId.value) : null,
    tipoPago: f.tipoPago.value || 'C',
    observaciones: f.observaciones.value || '',
    items: items
  };

  try {
    const res = await fetch(API, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
    const data = await res.json().catch(() => ({}));
    if (!res.ok) { showErr(data?.error || 'No se pudo registrar la venta'); return; }

    const modalEl = document.getElementById('modalNuevaVenta');
    const modal = bootstrap.Modal.getInstance(modalEl);
    modal.hide();
    document.getElementById('formVenta').reset();
    document.querySelector('#tablaItems tbody').innerHTML = '';
    agregarItem();
    showOk();
    page = 0;
    cargar(lastFilters);
  } catch (err) {
    showErr(err.message || 'Error de red');
  }
}
function showOk(){ new bootstrap.Toast(document.getElementById('toastOk')).show(); }
function showErr(msg){ const el = document.getElementById('toastErrMsg'); if (el) el.textContent = msg; new bootstrap.Toast(document.getElementById('toastErr')).show(); }

window.addEventListener('DOMContentLoaded', () => { cargar(); agregarItem(); });
</script>
</body>
</html>
