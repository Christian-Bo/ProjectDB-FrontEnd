<%--
  Document   : dashboard_operaciones
  Author     : Christian
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>OPERACIONES Dashboard • Nextech</title>

  <!-- API base opcional (puedes quitar si no lo usas) -->
  <meta name="api-base" content="http://localhost:8080"/>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/app.css">
  <!-- auth.guard debe exponer Auth.ensure / Auth.role / Auth.clear / Auth.load -->
  <script src="assets/js/auth.guard.js"></script>
  <!-- MUY RECOMENDADO: common.js con el parche de Authorization Bearer -->
  <script src="assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg">
<script>
  // Solo OPERACIONES (ADMIN también pasa por el interceptor y aquí)
  Auth.ensure(['OPERACIONES']);
</script>

<!-- Header compartido -->
<header class="navbar navbar-expand-lg nt-header">
  <div class="container-fluid">
    <a class="navbar-brand fw-bold" href="Dashboard.jsp">Nextech</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#nav">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="nav">
      <ul class="navbar-nav me-auto mb-2 mb-lg-0" id="menu-items"></ul>
      <div class="d-flex align-items-center gap-3">
        <span id="user-role" class="badge bg-secondary">OPERACIONES</span>
        <button class="btn btn-outline-light btn-sm" onclick="logout()">Salir</button>
      </div>
    </div>
  </div>
</header>

<main class="container py-4">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h1 class="h3 mb-0">OPERACIONES • Dashboard</h1>
    <small class="text-body-secondary">Accesos rápidos a tus módulos operativos.</small>
  </div>

  <div class="row g-3" id="cards"></div>
</main>

<script>
  // ===== MÓDULOS visibles para OPERACIONES =====
  // (ADMIN también los verá; Finanzas/RRHH NO van aquí)
  const MODULES = [
    { key:'compras',        name:'Compras',              href:'compras.jsp',         icon:'bi-bag-check' },
    { key:'compras_pagos',  name:'Pagos de Compras',     href:'compras_pagos.jsp',   icon:'bi-receipt' }, // si lo usa Operaciones
    { key:'proveedores',    name:'Proveedores',          href:'proveedores.jsp',     icon:'bi-truck' },
    { key:'productos',      name:'Productos',            href:'productos.jsp',       icon:'bi-box-seam' },
    { key:'inventario',     name:'Inventario',           href:'inventario.jsp',      icon:'bi-archive' },
    { key:'ventas',         name:'Ventas',               href:'ventas.jsp',          icon:'bi-cash-coin' },
    { key:'catalogos',      name:'Catálogos',            href:'catalogos.jsp',       icon:'bi-collection' }
  ];

  // ===== Navbar según rol actual =====
  (function buildNavbar(){
    const r = (Auth.role() || '').toUpperCase();
    document.getElementById('user-role').textContent = r || 'OPERACIONES';
    const menu = document.getElementById('menu-items');
    // Menú básico: solo lo propio de Operaciones. (Admin tiene otros dashboards)
    const items = MODULES.map(m =>
      `<li class="nav-item"><a class="nav-link" href="${m.href}">
         <i class="bi ${m.icon} me-1"></i>${m.name}
       </a></li>`
    ).join('');
    menu.innerHTML = items;
  })();

  // ===== Tarjetas de accesos =====
  (function buildCards(){
    const cont = document.getElementById('cards');
    cont.innerHTML = MODULES.map(m => `
      <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
        <a href="${m.href}" class="text-decoration-none">
          <div class="card nt-card h-100">
            <div class="card-body d-flex flex-column">
              <div class="d-flex align-items-center mb-2">
                <i class="bi ${m.icon} fs-3 me-2"></i>
                <h5 class="card-title mb-0">${m.name}</h5>
              </div>
              <p class="card-text text-body-secondary small flex-grow-1">
                ${descFor(m.key)}
              </p>
              <div class="mt-2">
                <span class="badge bg-outline">Acceso</span>
              </div>
            </div>
          </div>
        </a>
      </div>
    `).join('');
  })();

  // Descripciones cortas por módulo
  function descFor(key){
    switch(key){
      case 'compras':        return 'Crea y administra órdenes de compra.';
      case 'compras_pagos':  return 'Registra pagos y aplicaciones de compras.';
      case 'proveedores':    return 'ABM de proveedores y datos de contacto.';
      case 'productos':      return 'Catálogo de productos y atributos.';
      case 'inventario':     return 'Movimientos y existencias por almacén.';
      case 'ventas':         return 'Registro y seguimiento de ventas.';
      case 'catalogos':      return 'Catálogos compartidos (códigos, categorías).';
      default:               return 'Módulo operativo del sistema.';
    }
  }

  function logout(){
    // Limpia sesión (según cómo guardas)
    try { Auth.clear?.(); } catch {}
    try { localStorage.removeItem('nt.session'); } catch {}
    try { localStorage.removeItem('auth_token'); localStorage.removeItem('sessionToken'); } catch {}
    location.href = 'index.jsp';
  }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
