<%-- 
    Document   : compras
    Created on : 10 oct 2025, 0:49:18
    Author     : DELL

--%>

<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Nextech — Compras</title>

  <!-- URL base del backend -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css">

  <!-- Tema y estilos -->
  <link rel="stylesheet" href="assets/css/app.css?v=16">
  <link rel="stylesheet" href="assets/css/base.css?v=16">
  <link rel="stylesheet" href="assets/css/compras.css?v=16">

  <!-- Guard de autenticación (si lo usas en otros módulos) -->
  <script src="assets/js/auth.guard.js"></script>

  <style>
    /* Botón Regresar: mismo look en todo el sistema */
    .nt-back {
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border); background: transparent; color: var(--nt-primary);
    }
    .nt-back:hover{ background: var(--nt-surface-2); color: var(--nt-primary); }

    /* Tarjetas del selector de modo */
    .modo-card{
      border:1px solid var(--nt-border);
      background: var(--nt-surface);
      border-radius: 14px;
      padding: 1rem;
      cursor: pointer;
      transition: transform .08s ease, background .15s ease, border-color .15s ease;
      height: 100%;
    }
    .modo-card:hover{ transform: translateY(-1px); background: var(--nt-surface-2); border-color: var(--nt-border); }
    .modo-card .icon{
      width:48px;height:48px;border-radius:12px;
      display:flex;align-items:center;justify-content:center;
      background: rgba(127,90,240,.15);
      margin-bottom:.5rem;
      font-size: 1.35rem;
    }
    .modo-card h6{ color: var(--nt-primary); margin:0; }
    .modo-card p{ margin: .25rem 0 0; color: var(--nt-text); }

    /* Maestro–detalle */
    .det-mini { font-size:.8rem; color: var(--nt-text); }
    .det-meta { display:flex; gap:.5rem; flex-wrap:wrap; }
    .det-meta .form-control-plaintext { padding:0; min-height:auto; }

    /* Mantener input de ID (JS legacy) pero oculto visualmente */
    .legacy-producto-id{ display:none !important; }
  </style>
</head>
<body class="nt-bg">
<script>
  // (Opcional) Restringe acceso si quieres que solo roles permitidos entren
  // Auth.ensure(['ADMIN']); // descomenta si aplica
</script>

<!-- Header minimal, sin menú de módulos -->
<header class="navbar nt-navbar">
  <div class="container d-flex align-items-center justify-content-between">
    <a class="navbar-brand d-flex align-items-center gap-2 fw-bold">
      <i class="bi bi-bag-plus"></i> Nextech — Compras
    </a>
    <div class="d-flex align-items-center gap-2">
      <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
        <i class="bi bi-arrow-left"></i> Regresar
      </button>
    </div>
  </div>
</header>

