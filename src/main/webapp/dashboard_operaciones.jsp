<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>OPERACIONES Dashboard • NextTech</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
  <link rel="stylesheet" href="assets/css/base.css">
  <link rel="stylesheet" href="assets/css/app.css">

  <script src="assets/js/auth.guard.js"></script>
  <style>
    .nt-card{transition:transform .12s,border-color .12s,box-shadow .12s}
    .nt-card:hover{transform:translateY(-2px);border-color:var(--nt-accent);box-shadow:0 10px 24px rgba(0,0,0,.35)}
    .badge.bg-outline{background:transparent;color:var(--nt-accent);border:1px solid var(--nt-accent)}
  </style>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">
<script>Auth.ensure(['OPERACIONES']);</script>

<header class="navbar nt-navbar">
  <div class="container d-flex align-items-center justify-content-between">
    <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="Dashboard.jsp">
      <i class="bi bi-gear-wide-connected"></i> NextTech — Operaciones
    </a>
    <div class="d-flex align-items-center gap-2">
      <span id="user-role" class="badge bg-secondary">OPERACIONES</span>
      <button class="btn btn-outline-light btn-sm" onclick="logout()"><i class="bi bi-box-arrow-right me-1"></i> Salir</button>
    </div>
  </div>
</header>

<main class="container py-4 flex-grow-1">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h1 class="h3 mb-0 nt-title">OPERACIONES • Dashboard</h1>
    <small class="text-body-secondary">Accesos a módulos operativos.</small>
  </div>

  <div class="row g-3">
    <!-- Inventario y movimientos -->
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="inventario.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-archive fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Inventario</h5></div>
          <p class="card-text text-body-secondary small">Stock, kardex y alertas.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="ajustes.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-sliders fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Ajustes</h5></div>
          <p class="card-text text-body-secondary small">Correcciones de inventario.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="transferencias.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-arrow-left-right fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Transferencias</h5></div>
          <p class="card-text text-body-secondary small">Movimientos entre bodegas.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>

    <!-- Compras/Ventas/Devoluciones/Proveedores -->
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="compras.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-bag-check fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Compras</h5></div>
          <p class="card-text text-body-secondary small">Órdenes y recepción.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="ventas.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-cash-coin fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Ventas</h5></div>
          <p class="card-text text-body-secondary small">Facturación y seguimiento.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="devoluciones.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-arrow-counterclockwise fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Devoluciones</h5></div>
          <p class="card-text text-body-secondary small">Ingresos por devolución.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="proveedores.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-truck fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Proveedores</h5></div>
          <p class="card-text text-body-secondary small">ABM de proveedores.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="cotizaciones.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-calendar-check fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Cotizaciones</h5></div>
          <p class="card-text text-body-secondary small">Ingresos por cotizaciones.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="clientes.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-person-badge fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Clientes</h5></div>
          <p class="card-text text-body-secondary small">Manejo de Clientes</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <!-- Catálogos de producto -->
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="bodegas.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-buildings fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Bodegas</h5></div>
          <p class="card-text text-body-secondary small">Gestión de almacenes.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="categorias.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-diagram-3 fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Categorías</h5></div>
          <p class="card-text text-body-secondary small">Clasificación de productos.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
    <div class="col-12 col-sm-6 col-lg-4 col-xl-3">
      <a class="card nt-card text-decoration-none h-100" href="marcas.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-tags fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Marcas</h5></div>
          <p class="card-text text-body-secondary small">ABM de marcas.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
  </div>
</main>

<script>
  (function(){try{var r=(Auth.role&&Auth.role())?String(Auth.role()).toUpperCase():'OPERACIONES';document.getElementById('user-role').textContent=r;}catch(e){}})();
  function logout(){try{Auth.clear&&Auth.clear();localStorage.removeItem('nt.session');}catch(e){} location.href='index.jsp';}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
