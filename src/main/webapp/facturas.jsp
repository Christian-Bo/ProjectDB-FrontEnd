<%-- 
    Document   : facturas.jsp
    Purpose    : Listado, detalle, PDF y emisión de facturas
    Updated    : 2025-11-04
    Author     : NextTech (Assistant)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Facturas | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema del proyecto -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=14">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=14">

  <style>
    :root{
      --nt-row-hover: rgba(122,90,248,.08);
      --nt-row-border: rgba(122,90,248,.65);
      --nt-accent-rgb: 122,90,248;
    }
    body.nt-bg { background: var(--nt-bg); color: var(--nt-text); }
    .nt-navbar { background: var(--nt-surface); border-bottom: 1px solid var(--nt-border); }
    .nt-title { color: var(--nt-primary); }
    .nt-subtitle { color: var(--nt-text); opacity:.9; }

    .nt-card { 
      background: var(--nt-surface); 
      border:1px solid var(--nt-border); 
      border-radius:1rem; 
      transition: box-shadow .2s ease, border-color .2s ease, transform .15s ease;
    }
    .nt-card:hover{
      border-color: var(--nt-row-border);
      box-shadow: 0 6px 18px rgba(0,0,0,.25);
    }

    .nt-table-head { background: var(--nt-surface-2); color: var(--nt-primary); }
    .table.nt-table > :not(caption) > * > * { border-color: var(--nt-border); }
    .table.nt-table tbody tr{
      transition: background .15s ease, transform .08s ease, box-shadow .15s ease;
    }
    .table.nt-table tbody tr:hover{
      background: var(--nt-row-hover);
      transform: translateY(-1px);
      box-shadow: inset 0 0 0 1px var(--nt-row-border);
    }

    .nt-btn-accent { background: var(--nt-accent); color:#fff; border:none; }
    .nt-btn-accent:hover { filter:brightness(.95); }
    .pager .btn { border-color: var(--nt-border); }

    .modal-backdrop { --bs-backdrop-bg: #0b0d14; --bs-backdrop-opacity: .78; backdrop-filter: blur(2px); }
    .nt-modal .modal-content{ background:var(--nt-surface); color:var(--nt-text); border:1px solid var(--nt-border); border-radius:1rem; }
    .nt-modal .form-control, .nt-modal .form-select{ background:var(--nt-surface-2); color:var(--nt-text); border-color:var(--nt-border); }
    .nt-modal .form-control:focus, .nt-modal .form-select:focus{ border-color:var(--nt-accent); box-shadow:0 0 0 .2rem rgba(122,90,248,.25); }
    .nt-modal .form-control.is-invalid{ border-color:#dc3545!important; box-shadow:0 0 0 .2rem rgba(220,53,69,.25)!important; }

    /* Bloque-resumen (estilo ventas.jsp) */
    .resumen-row{
      background: var(--nt-surface-2);
      border: 1px solid var(--nt-border);
      border-radius: .75rem;
      padding: .75rem .9rem;
    }
    .resumen-row .badge{ font-size:.95rem; }
  </style>

  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="#">
        <i class="bi bi-receipt"></i>NextTech — Facturas
      </a>
      <div class="d-flex align-items-center gap-2">
        <button class="btn btn-sm btn-outline-secondary" type="button" onclick="goBack()">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <main class="container py-3 flex-grow-1">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <h2 class="m-0 nt-title">Facturas</h2>
        <div class="nt-subtitle">Listado, detalle, descarga en PDF y emisión</div>
      </div>
      <div class="d-flex align-items-center gap-2">
        <button class="btn nt-btn-accent" type="button" onclick="abrirEmitir()">
          <i class="bi bi-plus-lg me-1"></i> Emitir factura
        </button>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card nt-card mb-3">
      <div class="card-body">
        <form class="row g-3 align-items-end" onsubmit="buscar(event)">
          <div class="col-md-2">
            <label class="form-label">Desde</label>
            <input type="date" id="f-desde" class="form-control">
          </div>
          <div class="col-md-2">
            <label class="form-label">Hasta</label>
            <input type="date" id="f-hasta" class="form-control">
          </div>
          <div class="col-md-2">
            <label class="form-label">Serie</label>
            <select id="f-serieSel" class="form-select">
              <option value="">Todas</option>
              <option value="A">A</option>
              <option value="B">B</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label">Número</label>
            <input type="text" id="f-numero" class="form-control" placeholder="ej. 30">
          </div>
          <div class="col-md-3 d-flex justify-content-end gap-2">
            <button class="btn nt-btn-accent" type="submit"><i class="bi bi-search me-1"></i> Buscar</button>
            <button class="btn btn-outline-secondary" type="button" onclick="limpiar()"><i class="bi bi-x-circle me-1"></i> Limpiar</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Tabla -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table class="table table-hover nt-table align-middle mb-0">
          <thead class="nt-table-head">
            <tr>
              <th style="min-width:70px">ID</th>
              <th style="min-width:70px">Serie</th>
              <th style="min-width:90px">Número</th>
              <th style="min-width:120px">Fecha</th>
              <th>Cliente</th>
              <th class="text-end" style="min-width:120px">Total</th>
              <th class="text-end" style="min-width:180px">Acciones</th>
            </tr>
          </thead>
          <tbody id="tbody">
            <tr id="tbEmpty"><td colspan="7" class="text-center text-muted">Sin resultados</td></tr>
          </tbody>
        </table>
      </div>

      <!-- Paginación -->
      <div class="card-footer d-flex justify-content-between align-items-center">
        <div class="d-flex align-items-center gap-2">
          <button id="pg-prev" class="btn btn-outline-secondary btn-sm" type="button">« Anterior</button>
          <div id="pg-pages" class="btn-group"></div>
          <button id="pg-next" class="btn btn-outline-secondary btn-sm" type="button">Siguiente »</button>
        </div>
        <div class="d-flex align-items-center gap-2">
          <span class="text-muted">Tamaño</span>
          <select id="f-size" class="form-select form-select-sm" style="width:auto">
            <option value="10">10</option>
            <option value="25">25</option>
            <option value="50" selected>50</option>
          </select>
        </div>
      </div>
    </div>
  </main>

  <!-- ===== Modal Detalle ===== -->
  <div class="modal fade nt-modal" id="modalDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-receipt me-1"></i> Detalle de factura <span id="m-title" class="text-muted"></span></h5>
          <div class="d-flex gap-2">
            <button class="btn btn-outline-info btn-sm" id="m-btn-pdf"><i class="bi bi-filetype-pdf me-1"></i> PDF</button>
            <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
          </div>
        </div>
        <div class="modal-body">
          <!-- Resumen estilo ventas.jsp -->
          <div class="resumen-row d-flex align-items-center justify-content-between flex-wrap gap-3 mb-3">
            <div class="d-flex flex-column">
              <div class="small text-muted">Cliente</div>
              <div id="m-cliente" class="fw-semibold">—</div>
            </div>
            <div class="d-flex flex-column">
              <div class="small text-muted">Serie</div>
              <div id="m-serie" class="badge bg-primary-subtle text-primary-emphasis">—</div>
            </div>
            <div class="d-flex flex-column">
              <div class="small text-muted">Número</div>
              <div id="m-numero" class="badge bg-secondary-subtle text-secondary-emphasis">—</div>
            </div>
            <div class="d-flex flex-column">
              <div class="small text-muted">Fecha</div>
              <div id="m-fecha" class="badge bg-info-subtle text-info-emphasis">—</div>
            </div>
            <div class="d-flex flex-column">
              <div class="small text-muted">Condición</div>
              <div id="m-condicion" class="badge bg-warning-subtle text-warning-emphasis">—</div>
            </div>
          </div>

          <div class="row g-3 mb-3">
            <div class="col-md-6">
              <div class="card nt-card h-100">
                <div class="card-body">
                  <div class="small text-muted text-uppercase">Cliente</div>
                  <div class="mt-1"><span class="text-muted">Nombre:</span> <span id="m-cliente2" class="fw-semibold"></span></div>
                  <div><span class="text-muted">NIT:</span> <span id="m-nit"></span></div>
                </div>
              </div>
            </div>
            <div class="col-md-6">
              <div class="card nt-card h-100">
                <div class="card-body">
                  <div class="small text-muted text-uppercase">Factura</div>
                  <div class="mt-1"><span class="text-muted">Serie:</span> <span id="m-serie2"></span></div>
                  <div><span class="text-muted">Número:</span> <span id="m-numero2"></span></div>
                  <div><span class="text-muted">Fecha:</span> <span id="m-fecha2"></span></div>
                  <div><span class="text-muted">Condición:</span> <span id="m-condicion2"></span></div>
                </div>
              </div>
            </div>
          </div>

          <div class="card nt-card mb-3">
            <div class="table-responsive">
              <table class="table table-sm mb-0">
                <thead class="nt-table-head">
                  <tr>
                    <th>Producto</th>
                    <th class="text-end" style="width:90px">Cant</th>
                    <th class="text-end" style="width:110px">Precio</th>
                    <th class="text-end" style="width:90px">Desc</th>
                    <th class="text-end" style="width:120px">Subtotal</th>
                  </tr>
                </thead>
                <tbody id="m-detalle"></tbody>
              </table>
            </div>
          </div>

          <div class="row g-3">
            <div class="col-md-6"></div>
            <div class="col-md-6">
              <div class="card nt-card">
                <div class="card-body">
                  <table class="table table-borderless table-sm mb-0">
                    <tr><td class="text-muted">Subtotal</td><td class="text-end" id="m-subtotal">—</td></tr>
                    <tr><td class="text-muted">Desc. Gral.</td><td class="text-end" id="m-desc">—</td></tr>
                    <tr><td class="text-muted">IVA</td><td class="text-end" id="m-iva">—</td></tr>
                    <tr class="border-top"><td class="fw-semibold">Total</td><td class="text-end fw-semibold" id="m-total">—</td></tr>
                  </table>
                </div>
              </div>
            </div>
          </div>

        </div> <!-- /modal-body -->
      </div>
    </div>
  </div>

  <!-- ===== Modal Emitir ===== -->
  <div class="modal fade nt-modal" id="modalEmitir" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-plus-circle me-1"></i> Emitir factura</h5>
          <button type="button" class="btn btn-outline-secondary btn-sm" data-bs-dismiss="modal">Cerrar</button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Venta ID *</label>
              <input id="e-venta" class="form-control" type="number" min="1" placeholder="ej. 1">
            </div>

            <div class="col-md-4">
              <label class="form-label">Serie *</label>
              <select id="e-serieSel" class="form-select">
                <option value="">— Selecciona —</option>
                <option value="1">A</option>
                <option value="2">B</option>
              </select>
              <input id="e-serie" type="hidden">
              <small class="text-muted d-block mt-1">Se envía el <strong>Serie ID</strong>.</small>
            </div>

            <div class="col-md-4">
              <label class="form-label">Emitida por</label>
              <select id="e-userSel" class="form-select">
                <option value="">Cargando...</option>
              </select>
              <input id="e-usuario" type="hidden" value="1">
              <small class="text-muted d-block mt-1">FK a <strong>empleados</strong> (usuarioId).</small>
            </div>

            <div class="col-12">
              <div id="e-msg" class="alert alert-danger d-none"></div>
              <small class="text-muted">Se llamará a <code>POST /api/facturas</code>.</small>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn nt-btn-accent" id="e-btn" onclick="emitir()">
            <i class="bi bi-check2-circle me-1"></i> Emitir
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Toast -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="appToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex align-items-center">
        <div class="toast-body" id="toastMsg">Listo.</div>
        <button id="toastAction" type="button" class="btn btn-light btn-sm me-2 d-none"></button>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </div>

  <!-- Bootstrap -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- ===== JS ===== -->
<script>
/* ========= Navegación ========= */
function goBack(){
  try{ if(history.length>1){ history.back(); return; } }catch(_){}
  var ctxRaw='${pageContext.request.contextPath}', ctx=(ctxRaw||'').trim();
  location.href=(ctx && ctx!=='/'?ctx:'')+'/Dashboard.jsp';
}

/* ========= Base API ========= */
function joinUrl(base, path){
  return String(base||'').replace(/\/+$/,'') + '/' + String(path||'').replace(/^\/+/,'');
}
(function(){
  var meta=document.querySelector('meta[name="api-base"]');
  var base=(window.API_BASE || (meta && meta.getAttribute('content')) || location.origin).trim();
  window.API_ROOT=base.replace(/\/+$/,'');
})();
var API_FACTURAS   = joinUrl(window.API_ROOT, '/api/facturas');
var API_CATALOGOS  = joinUrl(window.API_ROOT, '/api/catalogos');
var commonHeaders  = { 'Content-Type':'application/json' };

/* ========= Toast ========= */
var AppToast=(function(){
  function ensure(){
    var el = document.getElementById('appToast');
    if (!el){
      var wrap = document.createElement('div');
      wrap.className = 'position-fixed top-0 end-0 p-3';
      wrap.style.zIndex = '1080';
      wrap.innerHTML =
        '<div id="appToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">' +
          '<div class="d-flex align-items-center">' +
            '<div class="toast-body" id="toastMsg">Listo.</div>' +
            '<button id="toastAction" type="button" class="btn btn-light btn-sm me-2 d-none"></button>' +
            '<button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>' +
          '</div>' +
        '</div>';
      document.body.appendChild(wrap);
      el = document.getElementById('appToast');
    }
    return el;
  }
  function show(o){
    var t=ensure(), m=document.getElementById('toastMsg'), a=document.getElementById('toastAction');
    t.className='toast position-fixed top-0 end-0 m-3 align-items-center border-0 ' +
      (o&&o.type==='error' ? 'text-bg-danger' : o&&o.type==='warn' ? 'text-bg-warning' : 'text-bg-primary');
    m.textContent=(o&&o.message)||'OK';
    if (a){
      a.classList.add('d-none'); a.onclick=null;
      if (o && o.actionText && typeof o.onAction==='function'){
        a.textContent=o.actionText; a.classList.remove('d-none');
        a.onclick=function(e){ e.preventDefault(); try{o.onAction();}catch(_){ } bootstrap.Toast.getOrCreateInstance(t).hide(); };
      }
    }
    bootstrap.Toast.getOrCreateInstance(t,{delay:(o&&o.delay)||3500,autohide:true}).show();
  }
  return {
    ok:   function(m){ show({message:m}); },
    err:  function(m){ show({message: (typeof m==='string'?m:(m&&JSON.stringify(m))||'Error'), type:'error'}); },
    warn: function(m){ show({message:m, type:'warn'}); },
    show: show
  };
})();

/* ========= Helpers ========= */
function withNoCache(url){
  try{ var u=new URL(url, location.origin); u.searchParams.set('_', Date.now()); return u.toString(); }
  catch(_){ return url + (url.indexOf('?')>=0?'&':'?') + '_=' + Date.now(); }
}
function toNumber(n){
  if(n==null || n==='') return 0;
  var num = (typeof n==='string') ? Number(n.replace(/[^\d.-]/g,'')) : Number(n);
  return isNaN(num) ? 0 : num;
}
function round2(x){ return Math.round((Number(x)||0)*100)/100; }
function fmt(n){
  var num = toNumber(n);
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(num); }
  catch(_){ return 'Q ' + num.toFixed(2); }
}
function asArray(x){
  if (Array.isArray(x)) return x;
  if (!x) return [];
  return x.items || x.content || x.data || x.results || x.records || [];
}
async function tryFetchJson(url,opts){
  try{
    var o = opts || {};
    var method = (o.method || 'GET').toUpperCase();
    var finalUrl = (method==='GET') ? withNoCache(url) : url;
    var res = await fetch(finalUrl, Object.assign({cache:'no-store',credentials:'same-origin'}, o));
    var t = await res.text(); var data=null; try{ data=t?JSON.parse(t):null; }catch(_){}
    return { ok:res.ok, status:res.status, data:data };
  }catch(e){ return { ok:false, status:0, data:{error:e.message||'network'} }; }
}
/* deepPick: soporta rutas tipo "a.b.c" */
function deepPick(obj, paths, dflt){
  for (var i=0;i<paths.length;i++){
    var cur=obj, parts=String(paths[i]).split('.');
    for (var j=0;j<parts.length;j++){
      var k=parts[j];
      if (cur!=null && Object.prototype.hasOwnProperty.call(cur,k) && cur[k]!=null){ cur=cur[k]; }
      else { cur=undefined; break; }
    }
    if (cur!==undefined) return cur;
  }
  return dflt;
}
/* búsqueda recursiva por regex de clave (para texto como cliente/nit/fecha) */
function findByKeyRegex(obj, regexes){
  if (!obj || typeof obj!=='object') return undefined;
  var stack=[obj];
  while(stack.length){
    var cur=stack.pop();
    if (Array.isArray(cur)){ for (var i=0;i<cur.length;i++) stack.push(cur[i]); continue; }
    for (var k in cur){
      if (!Object.prototype.hasOwnProperty.call(cur,k)) continue;
      var v=cur[k];
      for (var r=0;r<regexes.length;r++){
        if (regexes[r].test(k)){
          if (typeof v==='string' || typeof v==='number') return v;
          if (v && typeof v==='object'){
            if ('monto' in v) return v.monto;
            if ('valor' in v) return v.valor;
          }
        }
      }
      if (v && typeof v==='object') stack.push(v);
    }
  }
  return undefined;
}
function safeSet(id, val){
  var el=document.getElementById(id);
  if (!el) return;
  el.textContent = (val==null ? '' : String(val));
}
function fmtDate(x){
  if(!x) return '';
  try{
    if (/^\d{4}-\d{2}-\d{2}/.test(x)) return x.replace('T',' ').replace('Z','');
    var d = new Date(x);
    if (isNaN(d.getTime())) return String(x);
    var pad = n=>String(n).padStart(2,'0');
    return d.getFullYear()+'-'+pad(d.getMonth()+1)+'-'+pad(d.getDate());
  }catch(_){ return String(x); }
}
function smartPick(obj, pathList, regexList, dflt){
  var v = deepPick(obj, pathList, undefined);
  if (v===undefined && regexList && regexList.length) v = findByKeyRegex(obj, regexList);
  return (v===undefined ? dflt : v);
}

/* ========= Normalizadores ========= */
const KEYS = {
  serie:      ['serie','serie_codigo','serieCodigo','serieNombre','serie_nombre','serie.codigo','cabecera.serie','header.serie','serieFactura'],
  numero:     ['numero','num','numero_fac','no','cabecera.numero','header.numero','numeroFactura'],
  fecha:      ['fecha_emision','fechaEmision','fecha','f_emision','cabecera.fecha','header.fecha','fechaFactura','fecha_factura','creado','created','createdAt','created_at'],
  condicion:  ['condicion','condicion_pago','condicionPago','origen','tipo_pago','tipoPago','cabecera.condicion','header.condicion'],
  cliNombre:  ['cliente','cliente_nombre','clienteNombre','cliente.nombre','cabecera.cliente','cliente.razonSocial','cliente.razon_social','datosCliente.nombre','clienteDatos.nombre'],
  nit:        ['nit','cliente_nit','cliente.nit','cabecera.nit','cliente.NIT','nitCliente','clienteNit','nit_cliente','datosCliente.nit','clienteDatos.nit','cabecera.cliente.nit'],
  clienteId:  ['clienteId','cliente_id','cliente.id','cabecera.clienteId','header.clienteId']
};
const TOTAL_KEYS = {
  subtotal:   ['totales.subtotal','resumen.subtotal','subtotal','sub_total','subTotal'],
  descuento:  ['totales.descuento','resumen.descuento','descuento','descuento_general','desc_total'],
  iva:        ['totales.iva','totales.impuestoIva','resumen.iva','iva','impuesto','vat','total_iva'],
  total:      ['totales.total','resumen.total','total','m_total','importe_total']
};
const ITEM_KEYS = {
  nombre:   ['producto','productoNombre','descripcion','nombre','producto.nombre','detalle','concepto'],
  cantidad: ['cantidad','qty','cant'],
  precio:   ['precio','precio_unitario','pu','precioUnitario','precioUnit'],
  dcto:     ['descuento','desc','dcto'],
  subtotal: ['subtotal','importe','total_linea','totales.subtotal','subtotalLinea']
};

/* Totales consistentes (evita capturar el subtotal de una línea) */
function computeTotalsStrict(data, items){
  const fromRoot = {
    subtotal: toNumber(deepPick(data, TOTAL_KEYS.subtotal, 0)),
    descuento:toNumber(deepPick(data, TOTAL_KEYS.descuento, 0)),
    iva:      toNumber(deepPick(data, TOTAL_KEYS.iva, 0)),
    total:    toNumber(deepPick(data, TOTAL_KEYS.total, 0))
  };
  const linesSum = round2(items.reduce((acc,it)=>acc + toNumber(it.subt), 0));

  // Si el subtotal de raíz falta o no coincide con la suma de líneas, preferimos líneas
  let subtotal = fromRoot.subtotal>0 ? fromRoot.subtotal : linesSum;
  if (Math.abs(subtotal - linesSum) > 0.01) subtotal = linesSum;

  let descuento = fromRoot.descuento || 0;
  let iva       = fromRoot.iva || 0;
  let total     = fromRoot.total || 0;

  // Derivar IVA/Total si faltan
  if (!total && subtotal){
    total = round2(subtotal - descuento + iva);
  }
  if (!iva && total){
    iva = round2(total - (subtotal - descuento));
  }
  if (!iva && subtotal){
    iva = round2((subtotal - descuento) * 0.12); // fallback 12%
    total = round2(subtotal - descuento + iva);
  } else {
    total = round2(subtotal - descuento + iva);
  }
  return { subtotal: round2(subtotal), descuento: round2(descuento), iva: round2(iva), total: round2(total) };
}

function normalizeFactura(data){
  var serie   = smartPick(data, KEYS.serie,   [/serie/i], '');
  var numero  = smartPick(data, KEYS.numero,  [/numero|nro|num\b/i], '');
  var fecha   = fmtDate(smartPick(data, KEYS.fecha, [/fecha.*emisi/i,/fecha/i,/cread/i], ''));
  var cond    = smartPick(data, KEYS.condicion, [/condic|origen|pago/i], '');
  var cliNom  = smartPick(data, KEYS.cliNombre, [/cliente.*(nombre|razon)|^cliente$/i], '');
  var nit     = smartPick(data, KEYS.nit,      [/nit\b/i,/cliente.*nit/i,/tax.?id/i], '');

  var itemsRaw = asArray( smartPick(data, ['items','detalle','lineas','renglones','detalle.items','detalles','conceptos'], [/detalle|items|renglones|lineas/i], []) );
  var items = itemsRaw.map(function(d){
    var nombre = smartPick(d, ITEM_KEYS.nombre,   [/prod|desc|concepto/i], '');
    var cant   = toNumber(smartPick(d, ITEM_KEYS.cantidad, [/cant/i], 0));
    var precio = toNumber(smartPick(d, ITEM_KEYS.precio,   [/precio/i], 0));
    var dcto   = toNumber(smartPick(d, ITEM_KEYS.dcto,     [/desc/i], 0));
    var subt   = toNumber(smartPick(d, ITEM_KEYS.subtotal, [/sub|importe|total/i], cant*precio - dcto));
    return {nombre, cant, precio, dcto, subt};
  });

  var tot = computeTotalsStrict(data, items);

  return {serie, numero, fecha, cond, cliNom, nit, items, tot,
          cliId: smartPick(data, KEYS.clienteId, [/cliente.*id/i], null)};
}

/* ========= Estado de grilla (paginación) ========= */
const UI = { page:0, size:50, hasNext:false };

/* ========= EMPLEADOS: Carga para select "Emitida por" ========= */
let _empleados = [];
let _empleadosCargados = false;

async function cargarEmpleados(){
  if (_empleadosCargados) return _empleados;
  
  const sel = document.getElementById('e-userSel');
  if(!sel) return [];
  
  try{
    const r = await tryFetchJson(joinUrl(API_CATALOGOS, '/empleados?limit=200'), {headers:commonHeaders});
    
    if(!r.ok || !r.data) {
      console.warn('[facturas] No se pudieron cargar empleados');
      fillSelectEmpleados(sel, [], '— Sin empleados —');
      return [];
    }
    
    _empleados = asArray(r.data);
    fillSelectEmpleados(sel, _empleados);
    _empleadosCargados = true;
    
    return _empleados;
    
  }catch(err){
    console.error('[facturas] Error al cargar empleados:', err);
    fillSelectEmpleados(sel, [], '— Error al cargar —');
    return [];
  }
}

function fillSelectEmpleados(sel, empleados, placeholder){
  if(!sel) return;
  
  let html = '<option value="">' + (placeholder || '— Selecciona empleado —') + '</option>';
  
  for(let i = 0; i < empleados.length; i++){
    const emp = empleados[i];
    const id = emp.id || emp.empleadoId || '';
    const codigo = emp.codigo || ('EMP-' + id);
    const nombres = emp.nombres || '';
    const apellidos = emp.apellidos || '';
    const nombre = (nombres + ' ' + apellidos).trim();
    const texto = codigo + ' - ' + nombre;
    
    html += '<option value="' + id + '">' + texto + '</option>';
  }
  
  sel.innerHTML = html;
  
  // Hook para sincronizar con el hidden
  sel.onchange = function(e){
    const hid = document.getElementById('e-usuario');
    if(hid) hid.value = e.target.value || '1'; // default 1 si está vacío
  };
}

/* ========= Listado ========= */
function buscar(ev){ if(ev) ev.preventDefault(); UI.page=0; doBuscar(); }

async function doBuscar(){
  var qs=new URLSearchParams();
  var desde =(document.getElementById('f-desde')||{}).value||'';
  var hasta =(document.getElementById('f-hasta')||{}).value||'';
  var serie =(document.getElementById('f-serieSel')||{}).value||'';
  var numero=(document.getElementById('f-numero')||{}).value||'';

  if(desde) qs.set('desde',desde.trim());
  if(hasta) qs.set('hasta',hasta.trim());
  if(serie) qs.set('serie',serie.trim());
  if(numero) qs.set('numero',numero.trim());

  // pedir size+1 para saber si hay siguiente
  qs.set('page', String(UI.page));
  qs.set('size', String(UI.size + 1));

  var url = API_FACTURAS + (qs.toString()?('?'+qs.toString()):'');
  var r = await tryFetchJson(url,{ headers:commonHeaders });
  if(!r.ok){ 
    AppToast.err((r.data&&(r.data.message||r.data.detail||r.data.error))||'No se pudo cargar'); 
    renderTabla([]); 
    renderPager(false);
    return; 
  }

  var rows = asArray(r.data);
  UI.hasNext = rows.length > UI.size;
  if (UI.hasNext) rows = rows.slice(0, UI.size);

  var items = rows.map(function(it){
    return {
      id:       smartPick(it, ['id','facturaId','factura_id'], [/id\b/i]),
      serie:    smartPick(it, KEYS.serie,  [/serie/i]),
      numero:   smartPick(it, KEYS.numero, [/num|nro|numero/i]),
      fecha:    fmtDate(smartPick(it, KEYS.fecha, [/fecha/i])),
      cliente:  smartPick(it, KEYS.cliNombre, [/cliente/i]),
      nit:      smartPick(it, KEYS.nit, [/nit/i]),
      total:    toNumber(smartPick(it, TOTAL_KEYS.total, [/total/i]))
    };
  });
  renderTabla(items);
  renderPager(true);
}

function limpiar(){
  ['f-desde','f-hasta','f-numero'].forEach(function(id){ var el=document.getElementById(id); if(el) el.value=''; });
  var s=document.getElementById('f-serieSel'); if(s) s.value='';
  UI.page=0; doBuscar();
}

/* ========= Tabla ========= */
function renderTabla(items){
  var tb=document.getElementById('tbody'); if(!tb) return;
  var empty=document.getElementById('tbEmpty');
  tb.innerHTML='';
  if(!items||!items.length){
    if (empty) empty.classList.remove('d-none');
    else {
      var tr=document.createElement('tr'); var td=document.createElement('td');
      td.colSpan=7; td.className='text-muted'; td.textContent='Sin resultados';
      tr.appendChild(td); tb.appendChild(tr);
    }
    return;
  }
  if (empty) empty.classList.add('d-none');

  for(var i=0;i<items.length;i++){
    var it=items[i]||{};
    var tr=document.createElement('tr');

    var td=document.createElement('td');
    var a=document.createElement('a'); a.href='#'; a.textContent=String(it.id||'');
    a.onclick=(function(row){return function(e){e.preventDefault(); ver(row.id, row);};})(it);
    td.appendChild(a); tr.appendChild(td);

    td=document.createElement('td'); td.textContent=it.serie||''; tr.appendChild(td);
    td=document.createElement('td'); td.textContent=it.numero||''; tr.appendChild(td);
    td=document.createElement('td'); td.textContent=it.fecha||''; tr.appendChild(td);
    td=document.createElement('td'); td.textContent=it.cliente||''; tr.appendChild(td);

    td=document.createElement('td'); td.className='text-end'; td.textContent=fmt(it.total); tr.appendChild(td);

    td=document.createElement('td'); td.className='text-end';
    var bPdf=document.createElement('button'); bPdf.type='button'; bPdf.className='btn btn-outline-info btn-sm me-1';
    bPdf.innerHTML='<i class="bi bi-filetype-pdf"></i>'; bPdf.title='PDF';
    bPdf.onclick=(function(id){return function(){ pdf(id); };})(it.id);
    var bVer=document.createElement('button'); bVer.type='button'; bVer.className='btn btn-outline-secondary btn-sm';
    bVer.innerHTML='<i class="bi bi-eye"></i>'; bVer.title='Ver';
    bVer.onclick=(function(row){return function(){ ver(row.id, row); };})(it);
    td.appendChild(bPdf); td.appendChild(bVer); tr.appendChild(td);

    tb.appendChild(tr);
  }
}

/* ========= Paginación ========= */
function renderPager(enable){
  const prev = document.getElementById('pg-prev');
  const next = document.getElementById('pg-next');
  const group= document.getElementById('pg-pages');
  if(!prev || !next || !group) return;

  prev.disabled = !enable || UI.page===0;
  next.disabled = !enable || !UI.hasNext;

  group.innerHTML='';
  // ventana de hasta 5 botones alrededor de la página actual
  const start = Math.max(0, UI.page - 2);
  const end   = UI.hasNext ? (UI.page + 3) : (UI.page + 1);
  for(let p=start; p<end; p++){
    const btn = document.createElement('button');
    btn.type='button';
    btn.className='btn btn-sm ' + (p===UI.page ? 'btn-primary' : 'btn-outline-secondary');
    btn.textContent = (p+1);
    btn.onclick = ()=>{ UI.page=p; doBuscar(); };
    group.appendChild(btn);
  }
}
(function hookPager(){
  const prev = document.getElementById('pg-prev');
  const next = document.getElementById('pg-next');
  const size = document.getElementById('f-size');
  if(prev) prev.onclick = ()=>{ if(UI.page>0){ UI.page--; doBuscar(); } };
  if(next) next.onclick = ()=>{ if(UI.hasNext){ UI.page++; doBuscar(); } };
  if(size) size.onchange = (e)=>{ UI.size = Number(e.target.value||50); UI.page=0; doBuscar(); };
})();

/* ========= Modal (Bootstrap) ========= */
var MOD_DET=null, MOD_EMI=null;
function showDetalleModal(){ if(!MOD_DET){ MOD_DET = bootstrap.Modal.getOrCreateInstance(document.getElementById('modalDetalle')); } MOD_DET.show(); }
function hideDetalleModal(){ if(MOD_DET){ MOD_DET.hide(); } }
function showEmitirModal(){ if(!MOD_EMI){ MOD_EMI = bootstrap.Modal.getOrCreateInstance(document.getElementById('modalEmitir')); } MOD_EMI.show(); }
function hideEmitirModal(){ if(MOD_EMI){ MOD_EMI.hide(); } }

/* ========= Fallback cliente por ID ========= */
async function tryFetchClienteById(id){
  if(!id) return null;
  try{
    var r = await tryFetchJson(joinUrl(API_CATALOGOS, '/clientes/'+id), { headers: commonHeaders });
    if(!r.ok) return null;
    var d = r.data || {};
    return {
      nombre: smartPick(d, ['nombre','razonSocial','razon_social','cliente','displayName'], [/nombre|razon/i], ''),
      nit:    smartPick(d, ['nit','NIT','documento','taxId'], [/nit|tax/i], '')
    };
  }catch(_){ return null; }
}

/* ========= Detalle ========= */
async function ver(id, hint){
  showDetalleModal();

  // Hint mientras carga
  safeSet('m-title', ' #'+(hint&&hint.numero || id || '')+' · '+(hint&&hint.fecha || 'cargando…'));
  safeSet('m-cliente',  hint&&hint.cliente || '—');
  safeSet('m-serie',    hint&&hint.serie   || '—');
  safeSet('m-numero',   hint&&hint.numero  || '—');
  safeSet('m-fecha',    hint&&hint.fecha   || '—');
  safeSet('m-condicion','—');
  safeSet('m-cliente2', hint&&hint.cliente || '');
  safeSet('m-nit',      hint&&hint.nit     || '');

  ['m-serie2','m-numero2','m-fecha2','m-condicion2','m-subtotal','m-desc','m-iva','m-total'].forEach(function(k){ safeSet(k,'—'); });
  var tbody=document.getElementById('m-detalle'); if(tbody) tbody.innerHTML='';

  try{
    var r = await tryFetchJson(joinUrl(API_FACTURAS,'/'+id), { headers:commonHeaders });
    if(!r.ok){ throw new Error((r.data&&(r.data.message||r.data.detail||r.data.error))||'No se pudo obtener la factura'); }
    var map = normalizeFactura(r.data||{});

    // Completar cliente/NIT si no vinieron en la respuesta
    if(!map.cliNom && hint && hint.cliente) map.cliNom = hint.cliente;
    if(!map.nit && hint && hint.nit) map.nit = hint.nit;
    if(!map.nit && map.cliId){
      var cli = await tryFetchClienteById(map.cliId);
      if(cli){ if(!map.cliNom && cli.nombre) map.cliNom = cli.nombre; if(cli.nit) map.nit = cli.nit; }
    }

    safeSet('m-title', ' #'+(map.numero||'')+' · '+(map.fecha||''));
    safeSet('m-cliente',  map.cliNom||''); safeSet('m-cliente2', map.cliNom||'');
    safeSet('m-nit',      map.nit||'');
    safeSet('m-serie',    map.serie||'');  safeSet('m-serie2',   map.serie||'');
    safeSet('m-numero',   map.numero||''); safeSet('m-numero2',  map.numero||'');
    safeSet('m-fecha',    map.fecha||'');  safeSet('m-fecha2',   map.fecha||'');
    safeSet('m-condicion',map.cond||'');   safeSet('m-condicion2', map.cond||'');

    if(tbody){
      if(!map.items.length){
        var tr0=document.createElement('tr'); tr0.innerHTML='<td colspan="5" class="text-center text-muted">Sin renglones</td>';
        tbody.appendChild(tr0);
      }else{
        for(var i=0;i<map.items.length;i++){
          var d=map.items[i];
          var tr = document.createElement('tr');
          tr.innerHTML =
            '<td>'+ (d.nombre||'') +'</td>'+
            '<td class="text-end">'+ Number(d.cant||0).toFixed(2) +'</td>'+
            '<td class="text-end">'+ fmt(d.precio) +'</td>'+
            '<td class="text-end">'+ fmt(d.dcto) +'</td>'+
            '<td class="text-end">'+ fmt(d.subt) +'</td>';
          tbody.appendChild(tr);
        }
      }
    }

    // Totales ya consistentes
    safeSet('m-subtotal', fmt(map.tot.subtotal));
    safeSet('m-desc',     fmt(map.tot.descuento));
    safeSet('m-iva',      fmt(map.tot.iva));
    safeSet('m-total',    fmt(map.tot.total));

    var pdfUrl = smartPick(r.data, ['pdf_url','pdfUrl'], [/pdf.*url/i], joinUrl(API_FACTURAS,'/'+id+'/pdf'));
    var btnPdf=document.getElementById('m-btn-pdf');
    if (btnPdf){ btnPdf.onclick=function(){ window.open(pdfUrl,'_blank'); }; }

  }catch(err){
    console.error('[facturas] detalle', err);
    AppToast.err(err.message||String(err));
  }
}

/* ========= PDF ========= */
function pdf(id){ if(!id) return; window.open(joinUrl(API_FACTURAS,'/'+id+'/pdf'),'_blank'); }

/* ========= Emitir ========= */
function abrirEmitir(){
  var msg=document.getElementById('e-msg'); 
  if(msg){ msg.textContent=''; msg.classList.add('d-none'); }
  
  ['e-venta','e-serie','e-usuario'].forEach(function(id){ 
    var el=document.getElementById(id); 
    if(el) el.value=''; 
  });
  
  // Setear selects por defecto
  var sSel=document.getElementById('e-serieSel'); if(sSel){ sSel.value=''; }
  var uSel=document.getElementById('e-userSel');  if(uSel){ uSel.value=''; }
  
  // Default usuario=1 si no se elige
  var u=document.getElementById('e-usuario'); 
  if(u && !u.value) u.value='1';
  
  // Cargar empleados al abrir modal (por si no se cargaron antes)
  cargarEmpleados();
  
  showEmitirModal();
}

async function emitir(){
  // tomar IDs desde los hidden que sincronizamos con los selects
  var ventaId   = Number((document.getElementById('e-venta')||{}).value||0);
  var serieId   = Number((document.getElementById('e-serie')||{}).value||0);
  var usuarioId = Number((document.getElementById('e-usuario')||{}).value||1);
  var msg = document.getElementById('e-msg');

  if (!ventaId || !serieId){
    if (msg){ msg.textContent='Venta y Serie son obligatorios.'; msg.classList.remove('d-none'); }
    AppToast.warn('Completa Venta y Serie'); return;
  }

  var payload = { ventaId:ventaId, serieId:serieId, emitidaPor:usuarioId };

  var r = await tryFetchJson(API_FACTURAS, { method:'POST', headers:commonHeaders, body:JSON.stringify(payload) });
  if (!r.ok){
    var err=(r.data&&(r.data.message||r.data.detail||r.data.error))||'No se pudo emitir';
    if (msg){ msg.textContent = err; msg.classList.remove('d-none'); }
    AppToast.err(err); return;
  }
  AppToast.ok('Factura emitida'); hideEmitirModal(); doBuscar();
}

/* ========= Hooks de selects (sincronizar a hidden) ========= */
function hookEmitirSelects(){
  const sSel=document.getElementById('e-serieSel');
  const sHid=document.getElementById('e-serie');
  if(sSel && sHid){ sSel.onchange=(e)=>{ sHid.value = e.target.value || ''; }; }

  const uSel=document.getElementById('e-userSel');
  const uHid=document.getElementById('e-usuario');
  if(uSel && uHid){ uSel.onchange=(e)=>{ uHid.value = e.target.value || ''; }; }
}

/* ========= Boot ========= */
window.addEventListener('DOMContentLoaded', function(){
  hookEmitirSelects();
  cargarEmpleados();   // Cargar empleados al iniciar
  doBuscar();

  // Paginación
  const prev = document.getElementById('pg-prev');
  const next = document.getElementById('pg-next');
  const size = document.getElementById('f-size');
  if(prev) prev.onclick = ()=>{ if(UI.page>0){ UI.page--; doBuscar(); } };
  if(next) next.onclick = ()=>{ if(UI.hasNext){ UI.page++; doBuscar(); } };
  if(size) size.onchange = (e)=>{ UI.size = Number(e.target.value||50); UI.page=0; doBuscar(); };

  window.addEventListener('keydown', function(ev){
    if (ev.key === 'Escape'){ hideDetalleModal(); hideEmitirModal(); }
  });
});
</script>

</body>
</html>