<%--
  Devoluciones | NextTech (estilo proyecto remoto)
  - Listado + filtros
  - Modal: Nueva devolución (por venta, ítems con máximo = saldo)
  - Modal: Ver devolución (detalle embebido)
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>Devoluciones | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Base del backend (igual que otras vistas) -->
  <meta name="api-base" content="http://localhost:8080" />

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet" />

  <!-- Paleta / tema del proyecto remoto -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=13" />
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=13" />

  <!-- Utils comunes del proyecto -->
  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>

 <style>
  /* === Mapea variables existentes del tema (base.css) ===
     Antes usabas --nt-surface-1, --nt-fg*, que no existen */
  body.nt-bg { background: var(--nt-bg); color: var(--nt-text); }
  .nt-title{ color: var(--nt-primary); }
  .nt-subtitle{ color: var(--nt-text); opacity:.9; }

  .nt-back{
    display:inline-flex; align-items:center; gap:.5rem;
    border:1px solid var(--nt-border);
    background:transparent; color:var(--nt-primary);
  }
  .nt-back:hover{ background:var(--nt-surface-2); }

  /* Cards coherentes con el tema */
  .nt-card{
    background: var(--nt-surface);                  /* <-- antes: --nt-surface-1 (NO existe) */
    border:1px solid var(--nt-border);
    border-radius:1rem; transition:.12s;
  }
  .nt-card:hover{
    transform: translateY(-1px);
    border-color: var(--nt-accent);
    box-shadow: 0 10px 24px rgba(0,0,0,.35);
  }

  /* Encabezados de tabla */
  .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-primary); }

  /* Botón de acento */
  .nt-btn-accent{ background: var(--nt-accent); color:#fff; border:none; }
  .nt-btn-accent:hover{ filter: brightness(.95); }

  /* Inputs oscuros como Transferencias */
  .form-control.nt-input, .form-select.nt-input{
    background: var(--nt-surface-2);
    color: var(--nt-text);                           /* <-- antes: --nt-fg (NO existe) */
    border-color: var(--nt-border);
  }
  .form-control.nt-input:focus, .form-select.nt-input:focus{
    border-color: var(--nt-accent);
    box-shadow: 0 0 0 .2rem rgba(0,102,255,.15);
  }

  /* Modal del tema (asegura fondo sólido) */
  .modal-content{
    background: var(--nt-surface) !important;        /* <-- antes: --nt-surface-1 (NO existe) */
    color: var(--nt-text);
    border:1px solid var(--nt-border);
    border-radius:1rem;
  }
  .modal-header{
    background: var(--nt-surface-2);
    border-bottom:1px solid var(--nt-border);
    color: var(--nt-primary);
  }
  .modal-footer{ border-top:1px solid var(--nt-border); }

  /* Opacidad del backdrop del modal */
  .modal-backdrop.show{ opacity:.6 !important; }
</style>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-arrow-repeat"></i> NextTech — Devoluciones
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <div class="container py-4 flex-grow-1">

    <!-- Título -->
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <h2 class="m-0 nt-title"><i class="bi bi-arrow-repeat"></i> Devoluciones</h2>
        <div class="nt-subtitle">Listado, creación y consulta de devoluciones</div>
      </div>
      <div class="d-flex gap-2">
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/ventas.jsp">
          <i class="bi bi-list-ul me-1"></i> Ir a ventas
        </a>
        <button id="btnNueva" class="btn nt-btn-accent" data-bs-toggle="modal" data-bs-target="#modalNuevaDev">
          <i class="bi bi-plus-circle me-1"></i> Nueva devolución
        </button>
      </div>
    </div>

    <!-- Filtros -->
    <div class="nt-card mb-3">
      <div class="card-body">
        <form class="row g-3 align-items-end">
          <div class="col-sm-3">
            <label class="form-label">Desde</label>
            <input type="date" id="f_desde" class="form-control">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Hasta</label>
            <input type="date" id="f_hasta" class="form-control">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Cliente ID</label>
            <input type="number" id="f_cliente" min="1" class="form-control" placeholder="Ej. 1">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Número</label>
            <input type="text" id="f_numero" class="form-control" placeholder="DEV-0001">
          </div>
          <div class="col-12 d-flex gap-2 justify-content-end">
            <button type="button" class="btn btn-primary" id="btnBuscar"><i class="bi bi-search me-1"></i> Buscar</button>
            <button type="button" class="btn btn-outline-secondary" id="btnLimpiar"><i class="bi bi-x-circle me-1"></i> Limpiar</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Tabla -->
    <div class="nt-card">
      <div class="table-responsive">
        <table class="table table-striped table-hover align-middle mb-0" id="tabla">
          <thead class="nt-table-head">
            <tr>
              <th>ID</th>
              <th>Número</th>
              <th>Fecha</th>
              <th>Venta</th>
              <th>Cliente</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="tablaEmpty" class="p-3 text-muted">Sin resultados.</div>
    </div>
  </div>

  <!-- Modal: Nueva devolución -->
  <div class="modal fade nt-modal" id="modalNuevaDev" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Nueva devolución</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">
          <div id="nd_alert" class="alert alert-danger d-none"></div>
          <div id="nd_ok" class="alert alert-success d-none"></div>

          <div class="row g-2">
            <div class="col-md-4">
              <label class="form-label">Venta *</label>
              <select id="nd_venta" class="form-select" required></select>
              <div class="form-text">Elige por número (p.ej. A-000010).</div>
            </div>
            <div class="col-md-3">
              <label class="form-label">Fecha *</label>
              <input id="nd_fecha" type="date" class="form-control" required>
            </div>
            <div class="col-md-5">
              <label class="form-label">Motivo *</label>
              <input id="nd_motivo" type="text" maxlength="200" class="form-control" placeholder="Describa el motivo" required>
            </div>
          </div>

          <hr class="my-3">
          <h6 class="mb-2">Ítems devueltos</h6>
          <div class="table-responsive">
            <table class="table table-sm table-hover align-middle mb-0">
              <thead>
                <tr>
                  <th>Producto</th>
                  <th class="text-center">Vendido</th>
                  <th class="text-center">Saldo</th>
                  <th class="w-120 text-center">Cantidad a devolver *</th>
                  <th>Obs.</th>
                </tr>
              </thead>
              <tbody id="nd_body"></tbody>
            </table>
          </div>
          <div class="mt-2">
            <small class="text-muted">
              El SP valida máximos. Aquí se valida que la cantidad sea &gt; 0 y ≤ <b>saldo</b>.
            </small>
          </div>
        </div>

        <div class="modal-footer">
          <button id="nd_save" type="button" class="btn nt-btn-accent" disabled>Crear devolución</button>
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal: Ver devolución (detalle embebido) -->
  <div class="modal fade nt-modal" id="mdlVerDev" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Detalle de devolución</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">
          <div id="vd_alert" class="alert alert-danger d-none"></div>

          <div class="nt-card mb-3">
            <div class="card-body" id="vd_cabecera">
              <div class="text-muted">Cargando devolución...</div>
            </div>
          </div>

          <div class="nt-card">
            <div class="table-responsive">
              <table class="table table-striped table-hover align-middle mb-0">
                <thead class="nt-table-head">
                  <tr>
                    <th>ID Detalle</th>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Observaciones</th>
                  </tr>
                </thead>
                <tbody id="vd_body"></tbody>
              </table>
            </div>
            <div id="vd_empty" class="p-3 text-muted d-none">Sin líneas.</div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- JS: Bootstrap -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* =========================
   CONFIG / ENDPOINTS
   ========================= */
(function syncApiBase(){
  try{
    window.API = window.API || {};
    if (!API.baseUrl || !API.baseUrl.trim()) {
      const meta = document.querySelector('meta[name="api-base"]');
      const base = (window.API_BASE || meta?.getAttribute('content') || '').trim();
      if (base) API.baseUrl = base;
    }
  }catch(_){}
})();

const API_BASE = (window.API?.baseUrl || document.querySelector('meta[name="api-base"]')?.content || '').replace(/\/+$/,'');
const API_DEV  = API_BASE + '/api/devoluciones';
const API_CAT  = API_BASE + '/api/catalogos';

/* =========================
   HELPERS
   ========================= */
async function fetchJson(url, opts){
  const r = await fetch(url, opts || {});
  const raw = await r.text();
  let d = null; try{ d = raw ? JSON.parse(raw) : null; }catch(_){}
  if(!r.ok) throw new Error((d && (d.error||d.detail||d.message)) || ('HTTP ' + r.status));
  return d;
}
function estadoBadgeHtml(e){
  if(e==='A') return '<span class="badge rounded-pill text-bg-success">Activa</span>';
  if(e==='N') return '<span class="badge rounded-pill text-bg-danger">Anulada</span>';
  return '<span class="badge rounded-pill text-bg-secondary">'+(e||'')+'</span>';
}
function clean(s){
  if(s==null) return '';
  return String(s).replace(/^[\s'"]+|[\s'"]+$/g,'').replace(/[\u0000-\u001F\u007F]/g,'').replace(/\s+/g,' ').trim();
}
function toInt(v, def=0){ const n = Number(v); return Number.isFinite(n) ? n : def; }
function hoyYYYYMMDD(){ const d=new Date(), m=String(d.getMonth()+1).padStart(2,'0'), dd=String(d.getDate()).padStart(2,'0'); return d.getFullYear()+'-'+m+'-'+dd; }
function goBack(){ try{ if(history.length>1){ history.back(); return; } }catch(_){ } location.href='${pageContext.request.contextPath}/Dashboard.jsp'; }

/* =========================
   LISTADO + FILTROS
   ========================= */
function setRows(rows){
  const tb = document.querySelector('#tabla tbody');
  const empty = document.getElementById('tablaEmpty');
  if (!tb) return;

  tb.innerHTML = '';
  if(!rows || !rows.length){
    if (empty) empty.textContent = 'Sin resultados.';
    return;
  }
  if (empty) empty.textContent = '';

  for(const r of rows){
    const id      = r.id ?? r.devolucionId ?? r.devolucion_id ?? '';
    const numero  = r.numero ?? r.numeroDevolucion ?? r.numero_devolucion ?? '';
    const fecha   = r.fecha ?? r.fechaDevolucion ?? r.fecha_devolucion ?? '';
    const vNum    = r.ventaNumero ?? r.numeroVenta ?? r.numero_venta ?? (r.ventaId ? ('V-' + r.ventaId) : '');
    const cliente = r.clienteNombre ?? r.cliente_nombre ?? '';
    const estado  = r.estado ?? 'A';

    const tr = document.createElement('tr');
    tr.innerHTML =
      '<td>'+id+'</td>'
    + '<td>'+numero+'</td>'
    + '<td>'+fecha+'</td>'
    + '<td>'+vNum+'</td>'
    + '<td>'+cliente+'</td>'
    + '<td>'+estadoBadgeHtml(estado)+'</td>'
    + '<td class="text-end">'
    +   '<div class="btn-group btn-group-sm">'
    +     '<button type="button" class="btn btn-outline-secondary" title="Ver" onclick="abrirVer('+id+')">'
    +       '<i class="bi bi-eye me-1"></i> Ver'
    +     '</button>'
    +   '</div>'
    + '</td>';
    tb.appendChild(tr);
  }
}

async function buscar(page=0,size=50){
  const p = new URLSearchParams();
  const d = document.getElementById('f_desde')?.value;
  const h = document.getElementById('f_hasta')?.value;
  const c = document.getElementById('f_cliente')?.value;
  const n = document.getElementById('f_numero')?.value;
  if(d) p.append('desde', d);
  if(h) p.append('hasta', h);
  if(c) p.append('clienteId', c);
  if(n) p.append('numero', n);
  p.append('page', page);
  p.append('size', size);

  const data = await fetchJson(API_DEV + '?' + p.toString());
  setRows(Array.isArray(data) ? data : []);
}

/* =========================
   NUEVA DEVOLUCIÓN (MODAL)
   ========================= */
const ndVentaSel = document.getElementById('nd_venta');
const ndBody     = document.getElementById('nd_body');
const ndSave     = document.getElementById('nd_save');
const ndAlert    = document.getElementById('nd_alert');
const ndOK       = document.getElementById('nd_ok');

let DETALLE_VENTA = []; // [{id, productoId, productoNombre, vendido, saldo}]

async function cargarVentasLite(){
  const ventas = await fetchJson(API_CAT + '/ventas-lite?max=100');
  if (ndVentaSel){
    ndVentaSel.innerHTML = '';
    ndVentaSel.appendChild(new Option('-- Selecciona venta --', ''));
    for (const v of ventas) {
      const id   = v.id ?? v.ventaId ?? v.venta_id ?? null;
      let numero = v.numeroVenta ?? v.numero_venta ?? v.numero ?? v.numeroDoc ?? v.num ?? '';
      numero = clean(numero);
      const text = numero || (id != null ? ('V-' + id) : '(sin número)');
      ndVentaSel.appendChild(new Option(text, id ?? ''));
    }
  }
  const f = document.getElementById('nd_fecha');
  if (f && !f.value) f.value = hoyYYYYMMDD();
}

async function cargarDetalleVenta(ventaId){
  const [arr, sal] = await Promise.all([
    fetchJson(API_CAT + '/venta/' + encodeURIComponent(ventaId) + '/detalle-lite'),
    fetchJson(API_DEV  + '/venta/' + encodeURIComponent(ventaId) + '/saldos')
  ]);

  const mapSaldo = {};
  (sal || []).forEach(s => { mapSaldo[String(s.detalle_venta_id)] = {
    saldo:  Number(s.saldo||0),
    vendido:Number(s.vendido||0)
  };});

  DETALLE_VENTA = (arr || []).map(d => {
    const id  = d.id ?? d.detalleId ?? d.detalle_id;
    const pid = d.productoId ?? d.producto_id;
    const nom = clean(d.productoNombre ?? d.producto_nombre ?? '');
    const vendido = Number(d.cantidad ?? 0);
    const itemSaldo = mapSaldo[String(id)] || {saldo: vendido, vendido: vendido};
    return { id, productoId: pid, productoNombre: nom, vendido: itemSaldo.vendido, saldo: itemSaldo.saldo };
  });

  if (ndBody){
    ndBody.innerHTML = '';
    for(const d of DETALLE_VENTA){
      const tr = document.createElement('tr');
      tr.dataset.detalleId = d.id;
      tr.dataset.saldo = d.saldo;
      tr.innerHTML =
        '<td>['+(d.productoId ?? '?')+'] '+(d.productoNombre||'(sin nombre)')+'</td>'
      + '<td class="text-center">'+ d.vendido +'</td>'
      + '<td class="text-center">'+ d.saldo +'</td>'
      + '<td class="w-120 text-end-input">'
      + '  <input type="number" class="form-control form-control-sm qty" min="0" max="'+ d.saldo +'" step="1" value="0" placeholder="0" title="Máximo: '+ d.saldo +'">'
      + '  <div class="invalid-feedback">No puedes devolver más que el saldo.</div>'
      + '</td>'
      + '<td><input type="text" class="form-control form-control-sm obs" maxlength="200" placeholder="Observaciones"></td>';
      ndBody.appendChild(tr);
    }
    for (const tr of Array.from(ndBody.querySelectorAll('tr'))) validateRow(tr);
  }
  validarFormulario();
}

function validateRow(tr){
  const inp = tr.querySelector('.qty'); if(!inp) return false;
  const max = toInt(inp.getAttribute('max'), 0);
  let val = toInt(inp.value, 0);
  if (val < 0) val = 0;
  if (String(val) !== inp.value) inp.value = val;
  const invalid = (val > max);
  inp.classList.toggle('is-invalid', invalid);
  inp.setCustomValidity(invalid ? 'Cantidad supera el saldo ('+max+').' : '');
  return !invalid && val >= 0;
}

function validarFormulario(){
  if (ndAlert){ ndAlert.classList.add('d-none'); ndAlert.textContent=''; }
  if (ndOK){ ndOK.classList.add('d-none'); ndOK.textContent=''; }

  const ventaId = ndVentaSel?.value;
  const f = document.getElementById('nd_fecha')?.value;
  const m = clean(document.getElementById('nd_motivo')?.value);

  let ok = !!ventaId && !!f && !!m;

  let alguna = false;
  if (ndBody){
    for(const tr of Array.from(ndBody.querySelectorAll('tr'))){
      const good = validateRow(tr);
      const q = toInt(tr.querySelector('.qty')?.value, 0);
      if(!good){ ok=false; break; }
      if(q > 0) alguna = true;
    }
  }
  if(!alguna) ok = false;

  if (ndSave) ndSave.disabled = !ok;
  return ok;
}

/* =========================
   MODAL VER (DETALLE EMBEBIDO)
   ========================= */
function vd_estadoBadge(e){
  if(e==='A') return '<span class="badge rounded-pill text-bg-success">Activa</span>';
  if(e==='N') return '<span class="badge rounded-pill text-bg-danger">Anulada</span>';
  return '<span class="badge rounded-pill text-bg-secondary">'+(e||'')+'</span>';
}
function vd_txt(x){ return (x==null)?'':String(x); }
function vd_renderHeader(h){
  const el = document.getElementById('vd_cabecera');
  if(!el) return;
  el.innerHTML =
    '<div class="row g-2">'
    + '<div class="col-md-3"><b>Número:</b> '+vd_txt(h.numero)+'</div>'
    + '<div class="col-md-3"><b>Fecha:</b> '+vd_txt(h.fecha)+'</div>'
    + '<div class="col-md-3"><b>Venta:</b> '+(vd_txt(h.numeroVenta)||('ID '+vd_txt(h.ventaId)))+'</div>'
    + '<div class="col-md-3"><b>Estado:</b> '+vd_estadoBadge(h.estado)+'</div>'
    + '</div>'
    + '<div class="row g-2 mt-2">'
    + '<div class="col-md-6"><b>Cliente:</b> '+vd_txt(h.clienteNombre || '')+'</div>'
    + '<div class="col-md-6"><b>Motivo:</b> '+vd_txt(h.motivo || '')+'</div>'
    + '</div>';
}
function vd_renderItems(items){
  const tb = document.getElementById('vd_body');
  const empty = document.getElementById('vd_empty');
  if (!tb) return;

  tb.innerHTML = '';
  if(!items || !items.length){
    if (empty) empty.classList.remove('d-none');
    return;
  }
  if (empty) empty.classList.add('d-none');

  for(const d of items){
    const tr = document.createElement('tr');
    tr.innerHTML =
      '<td>'+vd_txt(d.id)+'</td>'
      + '<td>['+vd_txt(d.productoId)+'] '+vd_txt(d.productoNombre||'')+'</td>'
      + '<td>'+vd_txt(d.cantidad)+'</td>'
      + '<td>'+vd_txt(d.observaciones)+'</td>';
    tb.appendChild(tr);
  }
}
function normalizeHeader(h){
  return {
    id:              h.id,
    numero:          h.numero,
    fecha:           h.fecha,
    estado:          h.estado,
    motivo:          h.motivo,
    ventaId:         h.venta_id,
    numeroVenta:     h.numero_venta,
    clienteNombre:   h.cliente_nombre,
    bodegaId:        h.bodega_id
  };
}
function normalizeItems(items){
  return (items||[]).map(d => ({
    id:               d.detalle_id,
    detalleVentaId:   d.detalle_venta_id,
    productoId:       d.producto_id,
    productoNombre:   d.producto_nombre,
    cantidad:         d.devuelto,
    vendido:          d.vendido,
    observaciones:    d.observaciones
  }));
}
async function abrirVer(id){
  const alert = document.getElementById('vd_alert');
  if (alert){ alert.classList.add('d-none'); alert.textContent=''; }
  const cab = document.getElementById('vd_cabecera');
  const bod = document.getElementById('vd_body');
  const emp = document.getElementById('vd_empty');
  if (cab) cab.innerHTML = '<div class="text-muted">Cargando devolución...</div>';
  if (bod) bod.innerHTML = '';
  if (emp) emp.classList.add('d-none');

  const modalEl = document.getElementById('mdlVerDev');
  const modal   = (typeof bootstrap !== 'undefined') ? (bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl)) : null;
  if (modal) modal.show();

  try{
    const raw = await fetchJson(API_DEV + '/' + encodeURIComponent(id));
    const header = normalizeHeader(raw || {});
    const items  = normalizeItems((raw && raw.items) || []);
    vd_renderHeader(header);
    vd_renderItems(items);
  }catch(err){
    if (alert){ alert.textContent = 'Error: ' + (err.message || 'desconocido'); alert.classList.remove('d-none'); }
    console.error(err);
  }
}

/* =========================
   EVENTOS / BOOT
   ========================= */
document.addEventListener('DOMContentLoaded', () => {
  // Filtros
  const btnBuscar = document.getElementById('btnBuscar');
  const btnLimpiar = document.getElementById('btnLimpiar');
  if (btnBuscar) btnBuscar.addEventListener('click', () => { buscar().catch(console.error); });
  if (btnLimpiar) btnLimpiar.addEventListener('click', () => {
    ['f_desde','f_hasta','f_cliente','f_numero'].forEach(id => { const el = document.getElementById(id); if (el) el.value=''; });
    buscar().catch(console.error);
  });

  // Modal Nueva devolución: listeners
  if (ndVentaSel) ndVentaSel.addEventListener('change', async () => { const id = ndVentaSel.value; if(id){ await cargarDetalleVenta(id); } else if (ndBody){ ndBody.innerHTML=''; } validarFormulario(); });
  const fFecha = document.getElementById('nd_fecha');
  const fMot   = document.getElementById('nd_motivo');
  if (fFecha) fFecha.addEventListener('change', validarFormulario);
  if (fMot)   fMot.addEventListener('input', validarFormulario);
  if (ndBody) ndBody.addEventListener('input', (e)=>{ if(e.target.classList.contains('qty')){ const tr = e.target.closest('tr'); if(tr) validateRow(tr); validarFormulario(); }});

  // Guardar devolución
  if (ndSave) ndSave.addEventListener('click', async () => {
    try{
      if(!validarFormulario()) return;
      const ventaId = parseInt(ndVentaSel.value,10);
      const fecha   = fFecha?.value || hoyYYYYMMDD();
      const motivo  = clean(fMot?.value);

      const items = [];
      if (ndBody){
        for (const tr of Array.from(ndBody.querySelectorAll('tr'))) {
          const q = parseInt(tr.querySelector('.qty')?.value || '0', 10);
          if (q > 0) {
            const detId = parseInt(tr.dataset.detalleId, 10);
            const obs   = clean(tr.querySelector('.obs')?.value) || null;
            const linea = DETALLE_VENTA.find(x => String(x.id) === String(detId));
            if (!linea || !linea.productoId) { throw new Error('No se pudo determinar el producto de la línea ' + detId); }
            items.push({ detalleVentaId: detId, productoId: linea.productoId, cantidad: q, observaciones: obs });
          }
        }
      }

      const res = await fetchJson(API_DEV, {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify({ ventaId, fecha, motivo, items })
      });

      if (ndOK){ ndOK.textContent = 'Devolución creada: ID ' + (res.id || res.devolucion_id) + ' (' + (res.message || 'OK') + ')'; ndOK.classList.remove('d-none'); }
      const modalEl = document.getElementById('modalNuevaDev');
      const modal = (typeof bootstrap !== 'undefined') ? (bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl)) : null;

      setTimeout(() => {
        if (modal) modal.hide();
        buscar().catch(console.error);
      }, 900);

    }catch(err){
      if (ndAlert){ ndAlert.textContent = err.message || 'Error al crear'; ndAlert.classList.remove('d-none'); }
      console.error(err);
    }
  });

  // Ciclo del modal Nueva devolución
  const mdNewEl = document.getElementById('modalNuevaDev');
  if (mdNewEl){
    mdNewEl.addEventListener('shown.bs.modal', async () => {
      try{
        await cargarVentasLite();
        if (ndBody) ndBody.innerHTML='';
        if (ndSave) ndSave.disabled = true;
      }catch(err){
        if (ndAlert){ ndAlert.textContent = err.message || 'Error cargando ventas'; ndAlert.classList.remove('d-none'); }
      }
    });
    mdNewEl.addEventListener('hidden.bs.modal', () => {
      if (ndAlert){ ndAlert.classList.add('d-none'); ndAlert.textContent=''; }
      if (ndOK){ ndOK.classList.add('d-none'); ndOK.textContent=''; }
      if (ndVentaSel) ndVentaSel.innerHTML='';
      if (ndBody) ndBody.innerHTML='';
      const f = document.getElementById('nd_fecha'); if (f) f.value='';
      const m = document.getElementById('nd_motivo'); if (m) m.value='';
      if (ndSave) ndSave.disabled = true;
    });
  }

  // Primera carga
  buscar().catch(console.error);
});
</script>

</body>
</html>
