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

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta global -->
  <link rel="stylesheet" href="assets/css/base.css?v=9">
  <link rel="stylesheet" href="assets/css/app.css?v=9">
  <!-- Estilos del módulo CxP -->
  <link rel="stylesheet" href="assets/css/cxp.css?v=12">
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
          <li class="nav-item"><a class="nav-link" href="Dashboard.jsp"><i class="bi bi-speedometer2"></i> Inicio</a></li>
          <li class="nav-item"><a class="nav-link" href="compras.jsp"><i class="bi bi-cart4"></i> Compras</a></li>
          <li class="nav-item"><a class="nav-link" href="compras_pagos.jsp"><i class="bi bi-cash-coin"></i> Pagos</a></li>
          <li class="nav-item"><a class="nav-link active" href="cxp.jsp"><i class="bi bi-receipt"></i> CxP</a></li>
        </ul>
      </div>
    </div>
  </nav>

  <main class="py-4">
    <div class="container">

      <!-- Título + acciones -->
      <div class="d-flex flex-wrap justify-content-between align-items-center gap-2 mb-3">
        <div>
          <h1 class="h3 nt-title mb-1"><i class="bi bi-receipt"></i> Cuentas por Pagar</h1>
          <p class="mb-0 nt-subtitle">Documentos, pagos y aplicaciones</p>
        </div>
        <div class="d-flex gap-2">
          <button id="pag-nuevo" class="btn btn-primary">
            <i class="bi bi-plus-circle"></i> Nuevo pago
          </button>
          <button id="doc-nuevo" class="btn btn-outline-secondary">
            <i class="bi bi-file-earmark-plus"></i> Nuevo documento
          </button>
        </div>
      </div>

      <!-- Pestañas estilo pills moradas -->
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
        <!-- =============== DOCUMENTOS =============== -->
        <div class="tab-pane fade show active" id="panel-documentos" role="tabpanel">
          <div class="card nt-card shadow-sm mb-3 rounded-xxl">
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">proveedor_id</label>
                  <input id="doc-proveedor" class="form-control" type="number" placeholder="ej. 10">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Texto</label>
                  <input id="doc-texto" class="form-control" placeholder="numero_documento / moneda">
                </div>
                <div class="col-md-3 text-md-end">
                  <button id="doc-buscar" class="btn btn-primary w-100">
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
                  <tbody id="doc-tbody"><!-- JS --></tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- =============== PAGOS =============== -->
        <div class="tab-pane fade" id="panel-pagos" role="tabpanel">
          <div class="card nt-card shadow-sm mb-3 rounded-xxl">
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">proveedor_id</label>
                  <input id="pag-proveedor" class="form-control" type="number" placeholder="ej. 10">
                </div>
                <div class="col-md-6">
                  <label class="form-label">Texto</label>
                  <input id="pag-texto" class="form-control" placeholder="forma_pago / observaciones">
                </div>
                <div class="col-md-3 text-md-end">
                  <button id="pag-buscar" class="btn btn-primary w-100">
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
                  <tbody id="pag-tbody"><!-- JS --></tbody>
                </table>
              </div>
            </div>
          </div>
        </div>

        <!-- =============== APLICACIONES =============== -->
        <div class="tab-pane fade" id="panel-aplicaciones" role="tabpanel">
          <div class="card nt-card shadow-sm mb-3 rounded-xxl">
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">pago_id</label>
                  <input id="apl-pago-id" class="form-control" type="number" placeholder="ID del pago">
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
                      <tbody id="apl-tbody"><!-- JS --></tbody>
                    </table>
                  </div>
                </div>
              </div>
            </div>
            <div class="col-lg-6">
              <form id="form-apl" class="card nt-card shadow-sm rounded-xxl h-100">
                <div class="card-header fw-semibold"><i class="bi bi-plus-circle"></i> Nueva aplicación (lote)</div>
                <div class="card-body">
                  <p class="text-muted small mb-2">Formato: una línea por item — <code>documento_id; monto</code></p>
                  <textarea id="apl-items" class="form-control" rows="8" placeholder="3001; 950.00&#10;3002; 250.00"></textarea>
                </div>
                <div class="card-footer text-end">
                  <button class="btn btn-primary"><i class="bi bi-check2-circle"></i> Aplicar</button>
                </div>
              </form>
            </div>
          </div>

        </div>
      </div>

    </div>
  </main>

  <!-- Modales (los mismos del módulo original) -->
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
            <div class="col-md-3">
              <label class="form-label">proveedor_id</label>
              <input id="proveedor_id" type="number" class="form-control" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">origen_tipo</label>
              <select id="origen_tipo" class="form-select" required>
                <option value="">—</option>
                <option value="C">C (Compra)</option>
                <option value="F">F (Manual)</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">origen_id</label>
              <input id="origen_id" type="number" class="form-control" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">numero_documento</label>
              <input id="numero_documento" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">fecha_emision</label>
              <input id="fecha_emision" type="date" class="form-control" required>
            </div>
            <div class="col-md-4">
              <label class="form-label">fecha_vencimiento</label>
              <input id="fecha_vencimiento" type="date" class="form-control">
            </div>
            <div class="col-md-2">
              <label class="form-label">moneda</label>
              <input id="moneda" class="form-control" value="GTQ" required>
            </div>
            <div class="col-md-2">
              <label class="form-label">monto_total</label>
              <input id="monto_total" type="number" step="0.01" min="0" class="form-control" required>
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn btn-primary" type="submit"><i class="bi bi-save2"></i> Guardar</button>
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
            <div class="col-md-3">
              <label class="form-label">proveedor_id</label>
              <input id="p_proveedor_id" type="number" class="form-control" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">fecha_pago</label>
              <input id="fecha_pago" type="date" class="form-control" required>
            </div>
            <div class="col-md-3">
              <label class="form-label">forma_pago</label>
              <select id="p_forma_pago" class="form-select" required>
                <option value="">—</option>
                <option value="transferencia">Transferencia</option>
                <option value="efectivo">Efectivo</option>
                <option value="cheque">Cheque</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">monto_total</label>
              <input id="p_monto_total" type="number" step="0.01" min="0" class="form-control" required>
            </div>
            <div class="col-12">
              <label class="form-label">observaciones</label>
              <input id="observaciones" class="form-control" placeholder="Opcional">
            </div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn btn-primary" type="submit"><i class="bi bi-save2"></i> Guardar</button>
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
  <script src="assets/js/cxp.js?v=11"></script>
</body>
</html>


