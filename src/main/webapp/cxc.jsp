<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Cuentas por Cobrar | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <meta name="api-base" content="http://localhost:8080" />

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema NextTech -->
  <link rel="stylesheet" href="assets/css/base.css?v=13">
  <link rel="stylesheet" href="assets/css/app.css?v=13">

  <style>
    /* ===== L&F global (igual a Transferencias) ===== */
    body.nt-bg { background: var(--nt-bg); color: var(--nt-fg); }
    .nt-title { color: var(--nt-fg-strong); }
    .nt-subtitle { color: var(--nt-fg-muted); }

    .nt-topbar{
      background: var(--nt-surface-1);
      border-bottom: 1px solid var(--nt-border);
    }
    .nt-back{
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border);
      background:transparent; color:var(--nt-primary);
    }
    .nt-back:hover{ background:var(--nt-surface-2); }

    .nt-card{
      background: var(--nt-surface-1);
      border: 1px solid var(--nt-border);
      border-radius: 1rem;
      transition: .12s;
    }
    .nt-card:hover{
      transform: translateY(-1px);
      border-color: var(--nt-accent);
      box-shadow: 0 10px 24px rgba(0,0,0,.25);
    }
    .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-fg); }

    .nt-btn-accent{
      background: var(--nt-accent);
      color:#fff; border:none;
    }
    .nt-btn-accent:hover{ filter: brightness(.95); }

    /* Inputs/Selects oscuros */
    .nt-input.form-control,
    .nt-input.form-select{
      background: var(--nt-surface-2);
      color: var(--nt-fg);
      border-color: var(--nt-border);
    }
    .nt-input.form-control:focus,
    .nt-input.form-select:focus{
      background: var(--nt-surface-2);
      color: var(--nt-fg);
      border-color: var(--nt-accent);
      box-shadow: 0 0 0 .2rem rgba(0, 102, 255, .15);
    }
    ::placeholder{ color: var(--nt-fg-muted) !important; opacity: 1; }

    /* Paginación */
    .nt-pager .btn{ border-color: var(--nt-border); }

    /* Alerta de error a tono con el tema */
    .alert-soft-danger{
      background: rgba(220,53,69,.12);
      border: 1px solid rgba(220,53,69,.35);
      color: #ffb3ba;
    }

    /* Hover de filas sutil como en Transferencias */
    .table-hover tbody tr:hover { background: rgba(255,255,255,.03); }
  </style>

  <script src="assets/js/auth.guard.js"></script>
  <script>
    function backToDashboard(){
      const role = (Auth.role?.() || '').toUpperCase();
      switch(role){
        case 'ADMIN':      location.href='Dashboard.jsp'; break;
        case 'FINANZAS':   location.href='dashboard_finanzas.jsp'; break;
        case 'AUDITOR':    location.href='dashboard_auditor.jsp'; break;
        case 'OPERACIONES':
        default:           location.href='dashboard_operador.jsp'; break;
      }
    }
    function logout(){
      Auth.clear?.();
      localStorage.removeItem('auth_token');
      localStorage.removeItem('auth_expires');
      localStorage.removeItem('auth_user');
      location.href='index.jsp';
    }
  </script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-arrow-left-right"></i> NextTech — CxC
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

<div class="container py-4">
  <div class="d-flex align-items-center justify-content-between mb-3">
    <div>
      <h1 class="h4 nt-title mb-1"><i class="bi bi-wallet2 me-2"></i> Cuentas por Cobrar</h1>
      <div class="nt-subtitle">Consulta y control de documentos CxC.</div>
    </div>
  </div>

  <!-- Filtros -->
  <div class="card nt-card mb-3">
    <div class="card-body">
      <form id="filtros" onsubmit="buscar(event)" class="row g-3">
        <div class="col-md-3">
          <label class="form-label">Desde</label>
          <input type="date" name="desde" class="form-control nt-input" placeholder="dd/mm/aaaa">
        </div>
        <div class="col-md-3">
          <label class="form-label">Hasta</label>
          <input type="date" name="hasta" class="form-control nt-input" placeholder="dd/mm/aaaa">
        </div>
        <div class="col-md-3">
          <label class="form-label">Cliente ID</label>
          <input type="number" min="1" name="clienteId" placeholder="Ej. 1" class="form-control nt-input">
        </div>
        <div class="col-md-3">
          <label class="form-label">Estado</label>
          <select name="estado" class="form-select nt-input">
            <option value="">(Todos)</option>
            <option value="P">Pendiente</option>
            <option value="C">Cancelado</option>
          </select>
        </div>
        <div class="col-12 d-flex gap-2 justify-content-end">
          <button class="btn nt-btn-accent" type="submit"><i class="bi bi-search"></i> Buscar</button>
          <button class="btn btn-outline-secondary" type="button" onclick="limpiar()"><i class="bi bi-eraser"></i> Limpiar</button>
        </div>
      </form>

      <!-- Caja de error -->
      <div id="errorBox" class="alert alert-soft-danger mt-3 d-none"></div>
    </div>
  </div>

  <!-- Paginación -->
  <div class="d-flex justify-content-between align-items-center mb-2 nt-pager">
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
          <th>ID</th>
          <th>Documento</th>
          <th>Fecha</th>
          <th>Cliente</th>
          <th class="text-end">Monto</th>
          <th class="text-end">Saldo</th>
          <th>Estado</th>
          <th class="text-end">Acciones</th>
        </tr>
        </thead>
        <tbody></tbody>
      </table>
    </div>
    <div id="tablaEmpty" class="p-3 text-muted d-none">Sin resultados para los filtros actuales.</div>
  </div>
