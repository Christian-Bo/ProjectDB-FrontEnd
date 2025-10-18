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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-purple-4">
  <script src="assets/js/common.js?v=99"></script>

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
    <div class="d-flex align-items-center gap-2 pager">
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(-1)">&laquo; Anterior</button>
      <div> Página <span id="pActual">1</span> </div>
      <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(1)">Siguiente &raquo;</button>
    </div>
    <small class="text-muted">Mostrando 10 por página</small>
  </div>

  <div class="card">
    <div class="table-responsive">
      <table id="tabla" class="table table-striped table-hover align-middle mb-0">
        <thead>
        <tr>
          <th>ID</th>
          <th>Número</th>
          <th>Fecha</th>
          <th>Cliente</th>
          <th class="text-end">Total</th>
          <th>Estado</th>
          <th>Tipo pago</th>
          <th></th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
    <div id="tablaEmpty" class="p-3 text-muted d-none">Sin resultados para los filtros actuales.</div>
  </div>

  <!-- Toasts -->
  <div class="position-fixed bottom-0 end-0 p-3" style="z-index:1080;">
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
            <div class="col-md-4">
              <label class="form-label">Cliente *</label>
              <select id="selCliente" class="form-select" name="clienteId" required>
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Vendedor</label>
              <select id="selVendedor" class="form-select" name="vendedorId">
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Cajero</label>
              <select id="selCajero" class="form-select" name="cajeroId">
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Bodega Origen</label>
              <select id="selBodegaOrigen" class="form-select" name="bodegaOrigenId">
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-4">
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
            <button type="button" class="btn btn-outline-primary btn-sm" onclick="agregarItem()">+ Agregar ítem</button>
          </div>
          <div class="table-responsive">
            <table class="table table-sm table-striped align-middle" id="tablaItems">
              <thead>
              <tr>
                <th style="width:180px;">Bodega *</th>
                <th style="width:320px;">Producto *</th>
                <th style="width:110px;">Stock</th>
                <th style="width:120px;">Cantidad *</th>
                <th style="width:150px;">Precio Unitario *</th>
                <th style="width:120px;">Descuento</th>
                <th style="width:140px;">Lote</th>
                <th style="width:140px;">Vence</th>
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
// ==== Endpoints (renombrados para no chocar con window.API de common.js) ====
const API_VENTAS     = 'http://localhost:8080/api/ventas';
const API_VENTAS_CAT = 'http://localhost:8080/api/catalogos';
const ctx            = '${pageContext.request.contextPath}';

// ==== Utils ====
// fetchJson usa fetch "pelado"; el common.js (v99) ya parcha fetch para inyectar Authorization y X-User-Id.
async function fetchJson(url){
  const res  = await fetch(url);
  if(!res.ok) throw new Error('HTTP '+res.status+' al llamar: '+url);
  // intenta JSON; si no, devuelve texto
  const text = await res.text();
  try { return text ? JSON.parse(text) : null; } catch { return text; }
}
function asArray(payload){
  if (Array.isArray(payload)) return payload;
  if (!payload || typeof payload !== 'object') return [];
  return payload.content || payload.items || payload.data || payload.results || payload.records || [];
}
function formatMoney(n){ if(n==null) return ''; return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(n); }

// ==== Tabla (lista de ventas) ====
let page = 0;
const size = 10;
let lastFilters = {};

async function cargar(params = {}) {
  try{
    const qs = new URLSearchParams({ page, size });
    if (params.desde) qs.set('desde', params.desde);
    if (params.hasta) qs.set('hasta', params.hasta);
    if (params.clienteId) qs.set('clienteId', params.clienteId);
    if (params.numeroVenta) qs.set('numeroVenta', params.numeroVenta);

    const data = await fetchJson(API_VENTAS + '?' + qs.toString());
    const rows = asArray(data);
    render(rows);
    document.getElementById('pActual').textContent = (page+1);
  }catch(err){
    console.error('Error cargando ventas:', err);
    showErr('No se pudo consultar ventas');
    render([]);
  }
}

