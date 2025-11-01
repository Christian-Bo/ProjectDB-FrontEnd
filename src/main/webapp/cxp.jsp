<%-- 
    Document   : cxp
    Created on : 10 oct 2025, 22:05:23
    Author     : DELL

--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech — Cuentas por Pagar</title>

  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema NextTech -->
  <link rel="stylesheet" href="assets/css/base.css?v=13">
  <link rel="stylesheet" href="assets/css/app.css?v=13">
  <link rel="stylesheet" href="assets/css/cxp.css?v=12">

  <style>
    body.nt-bg { background: var(--nt-bg); color: var(--nt-fg); }
    .nt-title{ color: var(--nt-fg-strong); }
    .nt-subtitle{ color: var(--nt-fg-muted); }

    .nt-back{ display:inline-flex; align-items:center; gap:.5rem; border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary); }
    .nt-back:hover{ background:var(--nt-surface-2); }

    .nt-card{ background: var(--nt-surface-1); border:1px solid var(--nt-border); border-radius:1rem; transition:.12s; }
    .nt-card:hover{ transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.35); }

    .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-fg); }
    .nt-btn-accent{ background: var(--nt-accent); color:#fff; border:none; }
    .nt-btn-accent:hover{ filter: brightness(.95); }

    /* Inputs oscuros como Transferencias */
    .form-control.nt-input, .form-select.nt-input{
      background: var(--nt-surface-2); color: var(--nt-fg); border-color: var(--nt-border);
    }
    .form-control.nt-input:focus, .form-select.nt-input:focus{
      border-color: var(--nt-accent);
      box-shadow: 0 0 0 .2rem rgba(0,102,255,.15);
    }

    /* Modal del tema */
    .modal-content{ background: var(--nt-surface-1); border:1px solid var(--nt-border); border-radius:1rem; }
    .modal-header{ background: var(--nt-surface-2); border-bottom:1px solid var(--nt-border); }
    .modal-backdrop.show{ opacity:.6 !important; }
  </style>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header minimal SIN botón de Salir -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-receipt"></i> NextTech — Cuentas por Pagar
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

      <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-receipt"></i> Cuentas por Pagar</h1>
          <p class="mb-0 nt-subtitle">Documentos, pagos y aplicaciones</p>
        </div>
        <div class="d-flex gap-2">
          <button id="pag-nuevo" class="btn nt-btn-accent">
            <i class="bi bi-plus-circle"></i> Nuevo pago
          </button>
          <button id="doc-nuevo" class="btn btn-outline-secondary">
            <i class="bi bi-file-earmark-plus"></i> Nuevo documento
          </button>
        </div>
      </div>

      <!-- Tabs -->
      <ul class="nav nav-pills nt-pills mb-3" id="pills-tab" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" id="tab-documentos" data-bs-toggle="pill" data-bs-target="#panel-documentos" type="button" role="tab">
            <i class="bi bi-files"></i> Documentos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="tab-pagos" data-bs-toggle="pill" data-bs-target="#panel-pagos" type="button" role="tab">
            <i class="bi bi-cash-stack"></i> Pagos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" id="tab-aplicaciones" data-bs-toggle="pill" data-bs-target="#panel-aplicaciones" type="button" role="tab">
            <i class="bi bi-diagram-3"></i> Aplicaciones
          </button>
        </li>
      </ul>

      <div class="tab-content">
        <!-- ===== DOCUMENTOS ===== -->
        <div class="tab-pane fade show active" id="panel-documentos" role="tabpanel">
          <div class="card nt-card shadow-sm mb-3 rounded-xxl">
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">proveedor_id</label>
                  <input id="doc-proveedor" class="form-control nt-input" type="number" placeholder="ej. 10">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Texto</label>
                  <input id="doc-texto" class="form-control nt-input" placeholder="numero_documento / moneda">
                </div>
                <div class="col-md-3 text-md-end">
                  <button id="doc-buscar" class="btn nt-btn-accent w-100">
                    <i class="bi bi-search"></i> Buscar
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="card nt-card shadow-sm rounded-xxl">
            <div class="card-body p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                  <thead class="nt-table-head">
                    <tr>
                      <th>#</th><th>Proveedor</th><th>Origen</th><th>Número</th>
                      <th>Emisión</th><th>Vencimiento</th><th>Moneda</th>
                      <th class="text-end">Monto</th><th class="text-end">Saldo</th><th class="text-end">Acciones</th>
                    </tr>
                  </thead>
                  <tbody id="doc-tbody"></tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- ===== PAGOS ===== -->
        <div class="tab-pane fade" id="panel-pagos" role="tabpanel">
          <div class="card nt-card shadow-sm mb-3 rounded-xxl">
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">proveedor_id</label>
                  <input id="pag-proveedor" class="form-control nt-input" type="number" placeholder="ej. 10">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Texto</label>
                  <input id="pag-texto" class="form-control nt-input" placeholder="forma_pago / observaciones">
                </div>
                <div class="col-md-3 text-md-end">
                  <button id="pag-buscar" class="btn nt-btn-accent w-100">
                    <i class="bi bi-search"></i> Buscar
                  </button>
                </div>
              </div>
            </div>
          </div>

          <div class="card nt-card shadow-sm rounded-xxl">
            <div class="card-body p-0">
              <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                  <thead class="nt-table-head">
                    <tr>
                      <th>#</th><th>Proveedor</th><th>Fecha</th><th>Forma</th>
                      <th class="text-end">Monto</th><th>Obs</th><th class="text-end">Acciones</th><th class="text-end">Aplicar</th>
                    </tr>
                  </thead>
                  <tbody id="pag-tbody"></tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- ===== APLICACIONES ===== -->
        <div class="tab-pane fade" id="panel-aplicaciones" role="tabpanel">
          <div class="card nt-card shadow-sm mb-3 rounded-xxl">
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">pago_id</label>
                  <input id="apl-pago-id" class="form-control nt-input" type="number" placeholder="ID del pago">
                </div>
                <div class="col-md-3">
                  <button id="apl-cargar" class="btn btn-outline-secondary mt-4"><i class="bi bi-arrow-repeat"></i> Cargar</button>
                </div>
              </div>
            </div>
          </div>

          <div class="row g-3">
            <div class="col-lg-6">
              <div class="card nt-card shadow-sm rounded-xxl h-100">
                <div class="card-header fw-semibold"><i class="bi bi-list-check"></i> Aplicaciones existentes</div>
                <div class="card-body p-0">
                  <div class="table-responsive">
                    <table class="table table-hover align-middle mb-0">
                      <thead class="nt-table-head">
                        <tr><th>#</th><th>pago_id</th><th>documento_id</th><th class="text-end">monto_aplicado</th><th>fecha</th></tr>
                      </thead>
                      <tbody id="apl-tbody"></tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-lg-6">
              <form id="form-apl" class="card nt-card shadow-sm rounded-xxl h-100">
                <div class="card-header fw-semibold"><i class="bi bi-plus-circle"></i> Nueva aplicación (lote)</div>
                <div class="card-body">
                  <p class="text-muted small mb-2">Formato: <code>documento_id; monto</code> (una línea por item)</p>
                  <textarea id="apl-items" class="form-control nt-input" rows="8" placeholder="3001; 950.00&#10;3002; 250.00"></textarea>
                </div>
                <div class="card-footer text-end">
                  <button class="btn nt-btn-accent"><i class="bi bi-check2-circle"></i> Aplicar</button>
                </div>
              </form>
            </div>
          </div>

        </div>
      </div>

    </div>
  </main>

  <!-- Modal Documento -->
  <div class="modal fade" id="modalDoc" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
      <form id="form-doc" class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="modalDocLabel">Documento CxP</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="doc-id">
          <div class="row g-3">
            <div class="col-md-3"><label class="form-label">proveedor_id</label><input id="proveedor_id" type="number" class="form-control nt-input" required></div>
            <div class="col-md-3"><label class="form-label">origen_tipo</label><select id="origen_tipo" class="form-select nt-input" required><option value="">—</option><option value="C">C (Compra)</option><option value="F">F (Manual)</option></select></div>
            <div class="col-md-3"><label class="form-label">origen_id</label><input id="origen_id" type="number" class="form-control nt-input" required></div>
            <div class="col-md-3"><label class="form-label">numero_documento</label><input id="numero_documento" class="form-control nt-input" required></div>
            <div class="col-md-4"><label class="form-label">fecha_emision</label><input id="fecha_emision" type="date" class="form-control nt-input" required></div>
            <div class="col-md-4"><label class="form-label">fecha_vencimiento</label><input id="fecha_vencimiento" type="date" class="form-control nt-input"></div>
            <div class="col-md-2"><label class="form-label">moneda</label><input id="moneda" class="form-control nt-input" value="GTQ" required></div>
            <div class="col-md-2"><label class="form-label">monto_total</label><input id="monto_total" type="number" step="0.01" min="0" class="form-control nt-input" required></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn nt-btn-accent" type="submit"><i class="bi bi-save2"></i> Guardar</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Modal Pago -->
  <div class="modal fade" id="modalPagoCxp" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
      <form id="form-pago-cxp" class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title">Pago CxP</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="pago_id">
          <div class="row g-3">
            <div class="col-md-3"><label class="form-label">proveedor_id</label><input id="p_proveedor_id" type="number" class="form-control nt-input" required></div>
            <div class="col-md-3"><label class="form-label">fecha_pago</label><input id="fecha_pago" type="date" class="form-control nt-input" required></div>
            <div class="col-md-3"><label class="form-label">forma_pago</label><select id="p_forma_pago" class="form-select nt-input" required><option value="">—</option><option value="transferencia">Transferencia</option><option value="efectivo">Efectivo</option><option value="cheque">Cheque</option></select></div>
            <div class="col-md-3"><label class="form-label">monto_total</label><input id="p_monto_total" type="number" step="0.01" min="0" class="form-control nt-input" required></div>
            <div class="col-12"><label class="form-label">observaciones</label><input id="observaciones" class="form-control nt-input" placeholder="Opcional"></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn nt-btn-accent" type="submit"><i class="bi bi-save2"></i> Guardar</button>
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
  <script src="assets/js/common.js?v=11"></script>
  <script src="assets/js/cxp.js?v=12"></script>

  <script>
    // Botón REGRESAR (igual que Transferencias)
    function parseAuthUser(){
      try{ if (window.Auth?.user) return window.Auth.user; const raw = localStorage.getItem('auth_user'); return raw ? JSON.parse(raw) : null; }catch(_){ return null; }
    }
    function homeForRole(role){
      const HOME = { ADMIN:'Dashboard.jsp', OPERADOR:'dashboard_operador.jsp', RRHH:'rrhh-dashboard.jsp' };
      return HOME[(role||'').toUpperCase()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1){ history.back(); return; }
      const user = parseAuthUser(); location.href = homeForRole(user?.role || user?.rol);
    }
  </script>
</body>
</html>
