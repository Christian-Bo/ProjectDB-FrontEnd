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
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=dark-purple-5-fix">
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
      <form id="filtros" onsubmit="buscar(event)" class="row g-3 align-items-end">
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

        <div class="col-12 d-flex flex-wrap gap-3 justify-content-between align-items-center">
          <div class="form-check form-switch">
            <input class="form-check-input" type="checkbox" role="switch" id="incluirAnuladas" name="incluirAnuladas">
            <label class="form-check-label" for="incluirAnuladas">Mostrar anuladas</label>
          </div>
          <div class="d-flex gap-2 ms-auto">
            <button class="btn btn-primary" type="submit"><i class="bi bi-search me-1"></i>Buscar</button>
            <button class="btn btn-outline-secondary" type="button" onclick="limpiar()"><i class="bi bi-x-circle me-1"></i>Limpiar</button>
          </div>
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
              <label class="form-label">Bodega Origen *</label>
              <select id="selBodegaOrigen" class="form-select" name="bodegaOrigenId" required>
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

            <div class="col-md-4">
              <label class="form-label">Serie *</label>
              <select id="selSerie" class="form-select" name="serieId" required>
                <option value="">Cargando...</option>
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
                  <th style="width:360px;">Producto *</th>
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


<!-- Modal: Editar maestro-detalle -->
<div class="modal fade" id="modalEditarDetalle" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">
          Editar detalle <span id="detNumeroVenta" class="text-muted"></span>
        </h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
      </div>

      <div class="modal-body">
        <input type="hidden" id="detVentaId">
        <div class="row g-3 mb-2">
          <div class="col-md-6">
            <label class="form-label">Bodega para movimientos *</label>
            <select id="selBodegaDet" class="form-select" required>
              <option value="">Cargando...</option>
            </select>
            <div class="form-text">Se usa para validar/afectar stock al guardar los cambios.</div>
          </div>
          <div class="col-md-6 d-flex align-items-end justify-content-end">
            <button class="btn btn-outline-primary btn-sm" type="button" onclick="agregarItemDet()">+ Agregar línea</button>
          </div>
        </div>

        <div class="table-responsive">
          <table class="table table-sm table-striped align-middle" id="tablaEditarDetalle">
            <thead>
              <tr>
                <th style="width:340px;">Producto *</th>
                <th style="width:90px;">Stock</th>
                <th style="width:110px;">Cantidad *</th>
                <th style="width:140px;">Precio *</th>
                <th style="width:120px;">Descuento</th>
                <th style="width:120px;">Lote</th>
                <th style="width:140px;">Vence</th>
                <th style="width:60px;"></th>
              </tr>
            </thead>
            <tbody></tbody>
          </table>
        </div>

        <div class="form-text">
          Las líneas existentes se marcan con acción <b>U</b> (Actualizar). Puedes cambiarlas a <b>D</b> (Eliminar).
          Las nuevas líneas se crean con acción <b>A</b> (Agregar).
        </div>
      </div>

      <div class="modal-footer">
        <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        <button class="btn btn-primary" onclick="guardarEdicionDetalle()">Guardar cambios</button>
      </div>
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
// ==== Endpoints / Config (renombrados para no chocar con window.API de common.js) ====
const API_VENTAS     = 'http://localhost:8080/api/ventas';
const API_VENTAS_CAT = 'http://localhost:8080/api/catalogos';
const USER_ID = 1; // <-- AJUSTA si tu backend exige usuario autenticado
const ctx     = '${pageContext.request.contextPath}';
const commonHeaders = {'X-User-Id': String(USER_ID)};

// ================= Utils =================
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
function setErr(msg){
  const m = typeof msg === 'string' ? msg : (msg && JSON.stringify(msg)) || 'Error interno';
  document.getElementById('toastErrMsg').textContent = m;
  new bootstrap.Toast(document.getElementById('toastErr')).show();
}
function mapTipoPago(c){ if(!c) return ''; return c === 'C' ? 'Contado' : (c === 'R' ? 'Crédito' : c); }
function estadoBadge(e){
  if(e === 'A') return '<span class="badge text-bg-danger">Anulada</span>';
  if(e === 'P') return '<span class="badge ok">Procesada</span>';
  return '<span class="badge text-bg-secondary">Desconocido</span>';
}

