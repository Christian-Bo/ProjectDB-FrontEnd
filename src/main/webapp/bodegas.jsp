<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Bodegas</title>

  <meta name="api-base" content="http://localhost:8080" />

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos comunes -->
  <link rel="stylesheet" href="assets/css/base.css">
  <link rel="stylesheet" href="assets/css/app.css">
</head>
<body class="nt-bg">
  <!-- Navbar -->
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
          <li class="nav-item"><a class="nav-link" href="Dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
          <li class="nav-item"><a class="nav-link active" href="bodegas.jsp"><i class="bi bi-building"></i> Bodegas</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- Contenido -->
  <main class="py-4">
    <div class="container">
      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-building"></i> Gestión de Bodegas</h1>
          <p class="mb-0 nt-subtitle">Administra las bodegas y almacenes del sistema.</p>
        </div>
        <div><button id="btnOpenCreate" class="btn nt-btn-accent"><i class="bi bi-plus-circle"></i> Nueva Bodega</button></div>
      </div>

      <!-- Filtros -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body d-flex flex-column flex-md-row align-items-md-center gap-3">
          <div class="input-group">
            <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
            <input id="txtSearch" class="form-control" placeholder="Buscar por nombre, dirección o teléfono..."/>
          </div>
          <div class="form-check form-switch ms-md-3">
            <input id="chkSoloActivos" class="form-check-input" type="checkbox" checked>
            <label for="chkSoloActivos" class="form-check-label">Solo activas</label>
          </div>
          <button id="btnBuscar" class="btn btn-outline-dark ms-md-auto"><i class="bi bi-arrow-repeat"></i> Buscar</button>
        </div>
      </div>

      <!-- Tabla -->
      <div class="card nt-card shadow-sm">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light nt-table-head">
              <tr>
                <th>ID</th>
                <th>Nombre</th>
                <th>Dirección</th>
                <th>Teléfono</th>
                <th>Email</th>
                <th>Estado</th>
                <th>Responsable</th>
                <th class="text-end">Acciones</th>
              </tr>
            </thead>
            <tbody id="tblBodegas">
              <tr><td colspan="8" class="text-center py-4"><div class="spinner-border text-primary" role="status"></div></td></tr>
            </tbody>
          </table>
        </div>
        <div class="card-footer d-flex justify-content-between align-items-center">
          <div id="lblResumen" class="small text-muted">Cargando...</div>
        </div>
      </div>
    </div>
  </main>

  <!-- MODAL: Crear / Editar -->
  <div class="modal fade" id="mdlUpsert" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <form id="frmUpsert" class="modal-content needs-validation" novalidate>
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title" id="mdlUpsertTitle"><i class="bi bi-pencil-square"></i> Bodega</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="bodega_id"/>
          <div class="row g-3">
            <div class="col-md-6">
              <label class="form-label">Nombre *</label>
              <input id="bodega_nombre" class="form-control" required>
              <div class="invalid-feedback">El nombre es obligatorio.</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Teléfono</label>
              <input id="bodega_telefono" class="form-control">
            </div>
            <div class="col-12">
              <label class="form-label">Dirección</label>
              <textarea id="bodega_direccion" class="form-control" rows="2"></textarea>
            </div>
            <div class="col-md-6">
              <label class="form-label">Email</label>
              <input id="bodega_email" type="email" class="form-control">
            </div>
            <div class="col-md-6">
              <label class="form-label">Responsable (ID Empleado)</label>
              <input id="bodega_responsable_id" type="number" class="form-control">
              <div class="form-text">Opcional: ID del empleado responsable</div>
            </div>
            <div class="col-12 d-flex align-items-end">
              <div class="form-check form-switch">
                <input id="bodega_activo" type="checkbox" class="form-check-input" checked>
                <label class="form-check-label">Activa</label>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" type="button" data-bs-dismiss="modal">Cancelar</button>
          <button id="btnSave" type="submit" class="btn nt-btn-accent"><i class="bi bi-check2-circle"></i> Guardar</button>
        </div>
      </form>
    </div>
  </div>

  <!-- MODAL: Ver Detalle -->
  <div class="modal fade" id="mdlView" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-eye"></i> Detalle de la Bodega</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <dl id="viewContent" class="row mb-0"></dl>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- MODAL: Eliminar -->
  <div class="modal fade" id="mdlDelete" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content border-0">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-exclamation-triangle"></i> Confirmar</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          ¿Deseas desactivar la bodega <span id="delNombre" class="fw-bold"></span>?
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btnConfirmDelete" class="btn btn-danger"><i class="bi bi-trash"></i> Desactivar</button>
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
  <script src="assets/js/common.js"></script>
  <script src="assets/js/bodegas.js"></script>
</body>
</html>