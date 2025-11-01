<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Categorías</title>
  <meta name="api-base" content="http://localhost:8080" />

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <link rel="stylesheet" href="assets/css/base.css?v=1">
  <link rel="stylesheet" href="assets/css/app.css?v=1">

  <style>
    /* Layout a pantalla completa */
    html, body { height: 100%; }
    body.nt-bg { min-height: 100vh; display: flex; flex-direction: column; }
    main.flex-grow-1 { flex: 1 1 auto; display: flex; flex-direction: column; }

    /* Topbar */
    .nt-navbar{ background: var(--nt-surface); border-bottom: 1px solid var(--nt-border); }
    .nt-navbar .container{
      display:flex; align-items:center; justify-content:space-between;
    }

    /* Botón Regresar (derecha) */
    .nt-back {
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border); background: transparent; color: var(--nt-primary);
    }
    .nt-back:hover{ background: var(--nt-surface-2); color: var(--nt-primary); }

    /* Tarjetas / estilos extra (por consistencia) */
    .modo-card{
      border:1px solid var(--nt-border);
      background: var(--nt-surface);
      border-radius: 14px;
      padding: 1rem;
      cursor: pointer;
      transition: transform .08s ease, background .15s ease, border-color .15s ease;
      height: 100%;
    }
    .modo-card:hover{ transform: translateY(-1px); background: var(--nt-surface-2); border-color: var(--nt-border); }
    .modo-card .icon{
      width:48px;height:48px;border-radius:12px;
      display:flex;align-items:center;justify-content:center;
      background: rgba(127,90,240,.15);
      margin-bottom:.5rem;
      font-size: 1.35rem;
    }
    .modo-card h6{ color: var(--nt-primary); margin:0; }
    .modo-card p{ margin: .25rem 0 0; color: var(--nt-text); }

    .det-mini { font-size:.8rem; color: var(--nt-text); }
    .det-meta { display:flex; gap:.5rem; flex-wrap:wrap; }
    .det-meta .form-control-plaintext { padding:0; min-height:auto; }

    .legacy-producto-id{ display:none !important; }
  </style>

  <script src="assets/js/auth.guard.js"></script>
  <script>
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
  <!-- Topbar -->
  <header class="navbar nt-navbar">
    <div class="container">
      <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-bag-plus"></i> Nextech — Categorías
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <main class="py-4 flex-grow-1">
    <div class="container">
      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-diagram-3"></i> Categorías</h1>
          <p class="mb-0 nt-subtitle">Clasifica tus productos por categoría.</p>
        </div>
        <div><button id="btnOpenCreate" class="btn nt-btn-accent"><i class="bi bi-plus-circle"></i> Nueva categoría</button></div>
      </div>

      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body d-flex flex-column flex-md-row align-items-md-center gap-3">
          <div class="input-group">
            <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
            <input id="txtSearch" class="form-control" placeholder="Buscar por nombre..."/>
          </div>
          <div class="form-check form-switch ms-md-3">
            <input id="chkSoloActivas" class="form-check-input" type="checkbox" checked>
            <label for="chkSoloActivas" class="form-check-label">Solo activas</label>
          </div>
          <button id="btnBuscar" class="btn btn-outline-dark ms-md-auto"><i class="bi bi-arrow-repeat"></i> Buscar</button>
        </div>
      </div>

      <div class="card nt-card shadow-sm">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light nt-table-head">
              <tr>
                <th style="width:120px">ID</th>
                <th>Nombre</th>
                <th style="width:120px">Activo</th>
                <th class="text-end" style="width:220px">Acciones</th>
              </tr>
            </thead>
            <tbody id="tblCategorias"><!-- filas JS --></tbody>
          </table>
        </div>
        <div class="card-footer d-flex justify-content-between align-items-center">
          <div id="lblResumen" class="small text-muted">0 resultados</div>
          <ul id="paginacion" class="pagination pagination-sm mb-0"><!-- paginado JS --></ul>
        </div>
      </div>
    </div>
  </main>

  <!-- Upsert -->
  <div class="modal fade" id="mdlUpsert" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-md modal-dialog-scrollable">
      <form id="frmUpsert" class="modal-content needs-validation" novalidate>
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title" id="mdlUpsertTitle"><i class="bi bi-pencil-square"></i> Categoría</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="cat_id"/>
          <div class="row g-3">
            <div class="col-12">
              <label class="form-label">Nombre *</label>
              <input id="cat_nombre" class="form-control" required maxlength="100" placeholder="Ej. Laptops, Accesorios...">
              <div class="invalid-feedback">El nombre es obligatorio.</div>
            </div>
            <div class="col-12 d-flex align-items-center justify-content-between">
              <div class="form-check form-switch">
                <input id="cat_activo" type="checkbox" class="form-check-input" checked>
                <label class="form-check-label">Activo</label>
              </div>
              <small class="text-muted">Se ocultarán si filtras solo activas.</small>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btnSave" type="submit" class="btn nt-btn-accent"><i class="bi bi-check2-circle"></i> Guardar</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Ver -->
  <div class="modal fade" id="mdlView" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-eye"></i> Detalle de categoría</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <dl id="viewContent" class="row mb-0"><!-- via JS --></dl>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Eliminar -->
  <div class="modal fade" id="mdlDelete" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content border-0">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-exclamation-triangle"></i> Confirmar</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          ¿Deseas eliminar la categoría <span id="delNombre" class="fw-bold"></span>?
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btnConfirmDelete" class="btn btn-danger"><i class="bi bi-trash"></i> Eliminar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/categorias.js?v=1"></script>
</body>
</html>