// ============== Tabla (lista de ventas) ==============
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
  if (typeof params.incluirAnuladas !== 'undefined') {
    qs.set('incluirAnuladas', params.incluirAnuladas ? '1' : '0');
  }

  const r = await tryFetchJson(API_VENTAS + '?' + qs.toString(), { headers: commonHeaders });
  const rows = r.ok ? asArray(r.data) : [];
  if(!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo consultar ventas'); }

  cacheVentas = {};
  for (let i=0;i<rows.length;i++){ cacheVentas[rows[i].id] = rows[i]; }
  render(rows);
  const p = document.getElementById('pActual'); if (p) p.textContent = (page+1);
}

function render(rows){
  const tbody = document.querySelector('#tabla tbody');
  const empty = document.getElementById('tablaEmpty');
  if (!tbody) return;

  tbody.innerHTML = '';
  if (!rows.length){
    if (empty) empty.classList.remove('d-none');
    return;
  }
  if (empty) empty.classList.add('d-none');

  for (let i=0;i<rows.length;i++){
    const v = rows[i];
    const clienteTxt = (v && v.clienteNombre && String(v.clienteNombre).trim() !== '')
                       ? v.clienteNombre : ('ID ' + (v && v.clienteId != null ? v.clienteId : ''));
    const link   = ctx + '/venta_detalle.jsp?id=' + (v && v.id != null ? v.id : '');
    const idTxt     = (v && v.id != null) ? v.id : '';
    const numTxt    = (v && v.numeroVenta != null) ? v.numeroVenta : '';
    const fechaTxt  = (v && v.fechaVenta != null) ? v.fechaVenta : '';
    const totalVal  = (v && v.total != null) ? v.total : null;
    const estadoTxt = (v && v.estado != null) ? v.estado : null;
    const tipoTxt   = (v && v.tipoPago != null) ? v.tipoPago : null;

    const tr = document.createElement('tr');
    tr.innerHTML =
        '<td>' + idTxt + '</td>'
      + '<td>' + numTxt + '</td>'
      + '<td>' + fechaTxt + '</td>'
      + '<td>' + clienteTxt + '</td>'
      + '<td class="text-end">' + formatMoney(totalVal) + '</td>'
      + '<td>' + estadoBadge(estadoTxt) + '</td>'
      + '<td>' + mapTipoPago(tipoTxt) + '</td>'
      + '<td class="text-end">'
      +   '<div class="btn-group btn-group-sm" role="group">'
      +     '<button class="btn btn-outline-primary" onclick="abrirSelectorEdicion('+idTxt+')"><i class="bi bi-pencil"></i></button>'
      +     '<a class="btn btn-outline-secondary" href="'+link+'"><i class="bi bi-eye"></i></a>'
      +     '<button class="btn btn-outline-danger" onclick="abrirEliminar('+idTxt+')"><i class="bi bi-trash"></i></button>'
      +   '</div>'
      + '</td>';
    tbody.appendChild(tr);
  }
}

function buscar(e){
  e.preventDefault();
  const f = e.target;
  page = 0;
  lastFilters = {
    desde: f.desde.value,
    hasta: f.hasta.value,
    clienteId: f.clienteId.value,
    numeroVenta: f.numeroVenta.value,
    incluirAnuladas: document.getElementById('incluirAnuladas').checked
  };
  cargar(lastFilters);
}
function limpiar(){
  document.getElementById('filtros').reset();
  const chk = document.getElementById('incluirAnuladas');
  if (chk) chk.checked = false;
  lastFilters = { incluirAnuladas:false };
  page = 0;
  cargar(lastFilters);
}
function cambiarPagina(delta){ page = Math.max(0, page + delta); cargar(lastFilters); }