<main class="container my-4">
  <!-- Título + acciones -->
  <div class="d-flex align-items-center justify-content-between mb-3 comp-actions">
    <h1 class="comp-hero-title h3 mb-0 nt-title"><i class="bi bi-cart2 me-2"></i>Compras</h1>
    <div class="d-flex gap-2">
      <button id="btnNuevaCompra" class="btn nt-btn-accent"><i class="bi bi-plus-circle"></i> Nueva compra</button>
      <button id="btnRefrescar" class="btn btn-outline-secondary"><i class="bi bi-arrow-clockwise"></i> Refrescar</button>
    </div>
  </div>

  <!-- Filtros -->
  <div class="comp-filters mb-3">
    <div class="row g-3 align-items-end">
      <div class="col-md-2">
        <label class="form-label">Fecha del</label>
        <input type="date" id="fDel" class="form-control">
      </div>
      <div class="col-md-2">
        <label class="form-label">Fecha al</label>
        <input type="date" id="fAl" class="form-control">
      </div>

      <!-- Proveedor: select + hidden (compat con backend/JS actual) -->
      <div class="col-md-3">
        <label class="form-label">Proveedor</label>
        <select id="fProveedorSel" class="form-select">
          <option value="">— Todos —</option>
        </select>
        <input type="hidden" id="fProveedorId">
      </div>

      <div class="col-md-2">
        <label class="form-label">Estado</label>
        <select id="fEstado" class="form-select">
          <option value="">— Todos —</option>
          <option value="P">Pendiente</option>
          <option value="R">Recibida</option>
          <option value="C">Cerrada</option>
          <option value="X">Anulada</option>
        </select>
      </div>
      <div class="col-md-2">
        <label class="form-label">Buscar</label>
        <input type="text" id="fTexto" class="form-control" placeholder="N° compra / factura / observaciones...">
      </div>
      <div class="col-md-1 d-grid">
        <button id="btnBuscar" class="btn nt-btn-accent"><i class="bi bi-search"></i> Buscar</button>
      </div>
    </div>
  </div>

  <!-- Tabla -->
  <div class="table-responsive">
    <table class="table table-hover align-middle mb-0" id="tblCompras">
      <thead class="nt-table-head">
        <tr>
          <th>#</th>
          <th>N° Compra</th>
          <th>Factura Proveedor</th>
          <th>Fecha</th>
          <th>Proveedor</th>
          <th>Bodega destino</th>
          <th class="text-end">Subtotal</th>
          <th class="text-end">Desc.</th>
          <th class="text-end">IVA</th>
          <th class="text-end">Total</th>
          <th>Estado</th>
          <th style="width: 210px;">Acciones</th>
        </tr>
      </thead>
      <tbody><!-- rows por JS --></tbody>
    </table>
  </div>
</main>

<!-- ======= MODALES ======= -->

<!-- Selector de modo de edición -->
<div class="modal fade" id="mdlModoEdicion" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-md">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-sliders me-2"></i>Selecciona el modo de edición</h5>
        <button class="btn-close" type="button" data-mm-close></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="modo_compraId">
        <div class="row g-3">
          <div class="col-md-6">
            <div class="modo-card h-100" id="optEditarCabecera">
              <div class="icon"><i class="bi bi-pencil-square"></i></div>
              <h6>Editar cabecera</h6>
              <p class="small">Modifica proveedor, fechas, documento y observaciones.</p>
            </div>
          </div>
          <div class="col-md-6">
            <div class="modo-card h-100" id="optMaestroDetalle">
              <div class="icon"><i class="bi bi-diagram-3"></i></div>
              <h6>Editar maestro–detalle</h6>
              <p class="small">Gestiona líneas (agregar, editar, eliminar) y totales.</p>
            </div>
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" type="button" data-mm-close>Cerrar</button>
      </div>
    </div>
  </div>
</div>

