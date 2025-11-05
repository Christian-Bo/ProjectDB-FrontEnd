<%-- 
  Document   : ventas_pagos
  Purpose    : Listar, crear, editar y eliminar pagos de ventas (CRÉDITO)
  Created on : 04/11/2025
  Author     : NextTech (Assistant)
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Pagos de Ventas | NextTech</title>
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

    /* Barra de detalles al estilo ventas.jsp (dentro de modales) */
    .saldo-summary .badge{ font-size: .95rem; }  /* liviano, sin negrita gruesa */
    .saldo-row { 
      background: var(--nt-surface-2);
      border: 1px solid var(--nt-border);
      border-radius: .75rem;
      padding: .75rem .75rem;
    }
  </style>

  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="javascript:void(0)">
        <i class="bi bi-wallet2"></i> Pagos de Ventas
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
        <h2 class="m-0 nt-title">Pagos</h2>
        <div class="nt-subtitle">Consulta, creación, edición y anulación de pagos registrados</div>
      </div>
        <button class="btn btn-sm nt-btn-accent" type="button" onclick="VPAGOS.abrirNuevo()">
          <i class="bi bi-plus-lg me-1"></i> Nuevo pago
        </button>
    </div>

    <!-- Filtros -->
    <div class="card nt-card mb-3">
      <div class="card-body">
        <form id="filtros" class="row g-3 align-items-end" onsubmit="VPAGOS.buscar(event)">
          <div class="col-md-3">
            <label class="form-label">Cliente</label>
            <select id="selCliente" class="form-select">
              <option value="">(Todos)</option>
            </select>
          </div>
          <div class="col-md-2">
            <label class="form-label">Venta ID</label>
            <input id="ventaId" type="number" min="1" class="form-control" placeholder="Ej. 1024">
          </div>
          <div class="col-md-2">
            <label class="form-label">Desde</label>
            <input id="desde" type="date" class="form-control">
          </div>
          <div class="col-md-2">
            <label class="form-label">Hasta</label>
            <input id="hasta" type="date" class="form-control">
          </div>
          <div class="col-md-3 d-flex gap-2 justify-content-end">
            <button class="btn nt-btn-accent" type="submit"><i class="bi bi-search me-1"></i>Buscar</button>
            <button class="btn btn-outline-secondary" type="button" onclick="VPAGOS.limpiar()"><i class="bi bi-x-circle me-1"></i>Limpiar</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Paginación -->
    <div class="d-flex justify-content-between align-items-center mb-2">
      <div class="d-flex align-items-center gap-2 pager">
        <button class="btn btn-outline-secondary btn-sm" onclick="VPAGOS.cambiarPagina(-1)">&laquo; Anterior</button>
        <div>Página <span id="pActual">1</span></div>
        <button class="btn btn-outline-secondary btn-sm" onclick="VPAGOS.cambiarPagina(1)">Siguiente &raquo;</button>
      </div>
      <div class="d-flex align-items-center gap-2">
        <label class="text-muted me-1">Por página</label>
        <select id="selSize" class="form-select form-select-sm" style="width:auto" onchange="VPAGOS.cambiarTamano()">
          <option value="10" selected>10</option>
          <option value="20">20</option>
          <option value="50">50</option>
        </select>
      </div>
    </div>

    <!-- Tabla -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table class="table table-hover nt-table align-middle mb-0">
          <thead class="nt-table-head">
            <tr>
              <th>ID Pago</th>
              <th>Venta</th>
              <th>Fecha Venta</th>
              <th>Cliente</th>
              <th>Forma</th>
              <th class="text-end">Monto</th>
              <th>Referencia</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody id="tablaBody">
            <tr id="tablaEmpty"><td colspan="8" class="text-center text-muted">Usa los filtros para consultar.</td></tr>
          </tbody>
        </table>
      </div>
    </div>
  </main>

  <!-- ===== Modales ===== -->

  <!-- Nuevo pago -->
  <div class="modal fade nt-modal" id="modalNuevo" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-plus-circle me-1"></i> Nuevo pago</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Venta ID</label>
              <input id="new_venta" type="number" min="1" class="form-control" placeholder="Ej. 1024" onblur="VPAGOS._hintNuevo()">
            </div>
            <div class="col-md-4">
              <label class="form-label">Forma de pago</label>
              <select id="new_forma" class="form-select">
                <option value="EFE">Efectivo (EFE)</option>
                <option value="TAR">Tarjeta (TAR)</option>
                <option value="TRF">Transferencia (TRF)</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Monto</label>
              <input id="new_monto" type="number" min="0.01" step="0.01" class="form-control" oninput="VPAGOS._calcNuevoSaldo()">
              <div id="new_monto_err" class="invalid-feedback">Monto inválido.</div>
            </div>

            <div class="col-12">
              <label class="form-label">Referencia</label>
              <input id="new_ref" type="text" maxlength="200" class="form-control" placeholder="Caja/POS/Banco/Nota">
            </div>

            <!-- Barra de detalles estilo ventas.jsp -->
            <div class="col-12">
              <div class="saldo-row saldo-summary d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div class="d-flex flex-column">
                  <div class="small text-muted">Origen</div>
                  <div id="newSaldoOrigen" class="fw-semibold">—</div>
                </div>
                <div class="d-flex flex-column">
                  <div class="small text-muted">Total</div>
                  <div id="newSaldoTotal" class="badge bg-primary-subtle text-primary-emphasis fs-6">—</div>
                </div>
                <div class="d-flex flex-column">
                  <div class="small text-muted">Pagado</div>
                  <div id="newSaldoPagado" class="badge bg-success-subtle text-success-emphasis fs-6">—</div>
                </div>
                <div class="d-flex flex-column">
                  <div class="small text-muted">Saldo</div>
                  <div id="newSaldoRestante" class="badge bg-warning-subtle text-warning-emphasis fs-6">—</div>
                </div>
                <div class="d-flex flex-column ms-md-auto">
                  <div class="small text-muted">Saldo tras guardar</div>
                  <div id="newSaldoRes" class="badge bg-info-subtle text-info-emphasis fs-6">—</div>
                </div>
              </div>
              <div id="new_alert" class="alert alert-danger d-none mt-2"></div>
              <small class="text-muted">Solo ventas a crédito aceptan pagos. El sistema valida sobrepagos.</small>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn nt-btn-accent" onclick="VPAGOS.confirmarNuevo()">Crear pago</button>
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Editar pago -->
  <div class="modal fade nt-modal" id="modalEditar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-pencil-square me-1"></i> Editar pago <span id="editPagoId" class="text-muted"></span></h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="edit_id">
          <input type="hidden" id="edit_monto_original" value="0">
          <input type="hidden" id="edit_venta_id" value="0">
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label">Forma de pago</label>
              <select id="edit_forma" class="form-select">
                <option value="EFE">Efectivo (EFE)</option>
                <option value="TAR">Tarjeta (TAR)</option>
                <option value="TRF">Transferencia (TRF)</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">Monto</label>
              <input id="edit_monto" type="number" min="0.01" step="0.01" class="form-control" required oninput="VPAGOS._calcEditSaldo()">
              <div id="edit_monto_err" class="invalid-feedback">Monto inválido.</div>
            </div>
            <div class="col-12">
              <label class="form-label">Referencia</label>
              <input id="edit_ref" type="text" maxlength="200" class="form-control" placeholder="Caja/POS/Banco/Nota">
            </div>

            <!-- Barra de detalles estilo ventas.jsp -->
            <div class="col-12">
              <div class="saldo-row saldo-summary d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div class="d-flex flex-column">
                  <div class="small text-muted">Origen</div>
                  <div id="editSaldoOrigen" class="fw-semibold">—</div>
                </div>
                <div class="d-flex flex-column">
                  <div class="small text-muted">Total</div>
                  <div id="editSaldoTotal" class="badge bg-primary-subtle text-primary-emphasis fs-6">—</div>
                </div>
                <div class="d-flex flex-column">
                  <div class="small text-muted">Pagado</div>
                  <div id="editSaldoPagado" class="badge bg-success-subtle text-success-emphasis fs-6">—</div>
                </div>
                <div class="d-flex flex-column">
                  <div class="small text-muted">Saldo</div>
                  <div id="editSaldoRestante" class="badge bg-warning-subtle text-warning-emphasis fs-6">—</div>
                </div>
                <div class="d-flex flex-column ms-md-auto">
                  <div class="small text-muted">Saldo tras guardar</div>
                  <div id="editSaldoRes" class="badge bg-info-subtle text-info-emphasis fs-6">—</div>
                </div>
              </div>
              <div id="edit_alert" class="alert alert-danger d-none mt-2"></div>
              <small class="text-muted">El saldo resultante considera el cambio de monto.</small>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn nt-btn-accent" onclick="VPAGOS.confirmarEditar()">Guardar</button>
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Eliminar pago -->
  <div class="modal fade nt-modal" id="modalEliminar" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Anular pago</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="del_id">
          <p>¿Confirmas anular el pago <b id="del_id_txt">#</b> de <span id="del_monto_txt">Q 0.00</span>?</p>
          <p class="text-muted mb-0">Esta acción es irreversible.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-danger" onclick="VPAGOS.confirmarEliminar()">Sí, anular</button>
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
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
  try{
    if (history.length > 1) { history.back(); return; }
  }catch(_){}
  const ctxRaw='${pageContext.request.contextPath}', ctx=(ctxRaw||'').trim();
  window.location.href = (ctx && ctx!=='/' ? ctx : '') + '/Dashboard.jsp';
}