// ============= Catálogos (cliente, bodega, serie, etc.) =============
let _catalogosCargados = false;
let _clientes = [], _empleados = [], _bodegas = [];

function fillSelect(sel, data, map, selected){
  let html = '<option value="">Seleccione...</option>';
  for (let i=0;i<data.length;i++){
    const o = map(data[i]);
    html += '<option value="'+o.value+'"'+ (String(selected)===String(o.value)?' selected':'') +'>'+o.text+'</option>';
  }
  sel.innerHTML = html;
}

async function cargarCatalogos(){
  if (_catalogosCargados) return;

  // producción
  let cli = await fetchJsonOrNull(API_VENTAS_CAT + '/clientes?limit=200');
  let emp = await fetchJsonOrNull(API_VENTAS_CAT + '/empleados?limit=200');
  let bod = await fetchJsonOrNull(API_VENTAS_CAT + '/bodegas?limit=200');
  let ser = await fetchJsonOrNull(API_VENTAS_CAT + '/series');

  // fallbacks locales
  if (!cli) cli = await fetchJsonOrNull('http://localhost:8080/api/catalogos/clientes?limit=200');
  if (!emp) emp = await fetchJsonOrNull('http://localhost:8080/api/catalogos/empleados?limit=200');
  if (!bod) bod = await fetchJsonOrNull('http://localhost:8080/api/catalogos/bodegas?limit=200');
  if (!ser) ser = await fetchJsonOrNull('http://localhost:8080/api/catalogos/series');

  _clientes  = asArray(cli);
  _empleados = asArray(emp);
  _bodegas   = asArray(bod);
  const series = asArray(ser);

  fillSelect(document.getElementById('selCliente'), _clientes,
    c => ({ value:c.id, text: ((c.codigo||('CLI-'+c.id)) + ' - ' + (c.nombre||'')) })
  );
  fillSelect(document.getElementById('selVendedor'), _empleados,
    e => ({ value:e.id, text: ((e.codigo||('EMP-'+e.id)) + ' - ' + (e.nombres||'') + ' ' + (e.apellidos||'')) })
  );
  fillSelect(document.getElementById('selCajero'), _empleados,
    e => ({ value:e.id, text: ((e.codigo||('EMP-'+e.id)) + ' - ' + (e.nombres||'') + ' ' + (e.apellidos||'')) })
  );
  const selBod = document.getElementById('selBodegaOrigen');
  fillSelect(selBod, _bodegas, b => ({ value:b.id, text:(b.nombre || ('Bodega '+b.id)) }));
  fillSelect(document.getElementById('selSerie'), series, s => ({ value:s.id, text:(s.serie + (s.correlativo ? ' ('+s.correlativo+')' : '')) }));

  _catalogosCargados = true;

  // Preselecciona bodega id=1 si existe
  if ([...selBod.options].some(o => o.value === '1')) { selBod.value = '1'; }

  // refresca productos en filas existentes
  await refrescarProductosDeTodasLasFilas();

  // si no hay filas, agrega una
  if (!document.querySelector('#tablaItems tbody tr')) agregarItem();
}

// ================== Items (Nueva Venta) ==================
/**
 * Pide al backend productos de la bodega y carga opciones.
 * NO muestra el stock en el texto visible del option.
 * Deja data-precio y data-stock para usar en la fila.
 */
async function cargarProductosParaBodega(selectEl, bodegaId, selectedId){
  selectEl.disabled = true;
  selectEl.innerHTML = '<option value="">Cargando...</option>';

  let url1 = API_VENTAS_CAT + '/productos-stock?bodegaId=' + encodeURIComponent(bodegaId || '');
  let r = await fetchJsonOrNull(url1);

  if (!r) {
    let url2 = 'http://localhost:8080/api/catalogos/productos-stock?bodegaId=' + encodeURIComponent(bodegaId || '');
    r = await fetchJsonOrNull(url2);
  }

  const prods = asArray(r);
  let html = '<option value="">Seleccione...</option>';
  for (let i=0;i<prods.length;i++){
    const p = prods[i];
    const precio = Number((p && p.precioVenta) != null ? p.precioVenta : 0);
    const stock  = Number((p && p.stockDisponible) != null ? p.stockDisponible : 0);
    const nombre = (p && p.nombre) ? p.nombre : ('Producto ' + (p && p.id != null ? p.id : ''));
    const pid    = (p && p.id != null) ? p.id : '';
    html += '<option value="' + pid + '" data-precio="' + precio + '" data-stock="' + stock + '"' +
            (String(selectedId) === String(pid) ? ' selected' : '') + '>' +
            nombre + '</option>';
  }
  selectEl.innerHTML = html || '<option value="">(sin datos)</option>';
  selectEl.disabled = false;
}