<!-- Cabecera: crear/editar -->
<div class="modal fade" id="mdlCabecera" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <form class="modal-content" id="frmCabecera">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i><span id="cabeceraTitle">Nueva compra</span></h5>
        <button class="btn-close" type="button" data-mm-close></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="cab_compraId">
        <div class="row g-3">
          <div class="col-md-3"><label class="form-label">Usuario ID</label><input type="number" id="cab_usuarioId" class="form-control" required></div>
          <div class="col-md-3"><label class="form-label">N° Compra</label><input type="text" id="cab_numeroCompra" class="form-control" maxlength="20" required></div>
          <div class="col-md-3"><label class="form-label">Factura proveedor</label><input type="text" id="cab_noFacturaProveedor" class="form-control" maxlength="50" required></div>
          <div class="col-md-3"><label class="form-label">Fecha</label><input type="date" id="cab_fechaCompra" class="form-control" required></div>

          <!-- Selects poblados por JS -->
          <div class="col-md-6">
            <label class="form-label">Proveedor</label>
            <select id="cab_proveedorSel" class="form-select" required>
              <option value="">Cargando...</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Bodega destino</label>
            <select id="cab_bodegaSel" class="form-select" required>
              <option value="">Cargando...</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Empleado comprador</label>
            <select id="cab_compradorSel" class="form-select" required>
              <option value="">Cargando...</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Empleado autoriza</label>
            <select id="cab_autorizaSel" class="form-select">
              <option value="">— Sin autorizar —</option>
            </select>
          </div>

          <div class="col-12"><label class="form-label">Observaciones</label><textarea id="cab_observaciones" rows="2" class="form-control"></textarea></div>
        </div>

        <hr class="my-4"/>

        <!-- Detalle inicial (solo al crear) -->
        <div id="panelDetalleInicial">
          <div class="d-flex align-items-center justify-content-between mb-2">
            <h6 class="mb-0"><i class="bi bi-list-ul me-2"></i>Detalle inicial</h6>
            <button type="button" class="btn btn-sm btn-outline-primary" id="btnAddLinea">
              <i class="bi bi-plus-circle"></i> Agregar línea
            </button>
          </div>
          <div class="table-responsive">
            <table class="table table-sm align-middle" id="tblDetalleNuevo">
              <thead>
                <tr>
                  <th style="width: 28%;">Producto</th>
                  <th style="width: 9%;" class="text-end">Cant.</th>
                  <th style="width: 13%;" class="text-end">P. Unit</th>
                  <th style="width: 12%;" class="text-end">Desc.</th>
                  <th style="width: 18%;">Lote</th>
                  <th style="width: 15%;">Vence</th>
                  <th style="width: 5%;"></th>
                </tr>
              </thead>
              <tbody><!-- filas por JS --></tbody>
            </table>
          </div>
          <div class="det-mini mt-1">
            <i class="bi bi-info-circle"></i> Al seleccionar un producto, se podrán autollenar código, unidad, stock y precio.
          </div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" type="button" data-mm-close>Cancelar</button>
        <button class="btn btn-primary" type="submit" id="btnGuardarCabecera"><i class="bi bi-save"></i> Guardar</button>
      </div>
    </form>
  </div>
</div>

<!-- Ver compra (maestro–detalle) -->
<div class="modal fade" id="mdlCompra" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-receipt me-2"></i>Compra <span id="cmp_numero"></span></h5>
        <button class="btn btn-sm btn-outline-secondary me-2" id="btnEditarCabeceraModal"><i class="bi bi-pencil-square"></i> Editar cabecera</button>
        <button class="btn btn-sm btn-outline-primary me-2" id="btnAgregarDetalleModal"><i class="bi bi-plus-circle"></i> Agregar líneas</button>
        <button class="btn btn-sm btn-outline-danger" id="btnAnularCompra"><i class="bi bi-x-circle"></i> Anular</button>
        <button class="btn-close ms-auto" type="button" data-mm-close></button>
      </div>
      <div class="modal-body">
        <div class="row g-2 mb-3">
          <div class="col-md-3"><div class="small text-muted">Proveedor</div><div id="cmp_proveedor"></div></div>
          <div class="col-md-3"><div class="small text-muted">Factura</div><div id="cmp_factura"></div></div>
          <div class="col-md-3"><div class="small text-muted">Bodega</div><div id="cmp_bodega"></div></div>
          <div class="col-md-3"><div class="small text-muted">Estado</div><span id="cmp_estado" class="badge bg-secondary badge-estado"></span></div>
        </div>

        <div class="table-responsive">
          <table class="table table-sm align-middle" id="tblDetalleExistente">
            <thead>
              <tr>
                <th>#</th>
                <th>Producto</th>
                <th class="text-end">Cant.</th>
                <th class="text-end">P. Unit</th>
                <th class="text-end">Desc.</th>
                <th class="text-end">Subtotal</th>
                <th>Lote</th>
                <th>Vence</th>
                <th style="width: 110px;">Acciones</th>
              </tr>
            </thead>
            <tbody><!-- rows por JS --></tbody>
          </table>
        </div>
      </div>
      <div class="modal-footer">
        <small class="text-muted me-auto" id="cmp_totales"></small>
        <button class="btn btn-primary" type="button" id="btnGuardarMaster"><i class="bi bi-check2-circle"></i> Guardar</button>
        <button class="btn btn-secondary" type="button" data-mm-close>Cerrar</button>
      </div>
    </div>
  </div>
