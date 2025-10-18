<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>NextTech · RRHH</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- IMPORTANTE: Base del backend -->
  <meta name="api-base" content="http://localhost:8080"/>

  <!-- Bootstrap 5 -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <!-- Tema oscuro base -->
  <link rel="stylesheet" href="assets/css/base.css">

  <style>
    .nt-fullpane { min-height: calc(100vh - 70px); padding-top: 1rem; padding-bottom: 2rem; }
    .nt-toolbar { gap: .5rem; }
    .nt-kpi { text-align:center; padding:1rem; border-radius:.75rem; }
    .nt-kpi h2 { color: var(--nt-primary); margin:0; }
    .nt-kpi p { margin:0; color: var(--nt-text); }
    .nt-divider { border-top:1px solid var(--nt-border); margin:1rem 0 1.5rem; }
    .table thead th.sticky { position: sticky; top: 0; z-index: 2; }
    .pagination .page-link { background: var(--nt-surface); border-color: var(--nt-border-soft); color: var(--nt-primary); }
    .pagination .page-item.active .page-link { background: var(--nt-accent); border-color: var(--nt-accent); }
  </style>
</head>
<body class="nt-bg">

  <!-- Navbar -->
  <nav class="navbar navbar-expand-lg nt-navbar">
    <div class="container-fluid">
      <a class="navbar-brand fw-semibold" href="#">NextTech · RRHH</a>
      <div class="d-flex align-items-center">
        <span id="loginUser" class="me-3 text-muted small"></span>
        <button id="btnLogout" class="btn btn-outline-secondary btn-sm">Salir</button>
      </div>
    </div>
  </nav>

  <div class="container-fluid mt-3">
    <!-- Tabs -->
    <ul class="nav nav-tabs" id="rrhhTabs" role="tablist">
      <li class="nav-item" role="presentation">
        <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-empleados" type="button" role="tab">Empleados</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-puestos" type="button" role="tab">Puestos</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-deptos" type="button" role="tab">Departamentos</button>
      </li>
      <li class="nav-item" role="presentation">
        <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-usuarios" type="button" role="tab">Usuarios</button>
      </li>
    </ul>

    <div class="tab-content">
      <div id="tab-empleados" class="tab-pane fade show active nt-fullpane" role="tabpanel">
        <div class="row g-3 mb-2">
          <div class="col-6 col-lg-3"><div class="card nt-kpi"><p>Total empleados</p><h2 id="kpiEmpTotal">—</h2></div></div>
          <div class="col-6 col-lg-3"><div class="card nt-kpi"><p>Activos</p><h2 id="kpiEmpActivos">—</h2></div></div>
          <div class="col-6 col-lg-3"><div class="card nt-kpi"><p>Inactivos</p><h2 id="kpiEmpInactivos">—</h2></div></div>
          <div class="col-6 col-lg-3"><div class="card nt-kpi"><p>Suspendidos</p><h2 id="kpiEmpSuspendidos">—</h2></div></div>
        </div>
        <jsp:include page="empleados.jsp" />
      </div>

      <div id="tab-puestos" class="tab-pane fade nt-fullpane" role="tabpanel">
        <div class="row g-3 mb-2">
          <div class="col-6 col-lg-3"><div class="card nt-kpi"><p>Puestos</p><h2 id="kpiPuestosTotal">—</h2></div></div>
        </div>
        <jsp:include page="puestos.jsp" />
      </div>

      <div id="tab-deptos" class="tab-pane fade nt-fullpane" role="tabpanel">
        <div class="row g-3 mb-2">
          <div class="col-6 col-lg-3"><div class="card nt-kpi"><p>Departamentos</p><h2 id="kpiDeptoTotal">—</h2></div></div>
        </div>
        <jsp:include page="departamentos.jsp" />
      </div>

      <div id="tab-usuarios" class="tab-pane fade nt-fullpane" role="tabpanel">
        <jsp:include page="usuarios.jsp" />
      </div>
    </div>
  </div>

  <!-- Toasts -->
  <div class="position-fixed bottom-0 end-0 p-3" style="z-index:1100">
    <div id="ntToast" class="toast nt-toast-info" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="toast-header">
        <strong class="me-auto" id="toastTitle">Info</strong>
        <small id="toastTime"></small>
        <button type="button" class="btn-close btn-close-white ms-2 mb-1" data-bs-dismiss="toast"></button>
      </div>
      <div class="toast-body" id="toastBody">…</div>
    </div>
  </div>

  <!-- Bootstrap bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- ✅ Carga primero el common que inyecta Authorization -->
  <script src="assets/js/common.api.js?v=99"></script>

  <!-- JS comunes del módulo RRHH -->
  <script src="assets/js/common_recursos.js?v=2"></script>

  <!-- Módulos -->
  <script src="assets/js/empleados.js"></script>
  <script src="assets/js/puestos.js"></script>
  <script src="assets/js/departamentos.js"></script>
  <script src="assets/js/usuarios.js"></script>

  <!-- Arranque -->
  <script src="assets/js/init.js"></script>
</body>
</html>
