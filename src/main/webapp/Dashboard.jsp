<%-- 
    Document   : index
    Created on : 9 oct 2025, 20:42:04
    Author     : DELL
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <!-- Metas -->
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>

  <!-- Título -->
  <title>NextTech • Dashboard</title>

  <!-- Bootstrap 5 + Icons (CDN) -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos: comunes + página -->
  <link rel="stylesheet" href="assets/css/base.css">
  <link rel="stylesheet" href="assets/css/Dashboard.css">
</head>
<body class="nt-bg">

  <!-- Navbar principal (reutilizada en todas las páginas) -->
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
          <!-- La página actual -->
          <li class="nav-item">
            <a class="nav-link active" href="./">
              <i class="bi bi-speedometer2"></i> Dashboard
            </a>
          </li>

          <!-- Navega al módulo Proveedores -->
          <li class="nav-item">
            <a class="nav-link" href="proveedores.jsp">
              <i class="bi bi-truck"></i> Proveedores
            </a>
          </li>

          <!-- Aquí podrás agregar más módulos -->
        </ul>
      </div>
    </div>
  </nav>

  <!-- Contenido principal -->
  <main class="py-4">
    <div class="container">

      <!-- Encabezado -->
      <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
          <h1 class="h3 nt-title mb-1">
            <i class="bi bi-speedometer2"></i> Dashboard
          </h1>
          <p class="mb-0 nt-subtitle">Resumen de Compras & CxP</p>
        </div>
        <div class="d-flex gap-2">
          <button id="btnRefrescar" class="btn nt-btn-accent">
            <i class="bi bi-arrow-repeat"></i> Actualizar
          </button>
          <a class="btn btn-outline-dark" href="proveedores.jsp">
            <i class="bi bi-truck"></i> Ir a Proveedores
          </a>
        </div>
      </div>

      <!-- KPIs -->
      <div class="row g-3 mb-3">
        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-truck"></i></div>
              <div>
                <div class="small text-muted">Proveedores activos</div>
                <div class="h4 mb-0" id="kpiProvActivos">--</div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-basket2"></i></div>
              <div>
                <div class="small text-muted">Compras (mes)</div>
                <div class="h4 mb-0" id="kpiComprasMes">--</div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-receipt"></i></div>
              <div>
                <div class="small text-muted">CxP pendientes</div>
                <div class="h4 mb-0" id="kpiCxPPendiente">--</div>
              </div>
            </div>
          </div>
        </div>

        <div class="col-12 col-sm-6 col-lg-3">
          <div class="card nt-card h-100 shadow-sm">
            <div class="card-body d-flex align-items-center gap-3">
              <div class="display-6"><i class="bi bi-cash-coin"></i></div>
              <div>
                <div class="small text-muted">Pagos (mes)</div>
                <div class="h4 mb-0" id="kpiPagosMes">--</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Últimos proveedores -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-header d-flex justify-content-between align-items-center">
          <span class="fw-semibold"><i class="bi bi-people"></i> Últimos proveedores</span>
          <a class="btn btn-sm btn-outline-dark" href="proveedores.jsp">
            <i class="bi bi-arrow-right"></i> Ver todos
          </a>
        </div>
        <div class="card-body p-0">
          <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
              <thead class="table-light nt-table-head">
                <tr>
                  <th>Código</th><th>Nombre</th><th>NIT</th><th>Teléfono</th><th>Días crédito</th>
                </tr>
              </thead>
              <tbody id="tblUltimosProv"><!-- Llenado por index.js --></tbody>
            </table>
          </div>
        </div>
      </div>

      <!-- Gráfico (Chart.js) -->
      <div class="card nt-card shadow-sm">
        <div class="card-header">
          <span class="fw-semibold"><i class="bi bi-bar-chart"></i> Compras últimas 6 semanas</span>
        </div>
        <div class="card-body">
          <canvas id="chartCompras" height="100"></canvas>
        </div>
      </div>
    </div>
  </main>

  <!-- Contenedor de toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.3/dist/chart.umd.min.js"></script>
  <script src="assets/js/common.js"></script>
  <script src="assets/js/Dashboard.js"></script>
</body>
</html>

