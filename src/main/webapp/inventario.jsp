<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Inventario</title>

  <meta name="api-base" content="https://nexttech-backend-jw9h.onrender.com">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos comunes -->
  <link rel="stylesheet" href="assets/css/base.css?v=13">
  <link rel="stylesheet" href="assets/css/app.css?v=13">

  <style>
    /* Topbar y tipografía NextTech */
    .nt-topbar{background:var(--nt-surface-1);border-bottom:1px solid var(--nt-border);}
    .nt-title{color:var(--nt-fg-strong);}
    .nt-subtitle{color:var(--nt-fg-muted);}
    .nt-card{background:var(--nt-surface-1);border:1px solid var(--nt-border);border-radius:1rem;transition:.12s;}
    .nt-card:hover{transform:translateY(-1px);border-color:var(--nt-accent);box-shadow:0 10px 24px rgba(0,0,0,.35);}
    .nt-table-head{background:var(--nt-surface-2);color:var(--nt-fg);}
    .nt-back{display:inline-flex;align-items:center;gap:.5rem;border:1px solid var(--nt-border);background:transparent;color:var(--nt-primary);}
    .nt-back:hover{background:var(--nt-surface-2);}

    /* Tabs estilo NextTech (pills planas) */
    .nt-pills .nav-link{
      border:1px solid var(--nt-border);
      background:var(--nt-surface-1);
      color:var(--nt-fg);
      margin-right:.5rem;
      border-radius:.75rem;
    }
    .nt-pills .nav-link:hover{background:var(--nt-surface-2);}
    .nt-pills .nav-link.active{
      background:var(--nt-accent); color:#fff; border-color:transparent;
      box-shadow:0 6px 16px rgba(0,0,0,.25);
    }

    /* Mensajes de tabla */
    .nt-empty{color:var(--nt-fg-muted);}
    .nt-error{color:#ff6b6b;}
  </style>

  <script src="assets/js/auth.guard.js"></script>
  <script>
    // Roles permitidos y chip de rol
    window.addEventListener('DOMContentLoaded', () => {
      Auth?.ensure?.(['OPERACIONES','ADMIN','FINANZAS','AUDITOR']);
      const role = (Auth.role?.() || '').toUpperCase();
      const chip = document.getElementById('roleChip');
      if(chip){ chip.textContent = role || 'MÓDULO'; }
    });

    // Botón Regresar inteligente por rol
    function parseAuthUser(){
      try{
        if (window.Auth?.user) return window.Auth.user;
        const raw = localStorage.getItem('auth_user');
        return raw ? JSON.parse(raw) : null;
      }catch(_){ return null; }
    }
    function homeForRole(role){
      const HOME_BY_ROLE = {
        'ADMIN': 'Dashboard.jsp',
        'OPERADOR': 'dashboard_operador.jsp',
        'FINANZAS': 'dashboard_finanzas.jsp',
        'AUDITOR': 'dashboard_auditor.jsp',
        'RRHH': 'rrhh-dashboard.jsp'
      };
      return HOME_BY_ROLE[role?.toUpperCase?.()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1) { history.back(); return; }
      const user = parseAuthUser();
      location.href = homeForRole(user?.role || user?.rol);
    }
  </script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">
  <!-- Topbar minimal -->
  <div class="nt-topbar py-2">
    <div class="container-fluid d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2">
        <i class="bi bi-box-seam"></i> NextTech — Inventario
      </a>
      <div class="d-flex align-items-center gap-2">
        <span class="badge text-bg-secondary" id="roleChip">MÓDULO</span>
        <button class="btn btn-sm nt-back" onclick="goBack()">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </div>

  <!-- Contenido -->
  <main class="py-4">
    <div class="container-fluid">
      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-box-seam"></i> Control de Inventario</h1>
          <p class="mb-0 nt-subtitle">Gestión de stock, movimientos y alertas.</p>
        </div>
      </div>

      <!-- Tabs de Navegación -->
      <ul class="nav nt-pills mb-3" id="inventarioTabs" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" id="stock-tab" data-bs-toggle="tab" data-bs-target="#stock" type="button">
            <i class="bi bi-boxes"></i> Stock
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="movimientos-tab" data-bs-toggle="tab" data-bs-target="#movimientos" type="button">
            <i class="bi bi-arrow-left-right"></i> Kardex / Movimientos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="alertas-tab" data-bs-toggle="tab" data-bs-target="#alertas" type="button">
            <i class="bi bi-exclamation-triangle"></i> Alertas
          </button>
        </li>
      </ul>

      <!-- Tab Content -->
      <div class="tab-content" id="inventarioTabContent">
        
        <!-- TAB: STOCK -->
        <div class="tab-pane fade show active" id="stock" role="tabpanel">
          <!-- Filtros Stock -->
          <div class="card nt-card shadow-sm mb-3">
            <div class="card-body d-flex flex-column flex-md-row align-items-md-center gap-3">
              <div class="flex-grow-1">
                <label class="form-label small mb-1">Bodega</label>
                <select id="filtroBodegaStock" class="form-select">
                  <option value="">Todas las bodegas</option>
                </select>
              </div>
              <div class="flex-grow-1">
                <label class="form-label small mb-1">Buscar Producto</label>
                <input id="txtSearchStock" class="form-control" placeholder="Buscar por nombre o código..."/>
              </div>
              <div class="align-self-end">
                <button id="btnBuscarStock" class="btn nt-btn-accent"><i class="bi bi-search"></i> Buscar</button>
              </div>
            </div>
          </div>

          <!-- Tabla Stock -->
          <div class="card nt-card shadow-sm">
            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0">
                <thead class="nt-table-head">
                  <tr>
                    <th>Código</th>
                    <th>Producto</th>
                    <th>Bodega</th>
                    <th>Disponible</th>
                    <th>Reservada</th>
                    <th>En Tránsito</th>
                    <th>Total</th>
                    <th>Último Costo</th>
                    <th>Estado</th>
                  </tr>
                </thead>
                <tbody id="tblStock">
                  <tr><td colspan="9" class="text-center py-4"><div class="spinner-border"></div></td></tr>
                </tbody>
              </table>
            </div>
            <div class="card-footer">
              <div id="lblResumenStock" class="small text-muted">Cargando...</div>
            </div>
          </div>
        </div>

        <!-- TAB: MOVIMIENTOS -->
        <div class="tab-pane fade" id="movimientos" role="tabpanel">
          <!-- Filtros Movimientos -->
          <div class="card nt-card shadow-sm mb-3">
            <div class="card-body">
              <div class="row g-3">
                <div class="col-md-3">
                  <label class="form-label small mb-1">Bodega</label>
                  <select id="filtroBodegaMov" class="form-select">
                    <option value="">Todas</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="form-label small mb-1">Fecha Desde</label>
                  <input id="filtroFechaDesde" type="date" class="form-control"/>
                </div>
                <div class="col-md-3">
                  <label class="form-label small mb-1">Fecha Hasta</label>
                  <input id="filtroFechaHasta" type="date" class="form-control"/>
                </div>
                <div class="col-md-3 d-flex align-items-end">
                  <button id="btnBuscarMov" class="btn nt-btn-accent w-100"><i class="bi bi-search"></i> Buscar</button>
                </div>
              </div>
            </div>
          </div>

          <!-- Tabla Movimientos -->
          <div class="card nt-card shadow-sm">
            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0 small">
                <thead class="nt-table-head">
                  <tr>
                    <th>Fecha</th>
                    <th>Tipo</th>
                    <th>Producto</th>
                    <th>Bodega</th>
                    <th>Cantidad</th>
                    <th>Saldo Anterior</th>
                    <th>Saldo Nuevo</th>
                    <th>Responsable</th>
                    <th>Motivo</th>
                  </tr>
                </thead>
                <tbody id="tblMovimientos">
                  <tr><td colspan="9" class="text-center py-4"><div class="spinner-border"></div></td></tr>
                </tbody>
              </table>
            </div>
            <div class="card-footer">
              <div id="lblResumenMov" class="small text-muted">Cargando...</div>
            </div>
          </div>
        </div>

        <!-- TAB: ALERTAS -->
        <div class="tab-pane fade" id="alertas" role="tabpanel">
          <!-- Filtros Alertas -->
          <div class="card nt-card shadow-sm mb-3">
            <div class="card-body d-flex gap-3 align-items-end">
              <div class="flex-grow-1">
                <label class="form-label small mb-1">Bodega</label>
                <select id="filtroBodegaAlert" class="form-select">
                  <option value="">Todas</option>
                </select>
              </div>
              <div class="flex-grow-1">
                <label class="form-label small mb-1">Tipo</label>
                <select id="filtroTipoAlert" class="form-select">
                  <option value="">Todos</option>
                  <option value="M">Stock Mínimo</option>
                  <option value="S">Sin Stock</option>
                  <option value="A">Stock Alto</option>
                </select>
              </div>
              <div>
                <button id="btnBuscarAlert" class="btn nt-btn-accent"><i class="bi bi-search"></i> Buscar</button>
              </div>
            </div>
          </div>

          <!-- Tabla Alertas -->
          <div class="card nt-card shadow-sm">
            <div class="table-responsive">
              <table class="table table-hover align-middle mb-0">
                <thead class="nt-table-head">
                  <tr>
                    <th>Fecha</th>
                    <th>Tipo</th>
                    <th>Producto</th>
                    <th>Bodega</th>
                    <th>Stock Actual</th>
                    <th>Stock Mínimo</th>
                    <th>Mensaje</th>
                  </tr>
                </thead>
                <tbody id="tblAlertas">
                  <tr><td colspan="7" class="text-center py-4"><div class="spinner-border"></div></td></tr>
                </tbody>
              </table>
            </div>
            <div class="card-footer">
              <div id="lblResumenAlert" class="small text-muted">Cargando...</div>
            </div>
          </div>
        </div>

      </div>
    </div>
  </main>

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.js?v=19"></script>
  <script src="assets/js/inventario.js?v=13"></script>
</body>
</html>