/** Refresca productos de todas las filas según la bodega actual */
async function refrescarProductosDeTodasLasFilas(){
  const bodId = document.getElementById('selBodegaOrigen').value || '';
  const selects = document.querySelectorAll('#tablaItems select[name="productoId"]');
  for (const sel of selects){
    const keep = sel.value || null;
    await cargarProductosParaBodega(sel, bodId, keep);
    // re-dispara change para que stock/precio se sincronicen
    sel.dispatchEvent(new Event('change', { bubbles:true }));
  }
}

/** Agrega una fila al tbody de Items */
function agregarItem(){
  const tbody = document.querySelector('#tablaItems tbody');
  const tr = document.createElement('tr');
  tr.innerHTML = `
    <td>
      <select class="form-select form-select-sm" name="productoId" required>
        <option value="">Cargando...</option>
      </select>
    </td>
    <td class="text-center">
      <span class="badge text-bg-secondary" data-stock="0">0</span>
    </td>
    <td><input type="number" step="1" min="1" class="form-control form-control-sm" name="cantidad" required></td>
    <td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="precioUnitario" required></td>
    <td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="descuento"></td>
    <td><input type="text" class="form-control form-control-sm" name="lote" placeholder="S/N"></td>
    <td><input type="date" class="form-control form-control-sm" name="fechaVencimiento"></td>
    <td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest('tr').remove()">X</button></td>
  `;
  tbody.appendChild(tr);

  // Poblado inicial de productos de acuerdo a la bodega seleccionada
  const selProd = tr.querySelector('select[name="productoId"]');
  const bodId   = document.getElementById('selBodegaOrigen').value || '';
  cargarProductosParaBodega(selProd, bodId, null);

  // Eventos de la fila
  wireRowEvents(tr);
}

/** Conecta eventos de cambio/validación para una fila concreta */
function wireRowEvents(tr){
  const selProd = tr.querySelector('select[name="productoId"]');
  const precio  = tr.querySelector('input[name="precioUnitario"]');
  const stockEl = tr.querySelector('[data-stock]');
  const cantInp = tr.querySelector('input[name="cantidad"]');

  // Al cambiar producto: actualizar stock (badge), max de cantidad y precio sugerido
  selProd.addEventListener('change', function(){
    const opt = selProd.selectedOptions[0];
    let st = 0, pr = 0;
    if (opt){
      st = Number(opt.getAttribute('data-stock') || 0);
      pr = Number(opt.getAttribute('data-precio') || 0);
    }
    stockEl.textContent = String(st);
    stockEl.setAttribute('data-stock', String(st));
    cantInp.max = (st > 0 ? String(st) : '');
    if (pr > 0) precio.value = pr;

    // limpia estado de validación
    cantInp.classList.remove('is-invalid');
    cantInp.setCustomValidity('');
  });

  // Validar cantidad contra stock
  cantInp.addEventListener('input', function(){
    const st = Number(stockEl.getAttribute('data-stock') || 0);
    const q  = Number(cantInp.value || 0);
    if (st > 0 && q > st) {
      cantInp.classList.add('is-invalid');
      cantInp.setCustomValidity('No hay stock suficiente');
    } else {
      cantInp.classList.remove('is-invalid');
      cantInp.setCustomValidity('');
    }
  });
}

