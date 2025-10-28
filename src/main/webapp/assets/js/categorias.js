(() => {
  const apiBase = window.NT_API_BASE || document.querySelector('meta[name="api-base"]').content || '';
  const headers = { 'Content-Type': 'application/json; charset=UTF-8' };
  const $ = (s) => document.querySelector(s);

  async function fetchJson(url, opts = {}) {
    const res = await fetch(url, { headers, ...opts });
    const data = await res.json().catch(() => ({}));
    return (typeof data.ok !== 'undefined') ? data : { ok: res.ok, message: data?.message || '', data };
  }

  // --- Endpoints (ajusta si tu controlador usa otro path) ---
  const API = {
    list: (soloActivas, page, pageSize, q) => {
      const url = new URL(apiBase + '/api/categorias');
      url.searchParams.set('soloActivas', String(!!soloActivas));
      url.searchParams.set('page', String(page));
      url.searchParams.set('pageSize', String(pageSize));
      if (q) url.searchParams.set('q', q);
      return fetchJson(url.toString());
    },
    get: (id) => fetchJson(`${apiBase}/api/categorias/${id}`),
    create: (payload) => fetchJson(`${apiBase}/api/categorias`, { method: 'POST', body: JSON.stringify(payload) }),
    update: (id, payload) => fetchJson(`${apiBase}/api/categorias/${id}`, { method: 'PUT', body: JSON.stringify(payload) }),
    remove: (id) => fetchJson(`${apiBase}/api/categorias/${id}`, { method: 'DELETE' }),
    activate: (id) => fetchJson(`${apiBase}/api/categorias/${id}/activar`, { method: 'PATCH' }),
  };

  const state = { page:1, pageSize:10, total:0, soloActivas:true, q:'', rows:[], pendingDelete:null };

  const el = {
    tblBody: $('#tblCategorias'),
    lblResumen: $('#lblResumen'),
    paginacion: $('#paginacion'),
    btnBuscar: $('#btnBuscar'),
    txtSearch: $('#txtSearch'),
    chkSoloActivas: $('#chkSoloActivas'),
    btnOpenCreate: $('#btnOpenCreate'),

    mdlUpsert: new bootstrap.Modal($('#mdlUpsert')),
    mdlView: new bootstrap.Modal($('#mdlView')),
    mdlDelete: new bootstrap.Modal($('#mdlDelete')),

    frmUpsert: $('#frmUpsert'),
    up_id: $('#cat_id'),
    up_nombre: $('#cat_nombre'),
    up_activo: $('#cat_activo'),

    viewContent: $('#viewContent'),
    delNombre: $('#delNombre'),
    btnConfirmDelete: $('#btnConfirmDelete'),
    toastStack: $('#toastStack'),
  };

  function toast({ title='Info', body='', type='info' }){
    const id = `t_${Date.now()}`;
    const box = document.createElement('div');
    box.className = `toast align-items-center nt-toast-${type}`;
    box.id = id;
    box.innerHTML = `
      <div class="toast-header">
        <i class="bi ${type==='success'?'bi-check-circle':type==='error'?'bi-x-circle':'bi-info-circle'} me-2"></i>
        <strong class="me-auto">${title}</strong>
        <small>ahora</small>
        <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
      </div>
      <div class="toast-body">${body}</div>`;
    el.toastStack.appendChild(box);
    new bootstrap.Toast(box, { delay:2500 }).show();
  }

  function renderRows(list){
    el.tblBody.innerHTML = list.length ? list.map(c => `
      <tr>
        <td class="text-muted">#${c.id ?? ''}</td>
        <td class="fw-semibold">${(c.nombre ?? '').replace(/</g,'&lt;')}</td>
        <td>${c.activo ? '<span class="badge ok">Activo</span>' : '<span class="badge bg-secondary">Inactivo</span>'}</td>
        <td class="text-end">
          <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-secondary" data-action="view" data-id="${c.id}"><i class="bi bi-eye"></i></button>
            <button class="btn btn-outline-primary" data-action="edit" data-id="${c.id}"><i class="bi bi-pencil"></i></button>
            ${c.activo ? '' : `<button class="btn btn-success" data-action="activate" data-id="${c.id}"><i class="bi bi-check2-circle"></i></button>`}
            <button class="btn btn-danger" data-action="delete" data-id="${c.id}" data-nombre="${(c.nombre ?? '').replace(/"/g,'&quot;')}"><i class="bi bi-trash"></i></button>
          </div>
        </td>
      </tr>
    `).join('') : `<tr><td colspan="4" class="text-center text-muted py-4">Sin resultados</td></tr>`;
  }

  function renderResumen(total,page,pageSize){
    const from=(page-1)*pageSize+1,to=Math.min(page*pageSize,total);
    el.lblResumen.textContent=`${total} resultado${total===1?'':'s'} • mostrando ${from}-${to}`;
  }
  function renderPaginacion(total,page,pageSize){
    const totalPages=Math.max(1,Math.ceil(total/pageSize));
    let html=`<li class="page-item ${page<=1?'disabled':''}"><a class="page-link" href="#" data-page="${page-1}">«</a></li>`;
    const start=Math.max(1,page-2),end=Math.min(totalPages,start+4);
    for(let p=start;p<=end;p++){ html+=`<li class="page-item ${p===page?'active':''}"><a class="page-link" href="#" data-page="${p}">${p}</a></li>`; }
    html+=`<li class="page-item ${page>=totalPages?'disabled':''}"><a class="page-link" href="#" data-page="${page+1}">»</a></li>`;
    el.paginacion.innerHTML=html;
  }

  async function load(){
    const { soloActivas,page,pageSize,q }=state;
    const resp=await API.list(soloActivas,page,pageSize,q);
    const list = Array.isArray(resp?.data) ? resp.data : (Array.isArray(resp) ? resp : (Array.isArray(resp?.data?.items)?resp.data.items:[]));
    const total=(resp?.meta?.total ?? resp?.total ?? list.length);
    const filtered = q ? list.filter(x => (x?.nombre||'').toLowerCase().includes(q.toLowerCase())) : list;
    state.rows=filtered; state.total=total;
    renderRows(filtered); renderResumen(total,page,pageSize); renderPaginacion(total,page,pageSize);
  }

  el.tblBody.addEventListener('click', async (ev)=>{
    const btn=ev.target.closest('button[data-action]'); if(!btn) return;
    const id=btn.getAttribute('data-id'); const action=btn.getAttribute('data-action');

    if(action==='view'){
      const r=await API.get(id); const c=r?.data||r;
      el.viewContent.innerHTML=`
        <dt class="col-4">ID</dt><dd class="col-8">${c.id ?? ''}</dd>
        <dt class="col-4">Nombre</dt><dd class="col-8">${(c.nombre ?? '').replace(/</g,'&lt;')}</dd>
        <dt class="col-4">Activo</dt><dd class="col-8">${c.activo?'Sí':'No'}</dd>`;
      el.mdlView.show();
    }
    if(action==='edit'){
      const r=await API.get(id); const c=r?.data||r;
      $('#mdlUpsertTitle').innerHTML='<i class="bi bi-pencil-square"></i> Editar categoría';
      el.up_id.value=c.id ?? ''; el.up_nombre.value=c.nombre ?? ''; el.up_activo.checked=!!c.activo;
      el.mdlUpsert.show();
    }
    if(action==='activate'){
      const r=await API.activate(id);
      r.ok ? (toast({title:'Activada',body:'La categoría fue activada.',type:'success'}), load())
           : toast({title:'Error',body:r.message||'No se pudo activar',type:'error'});
    }
    if(action==='delete'){
      state.pendingDelete={ id, nombre: btn.getAttribute('data-nombre') };
      el.delNombre.textContent = state.pendingDelete.nombre || '';
      el.mdlDelete.show();
    }
  });

  el.btnConfirmDelete.addEventListener('click', async ()=>{
    if(!state.pendingDelete) return;
    const r=await API.remove(state.pendingDelete.id);
    if(r.ok){ toast({title:'Eliminada',body:'La categoría fue eliminada.',type:'success'}); el.mdlDelete.hide(); state.pendingDelete=null; load(); }
    else{ toast({title:'Error',body:r.message||'No se pudo eliminar',type:'error'}); }
  });

  el.btnBuscar.addEventListener('click', ()=>{ state.q=($('#txtSearch').value||'').trim(); state.soloActivas=$('#chkSoloActivas').checked; state.page=1; load(); });
  el.txtSearch.addEventListener('keydown',(e)=>{ if(e.key==='Enter'){ e.preventDefault(); el.btnBuscar.click(); }});
  el.paginacion.addEventListener('click',(e)=>{ const a=e.target.closest('a[data-page]'); if(!a) return; e.preventDefault(); const p=+a.getAttribute('data-page'); if(p>=1){ state.page=p; load(); }});
  $('#btnOpenCreate').addEventListener('click',()=>{ el.frmUpsert.reset(); el.up_id.value=''; el.up_activo.checked=true; $('#mdlUpsertTitle').innerHTML='<i class="bi bi-plus-circle"></i> Nueva categoría'; el.mdlUpsert.show(); });

  el.frmUpsert.addEventListener('submit', async (e)=>{
    e.preventDefault(); e.stopPropagation();
    if(!el.frmUpsert.checkValidity()){ el.frmUpsert.classList.add('was-validated'); return; }
    const id = el.up_id.value ? Number(el.up_id.value) : null;
    const payload = { nombre: ($('#cat_nombre').value||'').trim(), activo: $('#cat_activo').checked };
    const r = id ? await API.update(id,payload) : await API.create(payload);
    if(r.ok){ toast({title:'Guardado',body:'La categoría fue guardada.',type:'success'}); el.mdlUpsert.hide(); load(); }
    else{ toast({title:'Error',body:r.message||'No se pudo guardar',type:'error'}); }
  });

  document.addEventListener('DOMContentLoaded', load);
})();
