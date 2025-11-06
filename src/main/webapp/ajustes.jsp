<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Ajustes de Inventario</title>

  <!-- Base del backend -->
  <meta name="api-base" content="http://localhost:8080" />

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos NextTech -->
  <link rel="stylesheet" href="assets/css/base.css">
  <link rel="stylesheet" href="assets/css/app.css">

  <style>
    /* Layout base */
    html, body { height: 100%; }
    body.nt-bg { min-height: 100vh; display: flex; flex-direction: column; }
    main.flex-grow-1 { flex: 1 1 auto; display: flex; flex-direction: column; }

    /* Topbar unificada (igual al resto del sistema) */
    .nt-navbar{
      background: var(--nt-surface-1);
      border-bottom: 1px solid var(--nt-border);
    }
    .nt-navbar .navbar-brand{ color: var(--nt-fg-strong); }
    .nt-navbar .container-fluid{
      display:flex; align-items:center; justify-content:space-between;
      min-height: 56px;
    }

    /* Botón Regresar estándar */
    .nt-back{
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border);
      background: transparent; color: var(--nt-primary);
    }
    .nt-back:hover{ background: var(--nt-surface-2); color: var(--nt-primary); }

    /* Tarjetas/Tabla */
    .nt-card{
      background: var(--nt-surface-1);
      border:1px solid var(--nt-border);
      border-radius: 1rem;
    }
    .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-fg); }

    /* Separaciones suaves dentro de cards */
    .nt-card .row,
    .nt-card .btn-toolbar,
    .nt-card .card-header { margin-bottom: .75rem; }
    .nt-card .table { margin-top: .5rem; }
    .nt-card .card-footer, .nt-card .pagination { margin-top: .75rem; }
  </style>

  <script src="assets/js/auth.guard.js"></script>
  <script>
    // Helpers de navegación (como en las demás pantallas)
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

  <!-- Topbar: marca a la izquierda y REGRESAR a la derecha (sin chip ni botón Salir) -->
  <header class="navbar nt-navbar">
    <div class="container-fluid">
      <a class="navbar-brand d-flex align-items-center gap-2 fw-bold">
        <i class="bi bi-sliders"></i> NextTech — Ajustes de Inventario
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
      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-sliders"></i> Ajustes de Inventario</h1>
          <p class="mb-0 nt-subtitle">Correcciones y ajustes de cantidades en inventario.</p>
        </div>
        <div>
          <button id="btnNuevoAjuste" class="btn nt-btn-accent">
            <i class="bi bi-plus-circle"></i> Nuevo Ajuste
          </button>
        </div>
      </div>

      <!-- Filtros -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body d-flex flex-column flex-md-row align-items-md-center gap-3">
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Bodega</label>
            <select id="filtroBodega" class="form-select">
              <option value="">Todas</option>
            </select>
          </div>
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Tipo de Ajuste</label>
            <select id="filtroTipo" class="form-select">
              <option value="">Todos</option>
              <option value="I">Incremento</option>
              <option value="D">Decremento</option>
              <option value="C">Corrección</option>
            </select>
          </div>
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Fecha Desde</label>
            <input id="filtroFechaDesde" type="date" class="form-control"/>
          </div>
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Fecha Hasta</label>
            <input id="filtroFechaHasta" type="date" class="form-control"/>
          </div>
          <div class="align-self-end">
            <button id="btnBuscar" class="btn btn-primary">
              <i class="bi bi-search"></i> Buscar
            </button>
          </div>
        </div>
      </div>

      <!-- Tabla -->
      <div class="card nt-card shadow-sm">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light nt-table-head">
              <tr>
                <th>Número</th>
                <th>Fecha</th>
                <th>Bodega</th>
                <th>Tipo</th>
                <th>Motivo</th>
                <th>Responsable</th>
                <th>Observaciones</th>
                <th class="text-end">Acciones</th>
              </tr>
            </thead>
            <tbody id="tblAjustes">
              <tr>
                <td colspan="8" class="text-center py-4">
                  <div class="spinner-border text-primary" role="status"></div>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="card-footer">
          <div id="lblResumen" class="small text-muted">Cargando...</div>
        </div>
      </div>
    </div>
  </main>

  <!-- MODAL: Ver Detalle -->
  <div class="modal fade" id="mdlDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl">
      <div class="modal-content nt-card">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-eye"></i> Detalle del Ajuste</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <!-- Información de cabecera -->
          <div class="row mb-4">
            <div class="col-md-6">
              <h6 class="text-muted">Información General</h6>
              <dl class="row small">
                <dt class="col-sm-5">Número:</dt>
                <dd class="col-sm-7" id="detNumero">-</dd>
                <dt class="col-sm-5">Fecha:</dt>
                <dd class="col-sm-7" id="detFecha">-</dd>
                <dt class="col-sm-5">Tipo:</dt>
                <dd class="col-sm-7" id="detTipo">-</dd>
                <dt class="col-sm-5">Bodega:</dt>
                <dd class="col-sm-7" id="detBodega">-</dd>
              </dl>
            </div>
            <div class="col-md-6">
              <h6 class="text-muted">Detalles</h6>
              <dl class="row small">
                <dt class="col-sm-5">Motivo:</dt>
                <dd class="col-sm-7" id="detMotivo">-</dd>
                <dt class="col-sm-5">Responsable:</dt>
                <dd class="col-sm-7" id="detResponsable">-</dd>
                <dt class="col-sm-5">Observaciones:</dt>
                <dd class="col-sm-7" id="detObservaciones">-</dd>
              </dl>
            </div>
          </div>

          <!-- Productos -->
          <h6 class="text-muted mb-3">Productos Ajustados</h6>
          <div class="table-responsive">
            <table class="table table-sm table-bordered">
              <thead class="table-light">
                <tr>
                  <th>Código</th>
                  <th>Producto</th>
                  <th>Cant. Antes</th>
                  <th>Ajuste</th>
                  <th>Cant. Después</th>
                  <th>Costo Unit.</th>
                </tr>
              </thead>
              <tbody id="tblDetalleProductos">
                <tr><td colspan="6" class="text-center">Cargando...</td></tr>
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

  <!-- MODAL: Crear Ajuste -->
  <div class="modal fade" id="mdlCrear" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <form id="frmCrear" class="modal-content needs-validation" novalidate>
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-plus-circle"></i> Nuevo Ajuste de Inventario</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3 mb-3">
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
              <label class="form-label">Responsable (Empleado ID) *</label>
              <input id="crear_responsable" type="number" class="form-control" value="1" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Bodega *</label>
              <select id="crear_bodega" class="form-select" required>
                <option value="">Seleccione...</option>
              </select>
              <div class="invalid-feedback">Seleccione una bodega</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Tipo de Ajuste *</label>
              <select id="crear_tipo" class="form-select" required>
                <option value="">Seleccione...</option>
                <option value="I">Incremento (+)</option>
                <option value="D">Decremento (-)</option>
                <option value="C">Corrección</option>
              </select>
              <div class="invalid-feedback">Seleccione un tipo</div>
            </div>
            <div class="col-12">
              <label class="form-label">Motivo *</label>
              <input id="crear_motivo" class="form-control" required>
              <div class="invalid-feedback">El motivo es requerido</div>
            </div>
            <div class="col-12">
              <label class="form-label">Observaciones</label>
              <textarea id="crear_observaciones" class="form-control" rows="2"></textarea>
            </div>
          </div>

          <h6 class="mb-3">Productos a Ajustar</h6>
          <div id="productosContainer">
            <div class="producto-item row g-2 mb-2">
              <div class="col-md-2">
                <input type="number" class="form-control producto-id" placeholder="ID Producto" required>
              </div>
              <div class="col-md-5">
                <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
              </div>
              <div class="col-md-2">
                <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" required>
              </div>
              <div class="col-md-3">
                <input type="number" step="0.01" class="form-control producto-costo" placeholder="Costo" required>
              </div>
            </div>
          </div>
          <button type="button" id="btnAgregarProducto" class="btn btn-sm btn-outline-primary mt-2">
            <i class="bi bi-plus"></i> Agregar Producto
          </button>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button type="submit" class="btn nt-btn-accent">
            <i class="bi bi-check2-circle"></i> Crear Ajuste
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.js"></script>
  <script src="assets/js/ajustes.js"></script>
</body>
</html>