// ============== Guardar NUEVA venta ==============
function leerItems(){
  const rows = Array.from(document.querySelectorAll('#tablaItems tbody tr'));
  return rows.map(function(r){
    const get = sel => { const el = r.querySelector(sel); return el ? el.value : null; };
    const toNum = v => (v==='' || v==null) ? null : Number(v);
    const fv = v => (v==='' ? null : v);
    return {
      productoId: toNum(get('select[name="productoId"]')),
      cantidad: toNum(get('input[name="cantidad"]')),
      precioUnitario: toNum(get('input[name="precioUnitario"]')),
      descuento: toNum(get('input[name="descuento"]')),
      lote: fv(get('input[name="lote"]')),
      fechaVencimiento: fv(get('input[name="fechaVencimiento"]'))
    };
  }).filter(it => it.productoId && it.cantidad && it.precioUnitario);
}

async function guardarVenta(e){
  e.preventDefault();
  const f = e.target;

  const clienteId = Number(f.clienteId.value);
  const bodegaId  = Number(f.bodegaOrigenId.value);
  const serieId   = Number(document.getElementById('selSerie').value || '');

  if (!clienteId) { setErr('Selecciona un cliente'); return; }
  if (!bodegaId)  { setErr('Selecciona la bodega de origen'); return; }
  if (!serieId)   { setErr('Selecciona la serie de factura'); return; }

  const items = leerItems();
  if (items.length === 0) { setErr('Agrega al menos un ítem'); return; }

  const payload = {
    usuarioId: USER_ID,
    clienteId: clienteId,
    vendedorId: f.vendedorId.value ? Number(f.vendedorId.value) : null,
    cajeroId:   f.cajeroId.value   ? Number(f.cajeroId.value)   : null,
    bodegaOrigenId: bodegaId,
    tipoPago: f.tipoPago.value || 'C',
    observaciones: f.observaciones.value || null,
    serieId: serieId,
    items
  };

  const r = await tryFetchJson(API_VENTAS, {
    method:'POST',
    headers:{'Content-Type':'application/json', ...commonHeaders},
    body: JSON.stringify(payload)
  });

  if (!r.ok) {
    const msg = (r.data && (r.data.error || r.data.message || r.data.detail)) || 'No se pudo registrar la venta';
    setErr(msg);
    console.error('POST /ventas fallo', r.data || {});
    return;
  }

  bootstrap.Modal.getInstance(document.getElementById('modalNuevaVenta')).hide();
  document.getElementById('formVenta').reset();
  document.querySelector('#tablaItems tbody').innerHTML = '';
  agregarItem();
  setOk('Venta registrada');
  page = 0;
  cargar(lastFilters);
}

