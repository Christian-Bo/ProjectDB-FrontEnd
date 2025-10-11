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
  <title>NextTech — Pagos de Compras</title>

  <!-- Base del backend (si cambias el puerto/origen, actualiza este meta) -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta y estilos globales del proyecto -->
  <link rel="stylesheet" href="assets/css/base.css?v=9">
  <link rel="stylesheet" href="assets/css/app.css?v=9">
  <!-- Estilos específicos del módulo (solo layout/look, no paleta) -->
  <link rel="stylesheet" href="assets/css/compras_pagos.css?v=12">
</head>
<body class="nt-bg">

  <!-- Navbar coherente con el resto del sitio -->
  <nav class="navbar navbar-expand-lg nt-navbar shadow-sm">
    <div class="container">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="./">
        <i class="bi bi-boxes"></i> NextTech
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div id="navMain" class="collapse navbar-collapse">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><a class="nav-link" href="Dashboard.jsp"><i class="bi bi-speedometer2"></i> Inicio</a></li>
          <li class="nav-item"><a class="nav-link" href="proveedores.jsp"><i class="bi bi-truck"></i> Proveedores</a></li>
          <li class="nav-item"><a class="nav-link" href="compras.jsp"><i class="bi bi-cart4"></i> Compras</a></li>
          <li class="nav-item"><a class="nav-link active" href="compras_pagos.jsp"><i class="bi bi-cash-coin"></i> Pagos</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <main class="py-4">
    <div class="container">

      <!-- Título + acciones (mimetiza la barra superior de “Compras”) -->
      <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-cash-coin"></i> Pagos de Compras</h1>
          <p class="mb-0 nt-subtitle">Aplicaciones vía SP, con la misma experiencia visual</p>
        </div>
        <div class="d-flex gap-2">
          <button id="btn-nuevo" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Nuevo pago
          </button>
          <button id="btn-buscar" class="btn btn-outline-secondary">
            <i class="bi bi-arrow-repeat"></i> Refrescar
          </button>
        </div>
      </div>

      <!-- Filtros (card oscura con bordes suaves, igual que Compras) -->
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
              <button id="btn-buscar-dup" class="btn btn-primary w-100">
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

  <!-- Modal Crear/Editar (mismo styling oscuro de tu tema) -->
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
          <button id="btn-guardar" class="btn btn-primary" data-mode="create" type="submit">
            <i class="bi bi-save2"></i> Guardar
          </button>
        </div>
      </form>
    </div>
  </div>

  <!-- Toasts (compartido con common.js) -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/common.js?v=11"></script>
  <script src="assets/js/compras_pagos.js?v=11"></script>
  <script>
    // Botón duplicado "Buscar" en la barra superior
    document.getElementById('btn-buscar-dup')?.addEventListener('click', ()=> {
      document.getElementById('btn-buscar')?.click();
    });
  </script>
</body>
</html>

