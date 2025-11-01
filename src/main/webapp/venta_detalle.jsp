<%--
  Document   : venta_detalle (solo lectura)
  Created on : 09/10/2025
  Author     : user
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Detalle de venta | NextTech</title>
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
    /* Integra el mismo estilo que ventas.jsp */
    body.nt-bg { background: var(--nt-bg); color: var(--nt-fg); }
    .nt-navbar { background: var(--nt-surface-1); border-bottom: 1px solid var(--nt-border); }
    .nt-title { color: var(--nt-fg-strong); }
    .nt-subtitle { color: var(--nt-fg-muted); }
    .nt-card { background: var(--nt-surface-1); border: 1px solid var(--nt-border); border-radius: 1rem; }
    .nt-card:hover { transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.25); transition: .12s; }
    .nt-table-head { background: var(--nt-surface-2); color: var(--nt-fg); }
    .nt-btn-accent { background: var(--nt-accent); color: #fff; border: none; }
    .nt-btn-accent:hover { filter: brightness(0.95); }
    .nt-back { display:inline-flex; align-items:center; gap:.5rem; border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary); }
    .nt-back:hover { background:var(--nt-surface-2); }
  </style>

  <!-- utilidades comunes del proyecto -->
  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header con botón Regresar -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-receipt"></i> NextTech — Ventas
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
        <h2 class="m-0 nt-title"><i class="bi bi-eye"></i> Detalle de venta</h2>
        <div class="nt-subtitle">Consulta de cabecera y líneas</div>
      </div>
      <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/ventas.jsp">
        <i class="bi bi-list-ul me-1"></i> Ir al listado
      </a>
    </div>

    <!-- Cabecera -->
    <div class="card nt-card mb-3">
      <div class="card-body" id="cabecera">
        <div class="text-muted">Cargando venta...</div>
      </div>
    </div>

    <!-- Detalle (líneas) -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table id="tabla" class="table table-hover align-middle mb-0">
          <thead class="nt-table-head">
          <tr>
            <th>ID Detalle</th>
            <th>Producto ID</th>
            <th>Cantidad</th>
            <th>Precio</th>
            <th>Desc. línea</th>
            <th>Subtotal</th>
            <th>Lote</th>
            <th>Vence</th>
          </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="tablaEmpty" class="p-3 text-muted d-none">Esta venta no tiene líneas.</div>
    </div>
  </div>

  <!-- Bootstrap -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
  // ====== Sync API.baseUrl desde <meta> (igual que ventas.jsp) ======
  (function(){
    try{
      window.API = window.API || {};
      if (!API.baseUrl || !API.baseUrl.trim()) {
        const meta = document.querySelector('meta[name="api-base"]');
        const base = (window.API_BASE || meta?.getAttribute('content') || '').trim();
        if (base) API.baseUrl = base;
      }
      console.log('[venta_detalle.jsp] API.baseUrl =', API.baseUrl || '(vacío)');
    }catch(_){}
  })();

  // Botón REGRESAR por rol (mismo helper)
  function parseAuthUser(){
    try{
      if (window.Auth?.user) return window.Auth.user;
      const raw = localStorage.getItem('auth_user');
      return raw ? JSON.parse(raw) : null;
    }catch(_){ return null; }
  }
  function homeForRole(role){
    const HOME_BY_ROLE = {
      'ADMIN': 'Dashboard.jsp',
      'OPERADOR': 'dashboard_operador.jsp',
      'RRHH': 'rrhh-dashboard.jsp'
    };
    return HOME_BY_ROLE[role?.toUpperCase?.()] || 'Dashboard.jsp';
  }
  function goBack(){
    if (history.length > 1) { history.back(); return; }
    const user = parseAuthUser();
    const home = homeForRole(user?.role || user?.rol);
    location.href = home;
  }

  // === Config/ENDPOINTS ===
  const API_BASE = (window.API?.baseUrl || document.querySelector('meta[name="api-base"]')?.content || '')
                    .replace(/\/+$/,'') + '/api/ventas';

  // === Utils ===
  function qs(name){ var u = new URL(window.location.href); return u.searchParams.get(name); }
  function money(n){
    if(n==null || n==='' || isNaN(n)) return '';
    try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
    catch(e){ return 'Q ' + Number(n).toFixed(2); }
  }
  function txt(x){ return (x===undefined || x===null) ? '' : String(x); }
  async function fetchJson(url, opts){
    const res = await fetch(url, opts||{});
    const txtRes = await res.text();
    let data = null;
    try{ data = txtRes ? JSON.parse(txtRes) : null; }catch{}
    if(!res.ok) throw new Error((data && (data.error||data.detail)) || ('HTTP '+res.status));
    return data;
  }
  function mapTipoPago(c){ if(!c) return ''; return c==='C'?'Contado':(c==='R'?'Crédito':c); }
  function estadoBadge(e){
    if(e==='A') return '<span class="badge text-bg-danger">Anulada</span>';
    if(e==='P') return '<span class="badge ok">Procesada</span>';
    return '<span class="badge text-bg-secondary">Desconocido</span>';
  }

  // === Render ===
  function renderCabecera(v){
    var cliente = (v && v.clienteNombre && String(v.clienteNombre).trim()!=='')
                  ? v.clienteNombre : ('ID ' + txt(v && v.clienteId));

    var html = ''
      + '<div class="row g-2">'
      +   '<div class="col-md-3"><b>Número:</b> ' + txt(v && v.numeroVenta) + '</div>'
      +   '<div class="col-md-3"><b>Fecha:</b> ' + txt(v && v.fechaVenta) + '</div>'
      +   '<div class="col-md-6"><b>Cliente:</b> ' + cliente + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-3"><b>Tipo Pago:</b> ' + mapTipoPago(v && v.tipoPago) + '</div>'
      +   '<div class="col-md-3"><b>Estado:</b> ' + estadoBadge(v && v.estado) + '</div>'
      +   '<div class="col-md-3"><b>VendedorID:</b> ' + txt(v && v.vendedorId) + '</div>'
      +   '<div class="col-md-3"><b>CajeroID:</b> ' + txt(v && v.cajeroId) + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-3"><b>Subtotal:</b> ' + money(v && v.subtotal) + '</div>'
      +   '<div class="col-md-3"><b>Descuento:</b> ' + money(v && v.descuentoGeneral) + '</div>'
      +   '<div class="col-md-3"><b>IVA:</b> ' + money(v && v.iva) + '</div>'
      +   '<div class="col-md-3"><span class="badge ok">Total ' + money(v && v.total) + '</span></div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-12"><b>Observaciones:</b> ' + txt(v && v.observaciones) + '</div>'
      + '</div>';

    document.getElementById('cabecera').innerHTML = html;
  }

  function renderDetalles(items){
    var tbody = document.querySelector('#tabla tbody');
    var empty = document.getElementById('tablaEmpty');
    tbody.innerHTML = '';

    if(!items || !items.length){
      if (empty) empty.classList.remove('d-none');
      return;
    }
    if (empty) empty.classList.add('d-none');

    for (var i=0;i<items.length;i++){
      var d = items[i];
      var tr = document.createElement('tr');
      tr.innerHTML =
          '<td>' + txt(d && d.id) + '</td>'
        + '<td>' + txt(d && d.productoId) + '</td>'
        + '<td>' + txt(d && d.cantidad) + '</td>'
        + '<td>' + money(d && d.precioUnitario) + '</td>'
        + '<td>' + money(d && d.descuentoLinea) + '</td>'
        + '<td>' + money(d && d.subtotal) + '</td>'
        + '<td>' + txt(d && d.lote) + '</td>'
        + '<td>' + txt(d && d.fechaVencimiento) + '</td>';
      tbody.appendChild(tr);
    }
  }

  // === Carga ===
  async function cargar(){
    try{
      var id = qs('id');
      if(!id) throw new Error('Falta parámetro ?id=');
      var venta = await fetchJson(API_BASE + '/' + id);
      renderCabecera(venta);
      renderDetalles(venta && venta.items);
    }catch(err){
      console.error(err);
      document.getElementById('cabecera').innerHTML =
        '<div class="alert alert-danger">Error: ' + (err.message || 'desconocido') + '</div>';
    }
  }

  // === Boot ===
  window.addEventListener('DOMContentLoaded', cargar);
  </script>
</body>
</html>
