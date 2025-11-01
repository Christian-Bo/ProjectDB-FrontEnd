<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>RRHH Dashboard • NextTech</title>

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
<script>Auth.ensure(['RRHH']);</script>

<header class="navbar nt-navbar">
  <div class="container d-flex align-items-center justify-content-between">
    <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="Dashboard.jsp">
      <i class="bi bi-people"></i> NextTech — RRHH
    </a>
    <div class="d-flex align-items-center gap-2">
      <span id="user-role" class="badge bg-secondary">RRHH</span>
      <button class="btn btn-outline-light btn-sm" onclick="logout()"><i class="bi bi-box-arrow-right me-1"></i> Salir</button>
    </div>
  </div>
</header>

<main class="container py-4 flex-grow-1">
  <div class="d-flex align-items-center justify-content-between flex-wrap gap-2 mb-3">
    <h1 class="h3 mb-0 nt-title">RRHH • Dashboard</h1>
    <small class="text-body-secondary">Empleados, puestos, departamentos y usuarios.</small>
  </div>

  <div class="row g-3">
    <div class="col-12 col-sm-6 col-lg-4">
      <a class="card nt-card text-decoration-none h-100" href="rrhh-dashboard.jsp">
        <div class="card-body">
          <div class="d-flex align-items-center mb-2"><i class="bi bi-layout-text-sidebar fs-3 me-2"></i><h5 class="card-title mb-0 nt-title">Panel RRHH</h5></div>
          <p class="card-text text-body-secondary small">Empleados / Puestos / Departamentos / Usuarios.</p>
          <span class="badge bg-outline">Acceso</span>
        </div>
      </a>
    </div>
</main>

<script>
  (function(){try{var r=(Auth.role&&Auth.role())?String(Auth.role()).toUpperCase():'RRHH';document.getElementById('user-role').textContent=r;}catch(e){}})();
  function logout(){try{Auth.clear&&Auth.clear();localStorage.removeItem('nt.session');}catch(e){} location.href='index.jsp';}
</script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