</div>

<!-- ======= Scripts (misma lógica, solo UI) ======= -->
<script>
  // ==== Config ====
  const API_DOCS = 'http://localhost:8080/api/cxc/documentos';
  let page = 0, size = 10, last = {};

  // ==== Utils ====
  function money(n){
    if(n==null || isNaN(n)) return '';
    try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
    catch(e){ return 'Q ' + Number(n).toFixed(2); }
  }
  async function fetchJson(url){
    const res = await fetch(url);
    let body = null; try{ body = await res.json(); }catch(e){}
    if(!res.ok){
      const msg = (body && (body.detail || body.error || body.message)) || ('HTTP ' + res.status);
      throw new Error(msg);
    }
    return body;
  }
  function toArr(p){
    if(Array.isArray(p)) return p;
    if(!p || typeof p!=='object') return [];
    return p.content || p.items || p.data || p.records || [];
  }
  function showError(msg){
    var box = document.getElementById('errorBox');
    if(!box) return;
    if(!msg){ box.classList.add('d-none'); box.textContent=''; return; }
    box.textContent = 'Error al llamar ' + msg;
    box.classList.remove('d-none');
  }

  // ==== Core ====
  async function cargar(params){
    params = params || {};
    try{
      var qs = new URLSearchParams({ page: page, size: size });
      if(params.desde)     qs.set('desde', params.desde);
      if(params.hasta)     qs.set('hasta', params.hasta);
      if(params.clienteId) qs.set('clienteId', params.clienteId);
      if(params.estado)    qs.set('estado', params.estado);

      var data = await fetchJson(API_DOCS + '?' + qs.toString());
      render(toArr(data));
      var pEl = document.getElementById('pActual'); if(pEl) pEl.textContent = (page+1);
      showError(null);
    }catch(err){
      var base = API_DOCS + '?' + new URLSearchParams({ page: page, size: size }).toString() + ': ' + err.message;
      showError(base);
      render([]);
    }
  }

  function render(rows){
    var tb = document.querySelector('#tabla tbody');
    var empty = document.getElementById('tablaEmpty');
    tb.innerHTML = '';
    if(!rows.length){ if(empty) empty.classList.remove('d-none'); return; }
    if(empty) empty.classList.add('d-none');

    rows.forEach(function(x){
      var id    = (x.id!=null ? x.id : (x.documento_id!=null ? x.documento_id : ''));
      var num   = (x.numero!=null ? x.numero : (x.numero_documento!=null ? x.numero_documento : (x.documento || '')));
      var fec   = (x.fecha!=null ? x.fecha : (x.fecha_emision!=null ? x.fecha_emision : ''));
      var cli   = (x.clienteNombre || x.cliente_nombre) || ((x.clienteId||x.cliente_id) ? ('ID ' + (x.clienteId||x.cliente_id)) : '');
      var monto = (x.monto!=null ? x.monto : (x.monto_total!=null ? x.monto_total : (x.total!=null ? x.total : null)));
      var saldo = (x.saldo!=null ? x.saldo : (x.saldoPendiente!=null ? x.saldoPendiente : (x.saldo_pendiente!=null ? x.saldo_pendiente : null)));
      var est   = (x.estado!=null ? x.estado : 'P');

      var numSafe = String(num).replace(/</g,'&lt;').replace(/>/g,'&gt;');
      var tr = document.createElement('tr');
      tr.innerHTML =
          '<td>' + id + '</td>'
        + '<td>' + numSafe + '</td>'
        + '<td>' + (fec||'') + '</td>'
        + '<td>' + (cli||'') + '</td>'
        + '<td class="text-end">' + money(monto) + '</td>'
        + '<td class="text-end">' + money(saldo) + '</td>'
        + '<td>' + (est||'') + '</td>'
        + '<td class="text-end">'
        +   '<div class="btn-group btn-group-sm">'
        +     '<button class="btn btn-outline-primary" onclick="abrirPago(' + id + ', \'' + numSafe.replace(/'/g, "\\'") + '\')">'
        +       '<i class="bi bi-cash-coin"></i> Registrar pago'
        +     '</button>'
        +   '</div>'
        + '</td>';
      tb.appendChild(tr);
    });
  }

  // ==== Filtros / Paginación ====
  function buscar(e){
    e.preventDefault();
    var f = e.target;
    page = 0;
    last = {
      desde: f.desde.value,
      hasta: f.hasta.value,
      clienteId: f.clienteId.value,
      estado: f.estado.value
    };
    cargar(last);
  }
  function limpiar(){
    var form = document.getElementById('filtros');
    if(form) form.reset();
    last = {};
    page = 0;
    cargar();
  }
  function cambiarPagina(delta){
    page = Math.max(0, page + delta);
    cargar(last);
  }

  // ==== Pagos (placeholder) ====
  function abrirPago(id, numero){
    alert('Registrar pago para documento ' + numero + ' (ID ' + id + ')');
  }

  // ==== Boot ====
  window.addEventListener('DOMContentLoaded', function(){
    try{ document.getElementById('roleChip').textContent = (Auth.role?.() || 'ADMIN').toUpperCase(); }catch{}
    cargar();
  });
</script>
<script>

  function goBack() {
    if (history.length > 1) {
      history.back();
      return;
    }
    backToDashboard();
  }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
