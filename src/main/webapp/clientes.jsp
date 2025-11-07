<%-- 
    Document   : clientes
    Created on : 2/11/2025, 01:54:52
    Author     : rodri
--%>

<%@page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="false"%>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Clientes | NextTech</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <!-- Base del backend (centralizado) -->
  <meta name="api-base" content="https://nexttech-backend-jw9h.onrender.com">

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema / estilos del proyecto -->
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/base.css?v=13">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/app.css?v=13">

  <!-- utilidades comunes -->
  <script src="${pageContext.request.contextPath}/assets/js/common.js?v=99"></script>

  <style>
  /* === Mapea variables existentes del tema (base.css) ===
     Antes usabas --nt-surface-1, --nt-fg*, que no existen */
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
    background: var(--nt-surface);                  /* <-- antes: --nt-surface-1 (NO existe) */
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
    color: var(--nt-text);                           /* <-- antes: --nt-fg (NO existe) */
    border-color: var(--nt-border);
  }
  .form-control.nt-input:focus, .form-select.nt-input:focus{
    border-color: var(--nt-accent);
    box-shadow: 0 0 0 .2rem rgba(0,102,255,.15);
  }

  /* Modal del tema (asegura fondo sólido) */
  .modal-content{
    background: var(--nt-surface) !important;        /* <-- antes: --nt-surface-1 (NO existe) */
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
</head>
<body class="nt-bg min-vh-100 d-flex flex-column">

  <!-- Header / Navbar -->
  <header class="navbar nt-navbar">
    <div class="container d-flex align-items-center justify-content-between">
      <a class="navbar-brand fw-bold d-flex align-items-center gap-2">
        <i class="bi bi-people"></i> NextTech — Clientes
      </a>
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
            <i class="bi bi-arrow-left"></i> Regresar
        </button>
    </div>
  </header>

  <div class="container py-4">

    <!-- Título -->
<div class="d-flex justify-content-between align-items-center mb-3">
  <div>
    <h3 class="m-0 nt-title">Clientes</h3>
    <div class="nt-subtitle">Gestión de clientes del sistema</div>
  </div>
  <div class="d-flex align-items-center gap-2">
    <a class="btn btn-sm nt-back" href="${pageContext.request.contextPath}/index.jsp" title="Inicio">
      <i class="bi bi-house-door"></i> Inicio
    </a>
    <button id="btnNuevo" class="btn btn-sm nt-btn-accent" data-bs-toggle="modal" data-bs-target="#modalCliente">
      <i class="bi bi-plus-lg me-1"></i> Nuevo cliente
    </button>
  </div>
</div>

    <!-- Filtros -->
    <div class="card nt-card mb-3">
      <div class="card-body">
        <form class="row g-2 align-items-end">
          <div class="col-sm-5">
            <label class="form-label">Texto</label>
            <input type="text" id="f_texto" class="form-control" placeholder="Nombre, NIT, código, email...">
          </div>
          <div class="col-sm-3">
            <label class="form-label">Estado</label>
            <select id="f_estado" class="form-select">
              <option value="">(Todos)</option>
              <option value="A">Activos</option>
              <option value="I">Inactivos</option>
            </select>
          </div>
          <div class="col-sm-2">
            <label class="form-label">Página</label>
            <input type="number" id="f_page" class="form-control" value="0" min="0">
          </div>
          <div class="col-sm-2">
            <label class="form-label">Tamaño</label>
            <input type="number" id="f_size" class="form-control" value="50" min="1">
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
            <th>Código</th>
            <th>Nombre</th>
            <th>NIT</th>
            <th>Teléfono</th>
            <th>Email</th>
            <th>Estado</th>
            <th class="text-end" style="width:140px;">Acciones</th>
          </tr>
          </thead>
          <tbody></tbody>
        </table>
      </div>
      <div id="tablaEmpty" class="p-3 text-muted">Sin resultados.</div>
    </div>
  </div>

  <!-- Modal: Ver cliente -->
  <div class="modal fade" id="modalVerCliente" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title"><i class="bi bi-eye me-2"></i>Detalle del cliente</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>
        <div class="modal-body">
          <div class="row g-3">
            <div class="col-md-4"><strong>Código:</strong> <span id="vc_codigo"></span></div>
            <div class="col-md-8"><strong>Nombre:</strong> <span id="vc_nombre"></span></div>
            <div class="col-md-4"><strong>NIT:</strong> <span id="vc_nit"></span></div>
            <div class="col-md-4"><strong>Teléfono:</strong> <span id="vc_tel"></span></div>
            <div class="col-md-4"><strong>Email:</strong> <span id="vc_email"></span></div>
            <div class="col-12"><strong>Dirección:</strong> <span id="vc_dir"></span></div>
            <div class="col-md-4"><strong>Límite crédito:</strong> <span id="vc_lim"></span></div>
            <div class="col-md-4"><strong>Días crédito:</strong> <span id="vc_dias"></span></div>
            <div class="col-md-4"><strong>Estado:</strong> <span id="vc_estado"></span></div>
            <div class="col-md-4"><strong>Tipo:</strong> <span id="vc_tipo"></span></div>
            <div class="col-md-8"><strong>Registrado por:</strong> <span id="vc_reg"></span></div>
          </div>
        </div>
        <div class="modal-footer">
          <button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- Modal: Crear/Editar Cliente -->
  <div class="modal fade" id="modalCliente" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
      <div class="modal-content nt-card">
        <div class="modal-header">
          <h5 class="modal-title" id="mc_title">Nuevo cliente</h5>
          <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Cerrar"></button>
        </div>

        <div class="modal-body">
          <div id="mc_alert" class="alert alert-danger d-none"></div>
          <div id="mc_ok" class="alert alert-success d-none"></div>

          <form class="row g-2">
            <input type="hidden" id="mc_id" value="">

            <div class="col-sm-4">
              <label class="form-label">Código</label>
              <div class="input-group">
                <input type="text" id="mc_codigo" class="form-control" placeholder="CLI-XXX">
                <button type="button" class="btn btn-outline-primary" id="mc_autocodigo">
                  <i class="bi bi-magic"></i> Auto
                </button>
              </div>
              <div class="form-text">Si lo dejas vacío, usa “Auto”.</div>
            </div>

            <div class="col-sm-8">
              <label class="form-label">Nombre *</label>
              <input type="text" id="mc_nombre" class="form-control" required maxlength="200">
            </div>

            <div class="col-sm-4">
              <label class="form-label">NIT</label>
              <input type="text" id="mc_nit" class="form-control" maxlength="30">
            </div>

            <div class="col-sm-4">
              <label class="form-label">Teléfono</label>
              <input type="text" id="mc_telefono" class="form-control" maxlength="30">
            </div>

            <div class="col-sm-4">
              <label class="form-label">Email</label>
              <input type="email" id="mc_email" class="form-control" maxlength="150" placeholder="correo@empresa.com">
            </div>

            <div class="col-12">
              <label class="form-label">Dirección</label>
              <input type="text" id="mc_direccion" class="form-control" maxlength="200">
            </div>

            <div class="col-sm-4">
              <label class="form-label">Límite crédito</label>
              <input type="number" id="mc_limite" class="form-control" min="0" step="0.01" placeholder="0.00">
            </div>

            <div class="col-sm-4">
              <label class="form-label">Días crédito</label>
              <input type="number" id="mc_dias" class="form-control" min="0" step="1" placeholder="0">
            </div>

            <div class="col-sm-2">
              <label class="form-label">Estado *</label>
              <select id="mc_estado" class="form-select" required>
                <option value="A">Activo</option>
                <option value="I">Inactivo</option>
              </select>
            </div>

            <div class="col-sm-2">
              <label class="form-label">Tipo</label>
              <select id="mc_tipo" class="form-select" disabled>
                <option value="I" selected>I</option>
              </select>
            </div>

          </form>

        </div>

        <div class="modal-footer">
          <button id="mc_save" type="button" class="btn nt-btn-accent">
            <i class="bi bi-save me-1"></i> Guardar
          </button>
          <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cerrar</button>
        </div>
      </div>
    </div>
  </div>

  <!-- JS -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <script>
  // ========= API base sincronizada con meta =========
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
  const API_CLI  = API_BASE + '/api/clientes';

  // ---------- helpers ----------
  async function fetchJson(url, opts){
    const r = await fetch(url, opts||{});
    const t = await r.text();
    let d = null; try{ d = t ? JSON.parse(t) : null; }catch(_){}
    if(!r.ok) throw new Error((d && (d.error||d.detail||d.message)||('HTTP '+r.status)));
    return d;
  }
  const clean = (s)=> (s==null)?'':String(s).replace(/^[\s'"]+|[\s'"]+$/g,'').replace(/\s+/g,' ').trim();
  const nz = (x, def)=> (x===undefined||x===null)?def:x;
  const estadoBadgeHtml = (e)=>{
    if(e==='A') return '<span class="badge rounded-pill text-bg-success">Activo</span>';
    if(e==='I') return '<span class="badge rounded-pill text-bg-secondary">Inactivo</span>';
    return '<span class="badge rounded-pill text-bg-dark">'+(e||'')+'</span>';
  };

  // ---------- tabla ----------
  async function buscar(){
    try{
      const p=new URLSearchParams();
      const texto = document.getElementById('f_texto')?.value||'';
      const estado= document.getElementById('f_estado')?.value||'';
      const page  = parseInt(document.getElementById('f_page')?.value||'0',10);
      const size  = parseInt(document.getElementById('f_size')?.value||'50',10);
      p.append('texto', texto);
      if(estado) p.append('estado', estado);
      p.append('page', page);
      p.append('size', size);

      const data = await fetchJson(API_CLI + '?' + p.toString());
      setRows(data);
    }catch(err){
      console.error('[clientes] buscar()', err);
      const empty = document.getElementById('tablaEmpty');
      if (empty) empty.textContent = 'Error: ' + (err.message||'desconocido');
    }
  }

  function setRows(rows){
    const tb = document.querySelector('#tabla tbody');
    const empty = document.getElementById('tablaEmpty');
    if(!tb){ console.error('tbody no encontrado'); return; }

    tb.innerHTML = '';
    if(!rows || !rows.length){
      if (empty) empty.textContent = 'Sin resultados.';
      return;
    }
    if (empty) empty.textContent = '';

    for (const r of rows){
      const activar = (r.estado === 'A')
        ? '<button class="btn btn-outline-danger btn-icon" title="Inactivar" data-chg="'+ r.id +'" data-to="I"><i class="bi bi-power"></i></button>'
        : '<button class="btn btn-outline-success btn-icon" title="Activar"   data-chg="'+ r.id +'" data-to="A"><i class="bi bi-power"></i></button>';

      const tr = document.createElement('tr');
      tr.innerHTML =
          '<td>'+ nz(r.id,'') +'</td>'
        + '<td>'+ nz(r.codigo,'') +'</td>'
        + '<td>'+ nz(r.nombre,'') +'</td>'
        + '<td>'+ nz(r.nit,'') +'</td>'
        + '<td>'+ nz(r.telefono,'') +'</td>'
        + '<td>'+ nz(r.email,'') +'</td>'
        + '<td>'+ estadoBadgeHtml(r.estado) +'</td>'
        + '<td class="text-end">'
        +   '<div class="btn-group" role="group">'
        +     '<button class="btn btn-outline-secondary btn-icon" title="Ver" data-view="'+ r.id +'"><i class="bi bi-eye"></i></button>'
        +     '<button class="btn btn-outline-primary   btn-icon" title="Editar" data-edit="'+ r.id +'"><i class="bi bi-pencil-square"></i></button>'
        +      activar
        +   '</div>'
        + '</td>';
      tb.appendChild(tr);
    }
  }

  // ---------- modal crear/editar ----------
  const mc = {
    id: document.getElementById('mc_id'),
    title: document.getElementById('mc_title'),
    alert: document.getElementById('mc_alert'),
    ok: document.getElementById('mc_ok'),
    codigo: document.getElementById('mc_codigo'),
    nombre: document.getElementById('mc_nombre'),
    nit: document.getElementById('mc_nit'),
    telefono: document.getElementById('mc_telefono'),
    direccion: document.getElementById('mc_direccion'),
    email: document.getElementById('mc_email'),
    limite: document.getElementById('mc_limite'),
    dias: document.getElementById('mc_dias'),
    estado: document.getElementById('mc_estado'),
    tipo: document.getElementById('mc_tipo'),
    btnAuto: document.getElementById('mc_autocodigo'),
    btnSave: document.getElementById('mc_save'),
  };
  const mc_cleanAlerts = ()=>{ mc.alert.classList.add('d-none'); mc.alert.textContent=''; mc.ok.classList.add('d-none'); mc.ok.textContent=''; };
  const mc_clearInvalid = ()=>{ [mc.nombre, mc.email, mc.limite, mc.dias].forEach(el=>el?.classList.remove('is-invalid')); };

  function mc_reset(){
    mc_cleanAlerts(); mc_clearInvalid();
    mc.id.value=''; mc.codigo.value=''; mc.nombre.value=''; mc.nit.value='';
    mc.telefono.value=''; mc.direccion.value=''; mc.email.value='';
    mc.limite.value=''; mc.dias.value=''; mc.estado.value='A';
    mc.tipo.value='I'; // fijo
  }
  function mc_fill(h){
    mc.id.value = h.id||'';
    mc.codigo.value = h.codigo||'';
    mc.nombre.value = h.nombre||'';
    mc.nit.value = h.nit||'';
    mc.telefono.value = h.telefono||'';
    mc.direccion.value = h.direccion||'';
    mc.email.value = h.email||'';
    mc.limite.value = (h.limite_credito!=null)?h.limite_credito:'';
    mc.dias.value   = (h.dias_credito!=null)?h.dias_credito:'';
    mc.estado.value = h.estado||'A';
    mc.tipo.value   = 'I'; // SIEMPRE I
  }
  async function mc_autoCodigo(){
    try{
      mc_cleanAlerts();
      const r = await fetchJson(API_CLI + '/next-codigo');
      mc.codigo.value = r.next_codigo || '';
    }catch(err){
      console.error(err);
      mc.alert.textContent = err.message || 'Error generando código';
      mc.alert.classList.remove('d-none');
    }
  }
  function mc_validate(){
    mc_clearInvalid();
    let ok = true;
    if(!clean(mc.nombre.value)){ mc.nombre.classList.add('is-invalid'); ok=false; }
    const mail = clean(mc.email.value);
    if(mail && !/^\S+@\S+\.\S+$/.test(mail)){ mc.email.classList.add('is-invalid'); ok=false; }
    const lim = mc.limite.value ? Number(mc.limite.value) : 0;
    if(lim < 0){ mc.limite.classList.add('is-invalid'); ok=false; }
    const dias = mc.dias.value ? Number(mc.dias.value) : 0;
    if(dias < 0){ mc.dias.classList.add('is-invalid'); ok=false; }
    return ok;
  }
  async function mc_save(){
    try{
      mc_cleanAlerts();
      if(!mc_validate()) return;

      const payload = {
        codigo: clean(mc.codigo.value) || null,
        nombre: clean(mc.nombre.value),
        nit: clean(mc.nit.value) || null,
        telefono: clean(mc.telefono.value) || null,
        direccion: clean(mc.direccion.value) || null,
        email: clean(mc.email.value) || null,
        limiteCredito: mc.limite.value ? Number(mc.limite.value) : null,
        diasCredito: mc.dias.value ? Number(mc.dias.value) : null,
        estado: mc.estado.value,   // A/I
        tipoCliente: 'I',          // SIEMPRE I (fijo)
        registradoPor: 1
      };

      const id = mc.id.value;
      let res;
      if(id){
        res = await fetchJson(API_CLI + '/' + encodeURIComponent(id), {
          method:'PUT', headers:{'Content-Type':'application/json'},
          body: JSON.stringify(payload)
        });
      }else{
        res = await fetchJson(API_CLI, {
          method:'POST', headers:{'Content-Type':'application/json'},
          body: JSON.stringify(payload)
        });
      }

      mc.ok.textContent = (res.message||'OK');
      mc.ok.classList.remove('d-none');
      setTimeout(()=>{
        const el = document.getElementById('modalCliente');
        (bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el)).hide();
        buscar();
      }, 700);

    }catch(err){
      console.error(err);
      mc.alert.textContent = err.message || 'Error al guardar';
      mc.alert.classList.remove('d-none');
    }
  }

  // ---------- Ver cliente ----------
  const vc = {
    codigo: document.getElementById('vc_codigo'),
    nombre: document.getElementById('vc_nombre'),
    nit: document.getElementById('vc_nit'),
    tel: document.getElementById('vc_tel'),
    email: document.getElementById('vc_email'),
    dir: document.getElementById('vc_dir'),
    lim: document.getElementById('vc_lim'),
    dias: document.getElementById('vc_dias'),
    estado: document.getElementById('vc_estado'),
    tipo: document.getElementById('vc_tipo'),
    reg: document.getElementById('vc_reg'),
  };
  function vc_fill(h){
    vc.codigo.textContent = h.codigo||'';
    vc.nombre.textContent = h.nombre||'';
    vc.nit.textContent    = h.nit||'';
    vc.tel.textContent    = h.telefono||'';
    vc.email.textContent  = h.email||'';
    vc.dir.textContent    = h.direccion||'';
    vc.lim.textContent    = (h.limite_credito!=null)?h.limite_credito:'';
    vc.dias.textContent   = (h.dias_credito!=null)?h.dias_credito:'';
    vc.estado.innerHTML   = estadoBadgeHtml(h.estado||'');
    vc.tipo.textContent   = 'I'; // fijo en UI
    vc.reg.textContent    = (h.registrado_por!=null)?('Usuario ID '+h.registrado_por):'';
  }
  async function onView(id){
    try{
      const h = await fetchJson(API_CLI + '/' + encodeURIComponent(id));
      vc_fill(h);
      const el = document.getElementById('modalVerCliente');
      (bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el)).show();
    }catch(err){
      console.error(err);
      alert('Error cargando cliente: ' + (err.message||''));
    }
  }
    function goBack(){ try{ if(history.length>1){ history.back(); return; } }catch(_){ } location.href='${pageContext.request.contextPath}/Dashboard.jsp'; }

  // ---------- acciones ----------
  async function onEdit(id){
    try{
      mc_reset();
      mc.title.textContent = 'Editar cliente';
      const h = await fetchJson(API_CLI + '/' + encodeURIComponent(id));
      mc_fill(h);
      const el = document.getElementById('modalCliente');
      (bootstrap.Modal.getInstance(el) || new bootstrap.Modal(el)).show();
    }catch(err){
      console.error(err);
      alert('Error cargando cliente: ' + (err.message||''));
    }
  }
  async function onChangeEstado(id, to){
    try{
      await fetchJson(API_CLI + '/' + encodeURIComponent(id) + '/estado?estado=' + encodeURIComponent(to), { method:'POST' });
      await buscar();
    }catch(err){
      console.error(err);
      alert('No se pudo cambiar estado: ' + (err.message||''));
    }
  }

  // ---------- listeners ----------
  document.getElementById('btnBuscar')?.addEventListener('click', buscar);
  document.getElementById('btnLimpiar')?.addEventListener('click', ()=>{
    document.getElementById('f_texto').value='';
    document.getElementById('f_estado').value='';
    document.getElementById('f_page').value='0';
    document.getElementById('f_size').value='50';
    buscar();
  });
  document.getElementById('btnNuevo')?.addEventListener('click', ()=>{
    mc_reset();
    mc.title.textContent = 'Nuevo cliente';
  });
  mc.btnAuto?.addEventListener('click', mc_autoCodigo);
  mc.btnSave?.addEventListener('click', mc_save);

  const tbody = document.querySelector('#tabla tbody');
  if(tbody){
    tbody.addEventListener('click', (e)=>{
      const btn = e.target.closest('button');
      if(!btn) return;
      const idView = btn.getAttribute('data-view');
      const idEdit = btn.getAttribute('data-edit');
      const chg = btn.getAttribute('data-chg');
      const to  = btn.getAttribute('data-to');
      if(idView){ onView(idView); return; }
      if(idEdit){ onEdit(idEdit); return; }
      if(chg && to){ onChangeEstado(chg, to); }
    });
  }

  // Carga inicial
  window.addEventListener('DOMContentLoaded', buscar);
  </script>
</body>
</html>