/* ========= BASE API / CONTEXTO ========= */
(function(){
  window.API = window.API || {};
  if (!API.baseUrl) {
    var meta = document.querySelector('meta[name="api-base"]');
    var base = (window.API_BASE || (meta && meta.getAttribute('content')) || '').trim();
    if (base) API.baseUrl = base;
  }
})();
function joinUrl(base, path){ return String(base||'').replace(/\/+$/,'') + '/' + String(path||'').replace(/^\/+/,''); }
(function(){
  var meta = document.querySelector('meta[name="api-base"]');
  var base = (window.API_BASE || (meta && meta.getAttribute('content')) || (location.origin)).trim();
  window.API_ROOT = base.replace(/\/+$/,'');
})();
var API_VENTAS    = joinUrl(window.API_ROOT, '/api/ventas');
var API_CATALOGOS = joinUrl(window.API_ROOT, '/api/catalogos');
var USER_ID       = 1;
var commonHeaders = { 'X-User-Id': String(USER_ID) };

/* ========= TOAST ========= */
var AppToast=(function(){function ensure(){var t=document.getElementById('appToast');if(!t){var w=document.createElement('div');w.className='position-fixed top-0 end-0 p-3';w.style.zIndex='1080';w.innerHTML='<div id="appToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true"><div class="d-flex align-items-center"><div class="toast-body" id="toastMsg">Listo.</div><button id="toastAction" type="button" class="btn btn-light btn-sm me-2 d-none"></button><button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button></div></div>';document.body.appendChild(w);t=document.getElementById('appToast');}if(!document.getElementById('toastMsg')){var b=t.querySelector('.d-flex')||t;var m=document.createElement('div');m.id='toastMsg';m.className='toast-body';m.textContent='Listo.';b.insertBefore(m,b.firstChild);}if(!document.getElementById('toastAction')){var b2=t.querySelector('.d-flex')||t;var btn=document.createElement('button');btn.id='toastAction';btn.type='button';btn.className='btn btn-light btn-sm me-2 d-none';var closeBtn=t.querySelector('.btn-close');b2.insertBefore(btn,closeBtn||null);}return t;}function show(o){var t=ensure(),m=document.getElementById('toastMsg'),a=document.getElementById('toastAction');t.className='toast position-fixed top-0 end-0 m-3 align-items-center border-0 '+(o&&o.type==='error'?'text-bg-danger':o&&o.type==='warn'?'text-bg-warning':'text-bg-primary');m.textContent=(o&&o.message)||'OK';a.classList.add('d-none');a.onclick=null;if(o&&o.actionText&&typeof o.onAction==='function'){a.textContent=o.actionText;a.classList.remove('d-none');a.onclick=function(e){e.preventDefault();try{o.onAction();}catch(_){ }bootstrap.Toast.getOrCreateInstance(t).hide();};}var delay=(o&&typeof o.delay==='number')?o.delay:(o&&o.actionText?10000:3500);bootstrap.Toast.getOrCreateInstance(t,{delay:delay,autohide:true}).show()}return{ok:function(m){show({message:m});},err:function(m){show({message:typeof m==='string'?m:(m&&JSON.stringify(m))||'Error',type:'error'});},warn:function(m){show({message:m,type:'warn'});},show:show};})();