// ============== Acciones (editar / anular) ==============
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
  if (!_catalogosCargados){ cargarCatalogos().then(()=> prepararModalEdicion(v)); }
  else { prepararModalEdicion(v); }
  bootstrap.Modal.getInstance(document.getElementById('modalAccionesEdicion')).hide();
}
function abrirEditarMaestroDetalle(){
  const id = Number(document.getElementById('editTargetId').value);
  const doOpen = () => cargarDetalleVentaEnModal(id);
  if (!_catalogosCargados){ cargarCatalogos().then(doOpen); } else { doOpen(); }
  bootstrap.Modal.getInstance(document.getElementById('modalAccionesEdicion')).hide();
}
function prepararModalEdicion(v){
  document.getElementById('editVentaId').value = v.id;
  document.getElementById('editNumeroVenta').textContent = v.numeroVenta ? ('#'+v.numeroVenta) : ('ID '+v.id);

  fillSelect(document.getElementById('editCliente'), _clientes,
    c => ({ value:c.id, text:((c.codigo || ('CLI-'+c.id)) + ' - ' + (c.nombre || c.razonSocial || '')) }),
    String(v.clienteId)
  );
  fillSelect(document.getElementById('editVendedor'), _empleados,
    e => ({ value:e.id, text:((e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '')) }),
    v.vendedorId!=null?String(v.vendedorId):''
  );
  fillSelect(document.getElementById('editCajero'), _empleados,
    e => ({ value:e.id, text:((e.codigo || ('EMP-'+e.id)) + ' - ' + (e.nombres || '') + ' ' + (e.apellidos || '')) }),
    v.cajeroId!=null?String(v.cajeroId):''
  );

  // Nota: el backend no actualiza bodegaOrigen en /header
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
    observaciones: document.getElementById('editObs').value || ''
  };
  const r = await tryFetchJson(API_VENTAS + '/' + id + '/header', {
    method:'PUT', headers:{'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify(body)
  });
  if (!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo actualizar'); return; }
  bootstrap.Modal.getInstance(document.getElementById('modalEditarVenta')).hide();
  setOk('Venta actualizada');
  cargar(lastFilters);
}
function valueOrNull(v){ return (v==='' || v==null) ? null : Number(v); }

// ============== Eliminar (anular) ==============
function abrirEliminar(id){
  const v = cacheVentas[id];
  if (!v){ setErr('Venta no encontrada'); return; }
  document.getElementById('delVentaId').value = id;
  document.getElementById('delNumeroVenta').textContent = v.numeroVenta || ('ID '+id);
  new bootstrap.Modal(document.getElementById('modalEliminar')).show();
}
async function confirmarEliminar(){
  const id = Number(document.getElementById('delVentaId').value);
  const r = await tryFetchJson(API_VENTAS + '/' + id + '/anular', {
    method:'POST', headers: {'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify({})
  });
  if(!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo eliminar la venta'); return; }
  bootstrap.Modal.getInstance(document.getElementById('modalEliminar')).hide();
  setOk('Venta eliminada');
  cargar(lastFilters);
}

// ============== EDITOR MAESTRO-DETALLE (SIN columna "Acción") ==============
const DELETED_IDS = new Set(); // líneas existentes eliminadas

/** Carga header+detalle, arma el modal y muestra */
async function cargarDetalleVentaEnModal(ventaId){
  const r = await tryFetchJson(API_VENTAS + '/' + ventaId, { headers: commonHeaders });
  if(!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo cargar la venta'); return; }
  const h = r.data || {};
  const items = Array.isArray(h.items) ? h.items : [];

  // ids del modal de detalle:
  // - detVentaId (hidden)
  // - detNumeroVenta (span)
  // - selBodegaDet (select bodega para movimientos)
  // - tablaEditarDetalle (tabla con tbody)
  // - modalEditarDetalle (modal)

  document.getElementById('detVentaId').value = h.id || ventaId;
  document.getElementById('detNumeroVenta').textContent = h.numeroVenta ? ('#' + h.numeroVenta) : ('ID ' + ventaId);

  // bodega por defecto = bodegaOrigen de la venta
  const selB = document.getElementById('selBodegaDet');
  fillSelect(selB, _bodegas, b => ({ value: b.id, text: (b.nombre || ('Bodega ' + b.id)) }),
            (h.bodegaOrigenId!=null?String(h.bodegaOrigenId):''));

  // limpiar estado
  DELETED_IDS.clear();
  const tbody = document.querySelector('#tablaEditarDetalle tbody');
  tbody.innerHTML = '';

  // construir filas para cada item existente (marcadas como "no nuevas")
  for (let i=0;i<items.length;i++){
    const it = items[i];
    const tr = construirFilaDetalle({
      detalleId: it.id,
      productoId: it.productoId,
      cantidad: it.cantidad,
      precioUnitario: it.precioUnitario,
      descuentoLinea: it.descuentoLinea,
      lote: it.lote || '',
      fechaVencimiento: it.fechaVencimiento || '',
      isNueva: false
    });
    tbody.appendChild(tr);
  }

  // cargar opciones de producto (según bodega seleccionada) y seleccionar cada producto
  await refrescarProductosEnTablaDetalle();

  // mostrar modal
  new bootstrap.Modal(document.getElementById('modalEditarDetalle')).show();
}

/** Construye una fila del editor de detalle (sin columna "Acción") */
function construirFilaDetalle(op){
  const tr = document.createElement('tr');
  tr.dataset.detalleId = op && op.detalleId ? String(op.detalleId) : '';
  tr.dataset.isNueva   = op && op.isNueva ? '1' : '0';
  if (op && op.productoId != null) tr.dataset.pid = String(op.productoId);

  tr.innerHTML = `
    <td>
      <select class="form-select form-select-sm det-producto" required>
        <option value="">Cargando...</option>
      </select>
    </td>
    <td class="text-center"><span class="badge text-bg-secondary det-stock" data-stock="0">0</span></td>
    <td><input type="number" class="form-control form-control-sm det-cantidad" min="1" step="1" required value="${op && op.cantidad != null ? op.cantidad : ''}"></td>
    <td><input type="number" class="form-control form-control-sm det-precio" min="0" step="0.01" required value="${op && op.precioUnitario != null ? op.precioUnitario : ''}"></td>
    <td><input type="number" class="form-control form-control-sm det-desc" min="0" step="0.01" value="${op && op.descuentoLinea != null ? op.descuentoLinea : ''}"></td>
    <td><input type="text" class="form-control form-control-sm det-lote" placeholder="S/N" value="${op && op.lote ? op.lote : ''}"></td>
    <td><input type="date" class="form-control form-control-sm det-vence" value="${op && op.fechaVencimiento ? op.fechaVencimiento : ''}"></td>
    <td><button type="button" class="btn btn-sm btn-outline-danger det-del">X</button></td>
  `;

  wireRowEventsDet(tr);
  return tr;
}

/** Agregar línea nueva (se marca internamente como nueva) */
function agregarItemDet(){
  const tbody = document.querySelector('#tablaEditarDetalle tbody');
  const tr = construirFilaDetalle({ isNueva:true });
  tbody.appendChild(tr);
  refrescarProductosEnTablaDetalle();
}

/** Carga productos para cada fila según la bodega seleccionada en el modal */
async function refrescarProductosEnTablaDetalle(){
  const bodId = document.getElementById('selBodegaDet').value || '';
  const rows = document.querySelectorAll('#tablaEditarDetalle tbody tr');

  for (const tr of rows){
    const sel = tr.querySelector('.det-producto');
    const keepId = tr.dataset.pid || sel.value || null;
    await cargarProductosParaBodega(sel, bodId, keepId);
    sel.dispatchEvent(new Event('change', { bubbles:true }));
  }
}

/** Eventos por fila en el modal de detalle */
function wireRowEventsDet(tr){
  const selProd = tr.querySelector('.det-producto');
  const precio  = tr.querySelector('.det-precio');
  const stockEl = tr.querySelector('.det-stock');
  const cantInp = tr.querySelector('.det-cantidad');
  const btnDel  = tr.querySelector('.det-del');

  selProd.addEventListener('change', function(){
    const opt = selProd.selectedOptions[0];
    let st = 0, pr = 0;
    if (opt){
      st = Number(opt.getAttribute('data-stock') || 0);
      pr = Number(opt.getAttribute('data-precio') || 0);
    }
    stockEl.textContent = String(st);
    stockEl.setAttribute('data-stock', String(st));
    cantInp.max = (st > 0 ? String(st) : '');
    // Precio sugerido del producto SIEMPRE al cambiar
    if (pr > 0) precio.value = pr;

    cantInp.classList.remove('is-invalid');
    cantInp.setCustomValidity('');
  });

  cantInp.addEventListener('input', function(){
    const st = Number(stockEl.getAttribute('data-stock') || 0);
    const q  = Number(cantInp.value || 0);
    if (st > 0 && q > st) {
      cantInp.classList.add('is-invalid');
      cantInp.setCustomValidity('No hay stock suficiente');
    } else {
      cantInp.classList.remove('is-invalid');
      cantInp.setCustomValidity('');
    }
  });

  // Eliminar: si la línea existía => queda registrada en DELETED_IDS; si era nueva, solo se remueve
  btnDel.addEventListener('click', function(){
    const detId = tr.dataset.detalleId;
    const esNueva = tr.dataset.isNueva === '1';
    if (detId && !esNueva) {
      DELETED_IDS.add(Number(detId));
    }
    tr.remove();
  });
}

/** Construye payload para PUT /api/ventas/{id}/detalle (acciones internas) */
function construirPayloadDetalle(){
  const items = [];
  const bodegaId = Number(document.getElementById('selBodegaDet').value || 0);

  // Filas visibles => A (nuevas) o U (existentes)
  document.querySelectorAll('#tablaEditarDetalle tbody tr').forEach(tr => {
    const detalleId = tr.dataset.detalleId ? Number(tr.dataset.detalleId) : null;
    const esNueva   = tr.dataset.isNueva === '1';
    const productoId = Number(tr.querySelector('.det-producto')?.value || 0);
    const cantidad   = Number(tr.querySelector('.det-cantidad')?.value || 0);
    const precio     = Number(tr.querySelector('.det-precio')?.value || 0);
    const descInp    = tr.querySelector('.det-desc')?.value;
    const lote       = tr.querySelector('.det-lote')?.value || null;
    const vence      = tr.querySelector('.det-vence')?.value || null;

    if (!productoId || !cantidad || !precio) return;

    items.push({
      detalleId: detalleId,                 // null para nuevas
      productoId: productoId,
      bodegaId: bodegaId || null,
      cantidad: cantidad,
      precioUnitario: precio,
      descuentoLinea: (descInp===''||descInp==null) ? null : Number(descInp),
      accion: esNueva || !detalleId ? 'A' : 'U',
      lote: lote,
      fechaVencimiento: vence
    });
  });

  // Líneas eliminadas => D
  DELETED_IDS.forEach(id => {
    items.push({
      detalleId: id,
      productoId: null,
      bodegaId: null,
      cantidad: null,
      precioUnitario: null,
      descuentoLinea: null,
      accion: 'D',
      lote: null,
      fechaVencimiento: null
    });
  });

  return items;
}

/** Guardar edición del detalle vía PUT /api/ventas/{id}/detalle */
async function guardarEdicionDetalle(){
  const ventaId = Number(document.getElementById('detVentaId').value);
  const bod = document.getElementById('selBodegaDet').value;
  if (!bod){ setErr('Selecciona la bodega para movimientos.'); return; }

  const items = construirPayloadDetalle();
  if (items.length === 0){ setErr('No hay cambios por enviar.'); return; }

  const r = await tryFetchJson(API_VENTAS + '/' + ventaId + '/detalle', {
    method:'PUT',
    headers: {'Content-Type':'application/json', ...commonHeaders},
    body: JSON.stringify(items)
  });

  if (!r.ok){
    setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo actualizar el detalle');
    return;
  }

  DELETED_IDS.clear();
  bootstrap.Modal.getInstance(document.getElementById('modalEditarDetalle')).hide();
  setOk('Detalle actualizado');
  cargar(lastFilters);
}

/** Cuando cambie la bodega del modal, refrescar catálogo/stock de las filas */
document.addEventListener('DOMContentLoaded', function(){
  const sel = document.getElementById('selBodegaDet');
  if (sel){
    sel.addEventListener('change', function(){
      if (!sel.value){
        const rows = document.querySelectorAll('#tablaEditarDetalle tbody tr');
        for (const tr of rows){
          tr.querySelector('.det-producto').innerHTML = '<option value="">Seleccione...</option>';
          const st = tr.querySelector('.det-stock');
          st.textContent = '0';
          st.setAttribute('data-stock','0');
        }
        return;
      }
      refrescarProductosEnTablaDetalle();
    });
  }
});

// ==== Boot ====
window.addEventListener('DOMContentLoaded', function(){
  lastFilters = { incluirAnuladas: (document.getElementById('incluirAnuladas')?.checked) || false };
  cargar(lastFilters);      // tabla
  agregarItem();            // primera fila del modal "Nueva venta"
  document.getElementById('modalNuevaVenta').addEventListener('show.bs.modal', cargarCatalogos);
});
</script>
</body>
</html>
