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
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-purple-5">
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
          <th class="text-end">Acciones</th>
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
        <div class="toast-body" id="toastOkMsg">Operación realizada correctamente.</div>
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

<!-- Modal Selector de Edición -->
<div class="modal fade" id="modalAccionesEdicion" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">¿Qué deseas editar?</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="editTargetId">
        <p class="mb-3">Selecciona el ámbito de edición para la venta <b id="editTargetNumero"></b>.</p>
        <div class="d-grid gap-2">
          <button class="btn btn-primary" onclick="abrirEditarCabecera()">Cabecera</button>
          <button class="btn btn-outline-primary" onclick="abrirEditarMaestroDetalle()">Editar maestro-detalle</button>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Modal Editar Venta (Cabecera) -->
<div class="modal fade" id="modalEditarVenta" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <div class="modal-content">
      <form id="formEditarVenta" onsubmit="guardarEdicionVenta(event)">
        <div class="modal-header">
          <h5 class="modal-title">Editar cabecera <span id="editNumeroVenta" class="text-muted"></span></h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="editVentaId">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label">Cliente *</label>
              <select id="editCliente" class="form-select" required>
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Tipo de pago *</label>
              <select id="editTipoPago" class="form-select" required>
                <option value="C">Contado</option>
                <option value="R">Crédito</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Vendedor</label>
              <select id="editVendedor" class="form-select">
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Cajero</label>
              <select id="editCajero" class="form-select">
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Bodega Origen</label>
              <select id="editBodega" class="form-select">
                <option value="">Cargando...</option>
              </select>
            </div>
            <div class="col-12">
              <label class="form-label">Observaciones</label>
              <input type="text" id="editObs" class="form-control" placeholder="Observaciones">
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" type="button" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn btn-primary" type="submit">Guardar cambios</button>
        </div>
      </form>
    </div>
  </div>
</div>

<!-- Modal Confirmar Eliminación -->
<div class="modal fade" id="modalEliminar" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">Confirmar eliminación</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="delVentaId">
        <p>¿Seguro que deseas eliminar (lógico) la venta <b id="delNumeroVenta"></b>?</p>
        <p class="text-muted mb-0">Puedes revertirlo desde backoffice si se requiere.</p>
      </div>
      <div class="modal-footer">
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-danger" onclick="confirmarEliminar()">Sí, eliminar</button>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// ==== Endpoints / Config ====
const API     = 'http://localhost:8080/api/ventas';
const API_CAT = 'http://localhost:8080/api/catalogos';
const USER_ID = 1; // <-- AJUSTA si tu backend exige el usuario autenticado
const ctx     = '${pageContext.request.contextPath}';
const commonHeaders = {'X-User-Id': String(USER_ID)};

// ==== Utils ====
async function tryFetchJson(url, options){
  try{
    const res = await fetch(url, options || {});
    if(!res.ok) return { ok:false, status:res.status, data: await safeJson(res) };
    return { ok:true, status:res.status, data: await safeJson(res) };
  }catch(err){
    console.error('fetch fail', url, err);
    return { ok:false, status:0, data:{ error: err.message || 'network' } };
  }
}
async function safeJson(res){ try{ return await res.json(); }catch{ return {}; } }

async function fetchJsonOrNull(url){
  const r = await tryFetchJson(url, { headers: commonHeaders });
  return r.ok ? r.data : null;
}
function asArray(payload){
  if (Array.isArray(payload)) return payload;
  if (!payload || typeof payload !== 'object') return [];
  return payload.content || payload.items || payload.data || payload.results || payload.records || [];
}
function formatMoney(n){ if(n==null) return ''; return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(n); }
function setOk(msg){ document.getElementById('toastOkMsg').textContent = msg || 'OK'; new bootstrap.Toast(document.getElementById('toastOk')).show(); }
function setErr(msg){ document.getElementById('toastErrMsg').textContent = msg || 'Error interno'; new bootstrap.Toast(document.getElementById('toastErr')).show(); }