</div>

<!-- Agregar líneas -->
<div class="modal fade" id="mdlAgregarLineas" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog modal-lg modal-dialog-scrollable">
    <form class="modal-content" id="frmAgregarLineas">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-plus-circle me-2"></i>Agregar líneas</h5>
        <button class="btn-close" type="button" data-mm-close></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="add_compraId">
        <input type="hidden" id="add_usuarioId">
        <div class="d-flex justify-content-between mb-2">
          <div class="small text-muted">Compra: <span id="add_compraTitulo"></span></div>
          <button type="button" class="btn btn-sm btn-outline-primary" id="btnAddLinea2"><i class="bi bi-node-plus"></i> Agregar línea</button>
        </div>

        <div class="table-responsive">
          <table class="table table-sm align-middle" id="tblDetalleAgregar">
            <thead>
              <tr>
                <th style="width: 28%;">Producto</th>
                <th style="width: 11%;" class="text-end">Cant.</th>
                <th style="width: 15%;" class="text-end">P. Unit</th>
                <th style="width: 13%;" class="text-end">Desc.</th>
                <th style="width: 18%;">Lote</th>
                <th style="width: 15%;">Vence</th>
                <th style="width: 5%;"></th>
              </tr>
            </thead>
            <tbody><!-- por JS --></tbody>
          </table>
        </div>
        <div class="det-mini mt-1">
          <i class="bi bi-info-circle"></i> El precio por defecto y meta de producto se tomarán del autofill.
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" type="button" data-mm-close>Cancelar</button>
        <button class="btn btn-primary" type="submit"><i class="bi bi-save"></i> Guardar líneas</button>
      </div>
    </form>
  </div>
</div>

<!-- Editar línea -->
<div class="modal fade" id="mdlEditarLinea" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" id="frmEditarLinea">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i>Editar línea</h5>
        <button class="btn-close" type="button" data-mm-close></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="ed_compraId">
        <input type="hidden" id="ed_detalleId">
        <input type="hidden" id="ed_usuarioId">
        <div class="row g-3">
          <div class="col-6"><label class="form-label">Precio unitario</label><input type="number" step="0.01" class="form-control" id="ed_precioUnitario" required></div>
          <div class="col-6"><label class="form-label">Descuento</label><input type="number" step="0.01" class="form-control" id="ed_descuentoLinea"></div>
          <div class="col-6"><label class="form-label">Cantidad pedida</label><input type="number" class="form-control" id="ed_cantidadPedida"></div>
          <div class="col-6"><label class="form-label">Lote</label><input type="text" class="form-control" id="ed_lote"></div>
          <div class="col-6"><label class="form-label">Fecha vencimiento</label><input type="date" class="form-control" id="ed_fechaVencimiento"></div>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" type="button" data-mm-close>Cancelar</button>
        <button class="btn btn-primary" type="submit"><i class="bi bi-save"></i> Guardar cambios</button>
      </div>
    </form>
  </div>
</div>

<!-- Anular compra -->
<div class="modal fade" id="mdlAnular" data-bs-backdrop="static" data-bs-keyboard="false" tabindex="-1" aria-hidden="true">
  <div class="modal-dialog">
    <form class="modal-content" id="frmAnular">
      <div class="modal-header">
        <h5 class="modal-title"><i class="bi bi-x-circle me-2 text-danger"></i>Anular compra</h5>
        <button class="btn-close" type="button" data-mm-close></button>
      </div>
      <div class="modal-body">
        <input type="hidden" id="anu_compraId">
        <input type="hidden" id="anu_usuarioId">
        <div class="mb-3">
          <label class="form-label">Motivo</label>
          <textarea id="anu_motivo" class="form-control" rows="3" required placeholder="Explique el motivo de anulación"></textarea>
        </div>
      </div>
      <div class="modal-footer">
        <button class="btn btn-secondary" type="button" data-mm-close>Cancelar</button>
        <button class="btn btn-danger" type="submit"><i class="bi bi-x-octagon"></i> Anular</button>
      </div>
    </form>
  </div>
