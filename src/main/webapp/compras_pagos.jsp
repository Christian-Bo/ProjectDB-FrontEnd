<%-- 
    Document   : compras_pagos
    Created on : 10 oct 2025
    Author     : DELL
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Nextech — Pagos de Compras</title>

  <!-- Base del backend -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta del proyecto -->
  <link rel="stylesheet" href="assets/css/base.css?v=12">
  <link rel="stylesheet" href="assets/css/app.css?v=12">
  <link rel="stylesheet" href="assets/css/compras_pagos.css?v=16">

  <style>
    .nt-back { display:inline-flex; align-items:center; gap:.5rem; border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary); }
    .nt-back:hover{ background:var(--nt-surface-2); color:var(--nt-primary); }
    .nt-card { transition: transform .1s ease, border-color .12s ease, box-shadow .12s ease; }
    .nt-card:hover { transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.35); }

    /* Toast pro (incluye destructivo) */
    #appToast.text-bg-primary { background: linear-gradient(135deg,#6937ff,#885bff)!important; }
    #appToast.text-bg-success { background: linear-gradient(135deg,#179f5c,#35cc7a)!important; }
    #appToast.text-bg-danger  { background: linear-gradient(135deg,#c62828,#ff6b6b)!important; box-shadow: 0 0 0 2px rgba(255,255,255,.12), 0 12px 28px rgba(198,40,40,.35)!important; }
    #appToast.text-bg-warning { background: linear-gradient(135deg,#f7b500,#ffd36b)!important; color:#222!important; }
    #appToast .toast-body .toast-icon { margin-right:.5rem; display:inline-flex; }

    /* Resumen bajo el select */
    .compra-summary{ display:none; border:1px dashed var(--nt-border,#2b3347); border-radius:.75rem; padding:.6rem .8rem; background: var(--nt-surface-2,#1b2231); margin-top:.5rem; font-size:.95rem; }
    .compra-summary .lbl { color:#9fb2d1; margin-right:.35rem; }

    .modal-danger .modal-header{ background:linear-gradient(135deg,#c62828,#ff6b6b); color:#fff; }
    .modal-danger .btn-danger{ box-shadow:0 6px 18px rgba(198,40,40,.35); }
    .td-compra small{ color:#9fb2d1; }
  </style>
</head>

<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-cash-coin"></i> Nextech — Pagos de Compras
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

      <!-- Título + acciones -->
      <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-cash-coin"></i> Pagos de Compras</h1>
          <p class="mb-0 nt-subtitle">Listado global con búsqueda y alta con selector de compras (con nombre asociado)</p>
        </div>
        <div class="d-flex gap-2">
          <button id="btn-nuevo" class="btn nt-btn-accent"><i class="bi bi-plus-circle"></i> Nuevo pago</button>
          <button id="btn-buscar" class="btn btn-outline-secondary"><i class="bi bi-arrow-repeat"></i> Buscar / Refrescar</button>
        </div>
      </div>

      <!-- Buscador global -->
      <div class="card nt-card shadow-sm mb-3 rounded-xxl filtros-card">
        <div class="card-body">
          <div class="row g-3 align-items-end">
            <div class="col-12 col-md-10">
              <label class="form-label">Buscar</label>
              <input id="filtro-texto" class="form-control" placeholder="forma de pago / referencia / #pago ...">
            </div>
            <div class="col-12 col-md-2 text-md-end">
              <button id="btn-buscar-único" class="btn nt-btn-accent w-100"><i class="bi bi-search"></i> Buscar</button>
            </div>
          </div>
          <div class="form-text mt-2">Tip: presiona <kbd>Enter</kbd> para buscar.</div>
        </div>
      </div>

      <!-- Tabla -->
      <div class="card nt-card shadow-sm rounded-xxl">
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="nt-table-head">
                <tr>
                  <th>#</th>
                  <th>Compra</th>
                  <th>Forma</th>
                  <th class="text-end">Monto</th>
                  <th>Referencia</th>
                  <th class="text-end">Acciones</th>
                </tr>
              </thead>
              <tbody id="pagos-tbody">
                <tr>
                  <td colspan="6" class="text-center text-muted py-4">
                    Usa el buscador para listar los pagos (o deja vacío y presiona <strong>Buscar</strong> para ver todos).
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>
  </main>

  <!-- Modal Crear/Editar -->
  <div class="modal fade" id="modalPago" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <form id="form-pago" class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="modalPagoLabel">Nuevo pago de compra</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
        </div>

        <div class="modal-body">
          <input type="hidden" id="pago-id">
          <input type="hidden" id="compra_id" required>

          <div class="mb-2">
            <label class="form-label">Compra <span class="text-danger">*</span></label>
            <select id="compra_select" class="form-select" required>
              <option value="">— Seleccione una compra —</option>
            </select>
          </div>

          <div id="compra-summary" class="compra-summary">
            <div><span class="lbl">Nombre:</span><span id="sum-nombre">—</span></div>
            <div><span class="lbl">Documento:</span><span id="sum-doc">—</span></div>
            <div><span class="lbl">Total:</span><span id="sum-total">Q 0.00</span></div>
          </div>

          <div class="row g-3 mt-1">
            <div class="col-md-6">
              <label class="form-label">forma_pago <span class="text-danger">*</span></label>
              <select id="forma_pago" class="form-select" required>
                <option value="">— Seleccione —</option>
                <option value="efectivo">Efectivo</option>
                <option value="transferencia">Transferencia</option>
                <option value="cheque">Cheque</option>
              </select>
            </div>
            <div class="col-md-6">
              <label class="form-label">monto (Q) <span class="text-danger">*</span></label>
              <input id="monto" type="number" step="0.01" min="0.01" class="form-control" required>
            </div>
            <div class="col-12">
              <label class="form-label">referencia</label>
              <input id="referencia" class="form-control" placeholder="# transferencia / cheque / caja">
            </div>
          </div>
        </div>

        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btn-guardar" class="btn nt-btn-accent" type="submit"><i class="bi bi-save2"></i> Guardar</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Modal Confirmación Eliminar -->
  <div class="modal fade" id="modalConfirmDelete" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
      <div class="modal-content modal-danger">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-exclamation-octagon-fill me-2"></i>Eliminar pago</h5>
          <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <p class="mb-1">¿Seguro que deseas eliminar el pago <strong id="del-num">#—</strong>?</p>
          <p class="text-warning small mb-0"><i class="bi bi-exclamation-triangle-fill me-1"></i>Esta acción es permanente.</p>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-light" data-bs-dismiss="modal">Cancelar</button>
          <button id="btn-confirm-delete" class="btn btn-danger"><i class="bi bi-trash3"></i> Eliminar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Toast -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="appToast" class="toast align-items-center text-bg-primary border-0 shadow" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="toastMsg">Listo.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.js?v=13"></script>

  <!-- Sincroniza API.baseUrl -->
  <script>
    (function(){
      try{
        window.API = window.API || {};
        if (!API.baseUrl || !API.baseUrl.trim()) {
          const meta = document.querySelector('meta[name="api-base"]');
          const base = (window.API_BASE || meta?.getAttribute('content') || '').trim();
          if (base) API.baseUrl = base;
        }
        console.log('[compras_pagos.jsp] API.baseUrl =', API.baseUrl || '(vacío)');
      }catch(_){}
    })();
  </script>

  <!-- Módulo -->
  <script src="assets/js/compras_pagos.js?v=18"></script>

  <script>
    // Accesos rápidos del buscador
    document.getElementById('btn-buscar-único').addEventListener('click', ()=> {
      document.getElementById('btn-buscar')?.click();
    });
    document.getElementById('filtro-texto').addEventListener('keydown', (e)=>{
      if (e.key === 'Enter') { e.preventDefault(); document.getElementById('btn-buscar')?.click(); }
    });

    // Botón REGRESAR por rol
    function parseAuthUser(){
      try{
        if (window.Auth?.user) return window.Auth.user;
        const raw = localStorage.getItem('auth_user');
        return raw ? JSON.parse(raw) : null;
      }catch(_){ return null; }
    }
    function homeForRole(role){
      const HOME_BY_ROLE = { 'ADMIN':'Dashboard.jsp','OPERADOR':'dashboard_operador.jsp','RRHH':'rrhh-dashboard.jsp' };
      return HOME_BY_ROLE[role?.toUpperCase?.()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1) { history.back(); return; }
      const user = parseAuthUser();
      location.href = homeForRole(user?.role || user?.rol);
    }
  </script>

</body>
</html>
