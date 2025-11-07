<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech — Transferencias</title>

  <!-- Base del backend -->
  <meta name="api-base" content="https://nexttech-backend-jw9h.onrender.com">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta / tema -->
  <link rel="stylesheet" href="assets/css/base.css?v=13">
  <link rel="stylesheet" href="assets/css/app.css?v=13">

  <style>
    body.nt-bg { background: var(--nt-bg); color: var(--nt-fg); }
    .nt-navbar { background: var(--nt-surface-1); border-bottom: 1px solid var(--nt-border); }
    .nt-title { color: var(--nt-fg-strong); }
    .nt-subtitle { color: var(--nt-fg-muted); }
    .nt-card { background: var(--nt-surface-1); border: 1px solid var(--nt-border); border-radius: 1rem; }
    .nt-card:hover { transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.25); transition: .12s; }
    .nt-table-head { background: var(--nt-surface-2); color: var(--nt-fg); }
    .nt-btn-accent { background: var(--nt-accent); color:#fff; border:none; }
    .nt-btn-accent:hover { filter: brightness(.95); }
    .nt-back { display:inline-flex; align-items:center; gap:.5rem; border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary); }
    .nt-back:hover { background:var(--nt-surface-2); }
    .nt-modal-header{ background: var(--nt-surface-2); border-bottom: 1px solid var(--nt-border); }

    /* ===== FIX MODAL TRANSPARENTE ===== */
    /* fondo del contenido del modal SIEMPRE sólido */
    .modal-content {
      background-color: var(--nt-surface-1) !important;
      border: 1px solid var(--nt-border);
      border-radius: 1rem;
      box-shadow: 0 24px 48px rgba(0,0,0,.45);
    }
    /* header del modal con mismo tema */
    .modal-content .modal-header {
      background: var(--nt-surface-2);
      border-bottom: 1px solid var(--nt-border);
    }
    /* cuando la card está dentro de un modal, no hagas "hover lift" */
    .modal .nt-card:hover { transform:none; box-shadow:none; border-color:var(--nt-border); }
    /* backdrop más oscuro */
    .modal-backdrop.show { opacity: .6 !important; }

    /* corrige scroll visual en modal-xl + tabla */
    .modal-dialog-scrollable .modal-body {
      background: var(--nt-surface-1);
    }
  </style>
</head>

