<%-- 
    Document   : index
    Created on : 9 oct 2025, 20:42:04
    Author     : DELL
--%>

<%-- 
    Dashboard unificado NextTech
    - Resumen general de Proveedores, Compras y CxP
    - Interactividad vía assets/js/Dashboard.js
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Dashboard</title>

  <!-- Base del backend (ajústalo si usas context-path distinto) -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos del proyecto (tu paleta y look & feel) -->
  <link rel="stylesheet" href="assets/css/base.css?v=9">
  <link rel="stylesheet" href="assets/css/app.css?v=9">
  <!-- Estilos del módulo Dashboard (ligeros, no sobrescriben tu paleta) -->
  <link rel="stylesheet" href="assets/css/Dashboard.css?v=9">
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Navbar mínima con botón Regresar -->
  <nav class="navbar nt-navbar shadow-sm">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2"  title="Inicio">
        <i class="bi bi-boxes"></i> NextTech
      </a>
      <button type="button" class="btn btn-outline-light btn-sm" onclick="goBack()" title="Regresar">
        <i class="bi bi-arrow-left me-1"></i> Regresar
      </button>
    </div>
  </nav>

  <!-- Contenido -->
  <main class="py-4 flex-grow-1">
    <div class="container">

      <!-- Título + acciones (dejé solo Actualizar + accesos rápidos que ya tenías) -->
      <div class="d-flex flex-wrap justify-content-between align-items-center mb-3 gap-2">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-speedometer2"></i> Dashboard</h1>
          <p class="mb-0 nt-subtitle">Resumen general: Proveedores, Compras y CxP</p>
        </div>
        <div class="d-flex gap-2">
          <button id="btnRefrescar" class="btn nt-btn-accent">
            <i class="bi bi-arrow-repeat"></i> Actualizar
          </button>
          <a class="btn btn-outline-dark" href="proveedores.jsp"><i class="bi bi-truck"></i> Proveedores</a>
          <a class="btn btn-primary" href="compras.jsp"><i class="bi bi-cart4"></i> Compras</a>
        </div>
      </div>

      <!-- KPIs -->
      <div class="row g-3 mb-3">
        <!-- Proveedores activos -->
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-people"></i></div>
              <div>
                <div class="small text-muted">Proveedores activos</div>
                <div class="h4 mb-0" id="kpiProvActivos">--</div>
              </div>
            </div>
          </div>
        </div>

        <!-- Compras del mes (conteo / total Q) -->
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-basket2"></i></div>
              <div>
                <div class="small text-muted">Compras (mes)</div>
                <div class="h4 mb-0">
                  <span id="kpiComprasMes">--</span>
                  <small class="text-muted">/ Q<span id="kpiComprasMesTotal">--</span></small>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Saldo CxP pendiente -->
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-wallet2"></i></div>
              <div>
                <div class="small text-muted">CxP pendiente</div>
                <div class="h4 mb-0">Q<span id="kpiCxpPendiente">--</span></div>
              </div>
            </div>
          </div>
        </div>

        <!-- Pagos CxP del mes -->
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-cash-coin"></i></div>
              <div>
                <div class="small text-muted">Pagos CxP (mes)</div>
                <div class="h4 mb-0">Q<span id="kpiPagosMes">--</span></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Últimos proveedores -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <span class="fw-semibold"><i class="bi bi-people"></i> Últimos proveedores</span>
          <a class="btn btn-sm btn-outline-dark" href="proveedores.jsp"><i class="bi bi-arrow-right"></i> Ver todos</a>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light nt-table-head">
                <tr>
                  <th>Código</th>
                  <th>Nombre</th>
                  <th>NIT</th>
                  <th>Teléfono</th>
                  <th>Días crédito</th>
                </tr>
              </thead>
              <tbody id="tblUltimosProv"><!-- JS --></tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Últimas compras -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <span class="fw-semibold"><i class="bi bi-receipt"></i> Últimas compras</span>
          <a class="btn btn-sm btn-outline-dark" href="compras.jsp"><i class="bi bi-arrow-right"></i> Ver todas</a>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light nt-table-head">
                <tr>
                  <th>#</th>
                  <th>N° Compra</th>
                  <th>Fecha</th>
                  <th>Proveedor</th>
                  <th class="text-end">Total</th>
                  <th>Estado</th>
                </tr>
              </thead>
              <tbody id="tblUltimasCompras"><!-- JS --></tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Últimos pagos CxP -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <span class="fw-semibold"><i class="bi bi-cash-stack"></i> Últimos pagos CxP</span>
          <a class="btn btn-sm btn-outline-dark" href="cxp.jsp"><i class="bi bi-arrow-right"></i> Ver CxP</a>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light nt-table-head">
                <tr>
                  <th>#</th>
                  <th>Proveedor</th>
                  <th>Fecha</th>
                  <th>Forma</th>
                  <th class="text-end">Monto</th>
                  <th>Obs</th>
                </tr>
              </thead>
              <tbody id="tblUltimosPagos"><!-- JS --></tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Gráfico principal -->
      <div class="card nt-card shadow-sm">
        <div class="card-header">
          <span class="fw-semibold"><i class="bi bi-bar-chart"></i> Compras — últimas 6 semanas</span>
        </div>
        <div class="card-body">
          <canvas id="chartCompras" height="100"></canvas>
        </div>
      </div>

    </div>
  </main>

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS -->
  <script>
    function goBack(){
      if (window.history.length > 1) {
        window.history.back();
      } else {
        // si no hay historial, vete al portal principal
        window.location.href = 'Dashboard.jsp';
      }
    }
  </script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <script src="assets/js/common.js?v=10"></script>
  <script src="assets/js/Dashboard.js?v=10"></script>
</body>
</html>
