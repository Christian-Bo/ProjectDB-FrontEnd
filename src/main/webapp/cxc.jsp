<%--
  Cuentas por Cobrar (UNIFICADO, sin navegación por hash)
  - Listado + filtros + paginación
  - Modal: Registrar pago
  - Modal: Detalle de documento
  - Modal: Pagos registrados
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Cuentas por Cobrar | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Base del backend -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta / tema del proyecto -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=13">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=13">

<style>
  body.nt-bg { background: var(--nt-bg); color: var(--nt-text); }
  .nt-title{ color: var(--nt-primary); }
  .nt-subtitle{ color: var(--nt-text); opacity:.9; }

  .nt-back{
    display:inline-flex; align-items:center; gap:.5rem;
    border:1px solid var(--nt-border);
    background:transparent; color: var(--nt-primary);
  }
  .nt-back:hover{ background: var(--nt-surface-2); }

  .nt-card{
    background: var(--nt-surface);
    border:1px solid var(--nt-border);
    border-radius:1rem; transition:.12s;
  }
  .nt-card:hover{
    transform: translateY(-1px);
    border-color: var(--nt-accent);
    box-shadow: 0 10px 24px rgba(0,0,0,.35);
  }

  .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-primary); }

  .nt-btn-accent{ background: var(--nt-accent); color:#fff; border:none; }
  .nt-btn-accent:hover{ filter: brightness(.95); }

  .form-control.nt-input, .form-select.nt-input{
    background: var(--nt-surface-2);
    color: var(--nt-text);
    border-color: var(--nt-border);
  }
  .form-control.nt-input:focus, .form-select.nt-input:focus{
    border-color: var(--nt-accent);
    box-shadow: 0 0 0 .2rem rgba(0,102,255,.15);
  }

  .modal-content{
    background: var(--nt-surface) !important;
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
  .modal-backdrop.show{ opacity:.6 !important; }
</style>

  <!-- utilidades comunes del proyecto -->
  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2">
        <i class="bi bi-receipt"></i> NextTech — Cuentas por Cobrar
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <div class="container py-4">

    <!-- Título + acción -->
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <h2 class="m-0 nt-title"><i class="bi bi-cash-coin"></i> Cuentas por Cobrar</h2>
        <div class="nt-subtitle">Filtra, consulta y registra pagos de documentos a crédito</div>
      </div>
      <button type="button" class="btn nt-btn-accent" data-bs-toggle="modal" data-bs-target="#mdlPagos">
        <i class="bi bi-wallet2 me-1"></i> Ver pagos
      </button>
    </div>

    <!-- Filtros -->
    <div class="card nt-card mb-3">
      <div class="card-body">
        <form id="filtros" onsubmit="buscar(event)" class="row g-3">
          <div class="col-md-3">
            <label class="form-label">Desde</label>
            <input type="date" name="desde" class="form-control" placeholder="dd/mm/aaaa">
          </div>
          <div class="col-md-3">
            <label class="form-label">Hasta</label>
            <input type="date" name="hasta" class="form-control" placeholder="dd/mm/aaaa">
          </div>
          <div class="col-md-3">
            <label class="form-label">Cliente</label>
            <select id="selCliente" class="form-select">
              <option value="">(Todos)</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label">Estado</label>
            <select name="estado" class="form-select">
              <option value="">(Todos)</option>
              <option value="P">Pendiente</option>
              <option value="C">Cancelado</option>
              <option value="A">Anulado</option>
            </select>
          </div>

          <div class="col-12 d-flex gap-2 justify-content-end">
            <button class="btn nt-btn-accent" type="submit"><i class="bi bi-search me-1"></i>Buscar</button>
            <button class="btn btn-outline-secondary" type="button" onclick="limpiar()"><i class="bi bi-x-circle me-1"></i>Limpiar</button>
          </div>

          <div id="errorBox" class="alert alert-danger mt-2 d-none"></div>
        </form>
      </div>
    </div>

    <!-- Paginación -->
    <div class="d-flex justify-content-between align-items-center mb-2">
      <div class="d-flex align-items-center gap-2">
        <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(-1)">&laquo; Anterior</button>
        <div> Página <span id="pActual">1</span> </div>
        <button class="btn btn-outline-secondary btn-sm" onclick="cambiarPagina(1)">Siguiente &raquo;</button>
      </div>
      <small class="text-muted">Mostrando 10 por página</small>
    </div>

    <!-- Tabla -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table id="tabla" class="table table-hover align-middle mb-0">
          <thead class="nt-table-head">
            <tr>
              <th>Documento</th>
              <th>Cliente</th>
              <th>Fecha Emisión</th>
              <th>Fecha Venc.</th>
              <th>Venta ID</th>
              <th class="text-end">Monto</th>
              <th class="text-end">Saldo</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody id="tablaBody">
            <tr id="tablaEmpty"><td colspan="9" class="text-center text-muted">Sin resultados</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ======================= MODALES ======================= -->

  <!-- Modal: Registrar Pago -->
  <div class="modal fade" id="mdlCobro" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Registrar pago</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>

        <div class="modal-body">
          <div class="mb-2">
            <label class="form-label">Cliente</label>
            <input id="pCliente" class="form-control" readonly>
          </div>
          <div class="mb-2">
            <label class="form-label">Documento</label>
            <input id="pDocNum" class="form-control" readonly>
          </div>

          <div class="row">
            <div class="col-md-6 mb-2">
              <label class="form-label">Monto</label>
              <input id="pMonto" type="number" step="0.01" class="form-control" inputmode="decimal">
              <div id="pMontoHelp" class="form-text">No puede exceder el saldo.</div>
            </div>
            <div class="col-md-6 mb-2">
              <label class="form-label">Fecha</label>
              <input id="pFecha" type="date" class="form-control" readonly>
            </div>
          </div>

          <div class="row">
            <div class="col-md-6 mb-2">
              <label class="form-label">Forma de pago</label>
              <select id="pForma" class="form-select">
                <option value="EFE">Efectivo</option>
                <option value="TAR">Tarjeta</option>
                <option value="TRF">Transferencia</option>
              </select>
            </div>
            <div class="col-md-6 mb-2">
              <label class="form-label">Observaciones</label>
              <input id="pObs" class="form-control" placeholder="caja / ref. bancaria">
            </div>
          </div>

          <!-- TARJETA -->
          <div id="extraTarjeta" class="row g-3 mt-2 d-none">
            <div class="col-12"><hr class="my-2"><div class="text-muted mb-1">Datos de tarjeta</div></div>
            <div class="col-12 col-md-7">
              <label class="form-label">Número de tarjeta</label>
              <input id="cardNum" type="text" inputmode="numeric" maxlength="19"
                     class="form-control" placeholder="#### #### #### ####"
                     pattern="^[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4}$">
              <div class="form-text">Solo se guardan los últimos 4 (no se almacena CVV).</div>
            </div>
            <div class="col-6 col-md-3">
              <label class="form-label">Vencimiento</label>
              <input id="cardExp" type="text" class="form-control" placeholder="MM/AA"
                     maxlength="5" pattern="^(0[1-9]|1[0-2])\/[0-9]{2}$">
            </div>
            <div class="col-6 col-md-2">
              <label class="form-label">CVV</label>
              <input id="cardCvv" type="password" class="form-control" inputmode="numeric"
                     maxlength="4" pattern="^[0-9]{3,4}$">
            </div>
            <div class="col-12">
              <label class="form-label">Titular (opcional)</label>
              <input id="cardName" type="text" class="form-control" placeholder="Como aparece en la tarjeta">
            </div>
          </div>

          <!-- TRANSFERENCIA -->
          <div id="extraTransfer" class="row g-3 mt-2 d-none">
            <div class="col-12"><hr class="my-2"><div class="text-muted mb-1">Datos de transferencia</div></div>
            <div class="col-12 col-md-4">
              <label class="form-label">Banco</label>
              <input id="trfBank" type="text" class="form-control" placeholder="BANRURAL / BAC...">
            </div>
            <div class="col-12 col-md-5">
              <label class="form-label">Referencia</label>
              <input id="trfRef" type="text" class="form-control" placeholder="N° de comprobante">
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label">Fecha dep.</label>
              <input id="trfDate" type="date" class="form-control">
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn nt-btn-accent" id="btnCobrarGo">Registrar pago</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal: Detalle de CxC -->
  <div class="modal fade" id="mdlDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-journal-text me-2"></i>Detalle de CxC</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <!-- Resumen -->
          <div class="card nt-card mb-3">
            <div class="card-body">
              <div class="row g-3 align-items-center">
                <div class="col-lg-4">
                  <div class="nt-subtitle mb-1">Documento</div>
                  <div id="hNumero" class="fs-5 fw-semibold">—</div>
                </div>
                <div class="col-6 col-lg-2">
                  <div class="nt-subtitle">Estado</div>
                  <div id="hEstado"><span class="badge text-bg-secondary rounded-pill">—</span></div>
                </div>
                <div class="col-6 col-lg-2">
                  <div class="nt-subtitle">Monto</div>
                  <div id="hMonto" class="fw-semibold">—</div>
                </div>
                <div class="col-6 col-lg-2">
                  <div class="nt-subtitle">Saldo</div>
                  <div id="hSaldo" class="fw-semibold">—</div>
                </div>
                <div class="col-6 col-lg-2">
                  <div class="nt-subtitle">Total abonado</div>
                  <div id="hAbonado" class="fw-semibold">—</div>
                </div>
              </div>
            </div>
          </div>

          <!-- Historial de abonos -->
          <div class="card nt-card">
            <div class="table-responsive">
              <table id="tbApl" class="table table-hover align-middle mb-0">
                <thead class="nt-table-head">
                  <tr>
                    <th style="width:110px;">ID pago</th>
                    <th style="width:150px;">Fecha</th>
                    <th style="width:160px;">Forma</th>
                    <th>Observaciones</th>
                    <th class="text-end" style="width:160px;">Monto aplicado</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td colspan="5" class="text-center text-muted">Cargando…</td></tr>
                </tbody>
              </table>
            </div>
          </div>

        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal: Pagos registrados -->
  <div class="modal fade" id="mdlPagos" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-wallet2 me-2"></i>Pagos registrados</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <!-- Filtros internos del modal -->
          <form id="fPagos" class="row g-3 align-items-end mb-3" onsubmit="return buscarPagos(event)">
            <div class="col-12 col-md-3">
              <label class="form-label">Desde</label>
              <input type="date" class="form-control" name="desde" placeholder="dd/mm/aaaa"/>
            </div>
            <div class="col-12 col-md-3">
              <label class="form-label">Hasta</label>
              <input type="date" class="form-control" name="hasta" placeholder="dd/mm/aaaa"/>
            </div>
            <div class="col-12 col-md-4">
              <label class="form-label">Cliente</label>
              <select id="selClientePagos" class="form-select">
                <option value="">(Todos)</option>
              </select>
            </div>
            <div class="col-12 col-md-2 d-flex gap-2 justify-content-end">
              <button type="submit" class="btn nt-btn-accent"><i class="bi bi-search me-1"></i>Buscar</button>
              <button type="button" class="btn btn-outline-secondary" onclick="limpiarPagos()"><i class="bi bi-x-circle me-1"></i>Limpiar</button>
            </div>
          </form>

          <!-- Tabla de pagos (aplicaciones aplanadas) -->
          <div class="card nt-card">
            <div class="table-responsive">
              <table id="tbAppsFlat" class="table table-hover align-middle mb-0">
                <thead class="nt-table-head">
                  <tr>
                    <th style="width:100px;">ID</th>
                    <th style="width:140px;">Fecha</th>
                    <th style="width:160px;">Documento</th>
                    <th>Cliente</th>
                    <th style="width:160px;">Forma</th>
                    <th class="text-end" style="width:170px;">Total aplicado</th>
                    <th>Observaciones</th>
                  </tr>
                </thead>
                <tbody>
                  <tr><td colspan="7" class="text-center text-muted">Cargando…</td></tr>
                </tbody>
              </table>
            </div>
          </div>

        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Bootstrap -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

<script>
/* ====== Sync API.baseUrl desde <meta> ====== */
(function(){
  try{
    window.API = window.API || {};
    if (!API.baseUrl || !API.baseUrl.trim()) {
      const meta = document.querySelector('meta[name="api-base"]');
      const base = (window.API_BASE || (meta ? meta.getAttribute('content') : '') || '').trim();
      if (base) API.baseUrl = base;
    }
    console.log('[cxc.jsp UNIFICADO] API.baseUrl =', API.baseUrl || '(vacío)');
  }catch(_){}
})();

/* =================== Toasts (reemplazo de alert) =================== */
function ensureToastHost(){
  if (document.getElementById('ntToastHost')) return;
  var host = document.createElement('div');
  host.id = 'ntToastHost';
  host.className = 'position-fixed top-0 end-0 p-3';
  host.style.zIndex = '1080';
  document.body.appendChild(host);
}
function showToast(opts){
  opts = opts || {};
  var title  = opts.title  != null ? String(opts.title)  : 'Listo';
  var message= opts.message!= null ? String(opts.message): 'Operación realizada';
  var variant= (opts.variant || 'success').toLowerCase();
  var delay  = Number(opts.delay || 3500);
  var action = opts.action;

  ensureToastHost();

  var bg;
  switch(variant){
    case 'success': bg = 'bg-success'; break;
    case 'danger':  bg = 'bg-danger';  break;
    case 'warning': bg = 'bg-warning text-dark'; break;
    case 'info':    bg = 'bg-info text-dark';    break;
    default:        bg = 'bg-primary';
  }
  var useDarkText = /\btext-dark\b/.test(bg);
  var textColor   = useDarkText ? '' : 'text-white';
  var subText     = useDarkText ? 'text-muted' : 'text-white-50';

  var el = document.createElement('div');
  el.className = 'toast align-items-center border-0 shadow';
  el.setAttribute('role','alert');
  el.setAttribute('aria-live','assertive');
  el.setAttribute('aria-atomic','true');

  var wrap = document.createElement('div');
  wrap.className = 'd-flex ' + bg + (textColor ? (' ' + textColor) : '') + ' rounded-3';

  var body = document.createElement('div');
  body.className = 'toast-body';

  var h = document.createElement('div');
  h.className = 'fw-semibold';
  h.textContent = title;

  var sub = document.createElement('div');
  sub.className = subText + ' small';
  sub.textContent = message;

  body.appendChild(h);
  body.appendChild(sub);

  if (action && (action.label || action.onClick)){
    var actions = document.createElement('div');
    actions.className = 'mt-2 pt-2 border-top ' + (useDarkText ? 'border-dark-subtle' : 'border-light-subtle');

    var primary = document.createElement('button');
    primary.type = 'button';
    primary.className = useDarkText ? 'btn btn-dark btn-sm me-2' : 'btn btn-light btn-sm me-2';
    primary.textContent = action.label || 'Acción';
    primary.setAttribute('data-action','primary');

    var closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.className = useDarkText ? 'btn btn-outline-dark btn-sm' : 'btn btn-outline-light btn-sm';
    closeBtn.setAttribute('data-bs-dismiss','toast');
    closeBtn.textContent = 'Cerrar';

    actions.appendChild(primary);
    actions.appendChild(closeBtn);
    body.appendChild(actions);
  }

  var x = document.createElement('button');
  x.type = 'button';
  x.className = useDarkText ? 'btn-close me-2 m-auto' : 'btn-close btn-close-white me-2 m-auto';
  x.setAttribute('data-bs-dismiss','toast');
  x.setAttribute('aria-label','Close');

  wrap.appendChild(body);
  wrap.appendChild(x);
  el.appendChild(wrap);
  document.getElementById('ntToastHost').appendChild(el);

  var toast = bootstrap.Toast.getOrCreateInstance(el, { delay: delay, autohide: true });

  if (action && (action.label || action.onClick)){
    var primaryBtn = el.querySelector('[data-action="primary"]');
    if (primaryBtn){
      primaryBtn.addEventListener('click', function(){
        try{ if (typeof action.onClick === 'function') action.onClick(); }catch(_){}
        toast.hide();
      });
    }
  }

  el.addEventListener('hidden.bs.toast', function(){ el.remove(); });
  toast.show();
}

/* =================== Helpers navegación =================== */
function parseAuthUser(){
  try{
    if (window.Auth && window.Auth.user) return window.Auth.user;
    var raw = localStorage.getItem('auth_user');
    return raw ? JSON.parse(raw) : null;
  }catch(_){ return null; }
}
function homeForRole(role){
  var HOME_BY_ROLE = { 'ADMIN': 'Dashboard.jsp', 'OPERADOR': 'dashboard_operador.jsp', 'RRHH':'rrhh-dashboard.jsp' };
  return HOME_BY_ROLE[role && role.toUpperCase ? role.toUpperCase() : role] || 'Dashboard.jsp';
}
function goBack(){
  if (history.length > 1) { history.back(); return; }
  var user = parseAuthUser();
  location.href = homeForRole((user && (user.role || user.rol)) || '');
}

/* =================== Config =================== */
var API_BASE = (window.API && window.API.baseUrl ? window.API.baseUrl : (document.querySelector('meta[name="api-base"]') ? document.querySelector('meta[name="api-base"]').content : '')).replace(/\/+$/,'');
var API_CXC  = API_BASE + '/api/cxc';
var API_CAT  = API_BASE + '/api/catalogos';
var CTX      = '${pageContext.request.contextPath}';

var page = 0, size = 10, last = {};
var _clienteId = null;
var _docPago   = { id:null, numero:null, saldo:0, clienteId:null };
var CLIENTES_MAP = new Map();  // id -> "COD - NOMBRE"

/* =================== Utilidades =================== */
function money(n){
  if(n==null || isNaN(n)) return '';
  try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
  catch(e){ return 'Q ' + Number(n).toFixed(2); }
}
async function fetchJson(url, opts){
  const res = await fetch(url, Object.assign({ credentials:'omit' }, opts||{}));
  let body = null; try{ body = await res.json(); }catch(e){}
  if(!res.ok){
    const msg = (body && (body.detail || body.error || body.message)) || ('HTTP ' + res.status);
    throw new Error(msg);
  }
  return body;
}
function showError(msg){
  const box = document.getElementById('errorBox');
  if(!box) return;
  if(!msg){ box.classList.add('d-none'); box.textContent=''; return; }
  box.textContent = msg; box.classList.remove('d-none');
}

// Badges
function badgeEstado(est){
  est = (est||'').toUpperCase();
  if (est === 'P') return '<span class="badge rounded-pill text-bg-warning">Pendiente</span>';
  if (est === 'C') return '<span class="badge rounded-pill text-bg-success">Cancelado</span>';
  if (est === 'A') return '<span class="badge rounded-pill text-bg-danger">Anulado</span>';
  return '<span class="badge rounded-pill text-bg-secondary">'+ (est||'-') +'</span>';
}
function badgeOrigen(t){
  t = (t||'').toUpperCase();
  if (t === 'V') return '<span class="badge rounded-pill text-bg-primary ms-2">Venta</span>';
  if (t === 'F') return '<span class="badge rounded-pill text-bg-info ms-2">Factura</span>';
  return '';
}
function formaBadge(formaKey){
  const k = (formaKey||'').toUpperCase();
  if (k==='EFE') return '<span class="badge rounded-pill text-bg-success">Efectivo</span>';
  if (k==='TAR') return '<span class="badge rounded-pill text-bg-info">Tarjeta</span>';
  if (k==='TRF') return '<span class="badge rounded-pill text-bg-primary">Transferencia</span>';
  if (k==='CHE') return '<span class="badge rounded-pill text-bg-warning">Cheque</span>';
  return (k || '');
}

// Cliente helpers
function clienteLabel(cli){
  const codigo = cli.codigo || '';
  const nombre = cli.nombre || '';
  return (codigo && nombre) ? (codigo + ' - ' + nombre) : (nombre || ('Cliente ID ' + (cli.id != null ? cli.id : '')));
}
function onlyName(label){
  if (!label) return '';
  const i = label.indexOf(' - ');
  return (i >= 0) ? label.substring(i + 3) : label;
}
function clienteText(x){
  if (x.clienteNombre) return x.clienteNombre;
  if (x._clienteDisplay) return onlyName(x._clienteDisplay);
  const lab = CLIENTES_MAP.get(Number(x.clienteId));
  if (lab) return onlyName(lab);
  return 'ID ' + (x.clienteId != null ? x.clienteId : '');
}
function inferOrigenByNumero(num){
  if (!num) return '';
  const s = String(num).toUpperCase();
  if (s.startsWith('FAC')) return 'F';
  if (s.startsWith('A-') || s.startsWith('B-')) return 'V';
  return '';
}

/* =================== Catálogo: Clientes =================== */
async function cargarClientes(preselectId){
  const sel = document.getElementById('selCliente');
  const sel2 = document.getElementById('selClientePagos');
  try{
    const list = await fetchJson(API_CAT + '/clientes?limit=500');
    const arr = Array.isArray(list) ? list : [];

    [sel, sel2].forEach(function(s){
      if (!s) return;
      s.innerHTML = '<option value="">(Todos)</option>';
    });
    CLIENTES_MAP.clear();
    arr.forEach(function(cli){
      if (cli.id == null) return;
      const label = clienteLabel(cli);
      CLIENTES_MAP.set(Number(cli.id), label);
      if (sel){
        const o1 = document.createElement('option'); o1.value = cli.id; o1.textContent = label; sel.appendChild(o1);
      }
      if (sel2){
        const o2 = document.createElement('option'); o2.value = cli.id; o2.textContent = label; sel2.appendChild(o2);
      }
    });

    if (preselectId && sel)  sel.value  = String(preselectId);
    if (preselectId && sel2) sel2.value = String(preselectId);
  }catch(e){
    console.warn('[CxC] No se pudieron cargar clientes:', e.message);
  }
}

/* =================== Cargar tabla principal =================== */
async function cargar(params){
  params = params || {};
  try{
    const clienteId = (params.clienteId || _clienteId || '').toString().trim();
    const q = new URLSearchParams();
    let url;

    if (clienteId){
      url = API_CXC + '/estado-cuenta?clienteId=' + encodeURIComponent(clienteId);
    } else {
      if (params.estado) q.set('estado', params.estado);
      if (params.desde)  q.set('desde', params.desde);
      if (params.hasta)  q.set('hasta', params.hasta);
      url = API_CXC + '/documentos' + (q.toString()? ('?' + q.toString()) : '');
    }

    const data = await fetchJson(url);
    let rows = Array.isArray(data) ? data : [];

    rows = rows.map(function(r){
      const labelFromMap = CLIENTES_MAP.get(Number(r.clienteId));
      if (labelFromMap) r._clienteDisplay = labelFromMap;
      return r;
    });

    if (clienteId){
      if (params.estado){ rows = rows.filter(function(x){ return (x.estado||'') === params.estado; }); }
      if (params.desde){ rows = rows.filter(function(x){ return !x.fechaEmision || x.fechaEmision >= params.desde; }); }
      if (params.hasta){ rows = rows.filter(function(x){ return !x.fechaEmision || x.fechaEmision <= params.hasta; }); }

      const sel = document.getElementById('selCliente');
      const cliText = (sel && sel.value) ? sel.options[sel.selectedIndex].text : '';
      rows = rows.map(function(r){
        r.clienteId = Number(clienteId);
        if (cliText) r._clienteDisplay = cliText;
        return r;
      });
    }

    const start = page*size, end = start+size;
    render(rows.slice(start, end));
    const pel = document.getElementById('pActual'); if (pel) pel.textContent = (page+1);
    showError(null);
  }catch(err){
    console.error('CxC cargar error ->', err);
    showError('Error al cargar: ' + err.message);
    render([]);
  }
}

function render(rows){
  const tb    = document.querySelector('#tabla tbody');
  const empty = document.getElementById('tablaEmpty');
  if (tb) tb.innerHTML = '';

  if(!rows.length){
    if (empty) empty.classList.remove('d-none');
    return;
  }
  if (empty) empty.classList.add('d-none');

  rows.forEach(function(x){
    const id       = (x.documentoId != null ? x.documentoId : (x.id != null ? x.id : ''));
    const num      = (x.numeroDocumento != null ? x.numeroDocumento : (x.numero != null ? x.numero : ''));
    const femi     = (x.fechaEmision != null ? x.fechaEmision : '');
    const fven     = (x.fechaVencimiento != null ? x.fechaVencimiento : '');
    const monto    = (x.montoTotal != null ? x.montoTotal : (x.monto != null ? x.monto : null));
    const saldo    = (x.saldoPendiente != null ? x.saldoPendiente : (x.saldo != null ? x.saldo : null));
    const est      = (x.estado != null ? x.estado : 'P');
    const cliId    = (x.clienteId != null ? x.clienteId : null);

    const cliTxt   = clienteText(x);
    const ventaId  = (x.origenId != null ? x.origenId : '');
    const oTipo    = (x.origenTipo || inferOrigenByNumero(num));

    const canPay = (est === 'P' && Number(saldo) > 0);
    const numSafe = String(num).replace(/'/g, "\\'");

    const tr = document.createElement('tr');
    tr.innerHTML =
      '<td>' + (num || '') + ' ' + badgeOrigen(oTipo) + '</td>' +
      '<td>' + cliTxt + '</td>' +
      '<td>' + (femi || '') + '</td>' +
      '<td>' + (fven || '') + '</td>' +
      '<td>' + (ventaId || '') + '</td>' +
      '<td class="text-end">' + money(monto) + '</td>' +
      '<td class="text-end">' + money(saldo) + '</td>' +
      '<td>' + badgeEstado(est) + '</td>' +
      '<td class="text-end">' +
        '<div class="btn-group btn-group-sm">' +
          '<button class="btn btn-outline-secondary" onclick="navigateToDetalle(' + id + ')">Ver</button>' +
          '<button class="btn btn-outline-primary ms-1" ' + (canPay ? '' : 'disabled ') +
            'onclick="abrirPago(' + id + ', \'' + numSafe + '\', ' + (Number(saldo)||0) + ', ' + (cliId != null ? cliId : 'null') + ')">' +
            'Registrar pago' +
          '</button>' +
        '</div>' +
      '</td>';
    if (tb) tb.appendChild(tr);
  });
}

/* =================== Filtros / Paginación =================== */
function buscar(e){
  e.preventDefault();
  const f = e.target;
  page = 0;
  const sel = document.getElementById('selCliente');
  last = {
    desde: f.desde.value || '',
    hasta: f.hasta.value || '',
    clienteId: (sel && sel.value ? sel.value : ''),
    estado: f.estado.value || ''
  };
  _clienteId = last.clienteId || null;
  cargar(last);
}
function limpiar(){
  const form = document.getElementById('filtros');
  if (form) form.reset();
  const sel = document.getElementById('selCliente'); if (sel) sel.value = '';
  last = {}; page = 0; _clienteId = null;
  cargar({});
}
function cambiarPagina(delta){
  page = Math.max(0, page + delta);
  cargar(last);
}

/* =================== Detalle (modal) =================== */
function badgeForma(key){
  const k = (key||'').toUpperCase();
  if (k === 'EFE') return '<span class="badge rounded-pill text-bg-success">Efectivo</span>';
  if (k === 'TAR') return '<span class="badge rounded-pill text-bg-info">Tarjeta</span>';
  if (k === 'TRF') return '<span class="badge rounded-pill text-bg-primary">Transferencia</span>';
  if (k === 'CHE') return '<span class="badge rounded-pill text-bg-warning">Cheque</span>';
  return '<span class="badge rounded-pill text-bg-secondary">'+(key||'-')+'</span>';
}
async function verDetalle(documentoId){
  if(!documentoId) return;
  const md = new bootstrap.Modal(document.getElementById('mdlDetalle'));
  md.show();

  document.querySelector('#tbApl tbody').innerHTML = '<tr><td colspan="5" class="text-center text-muted">Cargando…</td></tr>';
  document.getElementById('hNumero').textContent = '—';
  document.getElementById('hEstado').innerHTML   = '<span class="badge text-bg-secondary rounded-pill">—</span>';
  document.getElementById('hMonto').textContent  = '—';
  document.getElementById('hSaldo').textContent  = '—';
  document.getElementById('hAbonado').textContent= '—';

  try{
    const urlDoc = API_CXC + '/documentos/' + encodeURIComponent(documentoId);
    const urlApl = API_CXC + '/documentos/' + encodeURIComponent(documentoId) + '/aplicaciones';
    const arr = await Promise.all([ fetchJson(urlDoc), fetchJson(urlApl) ]);
    const doc = arr[0], apl = arr[1];

    const docSafe = doc || {};
    const aplArr  = Array.isArray(apl) ? apl : [];

    document.getElementById('hNumero').textContent = (docSafe.numeroDocumento || ('ID ' + (docSafe.documentoId||'')));
    document.getElementById('hEstado').innerHTML   = badgeEstado(docSafe.estado);
    document.getElementById('hMonto').textContent  = money(docSafe.montoTotal);
    document.getElementById('hSaldo').textContent  = money(docSafe.saldoPendiente);

    const abonado = aplArr.reduce(function(s,a){ return s + Number(a.montoAplicado||0); }, 0);
    document.getElementById('hAbonado').textContent = money(abonado);

    const tb = document.querySelector('#tbApl tbody');
    tb.innerHTML = '';
    if(!aplArr.length){
      tb.innerHTML = '<tr><td colspan="5" class="text-center text-muted">Sin abonos</td></tr>';
    }else{
      aplArr.forEach(function(a){
        const fecha = a.fechaPago || a.fechaAplicacion || '';
        const tr = document.createElement('tr');
        tr.innerHTML =
            '<td>' + (a.pagoId || '') + '</td>'
          + '<td>' + (fecha || '') + '</td>'
          + '<td>' + badgeForma(a.formaPago) + '</td>'
          + '<td>' + (a.observaciones || '') + '</td>'
          + '<td class="text-end">' + money(a.montoAplicado) + '</td>';
        tb.appendChild(tr);
      });
    }
  }catch(err){
    showToast({ title:'Error cargando detalle', message: err.message, variant:'danger' });
  }
}
// Ahora solo abre el modal (no toca la URL)
function navigateToDetalle(id){
  verDetalle(id);
}

/* =================== Pagos (modal) + Paginación =================== */
var __pagosFlatAll = [];
var pagePagos = 0, sizePagos = 9;

function ensurePagosPagerUI(){
  const modalBody = document.querySelector('#mdlPagos .modal-body');
  const tableWrap = document.querySelector('#mdlPagos .modal-body .card');
  if (!modalBody || !tableWrap) return;

  if (!document.getElementById('pagosPager')){
    const bar = document.createElement('div');
    bar.id = 'pagosPager';
    bar.className = 'd-flex justify-content-between align-items-center mb-2';

    var left = document.createElement('div');
    left.className = 'd-flex align-items-center gap-2';

    var btnPrev = document.createElement('button');
    btnPrev.id = 'pagosPrev';
    btnPrev.className = 'btn btn-outline-secondary btn-sm';
    btnPrev.innerHTML = '&laquo; Anterior';

    var pageInfo = document.createElement('div');
    pageInfo.innerHTML = ' Página <span id="pagosActual">1</span> ';

    var btnNext = document.createElement('button');
    btnNext.id = 'pagosNext';
    btnNext.className = 'btn btn-outline-secondary btn-sm';
    btnNext.innerHTML = 'Siguiente &raquo;';

    left.appendChild(btnPrev);
    left.appendChild(pageInfo);
    left.appendChild(btnNext);

    var right = document.createElement('small');
    right.className = 'text-muted';
    right.textContent = 'Mostrando ' + sizePagos + ' por página';

    bar.appendChild(left);
    bar.appendChild(right);

    modalBody.insertBefore(bar, tableWrap);
    document.getElementById('pagosPrev').addEventListener('click', function(){ cambiarPaginaPagos(-1); });
    document.getElementById('pagosNext').addEventListener('click', function(){ cambiarPaginaPagos(1); });
  }
}

function renderPagosFlatPage(){
  const start = pagePagos * sizePagos;
  const slice = __pagosFlatAll.slice(start, start + sizePagos);
  const tb = document.querySelector('#tbAppsFlat tbody');
  tb.innerHTML = '';
  if(!slice.length){
    const tr0 = document.createElement('tr');
    tr0.innerHTML = '<td colspan="7" class="text-center text-muted">Sin aplicaciones</td>';
    tb.appendChild(tr0);
  }else{
    slice.forEach(function(r){
      const tr = document.createElement('tr');
      tr.innerHTML =
        '<td>' + (r.pagoId != null ? r.pagoId : '') + '</td>' +
        '<td>' + (r.fechaAplicacion != null ? r.fechaAplicacion : '') + '</td>' +
        '<td>' + (r.documento != null ? r.documento : '') + '</td>' +
        '<td>' + (r.clienteNombre != null ? r.clienteNombre : '') + '</td>' +
        '<td>' + formaBadge(r.formaKey) + '</td>' +
        '<td class="text-end">' + money(r.montoAplicado) + '</td>' +
        '<td>' + (r.observaciones != null ? r.observaciones : '') + '</td>';
      tb.appendChild(tr);
    });
  }
  const pa = document.getElementById('pagosActual'); if (pa) pa.textContent = (pagePagos+1);
}
function cambiarPaginaPagos(delta){
  const max = Math.max(0, Math.ceil(__pagosFlatAll.length / sizePagos) - 1);
  pagePagos = Math.max(0, Math.min(max, pagePagos + delta));
  renderPagosFlatPage();
}

async function cargarPagosFlat(params){
  params = params || {};
  const q = new URLSearchParams();
  if (params.clienteId) q.set('clienteId', params.clienteId);
  if (params.desde)     q.set('desde', params.desde);
  if (params.hasta)     q.set('hasta', params.hasta);

  const urlPagos = API_CXC + '/pagos' + (q.toString()? ('?' + q.toString()) : '');
  try{
    const pagos = await fetchJson(urlPagos);
    const pagosArr = Array.isArray(pagos) ? pagos : [];

    const combos = await Promise.all(
      pagosArr.map(function(p){
        return fetchJson(API_CXC + '/pagos/' + encodeURIComponent(p.pagoId) + '/aplicaciones')
          .then(function(apps){ return { pago: p, apps: (Array.isArray(apps)? apps : []) }; })
          .catch(function(){ return { pago: p, apps: [] }; });
      })
    );

    const flat = [];
    combos.forEach(function(o){
      var pago=o.pago, apps=o.apps;
      if (!apps.length) return;

      const clienteNombreSolo =
        (pago.clienteNombre && pago.clienteNombre.trim())
          ? pago.clienteNombre
          : ('ID ' + (pago.clienteId != null ? pago.clienteId : ''));

      const formaKey = (pago.formaPago || '').toUpperCase();

      apps.forEach(function(a){
        flat.push({
          pagoId:          pago.pagoId,
          fechaAplicacion: a.fechaAplicacion || a.fechaPago || pago.fechaPago || '',
          documento:       a.numeroDocumento || ('ID ' + (a.documentoId != null ? a.documentoId : '')),
          clienteNombre:   clienteNombreSolo,
          formaKey:        formaKey,
          montoAplicado:   a.montoAplicado,
          observaciones:   pago.observaciones || a.observaciones || ''
        });
      });
    });

    __pagosFlatAll = flat;
    pagePagos = 0;
    ensurePagosPagerUI();
    renderPagosFlatPage();
  }catch(err){
    showToast({ title:'Error cargando pagos', message: err.message, variant:'danger' });
    __pagosFlatAll = [];
    pagePagos = 0;
    ensurePagosPagerUI();
    renderPagosFlatPage();
  }
}
function buscarPagos(e){
  e.preventDefault();
  const f = e.target;
  const p = {
    desde: f.desde.value || '',
    hasta: f.hasta.value || '',
    clienteId: (document.getElementById('selClientePagos').value || '')
  };
  cargarPagosFlat(p);
  return false;
}
function limpiarPagos(){
  const f = document.getElementById('fPagos');
  f.reset();
  const sel = document.getElementById('selClientePagos'); if (sel) sel.value = '';
  cargarPagosFlat({});
}

/* =================== Pagos (validaciones FE) =================== */
function setBtnCobrarState(enabled){
  const btn = document.getElementById('btnCobrarGo');
  if (btn) btn.disabled = !enabled;
}
function validarMonto(){
  const inp = document.getElementById('pMonto');
  const help = document.getElementById('pMontoHelp');
  if (!inp) return { ok:false, value:0, max:0 };

  const raw = (inp.value || '').toString().replace(',', '.');
  let val = parseFloat(raw);
  if (isNaN(val)) val = 0;

  const max = Number(inp.max || _docPago.saldo || 0);
  const min = 0.01;

  const ok = (val >= min && val <= max);
  inp.classList.toggle('is-invalid', !ok);
  if (!ok) {
    let msg = '';
    if (val <= 0) msg = 'El monto debe ser mayor a 0.';
    else if (val > max) msg = 'El monto no puede exceder el saldo (' + money(max) + ').';
    else msg = 'Monto inválido.';
    if (help) help.textContent = msg;
  } else {
    if (help) help.textContent = 'No puede exceder el saldo.';
  }
  setBtnCobrarState(ok);
  return { ok: ok, value: ok ? Number(val.toFixed(2)) : 0, max: max };
}
function fijarFechaHoyBloqueada(){
  const f = document.getElementById('pFecha');
  if (!f) return;
  const tzNow = new Date();
  const yyyy = tzNow.getFullYear();
  const mm = String(tzNow.getMonth()+1).padStart(2,'0');
  const dd = String(tzNow.getDate()).padStart(2,'0');
  f.value = yyyy + '-' + mm + '-' + dd;
  f.readOnly = true;
  f.addEventListener('keydown', function(e){ e.preventDefault(); });
  f.addEventListener('mousedown', function(e){ e.preventDefault(); });
}

// Extras por forma
function maskCardNumber(value){ return value.replace(/\D/g,'').slice(0,16).replace(/(.{4})/g,'$1 ').trim(); }
function onCardNumberInput(e){ e.target.value = maskCardNumber(e.target.value); }
function toggleExtras(){
  const forma = (document.getElementById('pForma') && document.getElementById('pForma').value ? document.getElementById('pForma').value : '').toUpperCase();
  const tar = document.getElementById('extraTarjeta');
  const trf = document.getElementById('extraTransfer');
  if (tar && trf){
    tar.classList.toggle('d-none', forma !== 'TAR');
    trf.classList.toggle('d-none', forma !== 'TRF');
  }
}
function setTodayIfEmpty(inp){
  if (!inp) return;
  if (!inp.value){
    var d = new Date();
    var y = d.getFullYear();
    var m = String(d.getMonth()+1).padStart(2,'0');
    var dd = String(d.getDate()).padStart(2,'0');
    inp.value = y + '-' + m + '-' + dd;
  }
}
function validateCardBlock(){
  const num = (document.getElementById('cardNum') && document.getElementById('cardNum').value ? document.getElementById('cardNum').value : '').trim();
  const exp = (document.getElementById('cardExp') && document.getElementById('cardExp').value ? document.getElementById('cardExp').value : '').trim();
  const cvv = (document.getElementById('cardCvv') && document.getElementById('cardCvv').value ? document.getElementById('cardCvv').value : '').trim();
  if (!/^[0-9]{4} [0-9]{4} [0-9]{4} [0-9]{4}$/.test(num)) return {ok:false,msg:'Número de tarjeta inválido.'};
  if (!/^(0[1-9]|1[0-2])\/[0-9]{2}$/.test(exp))   return {ok:false,msg:'Vencimiento inválido (MM/AA).'};
  if (!/^[0-9]{3,4}$/.test(cvv))                 return {ok:false,msg:'CVV inválido.'};
  return {ok:true};
}
function cardLast4(){
  const raw = (document.getElementById('cardNum') && document.getElementById('cardNum').value ? document.getElementById('cardNum').value : '').replace(/\D/g,'');
  return raw.slice(-4);
}
function buildExtraObservaciones(forma){
  if (forma === 'TAR'){
    const last4 = cardLast4();
    const exp   = (document.getElementById('cardExp') && document.getElementById('cardExp').value ? document.getElementById('cardExp').value : '').trim();
    const name  = (document.getElementById('cardName') && document.getElementById('cardName').value ? document.getElementById('cardName').value : '').trim();
    const namePart = name ? ', titular: ' + name : '';
    return ' [Tarjeta **** **** **** ' + last4 + ', vence ' + exp + namePart + ']';
  }
  if (forma === 'TRF'){
    const bank = (document.getElementById('trfBank') && document.getElementById('trfBank').value ? document.getElementById('trfBank').value : '').trim();
    const ref  = (document.getElementById('trfRef') && document.getElementById('trfRef').value ? document.getElementById('trfRef').value : '').trim();
    const fdep = (document.getElementById('trfDate') && document.getElementById('trfDate').value ? document.getElementById('trfDate').value : '').trim();
    return ' [Transferencia banco: ' + (bank || '-') + ', ref: ' + (ref || '-') + (fdep ? ', fecha: ' + fdep : '') + ']';
  }
  return '';
}

function abrirPago(docId, docNum, saldo, cliId){
  _docPago = { id: docId, numero: docNum, saldo: Number(saldo)||0, clienteId: (cliId != null ? cliId : null) };
  const clienteEfectivo = (_docPago.clienteId != null ? _docPago.clienteId : (_clienteId != null ? Number(_clienteId) : null));
  _clienteId = clienteEfectivo;

  const pCli = document.getElementById('pCliente');
  if (pCli){
    const etiqueta = CLIENTES_MAP.get(Number(clienteEfectivo)) || (clienteEfectivo ? ('Cliente ID ' + clienteEfectivo) : '(Cliente no especificado)');
    pCli.value = etiqueta;
  }

  const doc = document.getElementById('pDocNum');
  if (doc) doc.value = (docNum || '') + ' (ID ' + docId + ')';

  const monto = document.getElementById('pMonto');
  if (monto){
    monto.min  = '0.01';
    monto.step = '0.01';
    monto.max  = (_docPago.saldo || 0).toFixed(2);
    monto.value = (_docPago.saldo || 0).toFixed(2);
    monto.removeEventListener('input', validarMonto);
    monto.addEventListener('input', validarMonto);
    validarMonto();
  }

  fijarFechaHoyBloqueada();

  const forma = document.getElementById('pForma'); if (forma) forma.value = 'EFE';
  const obs   = document.getElementById('pObs');   if (obs)   obs.value = '';

  ['cardNum','cardExp','cardCvv','cardName','trfBank','trfRef'].forEach(function(id){
    const el = document.getElementById(id); if (el) el.value = '';
  });
  setTodayIfEmpty(document.getElementById('trfDate'));
  toggleExtras();

  new bootstrap.Modal(document.getElementById('mdlCobro')).show();
}

/* =================== Boot (sin hash router) =================== */
function qs(name){ const p = new URLSearchParams(window.location.search); return p.get(name); }

document.addEventListener('DOMContentLoaded', async function(){
  const cid = qs('clienteId'); if (cid) _clienteId = cid;

  await cargarClientes(_clienteId);
  await cargar({ clienteId: _clienteId || '' });

  // Al abrir "Pagos", precargar tabla con el cliente seleccionado (si aplica)
  var mdlPagos = document.getElementById('mdlPagos');
  if (mdlPagos){
    mdlPagos.addEventListener('shown.bs.modal', function(){
      const pre = (document.getElementById('selCliente') && document.getElementById('selCliente').value) ? document.getElementById('selCliente').value : '';
      if (pre && document.getElementById('selClientePagos')) document.getElementById('selClientePagos').value = pre;
      ensurePagosPagerUI();
      cargarPagosFlat({ clienteId: pre });
    });
  }

  const sForma = document.getElementById('pForma');
  if (sForma){
    sForma.addEventListener('change', toggleExtras);
    toggleExtras();
  }
  const iCard = document.getElementById('cardNum');
  if (iCard) iCard.addEventListener('input', onCardNumberInput);
  setTodayIfEmpty(document.getElementById('trfDate'));

  const btnCobrar = document.getElementById('btnCobrarGo');
  if (btnCobrar){
    btnCobrar.addEventListener('click', async function(){
      try{
        if (!_clienteId) { showToast({ title:'Atención', message:'Selecciona un cliente antes de registrar pagos.', variant:'warning' }); return; }
        const v = validarMonto();
        if (!v || !v.ok) return;

        const fecha = document.getElementById('pFecha').value;
        const forma = document.getElementById('pForma').value;
        const obs   = document.getElementById('pObs').value;

        if (forma === 'TAR'){
          const vCard = validateCardBlock();
          if (!vCard.ok){ showToast({ title:'Tarjeta', message:vCard.msg, variant:'warning' }); return; }
        }
        if (forma === 'TRF'){
          const bank = (document.getElementById('trfBank') && document.getElementById('trfBank').value ? document.getElementById('trfBank').value : '').trim();
          const ref  = (document.getElementById('trfRef')  && document.getElementById('trfRef').value  ? document.getElementById('trfRef').value  : '').trim();
          if (!bank && !ref){ showToast({ title:'Transferencia', message:'Para transferencia indique banco o referencia.', variant:'warning' }); return; }
        }

        const obsExtra = buildExtraObservaciones(forma);
        const obsFinal = (obs || '') + obsExtra;

        // Crear pago
        const urlCrear = API_CXC + '/pagos/crear'
          + '?clienteId=' + encodeURIComponent(_clienteId)
          + '&monto=' + encodeURIComponent(v.value.toFixed(2))
          + '&formaPago=' + encodeURIComponent(forma)
          + '&fechaPago=' + encodeURIComponent(fecha)
          + '&observaciones=' + encodeURIComponent(obsFinal);
        const crearRes = await fetchJson(urlCrear, { method:'POST' });

        // Aplicar pago al documento
        const urlAplicar = API_CXC + '/pagos/' + crearRes.pagoId + '/aplicar';
        const body = JSON.stringify([{ documentoId: _docPago.id, monto: v.value }]);
        await fetchJson(urlAplicar, { method:'POST', headers:{'Content-Type':'application/json'}, body: body });

        bootstrap.Modal.getInstance(document.getElementById('mdlCobro')).hide();

        // Toast de éxito con acción "Ver detalle" (abre modal, no cambia URL)
        showToast({
          title: 'Pago aplicado',
          message: 'ID ' + crearRes.pagoId + ' por ' + money(v.value) + '.',
          variant: 'success',
          action: {
            label: 'Ver detalle',
            onClick: function(){ verDetalle(_docPago.id); }
          }
        });

        cargar(last);
      }catch(err){
        showToast({ title:'Error al registrar', message: err.message, variant:'danger' });
      }
    });
  }
});
</script>

</body>
</html>