// ==== Tabla (lista de ventas) ====
let page = 0;
const size = 10;
let lastFilters = {};
let cacheVentas = {}; // por id

async function cargar(params = {}) {
  const qs = new URLSearchParams({ page, size });
  if (params.desde) qs.set('desde', params.desde);
  if (params.hasta) qs.set('hasta', params.hasta);
  if (params.clienteId) qs.set('clienteId', params.clienteId);
  if (params.numeroVenta) qs.set('numeroVenta', params.numeroVenta);

  const r = await tryFetchJson(API + '?' + qs.toString(), { headers: commonHeaders });
  const rows = r.ok ? asArray(r.data) : [];
  if(!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo consultar ventas'); }

  cacheVentas = {};
  for (var i=0;i<rows.length;i++){ cacheVentas[rows[i].id] = rows[i]; }
  render(rows);
  document.getElementById('pActual').textContent = (page+1);
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
      + '<td class="text-end">'
      +   '<div class="btn-group btn-group-sm" role="group">'
      +     '<button class="btn btn-outline-primary" onclick="abrirSelectorEdicion('+v.id+')">Actualizar</button>'
      +     '<a class="btn btn-outline-secondary" href="'+link+'">Ver</a>'
      +     '<button class="btn btn-outline-danger" onclick="abrirEliminar('+v.id+')">Eliminar</button>'
      +   '</div>'
      + '</td>';
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

// ==== Catálogos robustos ====
let _catalogosCargados = false;
let _clientes=[], _empleados=[], _bodegas=[];

function fillSelect(sel, data, map, selected){
  var html = '<option value="">Seleccione...</option>';
  for (var i=0;i<data.length;i++){
    var o = map(data[i]);
    html += '<option value="'+o.value+'"'+(String(selected)===String(o.value)?' selected':'')+'>'+o.text+'</option>';
  }
  sel.innerHTML = html;
}

async function cargarCatalogos(){
  if (_catalogosCargados) return;
  try{
    // Intento 1: /api/catalogos/*
    let cli = await fetchJsonOrNull(API_CAT + '/clientes?limit=200');
    let emp = await fetchJsonOrNull(API_CAT + '/empleados?limit=200');
    let bod = await fetchJsonOrNull(API_CAT + '/bodegas?limit=200');

    // Intento 2: /api/*
    if (!cli) cli = await fetchJsonOrNull('http://localhost:8080/api/clientes?limit=200');
    if (!emp) emp = await fetchJsonOrNull('http://localhost:8080/api/empleados?limit=200');
    if (!bod) bod = await fetchJsonOrNull('http://localhost:8080/api/bodegas?limit=200');

    _clientes  = asArray(cli);
    _empleados = asArray(emp);
    _bodegas   = asArray(bod);

    // Relleno para "Nueva venta"
    fillSelect(
      document.getElementById('selCliente'),
      _clientes,
      function(c){ 
        return { 
          value: c.id,
          text: ( (c.codigo || ('CLI-'+c.id)) + ' - ' + (c.nombre || c.razonSocial || '') )
        };
      }
    );
    fillSelect(
      document.getElementById('selVendedor'),
      _empleados,
      function(e){
        return {
          value: e.id,
          text: ( (e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '') )
        };
      }
    );
    fillSelect(
      document.getElementById('selCajero'),
      _empleados,
      function(e){
        return {
          value: e.id,
          text: ( (e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '') )
        };
      }
    );
    fillSelect(
      document.getElementById('selBodegaOrigen'),
      _bodegas,
      function(b){ return { value:b.id, text:(b.nombre || ('Bodega '+b.id)) }; }
    );

    _catalogosCargados = true;
  }catch(err){
    console.error('Error catálogos:', err);
    setErr('No se pudieron cargar catálogos');
    // fallback mínimo para no bloquear
    document.getElementById('selCliente').innerHTML = '<option value="">(sin datos)</option>';
    document.getElementById('selVendedor').innerHTML = '<option value="">(sin datos)</option>';
    document.getElementById('selCajero').innerHTML = '<option value="">(sin datos)</option>';
    document.getElementById('selBodegaOrigen').innerHTML = '<option value="">(sin datos)</option>';
  }
}

// ==== Items del modal (nueva venta) ====
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
    let bod = await fetchJsonOrNull(API_CAT + '/bodegas?limit=200');
    if (!bod) bod = await fetchJsonOrNull('http://localhost:8080/api/bodegas?limit=200');
    const bodegas = asArray(bod);
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
      // productos por bodega (dos rutas posibles)
      let p1 = await fetchJsonOrNull(API_CAT + '/productos?bodegaId=' + encodeURIComponent(selBod.value));
      if (!p1) p1 = await fetchJsonOrNull('http://localhost:8080/api/productos?bodegaId=' + encodeURIComponent(selBod.value));
      const prods = asArray(p1);
      var html = '<option value="">Seleccione...</option>';
      for (var i=0;i<prods.length;i++){
        var p = prods[i];
        var st = (p.stockDisponible || p.stock || 0);
        var pr = (p.precioSugerido || p.precio || 0);
        html += '<option value="'+p.id+'" data-stock="'+st+'" data-precio="'+pr+'">'+ (p.nombre || ('Producto '+p.id)) +' (stock '+st+')</option>';
      }
      selProd.disabled = false;
      selProd.innerHTML = html || '<option value="">(sin datos)</option>';
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

// ==== Guardar NUEVA venta ====
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
  if (items.length === 0) { setErr('Agrega al menos un ítem'); return; }

  const payload = {
    usuarioId: USER_ID,
    clienteId: Number(f.clienteId.value),
    vendedorId: f.vendedorId.value ? Number(f.vendedorId.value) : null,
    cajeroId: f.cajeroId.value ? Number(f.cajeroId.value) : null,
    bodegaOrigenId: f.bodegaOrigenId.value ? Number(f.bodegaOrigenId.value) : null,
    tipoPago: f.tipoPago.value || 'C',
    observaciones: f.observaciones.value || '',
    items: items
  };

  const r = await tryFetchJson(API, { method:'POST', headers:{'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify(payload) });
  if (!r.ok) { setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo registrar la venta'); return; }

  bootstrap.Modal.getInstance(document.getElementById('modalNuevaVenta')).hide();
  document.getElementById('formVenta').reset();
  document.querySelector('#tablaItems tbody').innerHTML = '';
  agregarItem();
  setOk('Venta registrada');
  page = 0;
  cargar(lastFilters);
}

// ==== Selector de edición ====
function abrirSelectorEdicion(id){
  const v = cacheVentas[id];
  if (!v){ setErr('Venta no encontrada'); return; }
  document.getElementById('editTargetId').value = id;
  document.getElementById('editTargetNumero').textContent = v.numeroVenta || ('ID ' + id);
  new bootstrap.Modal(document.getElementById('modalAccionesEdicion')).show();
}

function abrirEditarCabecera(){
  const id = Number(document.getElementById('editTargetId').value);
  const v  = cacheVentas[id];
  if (!_catalogosCargados){
    cargarCatalogos().then(function(){ prepararModalEdicion(v); });
  }else{
    prepararModalEdicion(v);
  }
  bootstrap.Modal.getInstance(document.getElementById('modalAccionesEdicion')).hide();
}
function abrirEditarMaestroDetalle(){
  const id = Number(document.getElementById('editTargetId').value);
  window.location.href = ctx + '/venta_detalle.jsp?id=' + id; // (en futuro: modo edición)
}

// ==== Editar cabecera ====
function prepararModalEdicion(v){
  document.getElementById('editVentaId').value = v.id;
  document.getElementById('editNumeroVenta').textContent = v.numeroVenta ? ('#'+v.numeroVenta) : ('ID '+v.id);

  fillSelect(
    document.getElementById('editCliente'),
    _clientes,
    function(c){ return { value:c.id, text:( (c.codigo || ('CLI-'+c.id)) + ' - ' + (c.nombre || c.razonSocial || '') ) } },
    String(v.clienteId)
  );
  fillSelect(
    document.getElementById('editVendedor'),
    _empleados,
    function(e){ return { value:e.id, text:( (e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '') ) } },
    v.vendedorId!=null?String(v.vendedorId):''
  );
  fillSelect(
    document.getElementById('editCajero'),
    _empleados,
    function(e){ return { value:e.id, text:( (e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '') ) } },
    v.cajeroId!=null?String(v.cajeroId):''
  );
  fillSelect(
    document.getElementById('editBodega'),
    _bodegas,
    function(b){ return { value:b.id, text:(b.nombre || ('Bodega '+b.id)) } },
    v.bodegaOrigenId!=null?String(v.bodegaOrigenId):''
  );

  document.getElementById('editTipoPago').value = (v.tipoPago || 'C');
  document.getElementById('editObs').value = (v.observaciones || '');

  new bootstrap.Modal(document.getElementById('modalEditarVenta')).show();
}

async function guardarEdicionVenta(e){
  e.preventDefault();
  const id   = Number(document.getElementById('editVentaId').value);
  const body = {
    clienteId: Number(document.getElementById('editCliente').value),
    tipoPago:  document.getElementById('editTipoPago').value || 'C',
    vendedorId: valueOrNull(document.getElementById('editVendedor').value),
    cajeroId:   valueOrNull(document.getElementById('editCajero').value),
    bodegaOrigenId: valueOrNull(document.getElementById('editBodega').value),
    observaciones: document.getElementById('editObs').value || ''
  };

  // Intento principal: PUT /api/ventas/{id}?usuarioId=...
  let r = await tryFetchJson(API + '/' + id + '?usuarioId=' + encodeURIComponent(USER_ID), {
    method: 'PUT',
    headers: {'Content-Type':'application/json', ...commonHeaders},
    body: JSON.stringify(body)
  });

  if (!r.ok){
    setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo actualizar');
    return;
  }
  bootstrap.Modal.getInstance(document.getElementById('modalEditarVenta')).hide();
  setOk('Venta actualizada');
  cargar(lastFilters);
}
function valueOrNull(v){ return (v==='' || v==null) ? null : Number(v); }

// ==== Eliminar (lógico) con rutas alternativas ====
function abrirEliminar(id){
  const v = cacheVentas[id];
  if (!v){ setErr('Venta no encontrada'); return; }
  document.getElementById('delVentaId').value = id;
  document.getElementById('delNumeroVenta').textContent = v.numeroVenta || ('ID '+id);
  new bootstrap.Modal(document.getElementById('modalEliminar')).show();
}

async function confirmarEliminar(){
  const id = Number(document.getElementById('delVentaId').value);

  // 1) DELETE /api/ventas/{id}
  let r = await tryFetchJson(API + '/' + id + '?usuarioId=' + encodeURIComponent(USER_ID), {
    method:'DELETE',
    headers: commonHeaders
  });

  // 2) POST /api/ventas/{id}/anular
  if(!r.ok){
    r = await tryFetchJson(API + '/' + id + '/anular?usuarioId=' + encodeURIComponent(USER_ID), {
      method:'POST',
      headers: {'Content-Type':'application/json', ...commonHeaders},
      body: JSON.stringify({})
    });
  }

  // 3) PUT /api/ventas/{id}/anular
  if(!r.ok){
    r = await tryFetchJson(API + '/' + id + '/anular?usuarioId=' + encodeURIComponent(USER_ID), {
      method:'PUT',
      headers: {'Content-Type':'application/json', ...commonHeaders},
      body: JSON.stringify({})
    });
  }

  if(!r.ok){
    setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo eliminar la venta');
    return;
  }

  bootstrap.Modal.getInstance(document.getElementById('modalEliminar')).hide();
  setOk('Venta eliminada');
  cargar(lastFilters);
}

// ==== Boot ====
window.addEventListener('DOMContentLoaded', function(){
  cargar();          // tabla
  agregarItem();     // primera fila del modal "Nueva venta"
  document.getElementById('modalNuevaVenta').addEventListener('show.bs.modal', cargarCatalogos);
});
</script>
</body>
</html>
