<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!doctype html>
<html lang="es">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>NextTech • Transferencias</title>

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
    <div class="container-fluid">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="./">
        <i class="bi bi-boxes"></i> NextTech
      </a>
      <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navMain">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div id="navMain" class="collapse navbar-collapse">
        <ul class="navbar-nav ms-auto">
          <li class="nav-item"><a class="nav-link" href="Dashboard.jsp"><i class="bi bi-speedometer2"></i> Dashboard</a></li>
          <li class="nav-item"><a class="nav-link" href="bodegas.jsp"><i class="bi bi-building"></i> Bodegas</a></li>
          <li class="nav-item"><a class="nav-link" href="inventario.jsp"><i class="bi bi-box-seam"></i> Inventario</a></li>
          <li class="nav-item"><a class="nav-link active" href="transferencias.jsp"><i class="bi bi-arrow-left-right"></i> Transferencias</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <!-- Contenido -->
  <main class="py-4">
    <div class="container-fluid">
      <div class="d-flex align-items-center justify-content-between mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-arrow-left-right"></i> Transferencias entre Bodegas</h1>
          <p class="mb-0 nt-subtitle">Gestión de traslados de productos entre almacenes.</p>
        </div>
        <div><button id="btnNuevaTransferencia" class="btn nt-btn-accent"><i class="bi bi-plus-circle"></i> Nueva Transferencia</button></div>
      </div>

      <!-- Filtros -->
      <div class="card nt-card shadow-sm mb-3">
        <div class="card-body d-flex flex-column flex-md-row align-items-md-center gap-3">
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Bodega Origen</label>
            <select id="filtroBodegaOrigen" class="form-select">
              <option value="">Todas</option>
            </select>
          </div>
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Bodega Destino</label>
            <select id="filtroBodegaDestino" class="form-select">
              <option value="">Todas</option>
            </select>
          </div>
          <div class="flex-grow-1">
            <label class="form-label small mb-1">Estado</label>
            <select id="filtroEstado" class="form-select">
              <option value="">Todos</option>
              <option value="P">Pendiente</option>
              <option value="E">Enviada</option>
              <option value="R">Recibida</option>
              <option value="C">Cancelada</option>
            </select>
          </div>
          <div class="align-self-end">
            <button id="btnBuscar" class="btn btn-primary"><i class="bi bi-search"></i> Buscar</button>
          </div>
        </div>
      </div>

      <!-- Tabla -->
      <div class="card nt-card shadow-sm">
        <div class="table-responsive">
          <table class="table table-hover align-middle mb-0">
            <thead class="table-light nt-table-head">
              <tr>
                <th>Número</th>
                <th>Fecha</th>
                <th>Origen</th>
                <th>Destino</th>
                <th>Estado</th>
                <th>Fecha Envío</th>
                <th>Fecha Recepción</th>
                <th>Observaciones</th>
                <th class="text-end">Acciones</th>
              </tr>
            </thead>
            <tbody id="tblTransferencias">
              <tr><td colspan="9" class="text-center py-4"><div class="spinner-border text-primary"></div></td></tr>
            </tbody>
          </table>
        </div>
        <div class="card-footer">
          <div id="lblResumen" class="small text-muted">Cargando...</div>
        </div>
      </div>
    </div>
  </main>

  <!-- MODAL: Ver Detalle -->
  <div class="modal fade" id="mdlDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl">
      <div class="modal-content nt-card">
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-eye"></i> Detalle de Transferencia</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <!-- Información de cabecera -->
          <div class="row mb-4">
            <div class="col-md-6">
              <h6 class="text-muted">Información General</h6>
              <dl class="row small">
                <dt class="col-sm-5">Número:</dt>
                <dd class="col-sm-7" id="detNumero">-</dd>
                <dt class="col-sm-5">Fecha:</dt>
                <dd class="col-sm-7" id="detFecha">-</dd>
                <dt class="col-sm-5">Estado:</dt>
                <dd class="col-sm-7" id="detEstado">-</dd>
              </dl>
            </div>
            <div class="col-md-6">
              <h6 class="text-muted">Bodegas</h6>
              <dl class="row small">
                <dt class="col-sm-5">Origen:</dt>
                <dd class="col-sm-7" id="detOrigen">-</dd>
                <dt class="col-sm-5">Destino:</dt>
                <dd class="col-sm-7" id="detDestino">-</dd>
                <dt class="col-sm-5">Observaciones:</dt>
                <dd class="col-sm-7" id="detObservaciones">-</dd>
              </dl>
            </div>
          </div>

          <!-- Productos -->
          <h6 class="text-muted mb-3">Productos</h6>
          <div class="table-responsive">
            <table class="table table-sm table-bordered">
              <thead class="table-light">
                <tr>
                  <th>Código</th>
                  <th>Producto</th>
                  <th>Cant. Solicitada</th>
                  <th>Cant. Enviada</th>
                  <th>Cant. Recibida</th>
                </tr>
              </thead>
              <tbody id="tblDetalleProductos">
                <tr><td colspan="5" class="text-center">Cargando...</td></tr>
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

  <!-- MODAL: Crear Transferencia -->
  <div class="modal fade" id="mdlCrear" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg">
      <form id="frmCrear" class="modal-content needs-validation" novalidate>
        <div class="modal-header nt-modal-header">
          <h5 class="modal-title"><i class="bi bi-plus-circle"></i> Nueva Transferencia</h5>
          <button class="btn-close" data-bs-dismiss="modal"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3 mb-3">
            <div class="col-md-4">
              <label class="form-label">Número *</label>
              <input id="crear_numero" class="form-control" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Fecha *</label>
              <input id="crear_fecha" type="date" class="form-control" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Solicitado Por (Empleado ID) *</label>
              <input id="crear_solicitado" type="number" class="form-control" value="1" required>
              <div class="invalid-feedback">Requerido</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Bodega Origen *</label>
              <select id="crear_bodega_origen" class="form-select" required>
                <option value="">Seleccione...</option>
              </select>
              <div class="invalid-feedback">Seleccione una bodega</div>
            </div>
            <div class="col-md-6">
              <label class="form-label">Bodega Destino *</label>
              <select id="crear_bodega_destino" class="form-select" required>
                <option value="">Seleccione...</option>
              </select>
              <div class="invalid-feedback">Seleccione una bodega</div>
            </div>
            <div class="col-12">
              <label class="form-label">Observaciones</label>
              <textarea id="crear_observaciones" class="form-control" rows="2"></textarea>
            </div>
          </div>

          <h6 class="mb-3">Productos a Transferir</h6>
          <div id="productosContainer">
            <div class="producto-item row g-2 mb-2">
              <div class="col-md-2">
                <input type="number" class="form-control producto-id" placeholder="Producto ID" required>
              </div>
              <div class="col-md-8">
                <input type="text" class="form-control" placeholder="Nombre del producto" disabled>
              </div>
              <div class="col-md-2">
                <input type="number" class="form-control producto-cantidad" placeholder="Cantidad" min="1" required>
              </div>
            </div>
          </div>
          <button type="button" id="btnAgregarProducto" class="btn btn-sm btn-outline-primary mt-2">
            <i class="bi bi-plus"></i> Agregar Producto
          </button>
        </div>
        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button type="submit" class="btn nt-btn-accent"><i class="bi bi-check2-circle"></i> Crear Transferencia</button>
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
  <script src="assets/js/common.js"></script>
  <script src="assets/js/transferencias.js"></script>
</body>
</html>