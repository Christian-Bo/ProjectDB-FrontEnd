<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <title>NextTech — RRHH</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />

  <!-- Base del backend -->
  <meta name="api-base" content="http://localhost:8080"/>

  <!-- Bootstrap + Icons -->
  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
  <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

  <!-- Tema NextTech -->
  <link rel="stylesheet" href="assets/css/base.css?v=1">
  <link rel="stylesheet" href="assets/css/app.css?v=1">

  <style>
    /* Layout base */
    html, body { height: 100%; }
    body.nt-bg { min-height: 100vh; display: flex; flex-direction: column; }
    main.flex-grow-1 { flex: 1 1 auto; display: flex; flex-direction: column; }

    /* Topbar unificada */
    .nt-navbar{
      background: var(--nt-surface-1);
      border-bottom: 1px solid var(--nt-border);
    }
    .nt-navbar .navbar-brand{ color: var(--nt-fg-strong); }
    .nt-navbar .container-fluid{
      display:flex; align-items:center; justify-content:space-between;
      min-height: 56px;
    }

    /* Botón Regresar */
    .nt-back{
      display:inline-flex; align-items:center; gap:.5rem;
      border:1px solid var(--nt-border);
      background: transparent; color: var(--nt-primary);
    }
    .nt-back:hover{ background: var(--nt-surface-2); color: var(--nt-primary); }

    /* Tabs */
    .nt-pills .nav-link{
      border:1px solid var(--nt-border);
      background:var(--nt-surface-1);
      color:var(--nt-fg);
      margin-right:.5rem;
      border-radius:.75rem;
    }
    .nt-pills .nav-link:hover{ background:var(--nt-surface-2); }
    .nt-pills .nav-link.active{
      background:var(--nt-accent); color:#fff; border-color:transparent;
      box-shadow:0 6px 16px rgba(0,0,0,.25);
    }

    /* Tarjetas/Tablas/KPIs */
    .nt-card{
      background: var(--nt-surface-1);
      border:1px solid var(--nt-border);
      border-radius: 1rem;
      padding: .75rem;
    }
    .nt-table-head{ background: var(--nt-surface-2); color: var(--nt-fg); }

    .nt-kpi{
      text-align:center; padding:1rem; border-radius:.75rem;
      background: var(--nt-surface-1); border:1px solid var(--nt-border);
    }
    .nt-kpi h2{ color: var(--nt-primary); margin: 0; }
    .nt-kpi p { margin: 0; color: var(--nt-fg); opacity: .85; }

    /* Separaciones suaves */
    .nt-card .btn-toolbar,
    .nt-card .nt-toolbar,
    .nt-card .row,
    .nt-card .card-header { margin-bottom: .75rem; }

    .nt-card .table { margin-top: .75rem; }
    .nt-card .pagination,
    .nt-card .card-footer { margin-top: .75rem; }

    #rrhhTabs { margin-bottom: 1rem; }
  </style>
  
  <script src="assets/js/auth.guard.js"></script>
  <script>
    // Protección de acceso (RRHH o ADMIN)
    window.addEventListener('DOMContentLoaded', () => {
      Auth?.ensure?.(['RRHH','ADMIN']);
    });

    // Helpers de navegación
    function parseAuthUser(){
      try{
        if (window.Auth?.user) return window.Auth.user;
        const raw = localStorage.getItem('auth_user');
        return raw ? JSON.parse(raw) : null;
      }catch(_){ return null; }
    }
    function homeForRole(role){
      const map = {
        'ADMIN':'dashboard_admin.jsp',
        'FINANZAS':'dashboard_finanzas.jsp',
        'AUDITOR':'dashboard_auditor.jsp',
        'RRHH':'dashboard_rrhh.jsp',
        'OPERACIONES':'dashboard_operaciones.jsp',
        'OPERADOR':'dashboard_operaciones.jsp'
      };
      return map[(role||'').toUpperCase()] || 'Dashboard.jsp';
    }
    function goBack(){
      if (history.length > 1) { history.back(); return; }
      const user = parseAuthUser();
      location.href = homeForRole(user?.role || user?.rol);
    }
  </script>
