<%-- 
  Cotizaciones (listado) + Modal: Nueva cotización + Modal: Ver/Detalle (con convertir a venta)
  Unificado al estilo del proyecto remoto NextTech
--%>
<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Cotizaciones | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!-- Base del backend -->
  <meta name="api-base" content="http://localhost:8080">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Paleta / tema del proyecto -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=13">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=13">

  <style>
    body.nt-bg { background: var(--nt-bg); color: var(--nt-fg); }
    .nt-navbar { background: var(--nt-surface-1); border-bottom: 1px solid var(--nt-border); }
    .nt-title { color: var(--nt-fg-strong); }
    .nt-subtitle { color: var(--nt-fg-muted); }
    .nt-card { background: var(--nt-surface-1); border: 1px solid var(--nt-border); border-radius: 1rem; }
    .nt-card:hover { transform: translateY(-1px); border-color: var(--nt-accent); box-shadow: 0 10px 24px rgba(0,0,0,.25); transition: .12s; }
    .nt-table-head { background: var(--nt-surface-2); color: var(--nt-fg); }
    .nt-btn-accent { background: var(--nt-accent); color: #fff; border: none; }
    .nt-btn-accent:hover { filter: brightness(0.95); }
    .nt-back { display:inline-flex; align-items:center; gap:.5rem; border:1px solid var(--nt-border); background:transparent; color:var(--nt-primary); }
    .nt-back:hover { background:var(--nt-surface-2); }

    .badge-pill{border-radius:999px;padding:.35rem .6rem;font-weight:600}
    .table td, .table th{vertical-align: middle;}
    .w-90{width:90px} .w-100{width:100px} .w-120{width:120px} .w-110{width:110px} .w-200{width:200px} .w-70{width:70px}
  </style>

  <!-- utilidades comunes del proyecto -->
  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2" href="${pageContext.request.contextPath}/Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-receipt"></i> NextTech — Cotizaciones
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
            <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <div class="container py-4">

    <!-- Título + acciones -->
    <div class="d-flex align-items-center justify-content-between mb-3">
      <div>
        <h2 class="m-0 nt-title"><i class="bi bi-file-earmark-text"></i> Cotizaciones</h2>
        <div class="nt-subtitle">Listado y creación</div>
      </div>
      <button id="btnNuevaCot" class="btn nt-btn-accent" data-bs-toggle="modal" data-bs-target="#modalNuevaCot">
        <i class="bi bi-plus-circle me-1"></i> Nueva cotización
      </button>
    </div>

    <!-- Filtros -->
    <div class="card nt-card mb-3">
      <div class="card-body">
        <form id="filtros" class="row g-2 align-items-end">
          <div class="col-sm-3">
            <label class="form-label">Desde</label>
            <input type="date" id="f_desde" class="form-control">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Hasta</label>
            <input type="date" id="f_hasta" class="form-control">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Cliente ID</label>
            <input type="number" id="f_cliente" min="1" class="form-control" placeholder="Ej. 1">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Número</label>
            <input type="text" id="f_numero" class="form-control" placeholder="COT-0001">
          </div>
          <div class="col-12 d-flex gap-2 mt-2 justify-content-end">
            <button type="button" class="btn btn-primary" id="btnBuscar"><i class="bi bi-search me-1"></i>Buscar</button>
            <button type="button" class="btn btn-outline-secondary" id="btnLimpiar"><i class="bi bi-x-circle me-1"></i>Limpiar</button>
          </div>
        </form>
      </div>
    </div>

    <!-- Tabla -->
    <div class="card nt-card">
      <div class="table-responsive">
        <table class="table table-striped table-hover align-middle mb-0" id="tabla">
          <thead class="nt-table-head">
            <tr>
              <th>ID</th>
              <th>Número</th>
              <th>Fecha</th>
              <th>Cliente</th>
              <th>Total</th>
              <th>Estado</th>
              <th class="text-end">Acciones</th>
            </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="tablaEmpty" class="p-3 text-muted">Sin resultados.</div>
    </div>
  </div>

  <!-- Modal: Nueva cotización -->
  <div class="modal fade" id="modalNuevaCot" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Nueva cotización</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>

        <div class="modal-body">
          <div id="nc_alert" class="alert alert-danger d-none"></div>

          <div class="row g-2">
            <div class="col-md-4">
              <label class="form-label">Cliente *</label>
              <select id="nc_cliente" class="form-select" required></select>
              <div class="form-text">Se carga desde /api/catalogos/clientes</div>
            </div>
            <div class="col-md-4">
              <label class="form-label">Vendedor *</label>
              <select id="nc_vendedor" class="form-select" required></select>
              <div class="form-text">Se carga desde /api/catalogos/empleados</div>
            </div>
            <div class="col-md-2">
              <label class="form-label">Vigencia *</label>
              <input id="nc_vigencia" type="date" class="form-control" required>
            </div>
            <div class="col-md-2">
              <label class="form-label">Desc. general</label>
              <input id="nc_desc" type="number" step="0.01" min="0" class="form-control" value="0">
            </div>
          </div>

          <div class="row g-2 mt-2">
            <div class="col-md-6">
              <label class="form-label">Observaciones</label>
              <input id="nc_obs" type="text" maxlength="200" class="form-control">
            </div>
            <div class="col-md-6">
              <label class="form-label">Términos</label>
              <input id="nc_terms" type="text" maxlength="200" class="form-control" placeholder="Pago contra entrega" value="Pago contra entrega">
            </div>
          </div>

          <hr class="my-3">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <h6 class="m-0">Items</h6>
            <button id="nc_add" type="button" class="btn btn-sm btn-outline-primary">+ Agregar ítem</button>
          </div>

          <div class="table-responsive">
            <table class="table table-sm table-hover align-middle">
              <thead class="nt-table-head">
                <tr>
                  <th>Producto *</th>
                  <th class="text-center">Stock</th>
                  <th class="w-120 text-center">Cantidad *</th>
                  <th class="w-120">Precio Unitario *</th>
                  <th class="w-110">Descuento</th>
                  <th class="w-200">Lote</th>
                  <th class="w-120">Vence</th>
                  <th class="w-70"></th>
                </tr>
              </thead>
              <tbody id="nc_body"></tbody>
            </table>
          </div>

          <div class="text-end mt-3">
            <div><small>Subtotal: <span id="nc_sub">Q 0.00</span></small></div>
            <div><small>IVA: <span id="nc_iva">Q 0.00</span></small></div>
            <div class="fw-semibold">Total: <span id="nc_total">Q 0.00</span></div>
          </div>
        </div>

        <div class="modal-footer">
          <button id="nc_save" type="button" class="btn nt-btn-accent" disabled>Crear</button>
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal: Ver cotización (detalle + convertir a venta) -->
  <div class="modal fade" id="modalVerCot" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title">Detalle de cotización</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>

        <div class="modal-body">
          <div id="topAlert" class="alert alert-danger d-none">Error</div>

          <!-- Cabecera -->
          <div class="card nt-card mb-3">
            <div class="card-body" id="cabecera">
              <div class="text-muted">Cargando cotización...</div>
            </div>
          </div>

          <!-- Acciones convertir -->
          <div class="card nt-card mb-3">
            <div class="card-body d-flex flex-wrap gap-3 align-items-end">
              <div>
                <label class="form-label">Bodega ID</label>
                <input type="number" id="cv_bodega" class="form-control" min="1" value="1">
              </div>
              <div>
                <label class="form-label">Serie ID</label>
                <input type="number" id="cv_serie" class="form-control" min="1" value="1">
              </div>
              <div>
                <label class="form-label">Cajero ID</label>
                <input type="number" id="cv_cajero" class="form-control" min="1" value="1">
              </div>
              <div>
                <label class="form-label">Tipo de pago</label>
                <select id="cv_tipoPago" class="form-select">
                  <option value="C" selected>Contado</option>
                  <option value="R">Crédito</option>
                </select>
              </div>
              <div class="ms-auto">
                <button id="btnConvertir" class="btn nt-btn-accent" disabled>
                  <i class="bi bi-arrow-left-right me-1"></i> Convertir a venta
                </button>
              </div>
            </div>
            <div id="cv_alert" class="alert alert-danger d-none mx-3 mb-0"></div>
            <div id="cv_ok" class="alert alert-success d-none mx-3 mb-3"></div>
          </div>

          <!-- Detalle -->
          <div class="card nt-card">
            <div class="table-responsive">
              <table class="table table-striped table-hover align-middle mb-0" id="tabla">
                <thead class="nt-table-head">
                  <tr>
                    <th>ID Detalle</th>
                    <th>Producto</th>
                    <th>Cantidad</th>
                    <th>Precio</th>
                    <th>Desc. línea</th>
                    <th>Subtotal</th>
                    <th>Descripción</th>
                  </tr>
                </thead>
                <tbody></tbody>
              </table>
            </div>
            <div id="tablaEmpty" class="p-3 text-muted d-none">Sin líneas.</div>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
  /* =========================
     CONFIG / ENDPOINTS
     ========================= */
  (function syncApiBase(){
    try{
      window.API = window.API || {};
      if (!API.baseUrl || !API.baseUrl.trim()) {
        const meta = document.querySelector('meta[name="api-base"]');
        const base = (window.API_BASE || meta?.getAttribute('content') || '').trim();
        if (base) API.baseUrl = base;
      }
    }catch(_){}
  })();

  const API_BASE = (window.API?.baseUrl || document.querySelector('meta[name="api-base"]')?.content || '').replace(/\/+$/,'');
  const API_COTS = API_BASE + '/api/cotizaciones';
  const API_CAT  = API_BASE + '/api/catalogos';

  const CTX = '${pageContext.request.contextPath}';

  /* =========================
     UTILS
     ========================= */
  function money(n){
    if(n==null || n==='' || isNaN(n)) return 'Q 0.00';
    try{ return new Intl.NumberFormat('es-GT',{style:'currency',currency:'GTQ'}).format(Number(n)); }
    catch(e){ return 'Q ' + Number(n).toFixed(2); }
  }
  async function fetchJson(url, opts){
    const res = await fetch(url, opts||{});
    const raw = await res.text();
    let data = null;
    try{ data = raw ? JSON.parse(raw) : null; }catch(_){}
    if(!res.ok) throw new Error((data && (data.error||data.detail||data.message)) || ('HTTP '+res.status));
    return data;
  }
  function round2(x){ return Math.round(Number(x||0)*100)/100; }
  function txt(x){ return (x===undefined || x===null) ? '' : String(x); }

  // Estado (badge)
  function estadoBadgeHtml(e){
    const key = String(e || '').trim().toUpperCase();
    const map = {
      'V': { cls: 'badge rounded-pill text-bg-warning', label: 'Vigente' },
      'A': { cls: 'badge rounded-pill text-bg-danger',  label: 'Anulada' },
      'C': { cls: 'badge rounded-pill text-bg-success', label: 'Cerrada' }
    };
    const it = map[key] || { cls: 'badge rounded-pill text-bg-secondary', label: (e || '—') };
    return '<span class="'+it.cls+'" title="Estado: '+it.label+'">'+it.label+'</span>';
  }

  /* =========================
     LISTADO
     ========================= */
  function setRows(rows){
    const tb = document.querySelector('#tabla tbody');
    const empty = document.getElementById('tablaEmpty');
    tb.innerHTML = '';
    if(!rows || !rows.length){ empty.textContent='Sin resultados.'; return; }
    empty.textContent='';

    for(const r of rows){
      const id = r.id;
      const numero = r.numeroCotizacion || r.numero_cotizacion || '';
      const fecha  = r.fechaCotizacion || r.fecha_cotizacion || '';
      const cliente= r.clienteNombre || r.cliente_nombre || '';
      const total  = r.total;
      const estado = r.estado;

      const tr = document.createElement('tr');
      tr.innerHTML =
          '<td>'+ id +'</td>'
        + '<td>'+ numero +'</td>'
        + '<td>'+ fecha +'</td>'
        + '<td>'+ cliente +'</td>'
        + '<td>'+ money(total) +'</td>'
        + '<td>'+ estadoBadgeHtml(estado) +'</td>'
        + '<td class="text-end">'
        +   '<div class="btn-group btn-group-sm">'
        +     '<button type="button" class="btn btn-outline-secondary" onclick="abrirVerCot('+ id +')" title="Ver">'
        +       '<i class="bi bi-eye me-1"></i> Ver'
        +     '</button>'
        +   '</div>'
        + '</td>';
      tb.appendChild(tr);
    }
  }

  async function buscar(page=0, size=50){
    const params = new URLSearchParams();
    const d = document.getElementById('f_desde').value;
    const h = document.getElementById('f_hasta').value;
    const cli = document.getElementById('f_cliente').value;
    const num = document.getElementById('f_numero').value;
    if(d) params.append('desde', d);
    if(h) params.append('hasta', h);
    if(cli) params.append('clienteId', cli);
    if(num) params.append('numero', num);
    params.append('page', page);
    params.append('size', size);

    const data = await fetchJson(API_COTS + '?' + params.toString());
    setRows(Array.isArray(data) ? data : []);
  }

  document.getElementById('btnBuscar').addEventListener('click', () => buscar());
  document.getElementById('btnLimpiar').addEventListener('click', () => {
    document.getElementById('f_desde').value='';
    document.getElementById('f_hasta').value='';
    document.getElementById('f_cliente').value='';
    document.getElementById('f_numero').value='';
    buscar();
  });

  /* =========================
     MODAL NUEVA COTIZACIÓN
     ========================= */
  let CAT_CLIENTES = [];
  let CAT_VENDEDORES = [];
  let CAT_PRODS = []; // {id,codigo,nombre,precioVenta,stockDisponible}

  async function cargarCatalogos(){
    [CAT_CLIENTES, CAT_VENDEDORES, CAT_PRODS] = await Promise.all([
      fetchJson(API_CAT + '/clientes'),
      fetchJson(API_CAT + '/empleados'),
      fetchJson(API_CAT + '/productos-stock')
    ]);

    // Cliente
    const selCli = document.getElementById('nc_cliente');
    selCli.innerHTML = '<option value="">-- Selecciona --</option>' +
      CAT_CLIENTES.map(c => '<option value="'+c.id+'">['+(c.codigo||('CLI-'+c.id))+'] '+c.nombre+' '+(c.nit?('(NIT '+c.nit+')'):'')+'</option>').join('');

    // Vendedor
    const selVen = document.getElementById('nc_vendedor');
    selVen.innerHTML = '<option value="">-- Selecciona --</option>' +
      CAT_VENDEDORES.map(e => {
        const nom = ((e.nombres||'') + ' ' + (e.apellidos||'')).trim();
        return '<option value="'+e.id+'">['+(e.codigo||('EMP-'+e.id))+'] '+(nom||('Empleado '+e.id))+'</option>';
      }).join('');
  }

  const bodyItems = document.getElementById('nc_body');
  const btnAdd = document.getElementById('nc_add');
  const btnSave = document.getElementById('nc_save');
  const alertBox = document.getElementById('nc_alert');

  function prodOptionHtml(){
    return '<option value="">-- Selecciona --</option>' +
      CAT_PRODS.map(p => '<option value="'+p.id+'">'+(p.nombre||('PROD '+p.id))+'</option>').join('');
  }

  function validarFila(tr){
    const sel = tr.querySelector('.prod');
    const qty = tr.querySelector('.qty');
    const price = tr.querySelector('.price');
    const disc = tr.querySelector('.disc');
    const stock = Number(tr.querySelector('.stock').textContent || 0);

    let ok = true;

    if(!sel.value){ ok = false; sel.classList.add('is-invalid'); } else sel.classList.remove('is-invalid');

    const q = Number(qty.value || 0);
    if(!q || q<=0 || (stock>0 && q>stock)){
      ok = false; qty.classList.add('is-invalid');
    }else qty.classList.remove('is-invalid');

    const pr = Number(price.value || 0);
    if(isNaN(pr) || pr<0){ ok = false; price.classList.add('is-invalid'); } else price.classList.remove('is-invalid');

    const ds = Number(disc.value || 0);
    const subLinea = q*pr;
    if(ds<0 || ds>subLinea){ ok=false; disc.classList.add('is-invalid'); } else disc.classList.remove('is-invalid');

    return ok;
  }

  function validarFormulario(){
    alertBox.classList.add('d-none'); alertBox.textContent = '';
    const clienteId = document.getElementById('nc_cliente').value;
    const vendedorId = document.getElementById('nc_vendedor').value;
    const vigencia = document.getElementById('nc_vigencia').value;

    let ok = !!clienteId && !!vendedorId && !!vigencia;

    const filas = Array.from(bodyItems.querySelectorAll('tr'));
    if(filas.length===0) ok=false;
    for(const tr of filas){ if(!validarFila(tr)) ok=false; }

    btnSave.disabled = !ok;
    return ok;
  }

  function recalcular(){
    let subtotal = 0;
    for(const tr of Array.from(bodyItems.querySelectorAll('tr'))){
      const q = Number(tr.querySelector('.qty').value || 0);
      const p = Number(tr.querySelector('.price').value || 0);
      const d = Number(tr.querySelector('.disc').value || 0);
      subtotal += (q*p) - d;
    }
    const descGen = Number(document.getElementById('nc_desc').value || 0);
    const iva = round2( Math.max(subtotal - descGen, 0) * 0.12 );
    const total = round2( Math.max(subtotal - descGen + iva, 0) );

    document.getElementById('nc_sub').textContent = money(subtotal);
    document.getElementById('nc_iva').textContent = money(iva);
    document.getElementById('nc_total').textContent = money(total);

    validarFormulario();
  }

  function nuevaFila(){
    const tr = document.createElement('tr');
    tr.innerHTML =
      '<td>'
      +  '<select class="form-select form-select-sm prod" required></select>'
      + '</td>'
      + '<td class="text-center"><span class="badge bg-secondary-subtle text-secondary-emphasis badge-pill stock">0</span></td>'
      + '<td class="w-90 text-end-input">'
      +   '<input type="number" class="form-control form-control-sm qty" min="1" step="1" placeholder="0" title="Cantidad (no puede exceder el stock)">'
      + '</td>'
      + '<td><input type="number" class="form-control form-control-sm price" min="0" step="0.01" placeholder="0.00"></td>'
      + '<td><input type="number" class="form-control form-control-sm disc" min="0" step="0.01" placeholder="0.00"></td>'
      + '<td><input type="text" class="form-control form-control-sm lote" placeholder="S/N" value="S/N"></td>'
      + '<td><input type="date" class="form-control form-control-sm vence"></td>'
      + '<td class="text-end"><button type="button" class="btn btn-sm btn-outline-danger del">X</button></td>';

    bodyItems.appendChild(tr);

    // select producto
    const sel = tr.querySelector('select.prod');
    sel.innerHTML = prodOptionHtml();

    const stockSpan = tr.querySelector('.stock');
    const price = tr.querySelector('.price');
    const qty = tr.querySelector('.qty');

    sel.addEventListener('change', () => {
      const prodId = Number(sel.value||0);
      const p = CAT_PRODS.find(x => x.id === prodId);

      if(p){
        const stock = Number(p.stockDisponible ?? 0);
        stockSpan.textContent = stock;
        price.value = p.precioVenta ?? 0;
        qty.max = String(stock);
        qty.placeholder = stock ? '≤ '+stock : '0';
        qty.title = stock ? 'Máximo: '+stock : 'Sin stock';
        if(Number(qty.value||0) > stock) qty.value = stock || '';
      }else{
        stockSpan.textContent = '0';
        price.value = '';
        qty.value = '';
        qty.removeAttribute('max');
        qty.placeholder = '0';
      }
      validarFila(tr);
      recalcular();
    });

    qty.addEventListener('input', () => { validarFila(tr); recalcular(); });
    tr.querySelector('.price').addEventListener('input', () => { validarFila(tr); recalcular(); });
    tr.querySelector('.disc').addEventListener('input', () => { validarFila(tr); recalcular(); });
    tr.querySelector('.del').addEventListener('click', () => { tr.remove(); validarFormulario(); recalcular(); });

    validarFila(tr);
    validarFormulario();
  }

  btnAdd.addEventListener('click', () => { nuevaFila(); validarFormulario(); });
  document.getElementById('nc_desc').addEventListener('input', () => { recalcular(); validarFormulario(); });
  document.getElementById('nc_cliente').addEventListener('change', validarFormulario);
  document.getElementById('nc_vendedor').addEventListener('change', validarFormulario);
  document.getElementById('nc_vigencia').addEventListener('change', validarFormulario);

  btnSave.addEventListener('click', async () => {
    try{
      if(!validarFormulario()) return;

      // Build payload
      const items = [];
      for(const tr of Array.from(bodyItems.querySelectorAll('tr'))){
        const prodId = Number(tr.querySelector('.prod').value||0);
        const qty = Number(tr.querySelector('.qty').value||0);
        const price = Number(tr.querySelector('.price').value||0);
        const disc = Number(tr.querySelector('.disc').value||0);
        const lote = tr.querySelector('.lote').value || null;
        const vence = tr.querySelector('.vence').value || null;
        if(prodId && qty>0){
          items.push({
            productoId: prodId,
            cantidad: qty,
            precioUnitario: price,
            descuentoLinea: disc,
            descripcionAdicional: null,
            lote: lote,
            fechaVencimiento: vence
          });
        }
      }
      let subtotal = 0;
      for(const it of items){ subtotal += (it.cantidad*it.precioUnitario) - (it.descuentoLinea||0); }
      const descGen = Number(document.getElementById('nc_desc').value || 0);
      const iva = round2( Math.max(subtotal - descGen, 0) * 0.12 );

      const payload = {
        clienteId: Number(document.getElementById('nc_cliente').value),
        vendedorId: Number(document.getElementById('nc_vendedor').value),
        fechaVigencia: document.getElementById('nc_vigencia').value,
        observaciones: document.getElementById('nc_obs').value || null,
        terminos: document.getElementById('nc_terms').value || null,
        descuentoGeneral: descGen,
        iva: iva,
        items: items
      };

      await fetchJson(API_COTS, {
        method:'POST',
        headers:{'Content-Type':'application/json'},
        body: JSON.stringify(payload)
      });

      const modalEl = document.getElementById('modalNuevaCot');
      const md = bootstrap.Modal.getInstance(modalEl) || new bootstrap.Modal(modalEl);
      md.hide();
      await buscar();
    }catch(err){
      alertBox.textContent = err.message || 'Error al crear';
      alertBox.classList.remove('d-none');
    }
  });

  document.getElementById('modalNuevaCot').addEventListener('shown.bs.modal', async ()=>{
    try{
      if(CAT_CLIENTES.length===0) await cargarCatalogos();
      if(bodyItems.querySelectorAll('tr').length===0) nuevaFila();
      validarFormulario(); recalcular();
    }catch(err){
      alertBox.textContent = err.message || 'Error cargando catálogos';
      alertBox.classList.remove('d-none');
    }
  });
  document.getElementById('modalNuevaCot').addEventListener('hidden.bs.modal', ()=>{
    alertBox.classList.add('d-none'); alertBox.textContent='';
    bodyItems.innerHTML='';
    document.getElementById('nc_desc').value='0';
    document.getElementById('nc_obs').value='';
    document.getElementById('nc_terms').value='Pago contra entrega';
    document.getElementById('nc_vigencia').value='';
    const c = document.getElementById('nc_cliente'); if (c) c.value='';
    const v = document.getElementById('nc_vendedor'); if (v) v.value='';
    document.getElementById('nc_sub').textContent='Q 0.00';
    document.getElementById('nc_iva').textContent='Q 0.00';
    document.getElementById('nc_total').textContent='Q 0.00';
    btnSave.disabled = true;
  });

  /* =========================
     MODAL VER COTIZACIÓN
     ========================= */
    function goBack(){ try{ if(history.length>1){ history.back(); return; } }catch(_){ } location.href='${pageContext.request.contextPath}/Dashboard.jsp'; }

  let COT_ACTUAL = null;

  function setHtml(id, html){ var el=document.getElementById(id); if(el) el.innerHTML = html; }

  function renderCabecera(h){
    const estadoHtml = estadoBadgeHtml(h.estado);
    const html = ''
      + '<div class="row g-2">'
      +   '<div class="col-md-3"><b>Número:</b> ' + txt(h.numeroCotizacion) + '</div>'
      +   '<div class="col-md-3"><b>Fecha:</b> ' + txt(h.fechaCotizacion) + '</div>'
      +   '<div class="col-md-3"><b>Vigencia:</b> ' + txt(h.fechaVigencia) + '</div>'
      +   '<div class="col-md-3"><b>Estado:</b> ' + estadoHtml + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-6"><b>Cliente:</b> ' + txt(h.clienteNombre || ('ID '+h.clienteId)) + '</div>'
      +   '<div class="col-md-6"><b>Vendedor:</b> ' + txt(h.vendedorNombre || ('ID '+h.vendedorId)) + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-4"><b>Subtotal:</b> ' + money(h.subtotal) + '</div>'
      +   '<div class="col-md-4"><b>Descuento:</b> ' + money(h.descuentoGeneral) + '</div>'
      +   '<div class="col-md-4"><span class="badge ok">Total ' + money(h.total) + '</span></div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-12"><b>Observaciones:</b> ' + txt(h.observaciones) + '</div>'
      +   '<div class="col-md-12"><b>Términos:</b> ' + txt(h.terminosCondiciones) + '</div>'
      + '</div>';
    setHtml('cabecera', html);
  }

  function renderDetalle(items){
    const tbody = document.querySelector('#tabla tbody');
    const empty = document.getElementById('tablaEmpty');
    tbody.innerHTML = '';

    if(!items || !items.length){
      if(empty) empty.classList.remove('d-none');
      return;
    }
    if(empty) empty.classList.add('d-none');

    for (let i=0; i<items.length; i++){
      const d = items[i];
      const tr = document.createElement('tr');
      tr.innerHTML =
          '<td>' + txt(d.id) + '</td>'
        + '<td>[' + txt(d.productoId) + '] ' + txt(d.productoNombre || d.productoCodigo || '') + '</td>'
        + '<td>' + txt(d.cantidad) + '</td>'
        + '<td>' + money(d.precioUnitario) + '</td>'
        + '<td>' + money(d.descuentoLinea) + '</td>'
        + '<td>' + money(d.subtotal) + '</td>'
        + '<td>' + txt(d.descripcionAdicional) + '</td>';
      tbody.appendChild(tr);
    }
  }

  async function convertirAVenta(){
    const aErr = document.getElementById('cv_alert');
    const aOk  = document.getElementById('cv_ok');
    if(aErr){ aErr.classList.add('d-none'); aErr.textContent=''; }
    if(aOk){ aOk.classList.add('d-none'); aOk.textContent=''; }

    if(!COT_ACTUAL || !COT_ACTUAL.id){
      if(aErr){ aErr.textContent='Cotización no cargada.'; aErr.classList.remove('d-none'); }
      return;
    }

    const bodegaId = document.getElementById('cv_bodega')?.value;
    const serieId  = document.getElementById('cv_serie')?.value;
    const cajeroId = document.getElementById('cv_cajero')?.value;
    const tipoPago = document.getElementById('cv_tipoPago')?.value || 'C';

    if(!bodegaId || !serieId){
      if(aErr){ aErr.textContent='Bodega y Serie son obligatorios.'; aErr.classList.remove('d-none'); }
      return;
    }

    const url = API_COTS + '/' + encodeURIComponent(COT_ACTUAL.id) + '/to-venta'
              + '?bodegaId=' + encodeURIComponent(bodegaId)
              + '&serieId='  + encodeURIComponent(serieId)
              + (cajeroId ? ('&cajeroId=' + encodeURIComponent(cajeroId)) : '')
              + '&tipoPago=' + encodeURIComponent(tipoPago);

    const btn = document.getElementById('btnConvertir');
    try{
      if(btn){ btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm me-2"></span>Convirtiendo…'; }

      const res = await fetch(url, { method:'POST' });
      const raw = await res.text();
      let data = null; try{ data = raw ? JSON.parse(raw) : null; }catch(_){}

      if(!res.ok){
        const msg = (data && (data.error||data.detail||data.message)) || ('HTTP ' + res.status);
        throw new Error(msg);
      }

      const ventaId = (data && (data.venta_id || data.id)) || null;
      if(ventaId){
        if(aOk){ aOk.textContent = 'Venta creada (ID ' + ventaId + '). Redirigiendo…'; aOk.classList.remove('d-none'); }
        setTimeout(function(){
          window.location.href = CTX + '/ventas.jsp#detalle?id=' + encodeURIComponent(ventaId);
        }, 800);
      }else{
        if(aOk){ aOk.textContent = 'Convertido, pero la API no devolvió ID de venta.'; aOk.classList.remove('d-none'); }
      }
    }catch(err){
      if(aErr){ aErr.textContent = 'Error: ' + (err.message || 'no controlado'); aErr.classList.remove('d-none'); }
    }finally{
      if(btn){ btn.disabled = false; btn.innerHTML = '<i class="bi bi-arrow-left-right me-1"></i> Convertir a venta'; }
    }
  }

  async function abrirVerCot(id){
    const modalEl = document.getElementById('modalVerCot');
    const md = bootstrap.Modal.getOrCreateInstance(modalEl);
    // Limpia UI
    const topAlert = document.getElementById('topAlert');
    if(topAlert){ topAlert.classList.add('d-none'); topAlert.textContent=''; }
    setHtml('cabecera','<div class="text-muted">Cargando cotización...</div>');
    const tb = document.querySelector('#tabla tbody'); if (tb) tb.innerHTML='';
    const empty = document.getElementById('tablaEmpty'); if (empty) empty.classList.add('d-none');
    document.getElementById('btnConvertir').disabled = true;

    md.show();

    try{
      const h = await fetchJson(API_COTS + '/' + encodeURIComponent(id));
      if(!h || !h.id) throw new Error('Cotización no encontrada');

      COT_ACTUAL = h;
      renderCabecera(h);
      renderDetalle(h.items);
      document.getElementById('btnConvertir').disabled = false;
    }catch(err){
      if(topAlert){ topAlert.textContent = 'Error: ' + (err.message || 'desconocido'); topAlert.classList.remove('d-none'); }
      console.error(err);
    }
  }

  document.getElementById('btnConvertir').addEventListener('click', convertirAVenta);

  /* =========================
     BOOT
     ========================= */
  window.addEventListener('DOMContentLoaded', () => {
    buscar().catch(console.error);
  });
  </script>
</body>
</html>
