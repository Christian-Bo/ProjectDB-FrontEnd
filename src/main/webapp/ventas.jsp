<%-- 
  Document   : ventas (separado: sin pagos)
  Created on : 02/11/2025
  Author     : NextTech (ajustado por Assistant)
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Ventas | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Base del backend -->
  <meta name="api-base" content="https://nexttech-backend-jw9h.onrender.com">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta / tema del proyecto -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=13">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=13">

  <style>
    /* ====== Tema (sin hashes) ====== */
    body.nt-bg { background: var(--nt-bg); color: var(--nt-text); }
    .nt-navbar { background: var(--nt-surface); border-bottom: 1px solid var(--nt-border); }
    .nt-title { color: var(--nt-primary); }
    .nt-subtitle { color: var(--nt-text); opacity:.9; }
    .nt-card { background: var(--nt-surface); border: 1px solid var(--nt-border); border-radius: 1rem; }
    .nt-card:hover { transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.25); transition: .12s; }
    .nt-table-head { background: var(--nt-surface-2); color: var(--nt-primary); }
    .nt-btn-accent { background: var(--nt-accent); color: #fff; border: none; }
    .nt-btn-accent:hover { filter: brightness(0.95); }
    .nt-back { display:inline-flex; align-items:center; gap:.5rem; border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary); }
    .nt-back:hover { background:var(--nt-surface-2); }
    .pager .btn { border-color: var(--nt-border); }

    /* Modales */
    .modal-backdrop { --bs-backdrop-bg: #0b0d14; --bs-backdrop-opacity: .78; backdrop-filter: blur(2px); }
    .nt-modal .modal-content{
      background-color: var(--nt-surface, #12131a);
      color: var(--nt-text, #e7e9ee);
      border: 1px solid var(--nt-border, rgba(255,255,255,.12));
      border-radius: 1rem;
      box-shadow: 0 24px 64px rgba(0,0,0,.6);
    }
    .nt-modal .modal-header, .nt-modal .modal-footer{ border-color: var(--nt-border, rgba(255,255,255,.12)); }
    .nt-modal .form-control, .nt-modal .form-select{
      background: var(--nt-surface-2, #1b1d2a);
      color: var(--nt-text, #e7e9ee);
      border-color: var(--nt-border, rgba(255,255,255,.12));
    }
    .nt-modal .form-control:focus, .nt-modal .form-select:focus{
      border-color: var(--nt-accent, #7a5af8);
      box-shadow: 0 0 0 .2rem rgba(122,90,248,.25);
    }
    .nt-modal .form-control.is-invalid, .nt-modal .form-select.is-invalid{
      border-color:#dc3545!important; box-shadow:0 0 0 .2rem rgba(220,53,69,.25)!important;
    }

    /* Tabs (sin modificar URL) */
    .nt-tabs .nav-link { color: var(--nt-text); opacity:.8; border:1px solid var(--nt-border); }
    .nt-tabs .nav-link.active { color: var(--nt-text); opacity:1; background: var(--nt-surface-2); border-color: var(--nt-accent); }

    .d-none-important{ display:none !important; }

    /* Selector de edición */
    .nt-edit-modal { border-radius: 1rem; }
    .nt-edit-option {
      border: 1px solid var(--bs-border-color);
      background: #1b2233;
      border-radius: 0.85rem;
      padding: 0.9rem 1rem;
      display: grid;
      grid-template-columns: auto 1fr auto;
      align-items: center;
      gap: 0.9rem;
      transition: all .18s ease;
      color: #fff;
    }
    .nt-edit-option__icon {
      width: 44px; height: 44px; border-radius: 12px; display: grid; place-items: center;
      background: var(--bs-primary-bg-subtle, rgba(13,110,253,.08)); color: var(--bs-primary); font-size: 1.25rem; flex-shrink: 0;
    }
    .nt-edit-option__title { font-weight: 600; line-height: 1.2; margin-top: 2px; }
    .nt-edit-option__desc { color: #fff; opacity:.8; font-size: .925rem; }
    .nt-edit-option__chevron { color: var(--bs-secondary-color); font-size: 1.1rem; opacity: .85; }
  </style>

  <!-- utilidades comunes -->
  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2">
        <i class="bi bi-receipt"></i> NextTech — Ventas 
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <!-- Tabs de navegación (sin hash) -->
  <div class="container pt-3">
    <ul class="nav nav-pills nt-tabs gap-2 mb-3" id="ntTabs">
      <li class="nav-item"><a href="#" class="nav-link" data-view="lista"><i class="bi bi-list-ul me-1"></i>Listado</a></li>
      <li class="nav-item"><a href="#" class="nav-link" data-view="detalle"><i class="bi bi-eye me-1"></i>Detalle</a></li>
      <%-- Nota: pestaña Pagos eliminada --%>
    </ul>
  </div>

  <!-- ====== VISTA: LISTADO ====== -->
  <section id="view-lista" class="container py-3" data-view="lista">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <h2 class="m-0 nt-title"><i class="bi bi-receipt"></i> Ventas</h2>
        <div class="nt-subtitle">Listado, creación y edición</div>
      </div>
      <div class="d-flex gap-2">
        <%-- Botón "Ver pagos de ventas" eliminado --%>
        <button class="btn nt-btn-accent" data-bs-toggle="modal" data-bs-target="#modalNuevaVenta">
          <i class="bi bi-plus-circle me-1"></i> Nueva venta
        </button>
      </div>
    </div>

    <!-- Filtros -->
    <div class="card nt-card mb-3">
      <div class="card-body">
        <form id="filtros" onsubmit="VLIST.buscar(event)" class="row g-3 align-items-end">
          <div class="col-md-3">
            <label class="form-label">Desde</label>
            <input type="date" name="desde" class="form-control"/>
          </div>
          <div class="col-md-3">
            <label class="form-label">Hasta</label>
            <input type="date" name="hasta" class="form-control"/>
          </div>
          <div class="col-md-3">
            <label class="form-label">Cliente</label>
            <select id="selClienteFiltro" name="clienteId" class="form-select">
              <option value="">(Todos)</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label">Número venta</label>
            <input type="text" name="numeroVenta" placeholder="Ej. V-0007 o 007" class="form-control"/>
          </div>

          <div class="col-12 d-flex flex-wrap gap-3 justify-content-between align-items-center">
            <div class="form-check form-switch">
              <input class="form-check-input" type="checkbox" role="switch" id="incluirAnuladas" name="incluirAnuladas">
              <label class="form-check-label" for="incluirAnuladas">Mostrar anuladas</label>
            </div>
            <div class="d-flex gap-2 ms-auto">
              <button class="btn nt-btn-accent" type="submit"><i class="bi bi-search me-1"></i>Buscar</button>
              <button class="btn btn-outline-secondary" type="button" onclick="VLIST.limpiar()"><i class="bi bi-x-circle me-1"></i>Limpiar</button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- Paginación -->
    <div class="d-flex justify-content-between align-items-center mb-2">
      <div class="d-flex align-items-center gap-2 pager">
        <button class="btn btn-outline-secondary btn-sm" onclick="VLIST.cambiarPagina(-1)">&laquo; Anterior</button>
        <div> Página <span id="pActual">1</span> </div>
        <button class="btn btn-outline-secondary btn-sm" onclick="VLIST.cambiarPagina(1)">Siguiente &raquo;</button>
      </div>
      <small class="text-muted">Mostrando 10 por página</small>
    </div>

    <!-- Tabla -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table id="tabla" class="table table-hover align-middle mb-0">
          <thead class="nt-table-head">
            <tr>
              <th>ID</th>
              <th>Número</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th class="text-end">Total</th>
              <th>Estado</th>
              <th>Tipo pago</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="tablaEmpty" class="p-3 text-muted d-none">Sin resultados para los filtros actuales.</div>
    </div>
  </section>

  <!-- ====== VISTA: DETALLE ====== -->
  <section id="view-detalle" class="container py-3 d-none" data-view="detalle">
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <h2 class="m-0 nt-title"><i class="bi bi-eye"></i> Detalle de venta</h2>
        <div class="nt-subtitle">Consulta de cabecera y líneas</div>
      </div>
      <button class="btn btn-outline-secondary" type="button" onclick="Router.navigate('lista')">
        <i class="bi bi-list-ul me-1"></i> Ir al listado
      </button>
    </div>

    <!-- Cabecera -->
    <div class="card nt-card mb-3">
      <div class="card-body" id="cabecera">
        <div class="text-muted">Cargando venta...</div>
      </div>
    </div>

    <!-- Saldos / Acciones (solo emitir factura) -->
    <div class="card nt-card mb-3" id="boxSaldos" style="display:none;">
      <div class="card-body d-flex align-items-center justify-content-between flex-wrap gap-3">
        <div class="d-flex flex-column">
          <div class="small text-muted">Origen</div>
          <div id="saldoOrigen" class="fw-semibold">—</div>
        </div>
        <div class="d-flex flex-column">
          <div class="small text-muted">Total</div>
          <div id="saldoTotal" class="badge bg-primary-subtle text-primary-emphasis fs-6">—</div>
        </div>
        <div class="d-flex flex-column">
          <div class="small text-muted">Pagado</div>
          <div id="saldoPagado" class="badge bg-success-subtle text-success-emphasis fs-6">—</div>
        </div>
        <div class="d-flex flex-column">
          <div class="small text-muted">Saldo</div>
          <div id="saldoRestante" class="badge bg-warning-subtle text-warning-emphasis fs-6">—</div>
        </div>

        <div class="ms-auto d-flex gap-2">
          <!-- Emitir factura: DIRECTO, sin modal -->
          <button id="btnEmitirFactura" type="button" class="btn btn-outline-info" style="display:none;">
            <i class="bi bi-filetype-pdf me-1"></i> Emitir factura (PDF)
          </button>
          <%-- Botón Registrar pago y link CxC eliminados --%>
        </div>
      </div>
    </div>

    <!-- Detalle (líneas) -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table id="tablaDet" class="table table-hover align-middle mb-0">
          <thead class="nt-table-head">
            <tr>
              <th>ID Detalle</th>
              <th>Producto ID</th>
              <th>Cantidad</th>
              <th>Precio</th>
              <th>Desc. línea</th>
              <th>Subtotal</th>
              <th>Lote</th>
              <th>Vence</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="tablaDetEmpty" class="p-3 text-muted d-none">Esta venta no tiene líneas.</div>
    </div>
  </section>

  <%-- ====== VISTA: PAGOS eliminada por separación a ventas_pagos.jsp ====== --%>

  <!-- ====== MODALES ====== -->

  <!-- Modal Nueva Venta -->
  <div class="modal fade nt-modal" id="modalNuevaVenta" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
      <div class="modal-content nt-card">
        <form id="formVenta" onsubmit="VLIST.guardarVenta(event)">
          <div class="modal-header">
            <h5 class="modal-title">Registrar nueva venta</h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
          </div>
          <div class="modal-body">
            <div class="row g-3">
              <div class="col-md-4">
                <label class="form-label">Cliente *</label>
                <select id="selCliente" class="form-select" name="clienteId" required>
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Vendedor</label>
                <select id="selVendedor" class="form-select" name="vendedorId">
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Cajero</label>
                <select id="selCajero" class="form-select" name="cajeroId">
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Bodega Origen *</label>
                <select id="selBodegaOrigen" class="form-select" name="bodegaOrigenId" required>
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Tipo de Pago *</label>
                <select class="form-select" name="tipoPago" required>
                  <option value="C" selected>Contado</option>
                  <option value="R">Crédito</option>
                </select>
              </div>
              <div class="col-md-4">
                <label class="form-label">Serie *</label>
                <select id="selSerie" class="form-select" name="serieId" required>
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-12">
                <label class="form-label">Observaciones</label>
                <input type="text" class="form-control" name="observaciones" placeholder="Venta mostrador">
              </div>
            </div>

            <hr class="my-4">
            <div class="d-flex align-items-center justify-content-between mb-2">
              <h6 class="m-0">Items</h6>
              <button type="button" class="btn btn-outline-primary btn-sm" onclick="VLIST.agregarItem()">+ Agregar ítem</button>
            </div>
            <div class="table-responsive">
              <table class="table table-sm table-striped align-middle" id="tablaItems">
                <thead class="nt-table-head">
                  <tr>
                    <th style="width:360px;">Producto *</th>
                    <th style="width:110px;">Stock</th>
                    <th style="width:120px;">Cantidad *</th>
                    <th style="width:150px;">Precio Unitario *</th>
                    <th style="width:120px;">Descuento</th>
                    <th style="width:140px;">Lote</th>
                    <th style="width:140px;">Vence</th>
                    <th style="width:60px;"></th>
                  </tr>
                </thead>
                <tbody></tbody>
              </table>
            </div>
            <div class="form-text">Agrega al menos 1 ítem. Campos con * son obligatorios.</div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
            <button type="submit" class="btn nt-btn-accent">Guardar venta</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Modal Selector de Edición -->
  <div class="modal fade nt-modal" id="modalAccionesEdicion" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-md">
      <div class="modal-content nt-card nt-edit-modal shadow-lg border-0">
        <div class="modal-header py-3 border-0">
          <div class="d-flex align-items-center gap-2">
            <span class="badge rounded-pill bg-primary-subtle text-primary fw-semibold px-3 py-2">
              <i class="bi bi-sliders2-vertical me-1"></i> Acciones
            </span>
            <h5 class="modal-title mb-0">¿Qué deseas editar?</h5>
          </div>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>

        <div class="modal-body pt-0">
          <input type="hidden" id="editTargetId">
          <p class="text-secondary small mb-4">
            Selecciona el ámbito de edición para la venta <b id="editTargetNumero"></b>.
          </p>

          <div class="row g-3">
            <div class="col-12">
              <button type="button" class="nt-edit-option w-100 text-start" onclick="VLIST.abrirEditarCabecera()" aria-label="Editar cabecera de la venta">
                <div class="nt-edit-option__icon"><i class="bi bi-pencil-square"></i></div>
                <div class="nt-edit-option__body">
                  <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-primary-subtle text-primary">Cabecera</span>
                    <span class="text-muted small">Cliente, tipo de pago, vendedor, observaciones</span>
                  </div>
                  <div class="nt-edit-option__title">Editar datos de cabecera</div>
                  <div class="nt-edit-option__desc">Modifica metadatos generales sin tocar los ítems de la venta.</div>
                </div>
                <div class="nt-edit-option__chevron"><i class="bi bi-chevron-right"></i></div>
              </button>
            </div>

            <div class="col-12">
              <button type="button" class="nt-edit-option w-100 text-start" onclick="VLIST.abrirEditarMaestroDetalle()" aria-label="Editar detalle de la venta">
                <div class="nt-edit-option__icon"><i class="bi bi-diagram-3"></i></div>
                <div class="nt-edit-option__body">
                  <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-success-subtle text-success">Maestro-detalle</span>
                    <span class="text-muted small">Productos, cantidades, precios, lotes</span>
                  </div>
                  <div class="nt-edit-option__title">Editar ítems de la venta</div>
                  <div class="nt-edit-option__desc">Agrega, actualiza o elimina líneas. Controla stock y precios por bodega.</div>
                </div>
                <div class="nt-edit-option__chevron"><i class="bi bi-chevron-right"></i></div>
              </button>
            </div>
          </div>
        </div>

        <div class="modal-footer border-0 pt-0">
          <button type="button" class="btn btn-light" data-bs-dismiss="modal">
            <i class="bi bi-x-circle me-1"></i> Cancelar
          </button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal Editar Venta (Cabecera) -->
  <div class="modal fade nt-modal" id="modalEditarVenta" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
      <div class="modal-content nt-card">
        <form id="formEditarVenta" onsubmit="VLIST.guardarEdicionVenta(event)">
          <div class="modal-header">
            <h5 class="modal-title">Editar cabecera <span id="editNumeroVenta" class="text-muted"></span></h5>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
          </div>
          <div class="modal-body">
            <input type="hidden" id="editVentaId">
            <div class="row g-3">
              <div class="col-md-6">
                <label class="form-label">Cliente *</label>
                <select id="editCliente" class="form-select" required>
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label">Tipo de pago *</label>
                <select id="editTipoPago" class="form-select" required >
                  <option value="C">Contado</option>
                  <option value="R">Crédito</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label">Vendedor</label>
                <select id="editVendedor" class="form-select">
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-md-6">
                <label class="form-label">Cajero</label>
                <select id="editCajero" class="form-select">
                  <option value="">Cargando...</option>
                </select>
              </div>
              <div class="col-12">
                <label class="form-label">Observaciones</label>
                <input type="text" id="editObs" class="form-control" placeholder="Observaciones">
              </div>
            </div>
          </div>
          <div class="modal-footer">
            <button class="btn btn-outline-secondary" type="button" data-bs-dismiss="modal">Cancelar</button>
            <button class="btn nt-btn-accent" type="submit">Guardar cambios</button>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- Modal: Editar maestro-detalle -->
  <div class="modal fade nt-modal" id="modalEditarDetalle" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-scrollable">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Editar detalle <span id="detNumeroVenta" class="text-muted"></span></h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <input type="hidden" id="detVentaId">
          <div class="row g-3 mb-2">
            <div class="col-md-6">
              <label class="form-label">Bodega para movimientos *</label>
              <select id="selBodegaDet" class="form-select" required disabled>
                <option value="">Cargando...</option>
              </select>
              <div class="form-text">Se usa para validar/afectar stock al guardar los cambios.</div>
            </div>
            <div class="col-md-6 d-flex align-items-end justify-content-end">
              <button class="btn btn-outline-primary btn-sm" type="button" onclick="VLIST.agregarItemDet()">+ Agregar línea</button>
            </div>
          </div>
          <div class="table-responsive">
            <table class="table table-sm table-striped align-middle" id="tablaEditarDetalle">
              <thead class="nt-table-head">
                <tr>
                  <th style="width:340px;">Producto *</th>
                  <th style="width:90px;">Stock</th>
                  <th style="width:110px;">Cantidad *</th>
                  <th style="width:140px;">Precio *</th>
                  <th style="width:120px;">Descuento</th>
                  <th style="width:120px;">Lote</th>
                  <th style="width:140px;">Vence</th>
                  <th style="width:60px;"></th>
                </tr>
              </thead>
              <tbody></tbody>
            </table>
          </div>
          <div class="form-text">
            Las líneas existentes se marcan con acción <b>U</b> (Actualizar). Puedes cambiarlas a <b>D</b> (Eliminar).
            Las nuevas líneas se crean con acción <b>A</b> (Agregar).
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
          <button class="btn nt-btn-accent" onclick="VLIST.guardarEdicionDetalle()">Guardar cambios</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Toast (incluye botón de acción) -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="appToast" class="toast align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true">
      <div class="d-flex align-items-center">
        <div class="toast-body" id="toastMsg">Listo.</div>
        <button id="toastAction" type="button" class="btn btn-light btn-sm me-2 d-none"></button>
        <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
      </div>
    </div>
  </div>

  <!-- Bootstrap (ok incluirlo aquí) -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
/* ====== Sync API.baseUrl desde <meta> ====== */
(function(){
  try{
    window.API = window.API || {};
    if (!API.baseUrl || !API.baseUrl.trim()) {
      const meta = document.querySelector('meta[name="api-base"]');
      const base = (window.API_BASE || meta?.getAttribute('content') || '').trim();
      if (base) API.baseUrl = base;
    }
    console.log('[ventas.jsp] API.baseUrl =', API.baseUrl || '(vacío)');
  }catch(_){}
})();

/* ===== Helpers navegación/roles ===== */
function parseAuthUser(){
  try{
    if (window.Auth?.user) return window.Auth.user;
    const raw = localStorage.getItem('auth_user');
    return raw ? JSON.parse(raw) : null;
  }catch(_){ return null; }
}
function homeForRole(role){
  const HOME_BY_ROLE = { 'ADMIN': 'Dashboard.jsp', 'OPERADOR': 'dashboard_operador.jsp', 'RRHH':'rrhh-dashboard.jsp' };
  return HOME_BY_ROLE[role?.toUpperCase?.()] || 'Dashboard.jsp';
}
function goBack(){
  if (history.length > 1) { history.back(); return; }
  const user = parseAuthUser();
  location.href = homeForRole(user?.role || user?.rol);
}

/* ===== Config y helpers de URL ===== */
const ctxRaw = '${pageContext.request.contextPath}';
const ctx = (ctxRaw || '').trim();
function computeApiRoot(){
  try{
    const meta = document.querySelector('meta[name="api-base"]');
    const baseRaw = (window.API_BASE || meta?.getAttribute('content') || '').trim();
    let base = baseRaw;

    if (!base) {
      base = location.origin + (ctx && ctx!=='/' ? ctx : '');
    } else if (base.startsWith('//')) {
      base = location.protocol + base;
    } else if (base.startsWith('/')) {
      base = location.origin + base;
    } else if (!/^https?:\/\//i.test(base)) {
      base = location.origin + '/' + base;
    }

    base = base.replace(/\/+$/,'');
    try{
      const u = new URL(base);
      if (u.hostname.toLowerCase() === 'pdf'){
        base = (location.origin + (ctx && ctx!=='/' ? ctx : '')).replace(/\/+$/,'');
      }
    }catch(_){}
    return base;
  }catch(_){
    return (location.origin + (ctx && ctx!=='/' ? ctx : '')).replace(/\/+$/,'');
  }
}
function joinUrl(base, path){
  return String(base||'').replace(/\/+$/,'') + '/' + String(path||'').replace(/^\/+/,'');
}
function absolutize(url){
  try{
    const u = new URL(url, location.origin);
    if (u.hostname.toLowerCase() === 'pdf'){
      const root = (location.origin + (ctx && ctx!=='/' ? ctx : '')).replace(/\/+$/,'');
      return joinUrl(root, u.pathname + u.search + u.hash);
    }
    return u.toString();
  }catch(_){
    const root = (location.origin + (ctx && ctx!=='/' ? ctx : '')).replace(/\/+$/,'');
    return joinUrl(root, url);
  }
}

const API_ROOT      = computeApiRoot();
const API_VENTAS    = joinUrl(API_ROOT, '/api/ventas');
const API_FACTURAS  = joinUrl(API_ROOT, '/api/facturas');
const API_CATALOGOS = joinUrl(API_ROOT, '/api/catalogos');
const USER_ID       = 1;
const commonHeaders = {'X-User-Id': String(USER_ID)};

/* ===== Toast con acción ===== */
const AppToast = (function(){
  function ensure(){
    let t = document.getElementById('appToast');
    if (!t){
      const wrap = document.createElement('div');
      wrap.innerHTML = `
        <div id="appToast" class="toast position-fixed top-0 end-0 m-3 align-items-center text-bg-primary border-0" role="alert" aria-live="assertive" aria-atomic="true" data-bs-delay="3500" style="z-index:1080;">
          <div class="d-flex align-items-center">
            <div id="toastMsg" class="toast-body">OK</div>
            <button id="toastAction" type="button" class="btn btn-light btn-sm me-2 d-none"></button>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
          </div>
        </div>`;
      document.body.appendChild(wrap.firstElementChild);
      t = document.getElementById('appToast');
    } else {
      const body = t.querySelector('.d-flex') || t;
      if (!document.getElementById('toastMsg')){
        const msg = document.createElement('div');
        msg.id = 'toastMsg';
        msg.className = 'toast-body';
        msg.textContent = 'OK';
        body.insertBefore(msg, body.firstChild);
      }
      if (!document.getElementById('toastAction')){
        const btn = document.createElement('button');
        btn.id = 'toastAction';
        btn.type = 'button';
        btn.className = 'btn btn-light btn-sm me-2 d-none';
        const closeBtn = t.querySelector('.btn-close');
        body.insertBefore(btn, closeBtn || null);
      }
    }
    return t;
  }
  function show(opts){
    const tEl   = ensure();
    const msgEl = document.getElementById('toastMsg');
    const actBtn= document.getElementById('toastAction');

    const delay = opts?.delay ?? (opts?.actionText ? 10000 : 3500);
    tEl.className = 'toast position-fixed top-0 end-0 m-3 align-items-center border-0 ' + (
      opts?.type==='error' ? 'text-bg-danger'
      : opts?.type==='warn' ? 'text-bg-warning'
      : 'text-bg-primary'
    );
    msgEl.textContent = opts?.message ?? 'OK';

    if (actBtn){
      actBtn.classList.add('d-none');
      actBtn.onclick = null;
      if (opts?.actionText && typeof opts?.onAction === 'function'){
        actBtn.textContent = opts.actionText;
        actBtn.classList.remove('d-none');
        actBtn.onclick = function(ev){
          ev.preventDefault();
          try{ opts.onAction(); }catch(_){}
          bootstrap.Toast.getOrCreateInstance(tEl).hide();
        };
      }
    }

    const inst = bootstrap.Toast.getOrCreateInstance(tEl, { delay, autohide: true });
    inst.show();
  }
  return {
    show,
    ok:  (m) => show({ message: m }),
    err: (m) => show({ message: (typeof m==='string'?m:(m && JSON.stringify(m))||'Error interno'), type: 'error' }),
    warn:(m) => show({ message: m, type: 'warn' }),
  };
})();

/* ===== Utils ===== */
function withNoCache(url){
  try{ const u=new URL(url, location.origin); u.searchParams.set('_', String(Date.now())); return u.toString(); }
  catch(_){ return url + (url.includes('?')?'&':'?') + '_=' + Date.now(); }
}
function money(n){ if(n==null || isNaN(n)) return ''; try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); } catch(e){ return 'Q ' + Number(n||0).toFixed(2); } }
function txt(x){ return (x===undefined || x===null) ? '' : String(x); }
async function tryFetchJson(url, options){
  try{
    const opts = options || {};
    const method = (opts.method || 'GET').toUpperCase();
    const finalUrl = method==='GET' ? withNoCache(url) : url;
    const res = await fetch(finalUrl, { cache:'no-store', ...opts });
    const t = await res.text();
    let data=null; try{ data = t ? JSON.parse(t) : null; }catch(_){}
    if(!res.ok) return { ok:false, status:res.status, data };
    return { ok:true, status:res.status, data };
  }catch(err){ return { ok:false, status:0, data:{ error: err.message || 'network' } }; }
}
async function fetchJson(url, opts){
  const r = await tryFetchJson(url, opts);
  if(!r.ok) throw new Error((r.data && (r.data.error||r.data.detail||r.data.message)) || ('HTTP '+r.status));
  return r.data;
}
function asArray(x){ return Array.isArray(x)?x: (x && (x.items||x.content||x.data||x.results||x.records)) || []; }
function setOk(msg){ AppToast.ok(msg || 'OK'); }
function setErr(msg){ AppToast.err(msg); }
function estadoBadge(e){ if(e==='A') return '<span class="badge text-bg-danger">Anulada</span>'; if(e==='P') return '<span class="badge text-bg-success">Procesada</span>'; return '<span class="badge text-bg-secondary">Desconocido</span>'; }
function mapTipoPago(c){ if(!c) return ''; return c==='C'?'Contado':(c==='R'?'Crédito':c); }

/* ========= Router (solo lista/detalle) ========= */
const Router = (function(){
  let current = 'lista';
  let lastDetalleId = null;

  function selectTab(view){
    document.querySelectorAll('#ntTabs .nav-link').forEach(a=>{
      a.classList.toggle('active', a.dataset.view===view);
    });
  }
  function showView(view){
    document.querySelectorAll('[data-view]').forEach(el=>{
      el.classList.toggle('d-none', el.dataset.view!==view);
    });
    selectTab(view);
  }
  async function navigate(view, params){
    current = view || 'lista';
    showView(current);

    if (current === 'lista'){
      await VLIST.initOnce();
      await VLIST.cargar(VLIST.lastFilters);
    }
    if (current === 'detalle'){
      await VDET.initOnce();
      const id = params?.id ?? lastDetalleId;
      if (id){ lastDetalleId = id; await VDET.cargar(id); }
    }
  }
  function init(){
    document.querySelectorAll('#ntTabs .nav-link').forEach(el=>{
      el.addEventListener('click', function(ev){
        ev.preventDefault();
        const v = el.dataset.view;
        if (v) navigate(v);
      });
    });
  }
  return { init, navigate };
})();

/* ========= VISTA LISTA ========= */
const VLIST = (function(){
  let _inited = false, _catalogosCargados = false;
  let _clientes = [], _empleados = [], _bodegas = [], _series=[];
  let cacheVentas = {};
  let page=0, size=10;

  const state = { lastFilters: { incluirAnuladas:false } };
  function getLast(){ return state.lastFilters; }
  function syncPublicFilters(){ if (window.VLIST) window.VLIST.lastFilters = state.lastFilters; }

  async function fetchJsonOrNull(url){ try{ return await fetchJson(url, { headers: commonHeaders }); }catch{ return null; } }
  function fillSelect(sel, data, map, selected){
    let html = sel && sel.id==='selClienteFiltro' ? '<option value="">(Todos)</option>' : '<option value="">Seleccione...</option>';
    for (const it of data){ const o = map(it); html += '<option value="'+o.value+'"'+(String(selected)===String(o.value)?' selected':'')+'>'+o.text+'</option>'; }
    if (sel) sel.innerHTML = html;
  }

  async function cargarClientesFiltro(){
    let cli = await fetchJsonOrNull(API_CATALOGOS + '/clientes?limit=200');
    const clientes = asArray(cli);
    fillSelect(document.getElementById('selClienteFiltro'), clientes, c=>{
      const nombre = c?.nombre ? String(c.nombre) : '';
      const codigo = c?.codigo ? String(c.codigo) : '';
      const txt = nombre ? ((codigo? (codigo+' - '):'') + nombre) : ('CLI-' + c.id);
      return { value:c.id, text:txt };
    }, '');
  }

  async function cargarCatalogos(){
    if (_catalogosCargados) return;
    let cli = await fetchJsonOrNull(API_CATALOGOS + '/clientes?limit=200');
    let emp = await fetchJsonOrNull(API_CATALOGOS + '/empleados?limit=200');
    let bod = await fetchJsonOrNull(API_CATALOGOS + '/bodegas?limit=200');
    let ser = await fetchJsonOrNull(API_CATALOGOS + '/series');
    _clientes=asArray(cli); _empleados=asArray(emp); _bodegas=asArray(bod); _series=asArray(ser);

    fillSelect(document.getElementById('selCliente'), _clientes, c=>({ value:c.id, text: ((c.codigo||('CLI-'+c.id))+' - '+(c.nombre||'')) }));
    fillSelect(document.getElementById('selVendedor'), _empleados, e=>({ value:e.id, text: ((e.codigo||('EMP-'+e.id))+' - '+(e.nombres||'')+' '+(e.apellidos||'')) }));
    fillSelect(document.getElementById('selCajero'), _empleados, e=>({ value:e.id, text: ((e.codigo||('EMP-'+e.id))+' - '+(e.nombres||'')+' '+(e.apellidos||'')) }));
    const selBod = document.getElementById('selBodegaOrigen');
    fillSelect(selBod, _bodegas, b=>({ value:b.id, text:(b.nombre||('Bodega '+b.id)) }));
    fillSelect(document.getElementById('selSerie'), _series, s=>({ value:s.id, text:(s.serie + (s.correlativo?(' ('+s.correlativo+')'):'') ) }));
    if (selBod && [...selBod.options].some(o=>o.value==='1')) selBod.value='1';

    await refrescarProductosDeTodasLasFilas();
    if (!document.querySelector('#tablaItems tbody tr')) agregarItem();
    _catalogosCargados = true;
  }

  function estadoBadgeHtml(e){ return estadoBadge(e); }
  function mapTipoPagoTxt(c){ return mapTipoPago(c); }

  async function cargar(params = {}){
    const qs = new URLSearchParams({ page, size });
    if (params.desde) qs.set('desde', params.desde);
    if (params.hasta) qs.set('hasta', params.hasta);
    if (params.clienteId) qs.set('clienteId', params.clienteId);
    if (params.numeroVenta) qs.set('numeroVenta', params.numeroVenta);
    if (typeof params.incluirAnuladas !== 'undefined') qs.set('incluirAnuladas', params.incluirAnuladas ? '1' : '0');

    const r = await tryFetchJson(API_VENTAS + '?' + qs.toString(), { headers: commonHeaders });
    const rows = r.ok ? asArray(r.data) : [];
    if(!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo consultar ventas'); }

    cacheVentas = {}; for (const v of rows){ cacheVentas[v.id] = v; }
    render(rows);
    const p = document.getElementById('pActual'); if (p) p.textContent = (page+1);
  }

  function render(rows){
    const tbody = document.querySelector('#view-lista #tabla tbody');
    const empty = document.querySelector('#view-lista #tablaEmpty');
    if (!tbody) return;
    tbody.innerHTML = '';
    if (!rows.length){ if (empty) empty.classList.remove('d-none'); return; }
    if (empty) empty.classList.add('d-none');

    for (const v of rows){
      const clienteTxt = (v?.clienteNombre && String(v.clienteNombre).trim()!=='') ? v.clienteNombre : ('ID ' + (v?.clienteId ?? ''));
      const idTxt = v?.id ?? '';
      const tr = document.createElement('tr');
      tr.innerHTML =
        '<td>' + idTxt + '</td>'
      + '<td><button type="button" class="btn btn-link p-0" onclick="Router.navigate(\'detalle\', {id:'+idTxt+'})">' + txt(v?.numeroVenta) + '</button></td>'
      + '<td>' + txt(v?.fechaVenta) + '</td>'
      + '<td>' + clienteTxt + '</td>'
      + '<td class="text-end">' + money(v?.total) + '</td>'
      + '<td>' + estadoBadgeHtml(v?.estado) + '</td>'
      + '<td>' + mapTipoPagoTxt(v?.tipoPago) + '</td>'
      + '<td class="text-end">'
      +   '<div class="btn-group btn-group-sm" role="group">'
      +     '<button class="btn btn-outline-primary" onclick="VLIST.abrirSelectorEdicion('+idTxt+')"><i class="bi bi-pencil"></i></button>'
      +     '<button class="btn btn-outline-secondary" onclick="Router.navigate(\'detalle\', {id:'+idTxt+'})"><i class="bi bi-eye"></i></button>'
      +     '<button class="btn btn-outline-danger" onclick="VLIST.abrirEliminar('+idTxt+')"><i class="bi bi-trash"></i></button>'
      +   '</div>'
      + '</td>';
      tbody.appendChild(tr);
    }
  }

  function buscar(e){
    e.preventDefault();
    const f = e.target;
    page = 0;
    state.lastFilters = {
      desde: f.desde.value,
      hasta: f.hasta.value,
      clienteId: document.getElementById('selClienteFiltro').value,
      numeroVenta: f.numeroVenta.value,
      incluirAnuladas: document.getElementById('incluirAnuladas').checked
    };
    syncPublicFilters();
    cargar(state.lastFilters);
  }
  function limpiar(){
    document.getElementById('filtros').reset();
    const chk = document.getElementById('incluirAnuladas'); if (chk) chk.checked = false;
    const sel = document.getElementById('selClienteFiltro'); if (sel) sel.value = '';
    state.lastFilters = { incluirAnuladas:false };
    page = 0;
    syncPublicFilters();
    cargar(state.lastFilters);
  }
  function cambiarPagina(delta){ page = Math.max(0, page + delta); cargar(state.lastFilters); }

  /* === Nueva venta / items === */
  async function cargarProductosParaBodega(selectEl, bodegaId, selectedId){
    if (!selectEl) return;
    selectEl.disabled = true;
    if (!bodegaId) { selectEl.innerHTML = '<option value="">Seleccione bodega primero…</option>'; selectEl.disabled=false; return; }
    selectEl.innerHTML = '<option value="">Cargando...</option>';

    const url = joinUrl(API_CATALOGOS, '/productos-stock?bodegaId=' + encodeURIComponent(bodegaId));
    let r = await tryFetchJson(url, { headers: commonHeaders });
    if (!r.ok) { r = await tryFetchJson(url); }
    const prods = asArray(r.data);
    let html = '<option value="">Seleccione...</option>';
    for (const p of prods){
      const precio = Number((p?.precioVenta) ?? 0);
      const stock  = Number((p?.stockDisponible) ?? 0);
      const nombre = p?.nombre ? p.nombre : ('Producto ' + (p?.id ?? ''));
      const pid    = p?.id ?? '';
      html += '<option value="'+pid+'" data-precio="'+precio+'" data-stock="'+stock+'"'+(String(selectedId)===String(pid)?' selected':'')+'>'+nombre+'</option>';
    }
    selectEl.innerHTML = html || '<option value="">(sin datos)</option>';
    selectEl.disabled = false;
  }
  async function refrescarProductosDeTodasLasFilas(){
    const bodId = document.getElementById('selBodegaOrigen').value || '';
    const selects = document.querySelectorAll('#tablaItems select[name="productoId"]');
    for (const sel of selects){
      const keep = sel.value || null;
      await cargarProductosParaBodega(sel, bodId, keep);
      sel.dispatchEvent(new Event('change', { bubbles:true }));
    }
  }
  function wireRowEvents(tr){
    const selProd = tr.querySelector('select[name="productoId"]');
    const precio  = tr.querySelector('input[name="precioUnitario"]');
    const stockEl = tr.querySelector('[data-stock]');
    const cantInp = tr.querySelector('input[name="cantidad"]');

    selProd.addEventListener('change', function(){
      const opt = selProd.selectedOptions[0];
      let st = 0, pr = 0;
      if (opt){ st = Number(opt.getAttribute('data-stock') || 0); pr = Number(opt.getAttribute('data-precio') || 0); }
      stockEl.textContent = String(st); stockEl.setAttribute('data-stock', String(st));
      cantInp.max = (st > 0 ? String(st) : ''); if (pr > 0) precio.value = pr;
      cantInp.classList.remove('is-invalid'); cantInp.setCustomValidity('');
    });
    cantInp.addEventListener('input', function(){
      const st = Number(stockEl.getAttribute('data-stock') || 0);
      const q  = Number(cantInp.value || 0);
      if (st > 0 && q > st) { cantInp.classList.add('is-invalid'); cantInp.setCustomValidity('No hay stock suficiente'); }
      else { cantInp.classList.remove('is-invalid'); cantInp.setCustomValidity(''); }
    });
  }
  function agregarItem(){
    const tbody = document.querySelector('#tablaItems tbody');
    const tr = document.createElement('tr');
    tr.innerHTML = ''
      + '<td><select class="form-select form-select-sm" name="productoId" required><option value="">Seleccione bodega primero…</option></select></td>'
      + '<td class="text-center"><span class="badge text-bg-secondary" data-stock="0">0</span></td>'
      + '<td><input type="number" step="1" min="1" class="form-control form-control-sm" name="cantidad" required></td>'
      + '<td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="precioUnitario" required readonly></td>'
      + '<td><input type="number" step="0.01" min="0" class="form-control form-control-sm" name="descuento"></td>'
      + '<td><input type="text" class="form-control form-control-sm" name="lote" placeholder="S/N"></td>'
      + '<td><input type="date" class="form-control form-control-sm" name="fechaVencimiento"></td>'
      + '<td><button type="button" class="btn btn-sm btn-outline-danger" onclick="this.closest(\'tr\').remove()">X</button></td>';
    tbody.appendChild(tr);
    const selProd = tr.querySelector('select[name="productoId"]');
    const bodId   = document.getElementById('selBodegaOrigen').value || '';
    if (bodId) { cargarProductosParaBodega(selProd, bodId, null); }
    wireRowEvents(tr);
  }
  function leerItems(){
    const rows = Array.from(document.querySelectorAll('#tablaItems tbody tr'));
    return rows.map(function(r){
      const get = sel => { const el = r.querySelector(sel); return el ? el.value : null; };
      const toNum = v => (v==='' || v==null) ? null : Number(v);
      const fv = v => (v==='' ? null : v);
      return {
        productoId: toNum(get('select[name="productoId"]')),
        cantidad: toNum(get('input[name="cantidad"]')),
        precioUnitario: toNum(get('input[name="precioUnitario"]')),
        descuento: toNum(get('input[name="descuento"]')),
        lote: fv(get('input[name="lote"]')),
        fechaVencimiento: fv(get('input[name="fechaVencimiento"]'))
      };
    }).filter(it => it.productoId && it.cantidad && it.precioUnitario);
  }
  async function cargarYRefrescarTabla(){
    await cargar(state.lastFilters);
  }
  async function guardarVenta(e){
    e.preventDefault();
    const f = e.target;
    const clienteId = Number(f.clienteId.value);
    const bodegaId  = Number(f.bodegaOrigenId.value);
    const serieId   = Number(document.getElementById('selSerie').value || '');

    if (!clienteId) { setErr('Selecciona un cliente'); return; }
    if (!bodegaId)  { setErr('Selecciona la bodega de origen'); return; }
    if (!serieId)   { setErr('Selecciona la serie de factura'); return; }

    const items = leerItems();
    if (items.length === 0) { setErr('Agrega al menos un ítem'); return; }

    const payload = {
      usuarioId: USER_ID,
      clienteId,
      vendedorId: f.vendedorId.value ? Number(f.vendedorId.value) : null,
      cajeroId:   f.cajeroId.value   ? Number(f.cajeroId.value)   : null,
      bodegaOrigenId: bodegaId,
      tipoPago: f.tipoPago.value || 'C',
      observaciones: f.observaciones.value || null,
      serieId,
      items
    };

    const r = await tryFetchJson(API_VENTAS, {
      method:'POST', headers:{'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify(payload)
    });
    if (!r.ok){ setErr((r.data && (r.data.error||r.data.message||r.data.detail)) || 'No se pudo registrar la venta'); return; }

    bootstrap.Modal.getInstance(document.getElementById('modalNuevaVenta'))?.hide();
    document.getElementById('formVenta').reset();
    document.querySelector('#tablaItems tbody').innerHTML = '';
    agregarItem();

    setOk('Venta registrada');
    page = 0;
    await cargarYRefrescarTabla();
  }

  function abrirSelectorEdicion(id){
    const v = cacheVentas[id];
    if (!v){ setErr('Venta no encontrada'); return; }
    document.getElementById('editTargetId').value = id;
    document.getElementById('editTargetNumero').textContent = v.numeroVenta || ('ID ' + id);
    new bootstrap.Modal(document.getElementById('modalAccionesEdicion')).show();
  }
  function abrirEditarCabecera(){
    const id = Number(document.getElementById('editTargetId').value);
    const v  = cacheVentas[id];
    const doPrep = () => prepararModalEdicion(v);
    if (!_catalogosCargados){ cargarCatalogos().then(doPrep); } else doPrep();
    bootstrap.Modal.getInstance(document.getElementById('modalAccionesEdicion')).hide();
  }
  function abrirEditarMaestroDetalle(){
    const id = Number(document.getElementById('editTargetId').value);
    const doOpen = () => cargarDetalleVentaEnModal(id);
    if (!_catalogosCargados){ cargarCatalogos().then(doOpen); } else { doOpen(); }
    bootstrap.Modal.getInstance(document.getElementById('modalAccionesEdicion')).hide();
  }
  function prepararModalEdicion(v){
    document.getElementById('editVentaId').value = v.id;
    document.getElementById('editNumeroVenta').textContent = v.numeroVenta ? ('#'+v.numeroVenta) : ('ID '+v.id);

    fillSelect(document.getElementById('editCliente'), _clientes, c=>({ value:c.id, text:((c.codigo||('CLI-'+c.id)) + ' - ' + (c.nombre||c.razonSocial||'')) }), String(v.clienteId));
    fillSelect(document.getElementById('editVendedor'), _empleados, e=>({ value:e.id, text:((e.codigo||('EMP-'+e.id)) + ' - ' + (e.nombres||'') + ' ' + (e.apellidos||'')) }), v.vendedorId!=null?String(v.vendedorId):'');
    fillSelect(document.getElementById('editCajero'), _empleados, e=>({ value:e.id, text:((e.codigo||('EMP-'+e.id)) + ' - ' + (e.nombres||'') + ' ' + (e.apellidos||'')) }), v.cajeroId!=null?String(v.cajeroId):'');

    document.getElementById('editTipoPago').value = (v.tipoPago || 'C');
    document.getElementById('editObs').value = (v.observaciones || '');

    new bootstrap.Modal(document.getElementById('modalEditarVenta')).show();
  }

  function mapFriendlyUpdateError(r){
    const raw = (r && r.data) ? (r.data.detail || r.data.message || r.data.error || '') : '';
    const s = String(raw || '').toLowerCase();
    if (r.status===409 || s.includes('pago') || s.includes('pagos aplicad') || s.includes('tiene pagos') || s.includes('frontend/ventas')) {
      return 'No se puede actualizar: el documento tiene pagos aplicados.';
    }
    return null;
  }

  async function guardarEdicionVenta(e){
    e.preventDefault();
    const id   = Number(document.getElementById('editVentaId').value);
    const body = {
      clienteId: Number(document.getElementById('editCliente').value),
      tipoPago:  document.getElementById('editTipoPago').value || 'C',
      vendedorId: valueOrNull(document.getElementById('editVendedor').value),
      cajeroId:   valueOrNull(document.getElementById('editCajero').value),
      observaciones: document.getElementById('editObs').value || ''
    };
    const r = await tryFetchJson(joinUrl(API_VENTAS, '/' + id + '/header'), {
      method:'PUT', headers:{'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify(body)
    });
    if (!r.ok){
      const msg = mapFriendlyUpdateError(r) || (r.data && (r.data.error||r.data.detail)) || 'No se pudo actualizar';
      setErr(msg);
      return;
    }
    bootstrap.Modal.getInstance(document.getElementById('modalEditarVenta')).hide();
    setOk('Venta actualizada');
    await cargarYRefrescarTabla();
  }
  function valueOrNull(v){ return (v==='' || v==null) ? null : Number(v); }

  function abrirEliminar(id){
    const v = cacheVentas[id];
    if (!v){ setErr('Venta no encontrada'); return; }
    document.getElementById('delVentaId').value = id;
    document.getElementById('delNumeroVenta').textContent = v.numeroVenta || ('ID '+id);
    new bootstrap.Modal(document.getElementById('modalEliminar')).show();
  }

  function mapFriendlyDeleteError(r){
    const raw = (r && r.data) ? (r.data.detail || r.data.message || r.data.error || '') : '';
    const s = String(raw || '').toLowerCase();
    if (r.status===409 || s.includes('pago') || s.includes('pagos aplicad') || s.includes('tiene pagos')) {
      return 'No se puede anular: el documento tiene pagos aplicados.';
    }
    return null;
  }

  async function confirmarEliminar(){
    const id = Number(document.getElementById('delVentaId').value);
    const r = await tryFetchJson(joinUrl(API_VENTAS, '/' + id + '/anular'), {
      method:'POST', headers: {'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify({})
    });
    if(!r.ok){
      const msg = mapFriendlyDeleteError(r) || (r.data && (r.data.error||r.data.detail)) || 'No se pudo eliminar la venta';
      setErr(msg);
      return;
    }
    bootstrap.Modal.getInstance(document.getElementById('modalEliminar')).hide();
    setOk('Venta eliminada');
    await cargarYRefrescarTabla();
  }

  const DELETED_IDS = new Set();
  async function cargarDetalleVentaEnModal(ventaId){
    const r = await tryFetchJson(joinUrl(API_VENTAS, '/' + ventaId), { headers: commonHeaders });
    if(!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo cargar la venta'); return; }
    const h = r.data || {};
    const items = Array.isArray(h.items) ? h.items : [];

    document.getElementById('detVentaId').value = h.id || ventaId;
    document.getElementById('detNumeroVenta').textContent = h.numeroVenta ? ('#' + h.numeroVenta) : ('ID ' + ventaId);

    const selB = document.getElementById('selBodegaDet');
    fillSelect(selB, _bodegas, b => ({ value: b.id, text: (b.nombre || ('Bodega ' + b.id)) }),
              (h.bodegaOrigenId!=null?String(h.bodegaOrigenId):''));

    DELETED_IDS.clear();
    const tbody = document.querySelector('#tablaEditarDetalle tbody');
    tbody.innerHTML = '';
    for (const it of items){
      const tr = construirFilaDetalle({
        detalleId: it.id, productoId: it.productoId, cantidad: it.cantidad, precioUnitario: it.precioUnitario,
        descuentoLinea: it.descuentoLinea, lote: it.lote || '', fechaVencimiento: it.fechaVencimiento || '', isNueva:false
      });
      tbody.appendChild(tr);
    }
    await refrescarProductosEnTablaDetalle();
    new bootstrap.Modal(document.getElementById('modalEditarDetalle')).show();
  }

  function construirFilaDetalle(op){
    const tr = document.createElement('tr');
    tr.dataset.detalleId = op && op.detalleId ? String(op.detalleId) : '';
    tr.dataset.isNueva   = op && op.isNueva ? '1' : '0';
    if (op && op.productoId != null) tr.dataset.pid = String(op.productoId);

    tr.innerHTML =
        '<td><select class="form-select form-select-sm det-producto" required><option value="">Seleccione bodega primero…</option></select></td>'
      + '<td class="text-center"><span class="badge text-bg-secondary det-stock" data-stock="0">0</span></td>'
      + '<td><input type="number" class="form-control form-control-sm det-cantidad" min="1" step="1" required value="' + (op && op.cantidad != null ? op.cantidad : '') + '"></td>'
      + '<td><input type="number" class="form-control form-control-sm det-precio"   min="0" step="0.01" required value="' + (op && op.precioUnitario != null ? op.precioUnitario : '') + '"></td>'
      + '<td><input type="number" class="form-control form-control-sm det-desc"     min="0" step="0.01" value="' + (op && op.descuentoLinea != null ? op.descuentoLinea : '') + '"></td>'
      + '<td><input type="text"   class="form-control form-control-sm det-lote" placeholder="S/N" value="' + (op && op.lote ? op.lote : '') + '"></td>'
      + '<td><input type="date"   class="form-control form-control-sm det-vence" value="' + (op && op.fechaVencimiento ? op.fechaVencimiento : '') + '"></td>'
      + '<td><button type="button" class="btn btn-sm btn-outline-danger det-del">X</button></td>';

    wireRowEventsDet(tr);
    return tr;
  }
  function wireRowEventsDet(tr){
    const selProd = tr.querySelector('.det-producto');
    const precio  = tr.querySelector('.det-precio');
    const stockEl = tr.querySelector('.det-stock');
    const cantInp = tr.querySelector('.det-cantidad');
    const btnDel  = tr.querySelector('.det-del');

    selProd.addEventListener('change', function(){
      const opt = selProd.selectedOptions[0];
      let st = 0, pr = 0;
      if (opt){ st = Number(opt.getAttribute('data-stock') || 0); pr = Number(opt.getAttribute('data-precio') || 0); }
      stockEl.textContent = String(st); stockEl.setAttribute('data-stock', String(st));
      cantInp.max = (st > 0 ? String(st) : ''); if (pr > 0) precio.value = pr;
      cantInp.classList.remove('is-invalid'); cantInp.setCustomValidity('');
    });
    cantInp.addEventListener('input', function(){
      const st = Number(stockEl.getAttribute('data-stock') || 0);
      const q  = Number(cantInp.value || 0);
      if (st > 0 && q > st) { cantInp.classList.add('is-invalid'); cantInp.setCustomValidity('No hay stock suficiente'); }
      else { cantInp.classList.remove('is-invalid'); cantInp.setCustomValidity(''); }
    });
    btnDel.addEventListener('click', function(){
      const detId = tr.dataset.detalleId;
      const esNueva = tr.dataset.isNueva === '1';
      if (detId && !esNueva) { DELETED_IDS.add(Number(detId)); }
      tr.remove();
    });
  }
  async function refrescarProductosEnTablaDetalle(){
    const bodId = document.getElementById('selBodegaDet').value || '';
    const rows = document.querySelectorAll('#tablaEditarDetalle tbody tr');
    for (const tr of rows){
      const sel = tr.querySelector('.det-producto');
      const keepId = tr.dataset.pid || sel.value || null;
      await cargarProductosParaBodega(sel, bodId, keepId);
      sel.dispatchEvent(new Event('change', { bubbles:true }));
    }
  }
  function agregarItemDet(){
    const tbody = document.querySelector('#tablaEditarDetalle tbody');
    const tr = construirFilaDetalle({ isNueva:true });
    tbody.appendChild(tr);
    // Cargar productos según bodega actual
    const bodId = document.getElementById('selBodegaDet').value || '';
    const sel = tr.querySelector('.det-producto');
    if (bodId) cargarProductosParaBodega(sel, bodId, null);
  }
  async function guardarEdicionDetalleInterno(){
    const items = [];
    const bodegaId = Number(document.getElementById('selBodegaDet').value || 0);
    document.querySelectorAll('#tablaEditarDetalle tbody tr').forEach(tr => {
      const detalleId = tr.dataset.detalleId ? Number(tr.dataset.detalleId) : null;
      const esNueva   = tr.dataset.isNueva === '1';
      const productoId = Number(tr.querySelector('.det-producto')?.value || 0);
      const cantidad   = Number(tr.querySelector('.det-cantidad')?.value || 0);
      const precio     = Number(tr.querySelector('.det-precio')?.value || 0);
      const descInp    = tr.querySelector('.det-desc')?.value;
      const lote       = tr.querySelector('.det-lote')?.value || null;
      const vence      = tr.querySelector('.det-vence')?.value || null;
      if (!productoId || !cantidad || !precio) return;
      items.push({
        detalleId, productoId, bodegaId: bodegaId || null, cantidad, precioUnitario: precio,
        descuentoLinea: (descInp===''||descInp==null) ? null : Number(descInp),
        accion: esNueva || !detalleId ? 'A' : 'U', lote, fechaVencimiento: vence
      });
    });
    DELETED_IDS.forEach(id => { items.push({ detalleId:id, productoId:null, bodegaId:null, cantidad:null, precioUnitario:null, descuentoLinea:null, accion:'D', lote:null, fechaVencimiento:null }); });
    return items;
  }
  async function guardarEdicionDetalle(){
    const ventaId = Number(document.getElementById('detVentaId').value);
    const bod = document.getElementById('selBodegaDet').value;
    if (!bod){ setErr('Selecciona la bodega para movimientos.'); return; }
    const items = await guardarEdicionDetalleInterno();
    if (items.length === 0){ setErr('No hay cambios por enviar.'); return; }
    const r = await tryFetchJson(joinUrl(API_VENTAS, '/' + ventaId + '/detalle'), {
      method:'PUT', headers: {'Content-Type':'application/json', ...commonHeaders}, body: JSON.stringify(items)
    });
    if (!r.ok){ setErr((r.data && (r.data.error||r.data.detail)) || 'No se pudo actualizar el detalle'); return; }
    DELETED_IDS.clear();
    bootstrap.Modal.getInstance(document.getElementById('modalEditarDetalle')).hide();
    setOk('Detalle actualizado');
    await cargarYRefrescarTabla();
  }

  /* Expuestos */
  return {
    lastFilters: getLast(),
    initOnce: async function(){
      if (_inited) return;
      await cargarClientesFiltro();
      document.getElementById('modalNuevaVenta').addEventListener('show.bs.modal', cargarCatalogos);

      if (!document.getElementById('modalEliminar')){
        const wrap = document.createElement('div');
        wrap.innerHTML = `
        <div class="modal fade nt-modal" id="modalEliminar" tabindex="-1" aria-hidden="true">
          <div class="modal-dialog"><div class="modal-content nt-card">
            <div class="modal-header">
              <h5 class="modal-title">Confirmar eliminación</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
            </div>
            <div class="modal-body">
              <input type="hidden" id="delVentaId">
              <p>¿Seguro que deseas eliminar (lógico) la venta <b id="delNumeroVenta"></b>?</p>
              <p class="text-muted mb-0">Puedes revertirlo desde backoffice si se requiere.</p>
            </div>
            <div class="modal-footer">
              <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
              <button class="btn btn-danger" onclick="VLIST.confirmarEliminar()">Sí, eliminar</button>
            </div>
          </div></div>
        </div>`;
        document.body.appendChild(wrap.firstElementChild);
      }
      _inited = true;
      syncPublicFilters();
    },
    cargar, buscar, limpiar, cambiarPagina,
    agregarItem, guardarVenta,
    abrirSelectorEdicion, abrirEditarCabecera, abrirEditarMaestroDetalle,
    guardarEdicionVenta, confirmarEliminar, abrirEliminar,
    guardarEdicionDetalle, agregarItemDet
  };
})();

/* ========= VISTA DETALLE (sin pagos, solo emitir factura) ========= */
const VDET = (function(){
  let _inited=false;
  let _empleadosById = null;
  let VENTA_ACTUAL = null, SALDOS=null;

  function renderCabecera(v){
    var cliente = (v?.clienteNombre && String(v.clienteNombre).trim()!=='') ? v.clienteNombre : ('ID ' + txt(v?.clienteId));
    var vendedorTxt = v?.vendedorNombre || (v?.vendedorId ? ('ID ' + v.vendedorId) : '');
    var cajeroTxt   = v?.cajeroNombre   || (v?.cajeroId   ? ('ID ' + v.cajeroId)   : '');

    var html = ''
      + '<div class="row g-2">'
      +   '<div class="col-md-3"><b>Número:</b> ' + txt(v?.numeroVenta) + '</div>'
      +   '<div class="col-md-3"><b>Fecha:</b> ' + txt(v?.fechaVenta) + '</div>'
      +   '<div class="col-md-6"><b>Cliente:</b> ' + cliente + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-3"><b>Tipo Pago:</b> ' + mapTipoPago(v?.tipoPago) + '</div>'
      +   '<div class="col-md-3"><b>Estado:</b> ' + estadoBadge(v?.estado) + '</div>'
      +   '<div class="col-md-3"><b>Vendedor:</b> <span id="vendNom">' + vendedorTxt + '</span></div>'
      +   '<div class="col-md-3"><b>Cajero:</b> <span id="cajNom">' + cajeroTxt + '</span></div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-3"><b>Subtotal:</b> ' + money(v?.subtotal) + '</div>'
      +   '<div class="col-md-3"><b>Descuento:</b> ' + money(v?.descuentoGeneral) + '</div>'
      +   '<div class="col-md-3"><b>IVA:</b> ' + money(v?.iva) + '</div>'
      +   '<div class="col-md-3"><span class="badge bg-primary-subtle text-primary-emphasis">Total ' + money(v?.total) + '</span></div>'
      + '</div>'
      + '<div class="row g-2 mt-2"><div class="col-md-12"><b>Observaciones:</b> ' + txt(v?.observaciones) + '</div></div>';

    document.getElementById('cabecera').innerHTML = html;
  }
  function renderDetalles(items){
    const tbody = document.querySelector('#tablaDet tbody');
    const empty = document.getElementById('tablaDetEmpty');
    tbody.innerHTML = '';
    if (!items || !items.length){ if (empty) empty.classList.remove('d-none'); return; }
    if (empty) empty.classList.add('d-none');
    for (const d of items){
      const tr = document.createElement('tr');
      tr.innerHTML =
          '<td>' + txt(d?.id) + '</td>'
        + '<td>' + txt(d?.productoId) + '</td>'
        + '<td>' + txt(d?.cantidad) + '</td>'
        + '<td>' + money(d?.precioUnitario) + '</td>'
        + '<td>' + money(d?.descuentoLinea) + '</td>'
        + '<td>' + money(d?.subtotal) + '</td>'
        + '<td>' + txt(d?.lote) + '</td>'
        + '<td>' + txt(d?.fechaVencimiento) + '</td>';
      tbody.appendChild(tr);
    }
  }

  async function ensureEmpleados(){
    if (_empleadosById) return _empleadosById;
    try{
      const data = await fetchJson(joinUrl(API_CATALOGOS, '/empleados?limit=500'));
      const arr = asArray(data);
      _empleadosById = {}; for (const e of arr){ if (e?.id != null) _empleadosById[e.id] = e; }
    }catch(_){ _empleadosById = {}; }
    return _empleadosById;
  }
  async function enriquecerNombres(venta){
    if (!venta) return venta;
    if (venta.vendedorNombre && venta.cajeroNombre) return venta;
    const map = await ensureEmpleados();
    const vend = venta.vendedorId != null ? map[venta.vendedorId] : null;
    const caj  = venta.cajeroId   != null ? map[venta.cajeroId]   : null;
    if (vend) venta.vendedorNombre = [vend.nombres, vend.apellidos].filter(Boolean).join(' ') || vend.codigo || ('EMP-'+vend.id);
    if (caj)  venta.cajeroNombre   = [caj.nombres,  caj.apellidos ].filter(Boolean).join(' ') || caj.codigo  || ('EMP-'+caj.id);
    const vn = document.getElementById('vendNom'); if (vn && venta.vendedorNombre) vn.textContent = venta.vendedorNombre;
    const cn = document.getElementById('cajNom');  if (cn && venta.cajeroNombre)   cn.textContent = venta.cajeroNombre;
    return venta;
  }

  async function cargarSaldos(venta){
    const id = venta?.id; if(!id) return;
    const data = await fetchJson(joinUrl(API_VENTAS, '/' + id + '/saldos'));
    SALDOS = data;
    const box = document.getElementById('boxSaldos'); if (box) box.style.display='';
    const setText = (id,v) => { const el=document.getElementById(id); if(el) el.textContent=v; };
    setText('saldoOrigen', (data && data.origen) ? data.origen : '—');
    setText('saldoTotal',  money(data?.total));
    setText('saldoPagado', money(data?.pagado));
    setText('saldoRestante', money(data?.saldo));
    const btnEmit = document.getElementById('btnEmitirFactura');
    if (btnEmit) btnEmit.style.display = (venta && venta.estado !== 'A') ? '' : 'none';
  }

  /* ===== Helper: detectar serie desde el número de venta ===== */
  function detectarSerieDesdeNumero(numeroVenta){
    if (!numeroVenta) return '';
    const pref = String(numeroVenta).trim().split('-')[0] || '';
    return (pref.match(/[A-Za-z]+/)?.[0] || '').toUpperCase();
  }

  /* ===== PDF helpers ===== */
  function getFacturaPdfUrl(facturaId){
    const urlRel = joinUrl(API_FACTURAS, '/' + facturaId + '/pdf');
    return absolutize(urlRel);
  }
  async function abrirPdfFactura(facturaId){
    const urlAbs = getFacturaPdfUrl(facturaId);
    try{
      const w = window.open(urlAbs, '_blank');
      if (!w || w.closed){
        const resp = await fetch(urlAbs, { headers: commonHeaders });
        if (!resp.ok) throw new Error('HTTP ' + resp.status);
        const blob = await resp.blob();
        const blobUrl = URL.createObjectURL(blob);
        window.open(blobUrl, '_blank');
        setTimeout(()=>URL.revokeObjectURL(blobUrl), 60000);
      }
    }catch(e){
      console.error('No se pudo abrir el PDF:', e);
      setErr('No se pudo abrir el PDF automáticamente. Intenta con este enlace: ' + urlAbs);
    }
  }

  async function cargarCabeceraSinDetalle(){
    if(!VENTA_ACTUAL?.id) return;
    const venta = await fetchJson(joinUrl(API_VENTAS, '/' + VENTA_ACTUAL.id));
    VENTA_ACTUAL = await enriquecerNombres(venta);
    renderCabecera(VENTA_ACTUAL);
  }

  /* ===== Emisión de factura: SIN MODAL ===== */
  async function emitirFacturaAuto(){
    try{
      const ventaId = VENTA_ACTUAL?.id;
      if (!ventaId){ setErr('Venta no cargada.'); return; }
      if (VENTA_ACTUAL?.estado === 'A'){ setErr('La venta está anulada.'); return; }

      const pref = detectarSerieDesdeNumero(VENTA_ACTUAL?.numeroVenta || '');
      const series = asArray(await fetchJson(joinUrl(API_CATALOGOS, '/series')));
      if (!series.length){ setErr('No hay series configuradas.'); return; }
      let target = series.find(s => (s.serie || '').toUpperCase() === pref) || series[0];
      if (!target || target.id==null){ setErr('No se pudo seleccionar la serie.'); return; }
      if ((series.length > 1) && ((target.serie||'').toUpperCase() !== pref) && pref){
        AppToast.warn(`No encontré serie "${pref}". Usaré "${target.serie}".`);
      }

      const payload = { ventaId, serieId: Number(target.id), emitidaPor: USER_ID };
      const r = await tryFetchJson(API_FACTURAS, {
        method:'POST', headers:{ 'Content-Type':'application/json', ...commonHeaders }, body: JSON.stringify(payload)
      });
      if (!r.ok){
        const msg = (r.data && (r.data.message || r.data.detail || r.data.error)) || 'No se pudo emitir la factura';
        setErr(msg);
        return;
      }

      const facturaId = r.data?.id ?? r.data?.facturaId;
      if (!facturaId){ setErr('Factura emitida, pero no recibí el ID.'); return; }

      const pdfUrl = getFacturaPdfUrl(facturaId);
      localStorage.setItem('last_factura_id', String(facturaId));
      localStorage.setItem('last_factura_pdf', pdfUrl);
      localStorage.setItem('last_factura_venta', String(VENTA_ACTUAL?.id || ''));
      localStorage.setItem('last_factura_time', String(Date.now()));

      await abrirPdfFactura(facturaId);
      AppToast.show({
        message: 'La factura ya se ha creado.',
        actionText: 'Ver PDF',
        onAction: () => window.open(pdfUrl, '_blank'),
        delay: 12000
      });
    }catch(e){
      console.error(e);
      setErr('Error al emitir la factura.');
    }
  }

  return {
    initOnce: async function(){
      if (_inited) return;

      const btnEmit = document.getElementById('btnEmitirFactura');
      if (btnEmit){
        btnEmit.addEventListener('click', async function(){
          try{
            btnEmit.disabled = true;
            await emitirFacturaAuto();
          } finally {
            btnEmit.disabled = false;
          }
        });
      }

      _inited = true;
    },
    cargar: async function(id){
      try{
        const venta = await fetchJson(joinUrl(API_VENTAS, '/' + id));
        const v2 = await enriquecerNombres(venta);
        VENTA_ACTUAL = v2;
        renderCabecera(v2);
        renderDetalles(Array.isArray(v2.items) ? v2.items : []);
        await cargarSaldos(v2);
      }catch(err){
        console.error(err);
        document.getElementById('cabecera').innerHTML =
          '<div class="alert alert-danger">Error: ' + (err.message || 'desconocido') + '</div>';
      }
    }
  };
})();

/* ====== Boot ====== */
function maybeOfferLastFacturaToast(){
  try{
    const url = localStorage.getItem('last_factura_pdf');
    const ts  = Number(localStorage.getItem('last_factura_time') || 0);
    if (url && (!ts || (Date.now()-ts) < 24*60*60*1000)){
      AppToast.show({
        message: '¿Abrir la última factura generada?',
        actionText: 'Abrir PDF',
        onAction: () => window.open(url, '_blank'),
        delay: 12000
      });
    }
  }catch(_){}
}

window.addEventListener('DOMContentLoaded', async function(){
  Router.init();
  document.getElementById('selBodegaDet')?.addEventListener('change', function(){
    /* la recarga de productos del modal de detalle se maneja al abrir el modal */
  });
  await Router.navigate('lista');
  maybeOfferLastFacturaToast();
});
</script>

</body>
</html>