/* ========= UTILS ========= */
function withNoCache(url){try{var u=new URL(url,location.origin);u.searchParams.set('_',String(Date.now()));return u.toString();}catch(_){return url+(url.indexOf('?')>=0?'&':'?')+'_='+Date.now();}}
async function tryFetchJson(url,opts){try{var o=opts||{},m=(o.method||'GET').toUpperCase(),finalUrl=(m==='GET')?withNoCache(url):url;var res=await fetch(finalUrl,Object.assign({cache:'no-store'},o));var t=await res.text();var data=null;try{data=t?JSON.parse(t):null;}catch(_){ }if(!res.ok)return{ok:false,status:res.status,data:data};return{ok:true,status:res.status,data:data};}catch(e){return{ok:false,status:0,data:{error:e&&e.message?e.message:'network'}};}}
async function fetchJson(url,opts){var r=await tryFetchJson(url,opts);if(!r.ok)throw new Error((r.data&&(r.data.detail||r.data.message||r.data.error))||('HTTP '+r.status));return r.data;}
function asArray(x){if(Array.isArray(x))return x;if(!x)return[];return x.items||x.content||x.data||x.results||x.records||[];}
function money(n){if(n==null||isNaN(n))return'';try{return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n));}catch(_){return 'Q '+Number(n||0).toFixed(2);}}
function formaBadge(k){var kk=(k||'').toUpperCase();if(kk==='EFE')return'<span class="badge text-bg-success">Efectivo</span>';if(kk==='TAR')return'<span class="badge text-bg-info">Tarjeta</span>';if(kk==='TRF')return'<span class="badge text-bg-primary">Transferencia</span>';return'<span class="badge text-bg-secondary">'+(k||'')+'</span>';}