</div>

<!-- Plantillas de fila -->
<template id="tplFilaDetalleNuevo">
  <tr>
    <td>
      <select class="form-select form-select-sm prod-select" aria-label="Producto">
        <option value="">— Seleccione —</option>
      </select>
      <input type="number" class="form-control form-control-sm legacy-producto-id inp-productoId" placeholder="ID">
      <div class="det-meta mt-1">
        <span class="form-control-plaintext det-mini"><i class="bi bi-upc-scan"></i> <span class="meta-codigo">—</span></span>
        <span class="form-control-plaintext det-mini"><i class="bi bi-rulers"></i> <span class="meta-unidad">—</span></span>
        <span class="form-control-plaintext det-mini"><i class="bi bi-box-seam"></i> Stock: <span class="meta-stock">—</span></span>
      </div>
    </td>
    <td><input type="number" min="1" class="form-control form-control-sm text-end inp-cantidad" placeholder="0" value="1"></td>
    <td><input type="number" step="0.01" class="form-control form-control-sm text-end inp-precio" placeholder="0.00"></td>
    <td><input type="number" step="0.01" class="form-control form-control-sm text-end inp-descuento" placeholder="0.00"></td>
    <td><input type="text" class="form-control form-control-sm inp-lote" placeholder="Lote"></td>
    <td><input type="date" class="form-control form-control-sm inp-vence"></td>
    <td class="text-center"><button type="button" class="btn btn-sm btn-outline-danger btn-del-linea"><i class="bi bi-trash"></i></button></td>
  </tr>
</template>

<template id="tplFilaDetalleAgregar">
  <tr>
    <td>
      <select class="form-select form-select-sm prod-select" aria-label="Producto">
        <option value="">— Seleccione —</option>
      </select>
      <input type="number" class="form-control form-control-sm legacy-producto-id inp-productoId" placeholder="ID">
      <div class="det-meta mt-1">
        <span class="form-control-plaintext det-mini"><i class="bi bi-upc-scan"></i> <span class="meta-codigo">—</span></span>
        <span class="form-control-plaintext det-mini"><i class="bi bi-rulers"></i> <span class="meta-unidad">—</span></span>
        <span class="form-control-plaintext det-mini"><i class="bi bi-box-seam"></i> Stock: <span class="meta-stock">—</span></span>
      </div>
    </td>
    <td><input type="number" min="1" class="form-control form-control-sm text-end inp-cantidad" placeholder="0" value="1"></td>
    <td><input type="number" step="0.01" class="form-control form-control-sm text-end inp-precio" placeholder="0.00"></td>
    <td><input type="number" step="0.01" class="form-control form-control-sm text-end inp-descuento" placeholder="0.00"></td>
    <td><input type="text" class="form-control form-control-sm inp-lote" placeholder="Lote"></td>
    <td><input type="date" class="form-control form-control-sm inp-vence"></td>
    <td class="text-center"><button type="button" class="btn btn-sm btn-outline-danger btn-del-linea"><i class="bi bi-trash"></i></button></td>
  </tr>
</template>

<!-- Toasts -->
<div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
  <div id="toastStack" class="toast-container"></div>
</div>

<!-- JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="assets/js/common.js?v=17"></script>
<script src="assets/js/compras.js?v=17"></script>

<script>
  // Botón Regresar inteligente por rol
  function parseAuthUser(){
    try{
      if (window.Auth?.user) return window.Auth.user;
      const raw = localStorage.getItem('auth_user');
      return raw ? JSON.parse(raw) : null;
    }catch(_){ return null; }
  }

  function homeForRole(role){
    // Ajusta aquí los dashboards de cada rol
    const HOME_BY_ROLE = {
      'ADMIN': 'Dashboard.jsp',
      'OPERADOR': 'dashboard_operador.jsp',
      'RRHH': 'rrhh-dashboard.jsp'
      // agrega más roles si aplica
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
