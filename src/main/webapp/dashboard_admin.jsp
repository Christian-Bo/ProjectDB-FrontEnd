<%-- 
  Document   : dashboard_admin
  Created on : 16/10/2025
  Author     : Christian
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ADMIN Dashboard • NextTech</title>

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema oscuro -->
  <link rel="stylesheet" href="assets/css/base.css">
  <link rel="stylesheet" href="assets/css/app.css">

  <!-- Guard de autenticación -->
  <script src="assets/js/auth.guard.js"></script>

  <style>
    .nt-card{ transition: transform .12s ease, border-color .12s ease, box-shadow .12s ease; }
    .nt-card:hover{ transform: translateY(-2px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.35); }
    .badge.bg-outline{ background:transparent; color:var(--nt-accent); border:1px solid var(--nt-accent); }
    .section-title { font-size:.95rem; letter-spacing:.02em; color: var(--nt-text-soft,#aab); }
  </style>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">
<script>Auth.ensure(['ADMIN']);</script>

<!-- Header: SOLO en dashboards se muestra “Salir” -->
<header class="navbar nt-navbar">
  <div class="container d-flex align-items-center justify-content-between">
    <a class="navbar-brand fw-bold d-flex align-items-center gap-2">
      <i class="bi bi-shield-lock"></i> NextTech — Admin
    </a>
    <div class="d-flex align-items-center gap-2">
      <span id="user-role" class="badge bg-secondary">ADMIN</span>
      <button class="btn btn-outline-light btn-sm" onclick="logout()" title="Cerrar sesión">
        <i class="bi bi-box-arrow-right me-1"></i> Salir
      </button>
    </div>
  </div>
</header>

<main class="container py-4 flex-grow-1">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h1 class="h3 mb-0 nt-title">ADMIN • Dashboard</h1>
    <small class="text-body-secondary">Acceso total a módulos y catálogos.</small>
  </div>

  <div class="mb-2 section-title">Operaciones</div>
  <div class="row g-3 mb-4" id="sec-operaciones"></div>

  <div class="mb-2 section-title">Inventario y Logística</div>
  <div class="row g-3 mb-4" id="sec-inventario"></div>

  <div class="mb-2 section-title">Catálogos de Productos</div>
  <div class="row g-3 mb-4" id="sec-catalogos"></div>

  <div class="mb-2 section-title">Recursos Humanos</div>
  <div class="row g-3 mb-4" id="sec-rrhh"></div>

  <div class="mb-2 section-title">Utilidades / Sistema</div>
  <div class="row g-3" id="sec-utilidades"></div>
</main>

<script>
  // ====== Definición de módulos (todos los JSP de tu lista) ======
  var SECCIONES = {
    operaciones: [
      { name:'Compras',           href:'compras.jsp',            icon:'bi-bag-check',        desc:'Crear/editar compras.' },
      { name:'Pagos de Compras',  href:'compras_pagos.jsp',      icon:'bi-receipt',          desc:'Aplicaciones y conciliación.' },
      { name:'Ventas',            href:'ventas.jsp',             icon:'bi-cash-coin',        desc:'Registro y seguimiento de ventas.' },
      { name:'Pagos de Ventas',   href:'ventas_pagos.jsp',       icon:'bi-cash-stack',     desc:'ABM de clientes y gestión de información.' },
      { name:'Facturas',          href:'facturas.jsp',           icon:'bi-receipt',     desc:'ABM de clientes y gestión de información.' },
      { name:'Transferencias',    href:'transferencias.jsp',     icon:'bi-arrow-left-right', desc:'Traslados entre bodegas.' },
      { name:'CxC (Cobrar)',      href:'cxc.jsp',                icon:'bi-wallet2',          desc:'Cuentas por cobrar.' },
      { name:'CxP (Pagar)',       href:'cxp.jsp',                icon:'bi-cash-stack',       desc:'Cuentas por pagar.' },
      { name:'Devoluciones',      href:'devoluciones.jsp',       icon:'bi-arrow-counterclockwise', desc:'Gestión de devoluciones.' },
      { name:'Proveedores',       href:'proveedores.jsp',        icon:'bi-truck',            desc:'ABM de proveedores.' },
      { name:'Cotizaciones',     href:'cotizaciones.jsp',      icon:'bi-calendar-check',   desc:'Gestión de contizaciones y fechas de pago.' },
      { name:'Clientes',          href:'clientes.jsp',           icon:'bi-person-badge',     desc:'ABM de clientes y gestión de información.' }
    ],
    inventario: [
      { name:'Inventario',        href:'inventario.jsp',         icon:'bi-archive',          desc:'Stock, kardex y alertas.' },
      { name:'Bodegas',           href:'bodegas.jsp',            icon:'bi-building',         desc:'Catálogo de bodegas.' }
    ],
    catalogos: [
      { name:'Categorías',        href:'categorias.jsp',         icon:'bi-diagram-3',        desc:'Clasificación de productos.' },
      { name:'Marcas',            href:'marcas.jsp',             icon:'bi-tags',             desc:'ABM de marcas.' }
    ],
    rrhh: [
      { name:'Panel RRHH',        href:'rrhh-dashboard.jsp',     icon:'bi-people',           desc:'Empleados / Puestos / Depts.' },
    ],
    utilidades: [
      { name:'Ajustes',              href:'ajustes.jsp',              icon:'bi-sliders2',             desc:'Parámetros del sistema.' },
    ]
  };

  // ====== Render SIN template literals (evita conflicto con JSP EL) ======
  function cardHTML(m){
    var html = '';
    html += '<div class="col-12 col-sm-6 col-lg-4 col-xl-3">';
    html +=   '<a href="' + m.href + '" class="text-decoration-none">';
    html +=     '<div class="card nt-card h-100">';
    html +=       '<div class="card-body d-flex flex-column">';
    html +=         '<div class="d-flex align-items-center mb-2">';
    html +=           '<i class="bi ' + m.icon + ' fs-3 me-2"></i>';
    html +=           '<h5 class="card-title mb-0 nt-title">' + m.name + '</h5>';
    html +=         '</div>';
    html +=         '<p class="card-text text-body-secondary small flex-grow-1">' + (m.desc || 'Módulo del sistema.') + '</p>';
    html +=         '<div class="mt-2"><span class="badge bg-outline">Acceso</span></div>';
    html +=       '</div>';
    html +=     '</div>';
    html +=   '</a>';
    html += '</div>';
    return html;
  }

  function renderSection(containerId, items){
    var cont = document.getElementById(containerId);
    var out = '';
    for(var i=0;i<items.length;i++){ out += cardHTML(items[i]); }
    cont.innerHTML = out;
  }

  renderSection('sec-operaciones', SECCIONES.operaciones);
  renderSection('sec-inventario', SECCIONES.inventario);
  renderSection('sec-catalogos',  SECCIONES.catalogos);
  renderSection('sec-rrhh',       SECCIONES.rrhh);
  renderSection('sec-utilidades', SECCIONES.utilidades);

  // Badge de rol actual
  (function(){ 
    try{
      var r = (Auth.role && Auth.role()) ? String(Auth.role()).toUpperCase() : 'ADMIN';
      document.getElementById('user-role').textContent = r;
    }catch(e){}
  })();

  function logout(){
    try{
      Auth.clear && Auth.clear();
      localStorage.removeItem('auth_token');
      localStorage.removeItem('auth_expires');
      localStorage.removeItem('auth_user');
      localStorage.removeItem('nt.session');
    }catch(e){}
    location.href = 'index.jsp';
  }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
