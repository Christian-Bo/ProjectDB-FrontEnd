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
  /* === Mapea variables existentes del tema (base.css) === */
  body.nt-bg { background: var(--nt-bg); color: var(--nt-text); }
  .nt-title{ color: var(--nt-primary); }
  .nt-subtitle{ color: var(--nt-text); opacity:.9; }

  .nt-back{
    display:inline-flex; align-items:center; gap:.5rem;
    border:1px solid var(--nt-border);
    background:transparent; color:var(--nt-primary);
  }
  .nt-back:hover{ background:var(--nt-surface-2); }

  /* Cards coherentes con el tema */
  .nt-card{
    background: var(--nt-surface);
    border:1px solid var(--nt-border);
    border-radius:1rem; transition:.12s;
  }
  .nt-card:hover{
    transform: translateY(-1px);
    border-color: var(--nt-accent);
    box-shadow: 0 10px 24px rgba(0,0,0,.35);
  }

  /* Encabezados de tabla */
  .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-primary); }

  /* Botón de acento */
  .nt-btn-accent{ background: var(--nt-accent); color:#fff; border:none; }
  .nt-btn-accent:hover{ filter: brightness(.95); }

  /* Inputs oscuros como Transferencias */
  .form-control.nt-input, .form-select.nt-input{
    background: var(--nt-surface-2);
    color: var(--nt-text);
    border-color: var(--nt-border);
  }
  .form-control.nt-input:focus, .form-select.nt-input:focus{
    border-color: var(--nt-accent);
    box-shadow: 0 0 0 .2rem rgba(0,102,255,.15);
  }

  /* Modal del tema (asegura fondo sólido) */
  .modal-content{
    background: var(--nt-surface) !important;
    color: var(--nt-text);
    border:1px solid var(--nt-border);
    border-radius:1rem;
  }
  .modal-header{
    background: var(--nt-surface-2);
    border-bottom:1px solid var(--nt-border);
    color: var(--nt-primary);
  }
  .modal-footer{ border-top:1px solid var(--nt-border); }

  /* Opacidad del backdrop del modal */
  .modal-backdrop.show{ opacity:.6 !important; }
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
            <label class="form-label">Cliente</label>
            <select id="f_cliente" class="form-select">
              <option value="">Cargando...</option>
            </select>
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
    <div class="modal-dialog modal-xl modal-dialog-centered modal-dialog-scrollable">
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
            <div class="card-body">
              <div class="row g-3 align-items-end">
                <div class="col-md-3">
                  <label class="form-label">Bodega *</label>
                  <select id="cv_bodega" class="form-select">
                    <option value="">Cargando...</option>
                  </select>
                </div>
                <div class="col-md-3">
                  <label class="form-label">Serie *</label>
                  <select id="cv_serie" class="form-select">
                    <option value="">Cargando...</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <label class="form-label">Cajero</label>
                  <select id="cv_cajero" class="form-select">
                    <option value="">Cargando...</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <label class="form-label">Tipo de pago</label>
                  <select id="cv_tipoPago" class="form-select">
                    <option value="C" selected>Contado</option>
                    <option value="R">Crédito</option>
                  </select>
                </div>
                <div class="col-md-2">
                  <button id="btnConvertir" class="btn nt-btn-accent w-100" disabled>
                    <i class="bi bi-arrow-left-right me-1"></i> Convertir
                  </button>
                </div>
              </div>
              <div id="cv_alert" class="alert alert-danger d-none mt-3 mb-0"></div>
              <div id="cv_ok" class="alert alert-success d-none mt-3 mb-0"></div>
            </div>
          </div>

          <!-- Detalle -->
          <div class="card nt-card">
            <div class="card-header">
              <h6 class="m-0">Productos de la cotización</h6>
            </div>
            <div class="table-responsive">
              <table class="table table-striped table-hover align-middle mb-0" id="tablaDetalle">
                <thead class="nt-table-head">
                  <tr>
                    <th>Producto</th>
                    <th class="text-end">Cantidad</th>
                    <th class="text-end">Precio</th>
                    <th class="text-end">Desc. línea</th>
                    <th class="text-end">Subtotal</th>
                    <th>Lote</th>
                    <th>Vence</th>
                  </tr>
                </thead>
                <tbody id="tbodyDetalle"></tbody>
              </table>
            </div>
            <div id="tablaDetalleEmpty" class="p-3 text-muted d-none">Sin líneas.</div>
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
  function asArray(x){ return Array.isArray(x) ? x : (x && (x.items||x.content||x.data||x.results||x.records)) || []; }

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

  function goBack(){ 
    try{ if(history.length>1){ history.back(); return; } }catch(_){} 
    location.href='${pageContext.request.contextPath}/Dashboard.jsp'; 
  }

  /* =========================
     CATÁLOGOS GLOBALES
     ========================= */
  let CAT_CLIENTES = [];
  let CAT_VENDEDORES = [];
  let CAT_PRODS = [];
  let CAT_BODEGAS = [];
  let CAT_SERIES = [];
  let CAT_EMPLEADOS = []; // Para cajeros

  let CATALOGOS_CARGADOS = false;
  let CATALOGOS_CONVERSION_CARGADOS = false;
  let CATALOGOS_FILTRO_CARGADOS = false;

  // Cargar clientes para el filtro
  async function cargarClientesFiltro(){
    if(CATALOGOS_FILTRO_CARGADOS) return;
    
    try{
      const data = await fetchJson(API_CAT + '/clientes?limit=200');
      CAT_CLIENTES = asArray(data);
      
      const selFiltro = document.getElementById('f_cliente');
      if(selFiltro){
        selFiltro.innerHTML = '<option value="">(Todos)</option>' +
          CAT_CLIENTES.map(c => {
            const codigo = c.codigo || ('CLI-' + c.id);
            const nombre = c.nombre || c.razonSocial || '';
            const nit = c.nit ? (' - NIT: ' + c.nit) : '';
            return '<option value="'+c.id+'">['+codigo+'] '+nombre+nit+'</option>';
          }).join('');
      }
      
      CATALOGOS_FILTRO_CARGADOS = true;
    }catch(err){
      console.error('[cotizaciones] Error cargando clientes para filtro:', err);
      const selFiltro = document.getElementById('f_cliente');
      if(selFiltro) selFiltro.innerHTML = '<option value="">(Error al cargar)</option>';
    }
  }

  async function cargarCatalogos(){
    if(CATALOGOS_CARGADOS) return;
    
    try{
      [CAT_CLIENTES, CAT_VENDEDORES, CAT_PRODS] = await Promise.all([
        fetchJson(API_CAT + '/clientes'),
        fetchJson(API_CAT + '/empleados'),
        fetchJson(API_CAT + '/productos-stock')
      ]);

      CAT_CLIENTES = asArray(CAT_CLIENTES);
      CAT_VENDEDORES = asArray(CAT_VENDEDORES);
      CAT_PRODS = asArray(CAT_PRODS);

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

      CATALOGOS_CARGADOS = true;
    }catch(err){
      console.error('[cotizaciones] Error cargando catálogos:', err);
      throw err;
    }
  }

  async function cargarCatalogosConversion(){
    if(CATALOGOS_CONVERSION_CARGADOS) return;
    
    try{
      [CAT_BODEGAS, CAT_SERIES, CAT_EMPLEADOS] = await Promise.all([
        fetchJson(API_CAT + '/bodegas'),
        fetchJson(API_CAT + '/series'),
        fetchJson(API_CAT + '/empleados')
      ]);

      CAT_BODEGAS = asArray(CAT_BODEGAS);
      CAT_SERIES = asArray(CAT_SERIES);
      CAT_EMPLEADOS = asArray(CAT_EMPLEADOS);

      // Llenar select de bodegas
      const selBod = document.getElementById('cv_bodega');
      selBod.innerHTML = '<option value="">-- Selecciona bodega --</option>' +
        CAT_BODEGAS.map(b => '<option value="'+b.id+'">'+(b.nombre||('Bodega '+b.id))+'</option>').join('');
      // Preseleccionar bodega 1 si existe
      if(CAT_BODEGAS.find(b => b.id === 1)) selBod.value = '1';

      // Llenar select de series
      const selSer = document.getElementById('cv_serie');
      selSer.innerHTML = '<option value="">-- Selecciona serie --</option>' +
        CAT_SERIES.map(s => '<option value="'+s.id+'">'+(s.serie||('Serie '+s.id))+' ('+s.correlativo+')</option>').join('');
      // Preseleccionar serie 1 si existe
      if(CAT_SERIES.find(s => s.id === 1)) selSer.value = '1';

      // Llenar select de cajeros (empleados)
      const selCaj = document.getElementById('cv_cajero');
      selCaj.innerHTML = '<option value="">-- Ninguno --</option>' +
        CAT_EMPLEADOS.map(e => {
          const nom = ((e.nombres||'') + ' ' + (e.apellidos||'')).trim();
          return '<option value="'+e.id+'">['+(e.codigo||('EMP-'+e.id))+'] '+(nom||('Empleado '+e.id))+'</option>';
        }).join('');
      // Preseleccionar cajero 1 si existe
      if(CAT_EMPLEADOS.find(e => e.id === 1)) selCaj.value = '1';

      CATALOGOS_CONVERSION_CARGADOS = true;
    }catch(err){
      console.error('[cotizaciones] Error cargando catálogos de conversión:', err);
      throw err;
    }
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
    setRows(Array.isArray(data) ? data : asArray(data));
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
      + '<td><input type="number" class="form-control form-control-sm price" min="0" step="0.01" placeholder="0.00" readonly></td>'
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
      if(!CATALOGOS_CARGADOS) await cargarCatalogos();
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
  let COT_ACTUAL = null;

  function setHtml(id, html){ 
    var el=document.getElementById(id); 
    if(el) el.innerHTML = html; 
  }

  function renderCabecera(h){
    const estadoHtml = estadoBadgeHtml(h.estado);
    const html = ''
      + '<div class="row g-2">'
      +   '<div class="col-md-3"><b>Número:</b> ' + txt(h.numeroCotizacion || h.numero_cotizacion) + '</div>'
      +   '<div class="col-md-3"><b>Fecha:</b> ' + txt(h.fechaCotizacion || h.fecha_cotizacion) + '</div>'
      +   '<div class="col-md-3"><b>Vigencia:</b> ' + txt(h.fechaVigencia || h.fecha_vigencia) + '</div>'
      +   '<div class="col-md-3"><b>Estado:</b> ' + estadoHtml + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-6"><b>Cliente:</b> ' + txt(h.clienteNombre || h.cliente_nombre || ('ID '+h.clienteId)) + '</div>'
      +   '<div class="col-md-6"><b>Vendedor:</b> ' + txt(h.vendedorNombre || h.vendedor_nombre || ('ID '+h.vendedorId)) + '</div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-4"><b>Subtotal:</b> ' + money(h.subtotal) + '</div>'
      +   '<div class="col-md-4"><b>Descuento:</b> ' + money(h.descuentoGeneral || h.descuento_general) + '</div>'
      +   '<div class="col-md-4"><span class="badge bg-primary-subtle text-primary-emphasis">Total ' + money(h.total) + '</span></div>'
      + '</div>'
      + '<div class="row g-2 mt-2">'
      +   '<div class="col-md-12"><b>Observaciones:</b> ' + txt(h.observaciones) + '</div>'
      +   '<div class="col-md-12"><b>Términos:</b> ' + txt(h.terminosCondiciones || h.terminos_condiciones || h.terminos) + '</div>'
      + '</div>';
    setHtml('cabecera', html);
  }

  function renderDetalle(items){
    const tbody = document.getElementById('tbodyDetalle');
    const empty = document.getElementById('tablaDetalleEmpty');
    
    if(!tbody) return;
    
    tbody.innerHTML = '';

    if(!items || !items.length){
      if(empty) empty.classList.remove('d-none');
      return;
    }
    if(empty) empty.classList.add('d-none');

    for (let i=0; i<items.length; i++){
      const d = items[i];
      const prodNombre = d.productoNombre || d.producto_nombre || d.productoCodigo || d.producto_codigo || ('ID ' + d.productoId);
      
      const tr = document.createElement('tr');
      tr.innerHTML =
          '<td>' + prodNombre + '</td>'
        + '<td class="text-end">' + txt(d.cantidad) + '</td>'
        + '<td class="text-end">' + money(d.precioUnitario || d.precio_unitario) + '</td>'
        + '<td class="text-end">' + money(d.descuentoLinea || d.descuento_linea) + '</td>'
        + '<td class="text-end">' + money(d.subtotal) + '</td>'
        + '<td>' + txt(d.lote || 'S/N') + '</td>'
        + '<td>' + txt(d.fechaVencimiento || d.fecha_vencimiento || '—') + '</td>';
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

      const ventaId = (data && (data.venta_id || data.ventaId || data.id)) || null;
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
      if(btn){ btn.disabled = false; btn.innerHTML = '<i class="bi bi-arrow-left-right me-1"></i> Convertir'; }
    }
  }

  async function abrirVerCot(id){
    const modalEl = document.getElementById('modalVerCot');
    const md = bootstrap.Modal.getOrCreateInstance(modalEl);
    
    // Limpia UI
    const topAlert = document.getElementById('topAlert');
    if(topAlert){ topAlert.classList.add('d-none'); topAlert.textContent=''; }
    
    setHtml('cabecera','<div class="text-muted">Cargando cotización...</div>');
    
    const tb = document.getElementById('tbodyDetalle'); 
    if (tb) tb.innerHTML='';
    
    const empty = document.getElementById('tablaDetalleEmpty'); 
    if (empty) empty.classList.add('d-none');
    
    document.getElementById('btnConvertir').disabled = true;

    // Cargar catálogos de conversión si no están cargados
    if(!CATALOGOS_CONVERSION_CARGADOS){
      try{
        await cargarCatalogosConversion();
      }catch(err){
        console.error('[cotizaciones] Error cargando catálogos de conversión:', err);
      }
    }

    md.show();

    try{
      const h = await fetchJson(API_COTS + '/' + encodeURIComponent(id));
      if(!h || !h.id) throw new Error('Cotización no encontrada');

      COT_ACTUAL = h;
      renderCabecera(h);
      
      // Renderizar detalle - asegurarse de obtener el array correcto
      const items = h.items || h.detalle || h.lineas || [];
      renderDetalle(asArray(items));
      
      document.getElementById('btnConvertir').disabled = false;
    }catch(err){
      if(topAlert){ 
        topAlert.textContent = 'Error: ' + (err.message || 'desconocido'); 
        topAlert.classList.remove('d-none'); 
      }
      console.error('[cotizaciones] Error:', err);
    }
  }

  document.getElementById('btnConvertir').addEventListener('click', convertirAVenta);

  /* =========================
     BOOT
     ========================= */
  window.addEventListener('DOMContentLoaded', () => {
    // Cargar clientes para el filtro al iniciar
    cargarClientesFiltro().catch(console.error);
    // Buscar cotizaciones
    buscar().catch(console.error);
  });
  </script>
</body>
</html>