<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header con botón Regresar -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2">
        <i class="bi bi-arrow-left-right"></i> NextTech — Transferencias
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <main class="py-4">
    <div class="container">

      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h4 nt-title mb-1"><i class="bi bi-arrow-left-right"></i> Transferencias entre bodegas</h1>
          <div class="nt-subtitle">Listado, creación y consulta de traslados.</div>
        </div>
        <button id="btnNuevaTransferencia" class="btn nt-btn-accent">
          <i class="bi bi-plus-circle"></i> Nueva transferencia
        </button>
      </div>

      <!-- Filtros -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body">
          <div class="row g-3 align-items-end">
            <div class="col-md-4">
              <label class="form-label">Bodega Origen</label>
              <select id="filtroBodegaOrigen" class="form-select">
                <option value="">Todas</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">Bodega Destino</label>
              <select id="filtroBodegaDestino" class="form-select">
                <option value="">Todas</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Estado</label>
              <select id="filtroEstado" class="form-select">
                <option value="">Todos</option>
                <option value="P">Pendiente</option>
                <option value="E">Enviada</option>
                <option value="R">Recibida</option>
                <option value="C">Cancelada</option>
              </select>
            </div>
            <div class="col-md-1 text-md-end">
              <button id="btnBuscar" class="btn btn-outline-secondary w-100"><i class="bi bi-search"></i></button>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabla -->
      <div class="card nt-card shadow-sm">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="nt-table-head">
              <tr>
                <th>Número</th>
                <th>Fecha</th>
                <th>Origen</th>
                <th>Destino</th>
                <th>Estado</th>
                <th>F. Envío</th>
                <th>F. Recepción</th>
                <th>Obs.</th>
                <th class="text-end">Acciones</th>
              </tr>
            </thead>
            <tbody id="tblTransferencias">
              <tr><td colspan="9" class="text-center py-4"><div class="spinner-border"></div></td></tr>
            </tbody>
          </table>
        </div>
        <div class="card-footer small text-muted" id="lblResumen">Cargando…</div>
      </div>
    </div>
  </main>

  <!-- Modal Detalle -->
  <div class="modal fade" id="mdlDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
      <div class="modal-content nt-card">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-eye"></i> Detalle de transferencia</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row mb-3">
            <div class="col-md-6">
              <dl class="row small mb-0">
                <dt class="col-sm-4">Número:</dt><dd class="col-sm-8" id="detNumero">-</dd>
                <dt class="col-sm-4">Fecha:</dt><dd class="col-sm-8" id="detFecha">-</dd>
                <dt class="col-sm-4">Estado:</dt><dd class="col-sm-8" id="detEstado">-</dd>
              </dl>
            </div>
            <div class="col-md-6">
              <dl class="row small mb-0">
                <dt class="col-sm-4">Origen:</dt><dd class="col-sm-8" id="detOrigen">-</dd>
                <dt class="col-sm-4">Destino:</dt><dd class="col-sm-8" id="detDestino">-</dd>
                <dt class="col-sm-4">Observaciones:</dt><dd class="col-sm-8" id="detObservaciones">-</dd>
              </dl>
            </div>
          </div>

          <h6 class="text-muted mt-3">Productos</h6>
          <div class="table-responsive">
            <table class="table table-sm table-bordered mb-0">
              <thead class="nt-table-head">
                <tr>
                  <th>Código</th>
                  <th>Producto</th>
                  <th>Solicitada</th>
                  <th>Enviada</th>
                  <th>Recibida</th>
                </tr>
              </thead>
              <tbody id="tblDetalleProductos">
                <tr><td colspan="5" class="text-center">Cargando…</td></tr>
              </tbody>
            </table>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal Crear -->
  <div class="modal fade" id="mdlCrear" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <form id="frmCrear" class="modal-content nt-card needs-validation" novalidate>
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-plus-circle"></i> Nueva transferencia</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Número *</label>
              <input id="crear_numero" class="form-control" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Fecha *</label>
              <input id="crear_fecha" type="date" class="form-control" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Solicitado por (Empleado ID) *</label>
              <input id="crear_solicitado" type="number" class="form-control" value="1" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Bodega Origen *</label>
              <select id="crear_bodega_origen" class="form-select" required>
                <option value="">Seleccione…</option>
              </select>
              <div class="invalid-feedback">Seleccione una bodega</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Bodega Destino *</label>
              <select id="crear_bodega_destino" class="form-select" required>
                <option value="">Seleccione…</option>
              </select>
              <div class="invalid-feedback">Seleccione una bodega</div>
            </div>
            <div class="col-12">
              <label class="form-label">Observaciones</label>
              <textarea id="crear_observaciones" class="form-control" rows="2"></textarea>
            </div>
          </div>

          <hr>

          <h6 class="mb-2">Productos a transferir</h6>
          <div id="productosContainer">
            <div class="producto-item row g-2 mb-2">
              <div class="col-md-3">
                <input type="number" class="form-control producto-id" placeholder="Producto ID" required>
                <div class="invalid-feedback">Requerido</div>
              </div>
              <div class="col-md-7">
                <input type="text" class="form-control" placeholder="Nombre (opcional)" disabled>
              </div>
              <div class="col-md-2">
                <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" min="1" required>
                <div class="invalid-feedback">Mínimo 1</div>
              </div>
            </div>
          </div>
          <button type="button" id="btnAgregarProducto" class="btn btn-sm btn-outline-primary mt-2">
            <i class="bi bi-plus"></i> Agregar producto
          </button>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button type="submit" class="btn nt-btn-accent"><i class="bi bi-check2-circle"></i> Crear</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Toast unificado -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="appToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="toastMsg">Listo.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast"></button>
      </div>
    </div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.js?v=19"></script>

  <!-- Helpers navegación -->
  <script>
    (function(){
      try{
        window.API = window.API || {};
        if (!API.baseUrl || !API.baseUrl.trim()) {
          const meta = document.querySelector('meta[name="api-base"]');
          const base = (window.API_BASE || meta?.getAttribute('content') || '').trim();
          if (base) API.baseUrl = base;
        }
        console.log('[transferencias.jsp] API.baseUrl =', API.baseUrl || '(vacío)');
      }catch(_){}
    })();

    function parseAuthUser(){
      try{
        if (window.Auth?.user) return window.Auth.user;
        const raw = localStorage.getItem('auth_user');
        return raw ? JSON.parse(raw) : null;
      }catch(_){ return null; }
    }
    function homeForRole(role){
      const HOME_BY_ROLE = { 'ADMIN': 'Dashboard.jsp', 'OPERADOR': 'dashboard_operador.jsp', 'RRHH': 'rrhh-dashboard.jsp' };
      return HOME_BY_ROLE[role?.toUpperCase?.()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1) { history.back(); return; }
      const user = parseAuthUser();
      location.href = homeForRole(user?.role || user?.rol);
    }
  </script>

  <!-- Lógica de transferencias -->
  <script src="assets/js/transferencias.js?v=18"></script>
</body>
</html>
