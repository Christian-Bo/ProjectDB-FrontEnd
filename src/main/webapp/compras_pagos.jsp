<%-- 
    Document   : compras_pagos
    Created on : 10 oct 2025, 22:05:07
    Author     : DELL
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Nextech — Pagos de Compras</title>

  <!-- Base del backend (ajústalo si tienes context-path, ej: http://localhost:8080/nexttech_backend) -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta y estilos globales del proyecto -->
  <link rel="stylesheet" href="assets/css/base.css?v=12">
  <link rel="stylesheet" href="assets/css/app.css?v=12">
  <!-- Estilos específicos del módulo (solo layout/look, no paleta) -->
  <link rel="stylesheet" href="assets/css/compras_pagos.css?v=12">

  <style>
    /* Botón Regresar coherente con el tema */
    .nt-back {
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary);
    }
    .nt-back:hover{ background:var(--nt-surface-2); color:var(--nt-primary); }

    /* Realce sutil de cards (igual que dashboard) */
    .nt-card { transition: transform .1s ease, border-color .12s ease, box-shadow .12s ease; }
    .nt-card:hover { transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.35); }
  </style>
</head>

<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header minimal (sin menú de módulos) -->
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
          <p class="mb-0 nt-subtitle">Aplicaciones vía SP, con experiencia visual consistente</p>
        </div>
        <div class="d-flex gap-2">
          <button id="btn-nuevo" class="btn nt-btn-accent">
            <i class="bi bi-plus-circle"></i> Nuevo pago
          </button>
          <button id="btn-buscar" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-repeat"></i> Refrescar
          </button>
        </div>
      </div>

      <!-- Filtros -->
      <div class="card nt-card shadow-sm mb-3 rounded-xxl filtros-card">
        <div class="card-body">
          <div class="row g-3 align-items-end">
            <div class="col-12 col-md-3">
              <label class="form-label">Compra ID</label>
              <input id="filtro-compra-id" type="number" class="form-control" placeholder="ej. 120">
            </div>
            <div class="col-12 col-md-6">
              <label class="form-label">Buscar</label>
              <input id="filtro-texto" class="form-control" placeholder="forma de pago / referencia">
            </div>
            <div class="col-12 col-md-3 text-md-end">
              <button id="btn-buscar-dup" class="btn nt-btn-accent w-100">
                <i class="bi bi-search"></i> Buscar
              </button>
            </div>
          </div>
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
              <tbody id="pagos-tbody"><!-- JS --></tbody>
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
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">compra_id</label>
              <input id="compra_id" type="number" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">forma_pago</label>
              <select id="forma_pago" class="form-select" required>
                <option value="">— Seleccione —</option>
                <option value="efectivo">Efectivo</option>
                <option value="transferencia">Transferencia</option>
                <option value="cheque">Cheque</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="form-label">monto (Q)</label>
              <input id="monto" type="number" step="0.01" min="0" class="form-control" required>
            </div>
            <div class="col-12">
              <label class="form-label">referencia</label>
              <input id="referencia" class="form-control" placeholder="# transferencia / cheque / caja">
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btn-guardar" class="btn nt-btn-accent" data-mode="create" type="submit">
            <i class="bi bi-save2"></i> Guardar
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- Toasts (compat con common.js -> #appToast/#toastMsg) -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="appToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex">
        <div class="toast-body" id="toastMsg">Listo.</div>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Utilidades comunes -->
  <script src="assets/js/common.js?v=12"></script>

  <!-- Sincroniza API.baseUrl con <meta name="api-base"> (evita rutas relativas en 8082) -->
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

  <!-- Módulo del formulario -->
  <script src="assets/js/compras_pagos.js?v=12"></script>

  <script>
    // Duplicado "Buscar" en filtros
    document.getElementById('btn-buscar-dup')?.addEventListener('click', ()=> {
      document.getElementById('btn-buscar')?.click();
    });

    // Botón REGRESAR inteligente por rol
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
        'RRHH': 'rrhh-dashboard.jsp'
      };
      return HOME_BY_ROLE[role?.toUpperCase?.()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1) { history.back(); return; }
      const user = parseAuthUser();
      const home = homeForRole(user?.role || user?.rol);
      location.href = home;
    }
  </script>

</body>
</html>