function render(rows) {
  const tbody = document.querySelector('#tabla tbody');
  const empty = document.getElementById('tablaEmpty');
  tbody.innerHTML = '';
  if (!rows.length){
    empty.classList.remove('d-none');
    return;
  }
  empty.classList.add('d-none');

  for (var i=0;i<rows.length;i++) {
    var v = rows[i];
    var estadoHtml = v && v.estado ? '<span class="badge ok">'+ v.estado +'</span>' : '';
    var clienteTxt = (v && v.clienteNombre && String(v.clienteNombre).trim() !== '')
                     ? v.clienteNombre
                     : ('ID ' + (v && v.clienteId != null ? v.clienteId : ''));
    var link = ctx + '/venta_detalle.jsp?id=' + (v && v.id != null ? v.id : '');
    var tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + (v && v.id != null ? v.id : '') + '</td>'
      + '<td>' + (v && v.numeroVenta != null ? v.numeroVenta : '') + '</td>'
      + '<td>' + (v && v.fechaVenta != null ? v.fechaVenta : '') + '</td>'
      + '<td>' + clienteTxt + '</td>'
      + '<td class="text-end">' + formatMoney(v ? v.total : null) + '</td>'
      + '<td>' + estadoHtml + '</td>'
      + '<td>' + ((v && v.tipoPago) ? v.tipoPago : '') + '</td>'
      + '<td><a class="btn btn-sm btn-outline-primary" href="' + link + '">Ver</a></td>';
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

// ==== Catálogos (Cliente, Empleados, Bodegas) ====
let _catalogosCargados = false;

function fillSelect(sel, data, map){
  var html = '<option value="">Seleccione...</option>';
  for (var i=0;i<data.length;i++){
    var o = map(data[i]);
    html += '<option value="'+o.value+'">'+o.text+'</option>';
  }
  sel.innerHTML = html;
}

async function cargarCatalogos(){
  if (_catalogosCargados) return;
  try{
    const cliRaw = await fetchJson(API_VENTAS_CAT + '/clientes?limit=100');
    const empRaw = await fetchJson(API_VENTAS_CAT + '/empleados?limit=100');
    const bodRaw = await fetchJson(API_VENTAS_CAT + '/bodegas?limit=100');
    const clientes  = asArray(cliRaw);
    const empleados = asArray(empRaw);
    const bodegas   = asArray(bodRaw);

    fillSelect(
      document.getElementById('selCliente'),
      clientes,
      function(c){ 
        return { 
          value: c.id,
          text: ( (c.codigo || ('CLI-'+c.id)) + ' - ' + (c.nombre || c.razonSocial || '') )
        };
      }
    );
    fillSelect(
      document.getElementById('selVendedor'),
      empleados,
      function(e){
        return {
          value: e.id,
          text: ( (e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '') )
        };
      }
    );
    fillSelect(
      document.getElementById('selCajero'),
      empleados,
      function(e){
        return {
          value: e.id,
          text: ( (e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '') )
        };
      }
    );
    fillSelect(
      document.getElementById('selBodegaOrigen'),
      bodegas,
      function(b){ return { value:b.id, text:(b.nombre || ('Bodega '+b.id)) }; }
    );

    _catalogosCargados = true;
  }catch(err){
    console.error('Error catálogos:', err);
    showErr('No se pudieron cargar catálogos');
  }
}

// ==== Items del modal (bodega → productos con stock/precio) ====
function agregarItem(){
  const tbody = document.querySelector('#tablaItems tbody');
  const tr = document.createElement('tr');
  tr.innerHTML =
      '<td>'
    + '  <select class="form-select form-select-sm" name="bodegaId" required>'
    + '    <option value="">Seleccione...</option>'
    + '  </select>'
    + '</td>'
    + '<td>'
    + '  <select class="form-select form-select-sm" name="productoId" required disabled>'
    + '    <option value="">Seleccione bodega...</option>'
    + '  </select>'
    + '</td>'
    + '<td><span class="badge text-bg-secondary" data-stock="0">0</span></td>'
    + '<td><input type="number" step="0.01" min="0.01" class="form-control form-control-sm" name="cantidad" required></td>'
    + '<td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="precioUnitario" required></td>'
    + '<td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="descuento"></td>'
    + '<td><input type="text" class="form-control form-control-sm" name="lote" placeholder="S/N"></td>'
    + '<td><input type="date" class="form-control form-control-sm" name="fechaVencimiento"></td>'
    + '<td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest(\'tr\').remove()">X</button></td>';
  tbody.appendChild(tr);
  cargarBodegasFila(tr.querySelector('select[name="bodegaId"]'));
  wireRowEvents(tr);
}

async function cargarBodegasFila(sel){
  try{
    const raw = await fetchJson(API_VENTAS_CAT + '/bodegas?limit=100');
    const bodegas = asArray(raw);
    var html = '<option value="">Seleccione...</option>';
    for (var i=0;i<bodegas.length;i++){
      var b = bodegas[i];
      html += '<option value="'+b.id+'">'+ (b.nombre || ('Bodega '+b.id)) +'</option>';
    }
    sel.innerHTML = html;
  }catch{
    sel.innerHTML = '<option value="">(sin datos)</option>';
  }
}

function wireRowEvents(tr){
  const selBod = tr.querySelector('select[name="bodegaId"]');
  const selProd = tr.querySelector('select[name="productoId"]');
  const precio  = tr.querySelector('input[name="precioUnitario"]');
  const stockEl = tr.querySelector('[data-stock]');
  const cantInp = tr.querySelector('input[name="cantidad"]');

  selBod.addEventListener('change', async function(){
    selProd.disabled = true;
    selProd.innerHTML = '<option value="">Cargando...</option>';
    stockEl.textContent = '0';
    stockEl.setAttribute('data-stock','0');
    if (!selBod.value) { selProd.innerHTML = '<option value="">Seleccione bodega...</option>'; return; }
    try{
      const raw   = await fetchJson(API_VENTAS_CAT + '/productos?bodegaId=' + encodeURIComponent(selBod.value));
      const prods = asArray(raw);
      var html = '<option value="">Seleccione...</option>';
      for (var i=0;i<prods.length;i++){
        var p = prods[i];
        var st = (p.stockDisponible || 0);
        var pr = (p.precioSugerido || 0);
        html += '<option value="'+p.id+'" data-stock="'+st+'" data-precio="'+pr+'">'+ (p.nombre || ('Producto '+p.id)) +' (stock '+st+')</option>';
      }
      selProd.disabled = false;
      selProd.innerHTML = html;
    }catch{
      selProd.innerHTML = '<option value="">(sin datos)</option>';
      selProd.disabled = false;
    }
  });

  selProd.addEventListener('change', function(){
    const opt = selProd.selectedOptions[0];
    if (!opt) return;
    const st = Number(opt.getAttribute('data-stock') || 0);
    const pr = Number(opt.getAttribute('data-precio') || 0);
    stockEl.textContent = String(st);
    stockEl.setAttribute('data-stock', String(st));
    if (pr > 0) { precio.value = pr; }
  });

  cantInp.addEventListener('input', function(){
    const st = Number(stockEl.getAttribute('data-stock') || 0);
    const q  = Number(cantInp.value || 0);
    if (q > st && st > 0) {
      cantInp.classList.add('is-invalid');
      cantInp.setCustomValidity('No hay stock suficiente');
    } else {
      cantInp.classList.remove('is-invalid');
      cantInp.setCustomValidity('');
    }
  });
}

// ==== Guardar ====
function leerItems(){
  const rows = Array.from(document.querySelectorAll('#tablaItems tbody tr'));
  return rows.map(function(r){
    const get = function(sel){ const el = r.querySelector(sel); return el ? el.value : null; };
    const toNum = function(v){ return (v==='' || v==null) ? null : Number(v); };
    const fv = function(v){ return (v==='' ? null : v); };
    return {
      productoId: toNum(get('select[name="productoId"]')),
      bodegaId: toNum(get('select[name="bodegaId"]')),
      cantidad: toNum(get('input[name="cantidad"]')),
      precioUnitario: toNum(get('input[name="precioUnitario"]')),
      descuento: toNum(get('input[name="descuento"]')),
      lote: fv(get('input[name="lote"]')),
      fechaVencimiento: fv(get('input[name="fechaVencimiento"]'))
    };
  }).filter(function(it){ return it.productoId && it.bodegaId && it.cantidad && it.precioUnitario; });
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
    const res  = await fetch(API_VENTAS, { method:'POST', headers:{'Content-Type':'application/json'}, body: JSON.stringify(payload) });
    const data = await res.json().catch(function(){ return {}; });
    if (!res.ok) { showErr((data && data.error) ? data.error : 'No se pudo registrar la venta'); return; }

    const modal = bootstrap.Modal.getInstance(document.getElementById('modalNuevaVenta'));
    modal.hide();
    document.getElementById('formVenta').reset();
    document.querySelector('#tablaItems tbody').innerHTML = '';
    agregarItem();
    showOk();
    page = 0;
    cargar(lastFilters);
  } catch (err) {
    console.error(err);
    showErr(err.message || 'Error de red');
  }
}

// ==== Helpers ====
function showOk(){ new bootstrap.Toast(document.getElementById('toastOk')).show(); }
function showErr(msg){ const el = document.getElementById('toastErrMsg'); if (el) el.textContent = msg; new bootstrap.Toast(document.getElementById('toastErr')).show(); }

// ==== Boot ====
window.addEventListener('DOMContentLoaded', function(){
  cargar();          // tabla
  agregarItem();     // primera fila
  document.getElementById('modalNuevaVenta').addEventListener('show.bs.modal', cargarCatalogos);
});
</script>

</body>
</html>