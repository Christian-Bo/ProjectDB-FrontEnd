<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>NextTech — RRHH</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Base del backend -->
  <meta name="api-base" content="http://localhost:8080"/>

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema NextTech -->
  <link rel="stylesheet" href="assets/css/base.css?v=1">
  <link rel="stylesheet" href="assets/css/app.css?v=1">

  <style>
    /* Layout base */
    html, body { height: 100%; }
    body.nt-bg { min-height: 100vh; display: flex; flex-direction: column; }
    main.flex-grow-1 { flex: 1 1 auto; display: flex; flex-direction: column; }

    /* Topbar unificada */
    .nt-navbar{
      background: var(--nt-surface-1);
      border-bottom: 1px solid var(--nt-border);
    }
    .nt-navbar .navbar-brand{ color: var(--nt-fg-strong); }
    .nt-navbar .container-fluid{
      display:flex; align-items:center; justify-content:space-between;
      min-height: 56px;
    }

    /* Botón Regresar (estándar del proyecto) */
    .nt-back{
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border);
      background: transparent; color: var(--nt-primary);
    }
    .nt-back:hover{ background: var(--nt-surface-2); color: var(--nt-primary); }

    /* Tabs estilo NextTech (pills planas) */
    .nt-pills .nav-link{
      border:1px solid var(--nt-border);
      background:var(--nt-surface-1);
      color:var(--nt-fg);
      margin-right:.5rem;
      border-radius:.75rem;
    }
    .nt-pills .nav-link:hover{ background:var(--nt-surface-2); }
    .nt-pills .nav-link.active{
      background:var(--nt-accent); color:#fff; border-color:transparent;
      box-shadow:0 6px 16px rgba(0,0,0,.25);
    }

    /* Tarjetas/Tablas/KPIs */
    .nt-card{
      background: var(--nt-surface-1);
      border:1px solid var(--nt-border);
      border-radius: 1rem;
      padding: .75rem;           /* un poco de aire interno */
    }
    .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-fg); }

    .nt-kpi{
      text-align:center; padding:1rem; border-radius:.75rem;
      background: var(--nt-surface-1); border:1px solid var(--nt-border);
    }
    .nt-kpi h2{ color: var(--nt-primary); margin: 0; }
    .nt-kpi p { margin: 0; color: var(--nt-fg); opacity: .85; }

    /* ========= NUEVO: separaciones suaves ========= */
    /* Cuando hay controles/filtros arriba y una tabla abajo dentro de la misma card */
    .nt-card .btn-toolbar,
    .nt-card .nt-toolbar,
    .nt-card .row,
    .nt-card .card-header { margin-bottom: .75rem; }

    /* Si viene la tabla inmediatamente, darle aire */
    .nt-card .table { margin-top: .75rem; }

    /* Paginadores/footers también con aire arriba */
    .nt-card .pagination,
    .nt-card .card-footer { margin-top: .75rem; }

    /* Un poco más de separación bajo las tabs */
    #rrhhTabs { margin-bottom: 1rem; }
  </style>

  <script src="assets/js/auth.guard.js"></script>
  <script>
    // Protección de acceso (RRHH o ADMIN)
    window.addEventListener('DOMContentLoaded', () => {
      Auth?.ensure?.(['RRHH','ADMIN']);
    });

    // Helpers de navegación (mismo patrón del proyecto)
    function parseAuthUser(){
      try{
        if (window.Auth?.user) return window.Auth.user;
        const raw = localStorage.getItem('auth_user');
        return raw ? JSON.parse(raw) : null;
      }catch(_){ return null; }
    }
    function homeForRole(role){
      const map = {
        'ADMIN':'dashboard_admin.jsp',
        'FINANZAS':'dashboard_finanzas.jsp',
        'AUDITOR':'dashboard_auditor.jsp',
        'RRHH':'dashboard_rrhh.jsp',
        'OPERACIONES':'dashboard_operaciones.jsp',
        'OPERADOR':'dashboard_operaciones.jsp'
      };
      return map[(role||'').toUpperCase()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1) { history.back(); return; }
      const user = parseAuthUser();
      location.href = homeForRole(user?.role || user?.rol);
    }
  </script>
</head>
<body class="nt-bg">

  <!-- Topbar: marca a la izquierda, REGRESAR a la derecha -->
  <header class="navbar nt-navbar">
    <div class="container-fluid">
      <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-people"></i> NextTech — RRHH
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <!-- Contenido -->
  <main class="py-4 flex-grow-1">
    <div class="container-fluid">

      <!-- Tabs (pills moradas) -->
      <ul class="nav nt-pills mb-3" id="rrhhTabs" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-empleados" type="button" role="tab">
            <i class="bi bi-person-badge"></i> Empleados
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-puestos" type="button" role="tab">
            <i class="bi bi-diagram-3"></i> Puestos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-deptos" type="button" role="tab">
            <i class="bi bi-building"></i> Departamentos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-usuarios" type="button" role="tab">
            <i class="bi bi-people"></i> Usuarios
          </button>
        </li>
      </ul>

      <div class="tab-content">

        <!-- EMPLEADOS -->
        <div id="tab-empleados" class="tab-pane fade show active" role="tabpanel">
          <div class="row g-3 mb-3">
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Total empleados</p><h2 id="kpiEmpTotal">—</h2></div></div>
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Activos</p><h2 id="kpiEmpActivos">—</h2></div></div>
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Inactivos</p><h2 id="kpiEmpInactivos">—</h2></div></div>
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Suspendidos</p><h2 id="kpiEmpSuspendidos">—</h2></div></div>
          </div>
          <div class="card nt-card">
            <jsp:include page="empleados.jsp" />
          </div>
        </div>

        <!-- PUESTOS -->
        <div id="tab-puestos" class="tab-pane fade" role="tabpanel">
          <div class="row g-3 mb-3">
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Puestos</p><h2 id="kpiPuestosTotal">—</h2></div></div>
          </div>
          <div class="card nt-card">
            <jsp:include page="puestos.jsp" />
          </div>
        </div>

        <!-- DEPARTAMENTOS -->
        <div id="tab-deptos" class="tab-pane fade" role="tabpanel">
          <div class="row g-3 mb-3">
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Departamentos</p><h2 id="kpiDeptoTotal">—</h2></div></div>
          </div>
          <div class="card nt-card">
            <jsp:include page="departamentos.jsp" />
          </div>
        </div>

        <!-- USUARIOS -->
        <div id="tab-usuarios" class="tab-pane fade" role="tabpanel">
          <div class="card nt-card">
            <jsp:include page="usuarios.jsp" />
          </div>
        </div>

      </div>
    </div>
  </main>

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS bundle al final -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Inyector Authorization / API y utilidades -->
  <script src="assets/js/common.api.js?v=99"></script>
  <script src="assets/js/common_recursos.js?v=2"></script>

  <!-- Módulos (los tuyos) -->
  <script src="assets/js/empleados.js"></script>
  <script src="assets/js/puestos.js"></script>
  <script src="assets/js/departamentos.js"></script>
  <script src="assets/js/usuarios.js"></script>

  <!-- Arranque -->
  <script src="assets/js/init.js"></script>
</body>
</html>
