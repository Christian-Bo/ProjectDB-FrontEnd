<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Simulador de Precios</title>

  <!-- Base del API -->
  <meta name="api-base" content="http://localhost:8080" />

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema NextTech -->
  <link rel="stylesheet" href="assets/css/base.css?v=1">
  <link rel="stylesheet" href="assets/css/app.css?v=1">

  <style>
    html, body { height: 100%; }
    body.nt-bg { min-height: 100vh; display:flex; flex-direction:column; }
    main.flex-grow-1 { flex: 1 1 auto; }

    .nt-navbar{
      background: var(--nt-surface-1);
      border-bottom: 1px solid var(--nt-border);
    }
    .nt-back{
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border);
      background:transparent; color:var(--nt-primary);
    }
    .nt-back:hover{ background:var(--nt-surface-2); color:var(--nt-primary); }

    .nt-card{ background: var(--nt-surface-1); border:1px solid var(--nt-border); border-radius: 1rem; }
    .list-group-item { color: var(--nt-fg); border-color: var(--nt-border); }
    .form-label { color: var(--nt-fg); opacity: .95; }

    .nt-price-box { background: var(--nt-surface-2); border:1px solid var(--nt-border); border-radius: .9rem; }
    .nt-price-box .h4 { color: var(--nt-accent); font-weight:700; }

    .picker-display { background: var(--nt-surface-2); border:1px solid var(--nt-border); border-radius:.6rem; padding:.5rem .75rem; min-height: 38px; }
    .picker-display .muted { color: var(--nt-text); opacity:.8; }

    .picker-table thead th { position:sticky; top:0; background:var(--nt-surface-1); }
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
      if (history.length > 1){ history.back(); return; }
      const u = parseAuthUser();
      location.href = homeForRole(u?.role || u?.rol);
    }
    window.addEventListener('DOMContentLoaded', () => {
      Auth?.ensure?.(['OPERACIONES','ADMIN','FINANZAS','AUDITOR']);
    });
  </script>
</head>
<body class="nt-bg">

  <!-- Navbar -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-cash-stack"></i> NextTech — Simulador de Precios
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
    <div class="container">
      <h1 class="h3 nt-title mb-3"><i class="bi bi-calculator"></i> Simulador de precio</h1>

      <div class="card nt-card shadow-sm mb-4">
        <div class="card-body">
          <div class="row g-3">
            <!-- Producto (con picker) -->
            <div class="col-md-4">
              <label class="form-label">Producto *</label>
              <div class="d-grid gap-2">
                <div id="prod_display" class="picker-display"><span class="muted">Sin seleccionar</span></div>
                <div class="d-flex gap-2">
                  <button type="button" id="btnPickProducto" class="btn btn-outline-primary flex-grow-1">
                    <i class="bi bi-box-seam"></i> Elegir producto
                  </button>
                  <button type="button" id="btnClearProducto" class="btn btn-outline-secondary" title="Limpiar">
                    <i class="bi bi-x-lg"></i>
                  </button>
                </div>
              </div>
              <input id="prod_id" type="hidden" required>
            </div>

            <!-- Cliente (solo ID para evitar 500s; no se llama a /api/clientes*) -->
            <div class="col-md-4">
              <label class="form-label">Cliente (ID) *</label>
              <input id="cliente_id" type="number" min="1" class="form-control" placeholder="Ej.: 1" required>
              <div class="form-text">Introduce el ID del cliente. (No se consulta listado)</div>
            </div>

            <!-- Fecha -->
            <div class="col-md-4">
              <label class="form-label">Fecha (opcional)</label>
              <input id="fecha" type="date" class="form-control">
            </div>
          </div>

          <div class="mt-3 d-flex gap-2">
            <button id="btnSimular" class="btn nt-btn-accent">
              <span class="when-idle"><i class="bi bi-play-circle"></i> Simular</span>
              <span class="when-busy d-none"><span class="spinner-border spinner-border-sm me-1"></span> Simulando…</span>
            </button>
            <button id="btnLimpiar" class="btn btn-outline-secondary">Limpiar</button>
          </div>
        </div>
      </div>

      <div class="card nt-card shadow-sm" id="cardResultado" style="display:none;">
        <div class="card-header"><strong>Resultado</strong></div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <div class="p-3 nt-price-box">
                <div class="text-muted small">Precio final</div>
                <div class="h4" id="precio_final">—</div>
              </div>
            </div>
            <div class="col-md-8">
              <ul class="list-group">
                <li class="list-group-item bg-transparent d-flex justify-content-between">
                  <span>Base</span><span id="p_base">—</span>
                </li>
                <li class="list-group-item bg-transparent d-flex justify-content-between">
                  <span>Ajuste lista</span><span id="p_lista">—</span>
                </li>
                <li class="list-group-item bg-transparent d-flex justify-content-between">
                  <span>Margen</span><span id="p_margen">—</span>
                </li>
                <li class="list-group-item bg-transparent d-flex justify-content-between">
                  <span>Promoción/Descuento</span><span id="p_promo">—</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </div>

    </div>
  </main>

  <!-- MODAL Picker Productos -->
  <div class="modal fade" id="mdlPickProducto" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-box-seam"></i> Seleccionar producto</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="input-group mb-3">
            <span class="input-group-text bg-transparent"><i class="bi bi-search"></i></span>
            <input id="prod_q" class="form-control" placeholder="Buscar por nombre o código...">
            <button id="prod_btnBuscar" class="btn btn-outline-primary">Buscar</button>
          </div>
          <div class="table-responsive" style="max-height:50vh;">
            <table class="table table-hover align-middle picker-table">
              <thead>
                <tr><th style="width:120px;">ID</th><th>Nombre</th><th style="width:120px;"></th></tr>
              </thead>
              <tbody id="prod_rows">
                <tr><td colspan="3" class="text-center py-4"><div class="spinner-border"></div></td></tr>
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

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.api.js?v=99"></script>
  <script src="assets/js/simulador_de_precios.js?v=9"></script>
</body>
</html>
