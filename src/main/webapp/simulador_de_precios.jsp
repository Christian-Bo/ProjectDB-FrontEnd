<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Simulador de Precios</title>
  <meta name="api-base" content="http://localhost:8080" />

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <link rel="stylesheet" href="assets/css/base.css?v=1">
  <link rel="stylesheet" href="assets/css/app.css?v=1">
</head>
<body class="nt-bg">
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
          <li class="nav-item"><a class="nav-link" href="marcas.jsp"><i class="bi bi-tags"></i> Marcas</a></li>
          <li class="nav-item"><a class="nav-link" href="categorias.jsp"><i class="bi bi-diagram-3"></i> Categorías</a></li>
          <li class="nav-item"><a class="nav-link active" href="simulador_precios.jsp"><i class="bi bi-cash-stack"></i> Simulador</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <main class="py-4">
    <div class="container">
      <h1 class="h3 nt-title mb-3"><i class="bi bi-cash-stack"></i> Simulador de precio</h1>

      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Producto *</label>
              <input id="prod_id" type="number" min="1" class="form-control" placeholder="ID producto" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">Lista de precios</label>
              <input id="lista_id" type="number" min="1" class="form-control" placeholder="ID lista (opcional)">
            </div>
            <div class="col-md-4">
              <label class="form-label">Cliente (para acuerdos/promo)</label>
              <input id="cliente_id" type="number" min="1" class="form-control" placeholder="ID cliente (opcional)">
            </div>
          </div>
          <div class="mt-3 d-flex gap-2">
            <button id="btnSimular" class="btn nt-btn-accent"><i class="bi bi-calculator"></i> Simular</button>
            <button id="btnLimpiar" class="btn btn-outline-secondary">Limpiar</button>
          </div>
        </div>
      </div>

      <div class="card nt-card shadow-sm" id="cardResultado" style="display:none;">
        <div class="card-header">
          <strong>Resultado</strong>
        </div>
        <div class="card-body">
          <div class="row g-3">
            <div class="col-md-4">
              <div class="p-3 border rounded-xxl">
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
          <hr class="hr-soft my-3">
          <pre id="json_raw" class="small mb-0"></pre>
        </div>
      </div>
    </div>
  </main>

  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
  <script src="assets/js/simulador_precios.js?v=1"></script>
</body>
</html>