</head>
<body class="nt-bg">

  <!-- Topbar -->
  <header class="navbar nt-navbar">
    <div class="container-fluid">
      <a class="navbar-brand d-flex align-items-center gap-2 fw-bold" href="Dashboard.jsp" title="Ir al dashboard">
        <i class="bi bi-people"></i> NextTech — RRHH
      </a>
      <div class="d-flex align-items-center gap-2">
        <button type="button" class="btn btn-sm nt-back" onclick="goBack()" title="Regresar">
          <i class="bi bi-arrow-left"></i> Regresar
        </button>
      </div>
    </div>
  </header>

  <!-- Contenido -->
  <main class="py-4 flex-grow-1">
    <div class="container-fluid">

      <!-- Tabs -->
      <ul class="nav nt-pills mb-3" id="rrhhTabs" role="tablist">
        <li class="nav-item" role="presentation">
          <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#tab-empleados" type="button" role="tab">
            <i class="bi bi-person-badge"></i> Empleados
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-puestos" type="button" role="tab">
            <i class="bi bi-diagram-3"></i> Puestos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-deptos" type="button" role="tab">
            <i class="bi bi-building"></i> Departamentos
          </button>
        </li>
        <li class="nav-item" role="presentation">
          <button class="nav-link" data-bs-toggle="tab" data-bs-target="#tab-usuarios" type="button" role="tab">
            <i class="bi bi-people"></i> Usuarios
          </button>
        </li>
      </ul>

      <div class="tab-content">

        <!-- EMPLEADOS -->
        <div id="tab-empleados" class="tab-pane fade show active" role="tabpanel">
          <div class="row g-3 mb-3">
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Total empleados</p><h2 id="kpiEmpTotal">—</h2></div></div>
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Activos</p><h2 id="kpiEmpActivos">—</h2></div></div>
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Inactivos</p><h2 id="kpiEmpInactivos">—</h2></div></div>
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Suspendidos</p><h2 id="kpiEmpSuspendidos">—</h2></div></div>
          </div>
          <div class="card nt-card">
            <jsp:include page="empleados.jsp" />
          </div>
        </div>

        <!-- PUESTOS -->
        <div id="tab-puestos" class="tab-pane fade" role="tabpanel">
          <div class="row g-3 mb-3">
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Puestos</p><h2 id="kpiPuestosTotal">—</h2></div></div>
          </div>
          <div class="card nt-card">
            <jsp:include page="puestos.jsp" />
          </div>
        </div>

        <!-- DEPARTAMENTOS -->
        <div id="tab-deptos" class="tab-pane fade" role="tabpanel">
          <div class="row g-3 mb-3">
            <div class="col-6 col-lg-3"><div class="nt-kpi"><p>Departamentos</p><h2 id="kpiDeptoTotal">—</h2></div></div>
          </div>
          <div class="card nt-card">
            <jsp:include page="departamentos.jsp" />
          </div>
        </div>

        <!-- USUARIOS -->
        <div id="tab-usuarios" class="tab-pane fade" role="tabpanel">
          <div class="card nt-card">
            <jsp:include page="usuarios.jsp" />
          </div>
        </div>

      </div>
    </div>
  </main>

  <!-- Toasts -->
  <div class="position-fixed top-0 end-0 p-3" style="z-index:1080">
    <div id="toastStack" class="toast-container"></div>
  </div>

  <!-- JS bundle -->
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

  <!-- Inyector Authorization / API y utilidades -->
  <script src="assets/js/common.api.js?v=99"></script>
  <script src="assets/js/common_recursos.js?v=2"></script>

  <!-- ===== UI Bonita: toasts + confirm (sin tocar tus módulos) ===== -->
  <script>
  (function () {
    /* ---------- TOASTS (usa base.css) ---------- */
    var ICON = { success:'check-circle', error:'x-octagon', warn:'exclamation-triangle', warning:'exclamation-triangle', info:'info-circle' };
    var BORDER_VAR = { success:'var(--nt-success)', error:'var(--nt-danger)', warn:'var(--nt-warning)', warning:'var(--nt-warning)', info:'var(--nt-info)' };

    function getToastStack(){
      var s = document.getElementById('toastStack');
      if (s) return s;
      var wrap = document.createElement('div');
      wrap.className = 'position-fixed top-0 end-0 p-3';
      wrap.style.zIndex = 1080;
      s = document.createElement('div');
      s.id = 'toastStack';
      s.className = 'toast-container';
      wrap.appendChild(s);
      document.body.appendChild(wrap);
      return s;
    }

    function toast(title, bodyOrType, type, delay){
      var klass = 'info';
      var body  = bodyOrType;
      if ((bodyOrType === 'success' || bodyOrType === 'error' || bodyOrType === 'warn' || bodyOrType === 'warning' || bodyOrType === 'info') && (type === undefined || type === null)) {
        klass = bodyOrType; body = '';
      } else {
        klass = (['success','error','warn','warning','info'].indexOf(type||'')>=0)?(type||'info'):'info';
      }
      var stack = getToastStack();
      if (typeof bootstrap === 'undefined') { alert((title?title+': ':'')+(body||'')); return; }
      var el = document.createElement('div');
      el.className = 'toast nt-toast nt-toast-' + klass + ' text-white';
      el.setAttribute('role','alert'); el.setAttribute('aria-live','assertive'); el.setAttribute('aria-atomic','true');
      el.style.borderLeft = '4px solid ' + (BORDER_VAR[klass] || BORDER_VAR.info);
      el.style.boxShadow = 'var(--nt-shadow)';
      var now = (new Date()).toLocaleTimeString([], { hour:'2-digit', minute:'2-digit' });
      var icon = ICON[klass] || ICON.info;
      el.innerHTML =
        '<div class="toast-header text-white border-0" style="background: transparent;">' +
          '<i class="bi bi-' + icon + '"></i>' +
          '<strong class="me-auto" style="margin-left:.35rem;">' + (title || 'Mensaje') + '</strong>' +
          '<small class="text-muted">' + now + '</small>' +
          '<button type="button" class="btn-close btn-close-white ms-2 mb-1" data-bs-dismiss="toast" aria-label="Close"></button>' +
        '</div>' +
        '<div class="toast-body" style="color:var(--nt-text);">' + (body || '') + '</div>';
      stack.appendChild(el);
      var t = new bootstrap.Toast(el, { delay: (typeof delay==='number'?delay:3500), autohide:true });
      el.addEventListener('hidden.bs.toast', function(){ el.remove(); });
      t.show();
    }

    // API pública: mantiene compatibilidad con tus showToast existentes
    window.NT = window.NT || {};
    window.NT.showToast = toast;
    window.showToast = toast;
    (function patchAlert(){
      var old = window.alert;
      window.alert = function(msg){ try{ toast('Aviso', String(msg), 'info'); }catch(e){ old(msg);} };
    })();

    /* ---------- Confirm bonito (reemplaza confirm() feo) ---------- */
    function ensureConfirmModal(){
      var el = document.getElementById('ntConfirm');
      if (el) return el;
      el = document.createElement('div');
      el.className = 'modal fade';
      el.id = 'ntConfirm';
      el.tabIndex = -1;
      el.setAttribute('aria-hidden','true');
      el.innerHTML =
        '<div class="modal-dialog modal-dialog-centered">'+
          '<div class="modal-content" style="border-radius:1rem; overflow:hidden;">'+
            '<div class="modal-header">'+
              '<h5 class="modal-title" id="ntConfirmTitle">Confirmar</h5>'+
              '<button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>'+
            '</div>'+
            '<div class="modal-body" id="ntConfirmBody">¿Seguro?</div>'+
            '<div class="modal-footer">'+
              '<button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal" id="ntConfirmCancel">Cancelar</button>'+
              '<button type="button" class="btn btn-danger" id="ntConfirmOk">Aceptar</button>'+
            '</div>'+
          '</div>'+
        '</div>';
      document.body.appendChild(el);
      return el;
    }

    function confirmNice(opts, cb){
      if (typeof bootstrap === 'undefined') { cb(window.confirm(opts && opts.body ? opts.body : '¿Seguro?')); return; }
      var el = ensureConfirmModal();
      el.querySelector('#ntConfirmTitle').textContent = (opts && opts.title) ? opts.title : 'Confirmar';
      el.querySelector('#ntConfirmBody').textContent  = (opts && opts.body)  ? opts.body  : '¿Seguro?';
      var okBtn = el.querySelector('#ntConfirmOk');
      var cancelBtn = el.querySelector('#ntConfirmCancel');
      okBtn.className = 'btn ' + ((opts && opts.variant) ? ('btn-' + opts.variant) : 'btn-danger');
      okBtn.textContent = (opts && opts.confirmText) ? opts.confirmText : 'Aceptar';
      cancelBtn.textContent = (opts && opts.cancelText) ? opts.cancelText : 'Cancelar';

      var modal = bootstrap.Modal.getOrCreateInstance(el);
      var done = false;
      function cleanup(){
        okBtn.onclick = null;
        cancelBtn.onclick = null;
        el.removeEventListener('hidden.bs.modal', onHide);
      }
      function onHide(){ if (!done){ cleanup(); cb(false); } }
      okBtn.onclick = function(){ done=true; cleanup(); modal.hide(); cb(true); };
      cancelBtn.onclick = function(){ done=true; cleanup(); modal.hide(); cb(false); };
      el.addEventListener('hidden.bs.modal', onHide, {once:true});
      modal.show();
    }

    /* --- Intercepto clicks de eliminar y hago la operación + toast ---
       Esto conserva la UX anterior: seguirás viendo mensajes como
       "Empleado eliminado", "Puesto actualizado", etc. */
    // Empleados: data-del-emp
    document.addEventListener('click', function(e){
      var btn = e.target.closest('[data-del-emp]');
      if (!btn) return;
      e.preventDefault(); e.stopPropagation(); e.stopImmediatePropagation();
      var id = btn.getAttribute('data-del-emp');
      confirmNice({ title:'Eliminar empleado', body:'Esta acción no se puede deshacer. ¿Deseas continuar?', confirmText:'Sí, eliminar', variant:'danger' }, function(ok){
        if (!ok) return;
        NT.http(NT.baseUrl + '/api/rrhh/empleados/' + id, { method:'DELETE' }).then(function(){
          NT.showToast('Empleados','Empleado eliminado','success');
          try{ RRHH_Empleados && RRHH_Empleados.loadEmpleados && RRHH_Empleados.loadEmpleados(); }catch(_){}
          try{ NT.loadDashboardKPIs && NT.loadDashboardKPIs(); }catch(_){}
        }).catch(function(err){
          NT.showToast('Empleados', String(err && err.message ? err.message : err), 'error');
        });
      });
    }, true);

    // Departamentos: data-del-depto
    document.addEventListener('click', function(e){
      var btn = e.target.closest('[data-del-depto]');
      if (!btn) return;
      e.preventDefault(); e.stopPropagation(); e.stopImmediatePropagation();
      var id = btn.getAttribute('data-del-depto');
      confirmNice({ title:'Eliminar departamento', body:'¿Seguro que deseas eliminar este departamento?', confirmText:'Sí, eliminar', variant:'danger' }, function(ok){
        if (!ok) return;
        NT.http(NT.baseUrl + '/api/rrhh/departamentos/' + id, { method:'DELETE' }).then(function(){
          NT.showToast('Departamentos','Departamento eliminado','success');
          try{ RRHH_Departamentos && RRHH_Departamentos.renderDepartamentos && RRHH_Departamentos.renderDepartamentos(); }catch(_){}
          try{ NT.loadDashboardKPIs && NT.loadDashboardKPIs(); }catch(_){}
        }).catch(function(err){
          NT.showToast('Departamentos', String(err && err.message ? err.message : err), 'error');
        });
      });
    }, true);

    // Puestos: data-del-puesto
    document.addEventListener('click', function(e){
      var btn = e.target.closest('[data-del-puesto]');
      if (!btn) return;
      e.preventDefault(); e.stopPropagation(); e.stopImmediatePropagation();
      var id = btn.getAttribute('data-del-puesto');
      confirmNice({ title:'Eliminar puesto', body:'¿Seguro que deseas eliminar este puesto?', confirmText:'Sí, eliminar', variant:'danger' }, function(ok){
        if (!ok) return;
        NT.http(NT.baseUrl + '/api/rrhh/puestos/' + id, { method:'DELETE' }).then(function(){
          NT.showToast('Puestos','Puesto eliminado','success');
          try{ RRHH_Puestos && RRHH_Puestos.renderPuestos && RRHH_Puestos.renderPuestos(); }catch(_){}
          try{ NT.loadDashboardKPIs && NT.loadDashboardKPIs(); }catch(_){}
        }).catch(function(err){
          NT.showToast('Puestos', String(err && err.message ? err.message : err), 'error');
        });
      });
    }, true);

    // Usuarios: inactivar (data-act="del")
    document.addEventListener('click', function(e){
      var btn = e.target.closest('button[data-act="del"][data-id]');
      if (!btn) return;
      e.preventDefault(); e.stopPropagation(); e.stopImmediatePropagation();
      var id = btn.getAttribute('data-id');
      confirmNice({ title:'Inactivar usuario #' + id, body:'El usuario no podrá iniciar sesión hasta que lo actives.', confirmText:'Sí, inactivar', variant:'warning' }, function(ok){
        if (!ok) return;
        NT.http(NT.baseUrl + '/api/seg/usuarios/' + id + '/estado', { method:'PATCH', body: JSON.stringify({ estado:'I' }) }).then(function(){
          NT.showToast('Usuarios','Usuario #' + id + ' inactivado','success');
          // El módulo de usuarios no expone recarga → refrescamos la vista
          setTimeout(function(){ try{ location.reload(); }catch(_){ } }, 300);
        }).catch(function(err){
          NT.showToast('Usuarios', String(err && err.message ? err.message : err), 'error');
        });
      });
    }, true);

  })();
  </script>
  <!-- ===== /UI Bonita ===== -->

  <!-- Módulos (los tuyos) -->
  <script src="assets/js/empleados.js"></script>
  <script src="assets/js/puestos.js"></script>
  <script src="assets/js/departamentos.js"></script>
  <script src="assets/js/usuarios.js"></script>

  <!-- Arranque -->
  <script src="assets/js/init.js"></script>
</body>
</html>
