// assets/js/marcas.js (compat: sin ?. ni ??; maneja 204/text; seguro para JSP)
(function () {
  var meta = document.querySelector('meta[name="api-base"]');
  var apiBase = (window.NT_API_BASE || (meta ? meta.getAttribute('content') : '') || '').replace(/\/$/, '');
  var H = { 'Content-Type': 'application/json; charset=UTF-8' };

  function $(s){ return document.querySelector(s); }

  // ===== Toast =====
  function escapeHtml(s){ s = s == null ? '' : String(s); return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;'); }
  function iconFor(t){ return t==='success'?'bi-check-circle':(t==='error'?'bi-x-circle':'bi-info-circle'); }
  function toast(o){
    o=o||{}; var title=o.title||'Info', body=o.body||'', type=o.type||'info', stack=$('#toastStack'); if(!stack) return;
    var box=document.createElement('div');
    box.className='toast align-items-center nt-toast-'+type;
    box.innerHTML='<div class="toast-header">'
      +'<i class="bi '+iconFor(type)+' me-2"></i>'
      +'<strong class="me-auto">'+escapeHtml(title)+'</strong>'
      +'<small>ahora</small>'
      +'<button type="button" class="btn-close" data-bs-dismiss="toast"></button>'
      +'</div><div class="toast-body">'+body+'</div>';
    stack.appendChild(box); new bootstrap.Toast(box,{delay:2500}).show();
  }

  // ===== fetch robusto =====
  function fetchJson(url, opts){
    opts = opts || {};
    return fetch(url, Object.assign({ headers: H }, opts))
      .then(function(res){
        if(res.status===204 || res.status===205){ return { ok: res.ok, status: res.status, data: null, message:'' }; }
        return res.text().then(function(raw){
          var parsed; try{ parsed = raw ? JSON.parse(raw) : {}; }catch(e){ parsed = { message: raw }; }
          if(parsed && typeof parsed.ok !== 'undefined') return parsed;
          return { ok: res.ok, status: res.status, data: parsed, message: parsed && parsed.message ? parsed.message : '' };
        });
      })
      .catch(function(){ toast({title:'Red', body:'No se pudo conectar con el backend.', type:'error'}); return { ok:false, message:'Network error' }; });
  }

  // ===== API =====
  var API = {
    list: function(soloActivas, page, pageSize, q){
      var qs='?soloActivas='+(soloActivas?'true':'false')+'&page='+page+'&pageSize='+pageSize+(q?('&q='+encodeURIComponent(q)):'');
      return fetchJson(apiBase + '/api/marcas' + qs);
    },
    get:     function(id){ return fetchJson(apiBase + '/api/marcas/' + id); },
    create:  function(b){  return fetchJson(apiBase + '/api/marcas', { method:'POST', body: JSON.stringify(b) }); },
    update:  function(id,b){return fetchJson(apiBase + '/api/marcas/' + id, { method:'PUT', body: JSON.stringify(b) }); },
    remove:  function(id){ return fetchJson(apiBase + '/api/marcas/' + id, { method:'DELETE' }); },
    activate:function(id){ return fetchJson(apiBase + '/api/marcas/' + id + '/activar', { method:'PATCH' }); }
  };

  // ===== Estado / Elementos =====
  var state = { page:1, pageSize:10, total:0, soloActivas:true, q:'', rows:[], pendingDelete:null };
  var el = {
    tblBody: $('#tblMarcas'), lblResumen: $('#lblResumen'), paginacion: $('#paginacion'),
    btnBuscar: $('#btnBuscar'), txtSearch: $('#txtSearch'), chkSoloActivas: $('#chkSoloActivas'), btnOpenCreate: $('#btnOpenCreate'),
    mdlUpsert: new bootstrap.Modal($('#mdlUpsert')), mdlView:new bootstrap.Modal($('#mdlView')), mdlDelete:new bootstrap.Modal($('#mdlDelete')),
    frmUpsert: $('#frmUpsert'), up_id: $('#marca_id'), up_nombre: $('#marca_nombre'), up_activo: $('#marca_activo'),
    viewContent: $('#viewContent'), delNombre: $('#delNombre'), btnConfirmDelete: $('#btnConfirmDelete'), toastStack: $('#toastStack')
  };

  // ===== Render =====
  function renderRows(list){
    if(!el.tblBody) return;
    if(!list || !list.length){ el.tblBody.innerHTML='<tr><td colspan="4" class="text-center text-muted py-4">Sin resultados</td></tr>'; return; }
    var html='', i, m, id, nombre, activoBadge;
    for(i=0;i<list.length;i++){
      m=list[i]||{}; id=(m.id!=null?m.id:''); nombre=(m.nombre||'');
      activoBadge = (m.activo ? '<span class="badge ok">Activo</span>' : '<span class="badge bg-secondary">Inactivo</span>');
      html+='<tr>'
        +'<td class="text-muted">#'+id+'</td>'
        +'<td class="fw-semibold">'+escapeHtml(nombre)+'</td>'
        +'<td>'+activoBadge+'</td>'
        +'<td class="text-end"><div class="btn-group btn-group-sm">'
          +'<button class="btn btn-outline-secondary" data-action="view" data-id="'+id+'"><i class="bi bi-eye"></i></button>'
          +'<button class="btn btn-outline-primary" data-action="edit" data-id="'+id+'"><i class="bi bi-pencil"></i></button>'
          +(m.activo?'':'<button class="btn btn-success" data-action="activate" data-id="'+id+'"><i class="bi bi-check2-circle"></i></button>')
          +'<button class="btn btn-danger" data-action="delete" data-id="'+id+'" data-nombre="'+escapeHtml(nombre)+'"><i class="bi bi-trash"></i></button>'
        +'</div></td></tr>';
    }
    el.tblBody.innerHTML = html;
  }
  function renderResumen(total,page,pageSize){
    var from = total===0 ? 0 : ((page-1)*pageSize+1), to = Math.min(page*pageSize,total);
    el.lblResumen.textContent = total+' resultado'+(total===1?'':'s')+' • mostrando '+from+'-'+to;
  }
  function renderPaginacion(total,page,pageSize){
    var totalPages = Math.max(1, Math.ceil((+total||0)/(+pageSize||10)));
    var html='', start=Math.max(1,page-2), end=Math.min(totalPages,start+4), p;
    html+='<li class="page-item '+(page<=1?'disabled':'')+'"><a class="page-link" href="#" data-page="'+(page-1)+'">«</a></li>';
    for(p=start;p<=end;p++){ html+='<li class="page-item '+(p===page?'active':'')+'"><a class="page-link" href="#" data-page="'+p+'">'+p+'</a></li>'; }
    html+='<li class="page-item '+(page>=totalPages?'disabled':'')+'"><a class="page-link" href="#" data-page="'+(page+1)+'">»</a></li>';
    el.paginacion.innerHTML = html;
  }
  function normalizeListResponse(resp){
    var list=[], total=0;
    if (Object.prototype.toString.call(resp)==='[object Array]'){ list=resp; total=resp.length; }
    else if(resp && resp.data && Object.prototype.toString.call(resp.data)==='[object Array]'){ list=resp.data; total=(resp.meta&&resp.meta.total!=null?resp.meta.total:(resp.total!=null?resp.total:list.length)); }
    else if(resp && resp.data && resp.data.items && Object.prototype.toString.call(resp.data.items)==='[object Array]'){ list=resp.data.items; total=(resp.data.total!=null?resp.data.total:(resp.meta&&resp.meta.total!=null?resp.meta.total:list.length)); }
    else if(resp && (resp.status===204||resp.status===205)){ list=[]; total=0; }
    return { list:list, total:total };
  }

  // ===== Carga =====
  function load(){
    API.list(state.soloActivas, state.page, state.pageSize, state.q).then(function(resp){
      if(resp && resp.ok===false && resp.status>=400){
        toast({ title:'Error', body: resp.message || 'Fallo al obtener marcas', type:'error' });
        if(el.tblBody) el.tblBody.innerHTML='<tr><td colspan="4" class="text-center text-danger py-4">Error al cargar</td></tr>';
        return;
      }
      var norm = normalizeListResponse(resp), list = norm.list || [];
      var total = (typeof norm.total==='number') ? norm.total : list.length;
      if(state.q){
        var q = state.q.toLowerCase();
        list = list.filter(function(x){ var n = x && x.nombre ? String(x.nombre).toLowerCase() : ''; return n.indexOf(q)>=0; });
      }
      state.rows = list; state.total = total;
      renderRows(list); renderResumen(total, state.page, state.pageSize); renderPaginacion(total, state.page, state.pageSize);
    });
  }

  // ===== Eventos =====
  if(el.tblBody){
    el.tblBody.addEventListener('click', function(ev){
      var btn = ev.target.closest ? ev.target.closest('button[data-action]') : null; if(!btn) return;
      var id = btn.getAttribute('data-id'); var action = btn.getAttribute('data-action');

      if(action==='view'){
        API.get(id).then(function(r){
          var m = (r && r.data) ? r.data : r;
          el.viewContent.innerHTML =
            '<dt class="col-4">ID</dt><dd class="col-8">'+escapeHtml(m && m.id!=null ? m.id : '')+'</dd>'
           +'<dt class="col-4">Nombre</dt><dd class="col-8">'+escapeHtml(m && m.nombre ? m.nombre : '')+'</dd>'
           +'<dt class="col-4">Activo</dt><dd class="col-8">'+((m && m.activo)?'Sí':'No')+'</dd>';
          el.mdlView.show();
        });
      }

      if(action==='edit'){
        API.get(id).then(function(r){
          var m = (r && r.data) ? r.data : r;
          el.up_id.value = (m && m.id!=null) ? m.id : '';
          el.up_nombre.value = (m && m.nombre) ? m.nombre : '';
          el.up_activo.checked = !!(m && m.activo);
          document.getElementById('mdlUpsertTitle').innerHTML = '<i class="bi bi-pencil-square"></i> Editar marca';
          el.mdlUpsert.show();
        });
      }

      if(action==='activate'){
        API.activate(id).then(function(r){
          if(r && r.ok){ toast({ title:'Activada', body:'La marca fue activada.', type:'success' }); load(); }
          else{ toast({ title:'Error', body:(r && r.message) || 'No se pudo activar', type:'error' }); }
        });
      }

      if(action==='delete'){
        state.pendingDelete = { id:id, nombre: btn.getAttribute('data-nombre') };
        el.delNombre.textContent = state.pendingDelete.nombre || '';
        el.mdlDelete.show();
      }
    });
  }

  if(el.btnConfirmDelete){
    el.btnConfirmDelete.addEventListener('click', function(){
      if(!state.pendingDelete) return;
      API.remove(state.pendingDelete.id).then(function(r){
        if((r && r.ok) || (r && (r.status===204||r.status===205))){
          toast({ title:'Eliminada', body:'La marca fue eliminada.', type:'success' });
          el.mdlDelete.hide(); state.pendingDelete=null; load();
        } else {
          toast({ title:'Error', body:(r && r.message) || 'No se pudo eliminar', type:'error' });
        }
      });
    });
  }

  if(el.btnBuscar){
    el.btnBuscar.addEventListener('click', function(){
      state.q = (el.txtSearch && el.txtSearch.value ? el.txtSearch.value : '').trim();
      state.soloActivas = !!(el.chkSoloActivas && el.chkSoloActivas.checked);
      state.page = 1; load();
    });
  }
  if(el.txtSearch){
    el.txtSearch.addEventListener('keydown', function(e){ if(e.key==='Enter'){ e.preventDefault(); if(el.btnBuscar) el.btnBuscar.click(); } });
  }
  if(el.paginacion){
    el.paginacion.addEventListener('click', function(e){
      var a = e.target.closest ? e.target.closest('a[data-page]') : null; if(!a) return; e.preventDefault();
      var p = parseInt(a.getAttribute('data-page'),10); if(!isNaN(p) && p>=1){ state.page=p; load(); }
    });
  }
  if(el.btnOpenCreate){
    el.btnOpenCreate.addEventListener('click', function(){
      el.frmUpsert.reset(); el.up_id.value=''; el.up_activo.checked=true;
      document.getElementById('mdlUpsertTitle').innerHTML = '<i class="bi bi-plus-circle"></i> Nueva marca';
      el.mdlUpsert.show();
    });
  }
  if(el.frmUpsert){
    el.frmUpsert.addEventListener('submit', function(e){
      e.preventDefault(); e.stopPropagation();
      if(!el.frmUpsert.checkValidity()){ el.frmUpsert.classList.add('was-validated'); return; }
      var id = el.up_id.value ? Number(el.up_id.value) : null;
      var payload = { nombre: (el.up_nombre.value || '').trim(), activo: !!el.up_activo.checked };
      var req = id ? API.update(id, payload) : API.create(payload);
      req.then(function(r){
        if(r && r.ok){ toast({ title:'Guardado', body:'La marca fue guardada correctamente.', type:'success' }); el.mdlUpsert.hide(); load(); }
        else{ toast({ title:'Error', body:(r && r.message) || 'No se pudo guardar', type:'error' }); }
      });
    });
  }

  document.addEventListener('DOMContentLoaded', load);
})();
