<%-- 
    Document   : proveedores
    Created on : 9 oct 2025, 20:15:20
    Author     : DELL
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Proveedores</title>

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Estilos: comunes + página -->
  <link rel="stylesheet" href="assets/css/base.css?=6">
  <link rel="stylesheet" href="assets/css/proveedores.css?v=6">
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
          <li class="nav-item"><a class="nav-link active" href="proveedores.jsp"><i class="bi bi-truck"></i> Proveedores</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- Contenido -->
  <main class="py-4">
    <div class="container">
      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-truck"></i> Proveedores</h1>
          <p class="mb-0 nt-subtitle">Administra tus proveedores de compras y CxP.</p>
        </div>
        <div><button id="btnOpenCreate" class="btn nt-btn-accent"><i class="bi bi-plus-circle"></i> Nuevo</button></div>
      </div>

      <!-- Filtros -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body d-flex flex-column flex-md-row align-items-md-center gap-3">
          <div class="input-group">
            <span class="input-group-text bg-white"><i class="bi bi-search"></i></span>
            <input id="txtSearch" class="form-control" placeholder="Buscar por nombre, código o NIT..."/>
          </div>
          <div class="form-check form-switch ms-md-3">
            <input id="chkSoloActivos" class="form-check-input" type="checkbox" checked>
            <label for="chkSoloActivos" class="form-check-label">Solo activos</label>
          </div>
          <button id="btnBuscar" class="btn btn-outline-dark ms-md-auto"><i class="bi bi-arrow-repeat"></i> Buscar</button>
        </div>
      </div>

      <!-- Tabla (orden EXACTO del JSON que enviaste) -->
      <div class="card nt-card shadow-sm">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light nt-table-head">
              <tr>
                <th>Código</th>
                <th>Nombre</th>
                <th>NIT</th>
                <th>Teléfono</th>
                <th>Dirección</th>
                <th>Email</th>
                <th>Contacto principal</th>
                <th>Días crédito</th>
                <th>Activo</th>
                <th>Registrado por</th>
                <th class="text-end">Acciones</th>
              </tr>
            </thead>
            <tbody id="tblProveedores">
              <!-- filas por JS -->
            </tbody>
          </table>
        </div>
        <div class="card-footer d-flex justify-content-between align-items-center">
          <div id="lblResumen" class="small text-muted">0 resultados</div>
          <ul id="paginacion" class="pagination pagination-sm mb-0"><!-- paginado JS --></ul>
        </div>
      </div>
    </div>
  </main>

  <!-- ========= MODALES ========= -->

  <!-- Crear / Editar -->
  <div class="modal fade" id="mdlUpsert" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <form id="frmUpsert" class="modal-content needs-validation" novalidate>
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title" id="mdlUpsertTitle"><i class="bi bi-pencil-square"></i> Proveedor</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="prov_id"/>
          <div class="row g-3">
            <div class="col-md-4">
              <label class="form-label">Código *</label>
              <input id="prov_codigo" class="form-control" required>
              <div class="invalid-feedback">El código es obligatorio.</div>
            </div>
            <div class="col-md-8">
              <label class="form-label">Nombre *</label>
              <input id="prov_nombre" class="form-control" required>
              <div class="invalid-feedback">El nombre es obligatorio.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">NIT *</label>
              <input id="prov_nit" class="form-control" required>
              <div class="invalid-feedback">El NIT es obligatorio.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Teléfono *</label>
              <input id="prov_telefono" class="form-control" required>
              <div class="invalid-feedback">El teléfono es obligatorio.</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Días de crédito *</label>
              <input id="prov_dias_credito" type="number" min="0" class="form-control" required>
              <div class="invalid-feedback">Indica días de crédito (≥ 0).</div>
            </div>
            <div class="col-12">
              <label class="form-label">Dirección</label>
              <input id="prov_direccion" class="form-control">
            </div>
            <div class="col-md-8">
              <label class="form-label">Email</label>
              <input id="prov_email" type="email" class="form-control">
            </div>
            <div class="col-md-4">
              <label class="form-label">Contacto principal</label>
              <input id="prov_contacto_principal" class="form-control">
            </div>
            <div class="col-md-6">
              <label class="form-label">Registrado por (ID empleado) *</label>
              <input id="prov_registrado_por" type="number" class="form-control" required>
              <div class="invalid-feedback">Indica un empleado válido.</div>
            </div>
            <div class="col-md-6 d-flex align-items-end">
              <div class="form-check form-switch">
                <input id="prov_activo" type="checkbox" class="form-check-input" checked>
                <label class="form-check-label">Activo</label>
              </div>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btnSave" type="submit" class="btn nt-btn-accent"><i class="bi bi-check2-circle"></i> Guardar</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Ver -->
  <div class="modal fade" id="mdlView" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content nt-card">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-eye"></i> Detalle del Proveedor</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <dl id="viewContent" class="row mb-0"><!-- por JS --></dl>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Eliminar -->
  <div class="modal fade" id="mdlDelete" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content border-0">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-exclamation-triangle"></i> Confirmar</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          ¿Deseas eliminar (lógico) el proveedor <span id="delNombre" class="fw-bold"></span>?
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button id="btnConfirmDelete" class="btn btn-danger"><i class="bi bi-trash"></i> Eliminar</button>
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
  <script src="assets/js/proveedores.js"></script>
</body>
</html>

