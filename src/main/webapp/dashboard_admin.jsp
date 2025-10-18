<%-- 
    Document   : dashboard_admin
    Created on : 16/10/2025
    Author     : Christian
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>ADMIN Dashboard • Nextech</title>
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/app.css">
  <script src="assets/js/auth.guard.js"></script>
</head>
<body class="nt-bg">
<script>
  // Solo ADMIN entra a esta página
  Auth.ensure(['ADMIN']);
</script>

<!-- Header -->
<header class="navbar navbar-expand-lg nt-header">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="Dashboard.jsp">Nextech</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0" id="menu-items"></ul>
      <div class="d-flex align-items-center gap-3">
        <span id="user-role" class="badge bg-secondary">ADMIN</span>
        <button class="btn btn-outline-light btn-sm" onclick="logout()">Salir</button>
      </div>
    </div>
  </div>
</header>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h1 class="h3 mb-0">ADMIN Dashboard</h1>
    <small class="text-body-secondary">Acceso total a todos los módulos.</small>
  </div>

  <div class="row g-3" id="cards"></div>
</main>

<script>
  // ========= Lista única de módulos (solo los que existen en tu proyecto) =========
  const MODULES = [
    // Operaciones / Ventas / Compras
    { key:'compras',       name:'Compras',              href:'compras.jsp',         icon:'bi-bag-check' },
    { key:'compras_pagos', name:'Pagos de Compras',     href:'compras_pagos.jsp',   icon:'bi-receipt' },
    { key:'ventas',        name:'Ventas',               href:'ventas.jsp',          icon:'bi-cash-coin' },

    // Finanzas
    { key:'cxp',           name:'Cuentas por Pagar',    href:'cxp.jsp',             icon:'bi-cash-stack' },
    { key:'cxc',           name:'Cuentas por Cobrar',   href:'cxc.jsp',             icon:'bi-wallet2' },

    // RRHH
    { key:'rrhh',          name:'RRHH (panel)',         href:'rrhh-dashboard.jsp',  icon:'bi-people' },

    // Administración
    { key:'proveedores',   name:'Proveedores',          href:'proveedores.jsp',     icon:'bi-truck' },
  ];

  // ===== Navbar (como ADMIN, muestra todo) =====
  (function buildNavbar(){
    const menu = document.getElementById('menu-items');
    menu.innerHTML = MODULES.map(function(m){
      return '<li class="nav-item">' +
               '<a class="nav-link" href="'+ m.href +'">' +
                 '<i class="bi '+ m.icon +' me-1"></i>'+ m.name +
               '</a>' +
             '</li>';
    }).join('');
  })();

  // ===== Tarjetas (accesos rápidos) =====
  (function buildCards(){
    const cont = document.getElementById('cards');
    cont.innerHTML = MODULES.map(function(m){
      return '' +
      '<div class="col-12 col-sm-6 col-lg-4 col-xl-3">' +
        '<a href="'+ m.href +'" class="text-decoration-none">' +
          '<div class="card nt-card h-100">' +
            '<div class="card-body d-flex flex-column">' +
              '<div class="d-flex align-items-center mb-2">' +
                '<i class="bi '+ m.icon +' fs-3 me-2"></i>' +
                '<h5 class="card-title mb-0">'+ m.name +'</h5>' +
              '</div>' +
              '<p class="card-text text-body-secondary small flex-grow-1">'+ descFor(m.key) +'</p>' +
              '<div class="mt-2"><span class="badge bg-outline">Acceso</span></div>' +
            '</div>' +
          '</div>' +
        '</a>' +
      '</div>';
    }).join('');
  })();

  function descFor(key){
    switch(key){
      case 'compras':        return 'Crear/editar compras (cabecera y detalles).';
      case 'compras_pagos':  return 'Registrar pagos y aplicaciones a compras.';
      case 'ventas':         return 'Crear/editar ventas (cuando esté disponible).';
      case 'cxp':            return 'Pagos y conciliaciones a proveedores.';
      case 'cxc':            return 'Pagos y conciliaciones de clientes.';
      case 'rrhh':           return 'Panel de RRHH (departamentos, puestos, empleados).';
      case 'empleados':      return 'Gestión de empleados.';
      case 'departamentos':  return 'Catálogo de departamentos.';
      case 'puestos':        return 'Catálogo de puestos.';
      case 'proveedores':    return 'ABM de proveedores.';
      case 'usuarios':       return 'Gestión de usuarios/roles del sistema.';
      default:               return 'Módulo del sistema.';
    }
  }

  function logout(){
    // Limpia sesión guardada por Auth.save(...)
    Auth.clear?.();
    localStorage.removeItem('auth_token');
    localStorage.removeItem('auth_expires');
    localStorage.removeItem('auth_user');
    // Vuelve al login
    location.href = 'index.jsp';
  }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