/* ========= MÓDULO: VPAGOS ========= */
var VPAGOS=(function(){
  var _inited=false,page=0,size=10,lastFilters={};
  var _clientes=[], _cacheSaldos={};

  async function cargarCatalogos(){
    try{
      var data=await fetchJson(joinUrl(API_CATALOGOS,'/clientes?limit=500'),{headers:commonHeaders});
      _clientes=asArray(data);
      var sel=document.getElementById('selCliente');
      var html='<option value="">(Todos)</option>';
      for(var i=0;i<_clientes.length;i++){
        var c=_clientes[i]||{},id=(c.id!=null?c.id:''),cod=c.codigo||('CLI-'+id),nom=c.nombre||c.razonSocial||'';
        html+='<option value="'+id+'">'+cod+' - '+nom+'</option>';
      }
      sel.innerHTML=html;
    }catch(_){}
  }

  function escAttr(s){return String(s==null?'':s).replace(/\\/g,'\\\\').replace(/'/g,"\\'");}

  function render(rows){
    var tbody=document.getElementById('tablaBody'),empty=document.getElementById('tablaEmpty');
    tbody.innerHTML='';
    if(!rows||!rows.length){ if(empty) empty.classList.remove('d-none'); return; }
    if(empty) empty.classList.add('d-none');

    for(var i=0;i<rows.length;i++){
      var r=rows[i]||{};
      var clienteTxt=(r.clienteNombre&&String(r.clienteNombre).trim()!=='')?r.clienteNombre:(r.clienteCodigo||(r.clienteId!=null?('CLI-'+r.clienteId):''));
      var pagoId=(r.pagoId!=null)?r.pagoId:'';
      var numVta=(r.numeroVenta!=null)?r.numeroVenta:'';
      var ventaId=(r.ventaId!=null)?r.ventaId:'';
      var fechaV=(r.fechaVenta!=null)?r.fechaVenta:'';
      var forma=r.formaPago||'';
      var montoNum=Number(r.monto||0);
      var ref=(r.referencia!=null)?r.referencia:'';

      var onEdit="VPAGOS.abrirEditar("+pagoId+","+ventaId+",'"+escAttr(forma)+"',"+montoNum+",'"+escAttr(ref)+"')";
      var onDel ="VPAGOS.abrirEliminar("+pagoId+","+montoNum+")";

      var html=''
        +'<td>'+pagoId+'</td>'
        +'<td><div class="small text-muted">#'+numVta+'</div><div>Id: '+ventaId+'</div></td>'
        +'<td>'+fechaV+'</td>'
        +'<td>'+clienteTxt+'</td>'
        +'<td>'+formaBadge(forma)+'</td>'
        +'<td class="text-end">'+money(montoNum)+'</td>'
        +'<td>'+ref+'</td>'
        +'<td class="text-end">'
        +'  <div class="btn-group btn-group-sm">'
        +'    <button class="btn btn-outline-primary" title="Editar" onclick="'+onEdit+'">'
        +'      <i class="bi bi-pencil"></i>'
        +'    </button>'
        +'    <button class="btn btn-outline-danger" title="Anular" onclick="'+onDel+'">'
        +'      <i class="bi bi-trash"></i>'
        +'    </button>'
        +'  </div>'
        +'</td>';

      var tr=document.createElement('tr'); tr.innerHTML=html; tbody.appendChild(tr);
    }
  }

  async function cargar(params){
    params=params||{};
    var qs=new URLSearchParams();
    if(params.clienteId) qs.set('clienteId',params.clienteId);
    if(params.ventaId)   qs.set('ventaId',  params.ventaId);
    if(params.desde)     qs.set('desde',    params.desde);
    if(params.hasta)     qs.set('hasta',    params.hasta);

    var url=joinUrl(API_VENTAS,'/pagos'+(qs.toString()?('?'+qs.toString()):''));
    var all=asArray(await fetchJson(url,{headers:commonHeaders}));
    var start=page*size;
    render(all.slice(start,start+size));
    var p=document.getElementById('pActual'); if(p) p.textContent=(page+1);
    window.__rowsPagosAll=all;
  }

  function cambiarTamano(){
    var sel=document.getElementById('selSize');
    size=parseInt(sel.value||'10',10);
    page=0;
    cargar(lastFilters);
  }

  function cambiarPagina(delta){
    var all=window.__rowsPagosAll||[];
    var maxPage=Math.max(0,Math.ceil(all.length/size)-1);
    page=Math.max(0,Math.min(maxPage,page+delta));
    var start=page*size;
    render(all.slice(start,start+size));
    var p=document.getElementById('pActual'); if(p) p.textContent=(page+1);
  }

  function buscar(ev){
    ev.preventDefault();
    lastFilters={
      clienteId:document.getElementById('selCliente').value||'',
      ventaId:  document.getElementById('ventaId').value||'',
      desde:    document.getElementById('desde').value||'',
      hasta:    document.getElementById('hasta').value||''
    };
    page=0;
    cargar(lastFilters);
  }

  function limpiar(){
    var f=document.getElementById('filtros'); if(f) f.reset();
    var sel=document.getElementById('selCliente'); if(sel) sel.value='';
    lastFilters={}; page=0; cargar(lastFilters);
  }

  /* ===== helpers de saldos ===== */
  async function getSaldos(ventaId){
    if(!ventaId) return null;
    if(_cacheSaldos[ventaId]) return _cacheSaldos[ventaId];
    try{
      var s=await fetchJson(joinUrl(API_VENTAS,'/'+ventaId+'/saldos'),{headers:commonHeaders});
      _cacheSaldos[ventaId]=s;
      return s;
    }catch(_){ return null; }
  }

  function setSummary(prefix, s){
    // ids por modal: newSaldoOrigen / editSaldoOrigen, etc.
    function setTxt(id, txt){ var el=document.getElementById(id); if(el) el.textContent=txt; }
    var origen = (s && s.origen) ? String(s.origen) : '—';
    var total  = (s && s.total != null)  ? money(s.total)  : '—';
    var pagado = (s && s.pagado != null) ? money(s.pagado) : '—';
    var saldo  = (s && s.saldo != null)  ? money(s.saldo)  : '—';
    setTxt(prefix+'SaldoOrigen',   origen);
    setTxt(prefix+'SaldoTotal',    total);
    setTxt(prefix+'SaldoPagado',   pagado);
    setTxt(prefix+'SaldoRestante', saldo);
    // inicial de "tras guardar" = saldo actual
    setTxt(prefix+'SaldoRes',      '—' !== saldo ? saldo : '—');
  }

  /* ===== NUEVO ===== */
  function abrirNuevo(){
    document.getElementById('new_venta').value='';
    document.getElementById('new_forma').value='EFE';
    var m=document.getElementById('new_monto'); m.value=''; m.classList.remove('is-invalid');
    document.getElementById('new_monto_err').textContent='Monto inválido.';
    document.getElementById('new_ref').value='';
    document.getElementById('new_alert').classList.add('d-none');
    setSummary('new', null);
    new bootstrap.Modal(document.getElementById('modalNuevo')).show();
  }
  async function _hintNuevo(){
    var ventaId=Number(document.getElementById('new_venta').value||0);
    var s=await getSaldos(ventaId);
    setSummary('new', s);
    _calcNuevoSaldo();
  }
  function _calcNuevoSaldo(){
    var ventaId=Number(document.getElementById('new_venta').value||0);
    var m=Number(document.getElementById('new_monto').value||0);
    var el=document.getElementById('newSaldoRes');
    var s=_cacheSaldos[ventaId];
    if(el){
      if(s && typeof s.saldo==='number'){ el.textContent = money(Number(s.saldo) - m); }
      else el.textContent='—';
    }
  }
  async function confirmarNuevo(){
    var ventaId=Number(document.getElementById('new_venta').value);
    var forma=document.getElementById('new_forma').value||'EFE';
    var montoEl=document.getElementById('new_monto');
    var monto=Number(montoEl.value);
    var ref=document.getElementById('new_ref').value||null;

    if(!ventaId || ventaId<=0){ var a=document.getElementById('new_alert'); a.textContent='Ingresa un Venta ID válido.'; a.classList.remove('d-none'); return; }
    if(!monto || monto<=0){ montoEl.classList.add('is-invalid'); document.getElementById('new_monto_err').textContent='Ingresa un monto mayor a 0.'; return; }
    montoEl.classList.remove('is-invalid');

    var r=await tryFetchJson(joinUrl(API_VENTAS,'/'+ventaId+'/pagos'),{
      method:'POST',
      headers:Object.assign({'Content-Type':'application/x-www-form-urlencoded'},commonHeaders),
      body:new URLSearchParams({ forma:forma, monto:String(monto), referencia:ref==null?'':ref }).toString()
    });
    if(!r.ok){
      var a2=document.getElementById('new_alert');
      a2.textContent=(r.data&&(r.data.message||r.data.detail||r.data.error))||'No se pudo crear el pago';
      a2.classList.remove('d-none');
      return;
    }
    bootstrap.Modal.getInstance(document.getElementById('modalNuevo')).hide();
    AppToast.ok('Pago creado');
    lastFilters.ventaId=String(ventaId);
    document.getElementById('ventaId').value=String(ventaId);
    page=0;
    await cargar(lastFilters);
  }

  /* ===== EDITAR ===== */
  async function abrirEditar(pagoId,ventaId,forma,monto,ref){
    document.getElementById('edit_id').value=pagoId;
    document.getElementById('edit_monto_original').value=Number(monto||0);
    document.getElementById('edit_venta_id').value=ventaId;
    document.getElementById('editPagoId').textContent='#'+pagoId;
    document.getElementById('edit_forma').value=(forma||'EFE');

    var montoEl=document.getElementById('edit_monto');
    montoEl.value=(Number(monto||0)).toFixed(2);
    montoEl.classList.remove('is-invalid');
    document.getElementById('edit_monto_err').textContent='Monto inválido.';
    document.getElementById('edit_ref').value=ref||'';
    var alertBox=document.getElementById('edit_alert'); alertBox.classList.add('d-none'); alertBox.textContent='';

    try{
      var s=await getSaldos(ventaId);
      setSummary('edit', s);
      _calcEditSaldo();
    }catch(_){ setSummary('edit', null); }

    new bootstrap.Modal(document.getElementById('modalEditar')).show();
  }
  function _calcEditSaldo(){
    var ventaId=Number(document.getElementById('edit_venta_id').value||0);
    var original=Number(document.getElementById('edit_monto_original').value||0);
    var nuevo=Number(document.getElementById('edit_monto').value||0);
    var s=_cacheSaldos[ventaId];
    var el=document.getElementById('editSaldoRes');
    if(s && typeof s.saldo==='number'){ 
      var res=Number(s.saldo) + original - nuevo;
      if(el) el.textContent=money(res);
    }else{ if(el) el.textContent='—'; }
  }
  async function confirmarEditar(){
    var id=Number(document.getElementById('edit_id').value);
    var forma=document.getElementById('edit_forma').value||'EFE';
    var montoEl=document.getElementById('edit_monto');
    var monto=Number(montoEl.value);
    var ref=document.getElementById('edit_ref').value||null;

    if(!monto || monto<=0){ montoEl.classList.add('is-invalid'); document.getElementById('edit_monto_err').textContent='Ingresa un monto mayor a 0.'; return; }
    montoEl.classList.remove('is-invalid');

    var r=await tryFetchJson(joinUrl(API_VENTAS,'/pagos/'+id),{
      method:'PUT',
      headers:Object.assign({'Content-Type':'application/json'},commonHeaders),
      body:JSON.stringify({ formaPago:forma, monto:monto, referencia:ref })
    });
    if(!r.ok){
      var msg=(r.data&&(r.data.message||r.data.detail||r.data.error))||'No se pudo actualizar el pago';
      var alert=document.getElementById('edit_alert'); alert.textContent=msg; alert.classList.remove('d-none'); return;
    }
    bootstrap.Modal.getInstance(document.getElementById('modalEditar')).hide();
    AppToast.ok('Pago actualizado');
    await cargar(lastFilters);
  }

  /* ===== ELIMINAR ===== */
  function abrirEliminar(pagoId,monto){
    document.getElementById('del_id').value=pagoId;
    document.getElementById('del_id_txt').textContent='#'+pagoId;
    document.getElementById('del_monto_txt').textContent=money(monto||0);
    new bootstrap.Modal(document.getElementById('modalEliminar')).show();
  }
  async function confirmarEliminar(){
    var id=Number(document.getElementById('del_id').value);
    var r=await tryFetchJson(joinUrl(API_VENTAS,'/pagos/'+id),{method:'DELETE',headers:commonHeaders});
    if(!r.ok){ AppToast.err((r.data&&(r.data.message||r.data.detail||r.data.error))||'No se pudo anular'); return; }
    bootstrap.Modal.getInstance(document.getElementById('modalEliminar')).hide();
    AppToast.ok('Pago anulado');
    await cargar(lastFilters);
  }

  return {
    initOnce: async function(){ if(_inited) return; await cargarCatalogos(); _inited=true; },
    cargar:cargar, buscar:buscar, limpiar:limpiar, cambiarPagina:cambiarPagina, cambiarTamano:cambiarTamano,
    abrirNuevo:abrirNuevo, confirmarNuevo:confirmarNuevo, _hintNuevo:_hintNuevo, _calcNuevoSaldo:_calcNuevoSaldo,
    abrirEditar:abrirEditar, confirmarEditar:confirmarEditar, _calcEditSaldo:_calcEditSaldo,
    abrirEliminar:abrirEliminar, confirmarEliminar:confirmarEliminar
  };
})();

/* ========= BOOT ========= */
window.addEventListener('DOMContentLoaded',function(){
  var sel=document.getElementById('selSize'); if(sel) sel.value='10';
  VPAGOS.initOnce().then(function(){ VPAGOS.cargar({}); });
});
  </script>
</body>
</html>
