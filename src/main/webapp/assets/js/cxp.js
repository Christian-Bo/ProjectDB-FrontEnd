// assets/js/cxp.js v16.3.3
// - Ocultar documentos anulados (estado='A')
// - Confirm de "Anular" documento
// - Sin redeclaraciones duplicadas
// - MODO SEGURO: por defecto NO consulta /api/compras|/api/facturas/select (evita 500).
//   Se usa entrada manual para origen_id. Puedes habilitar listas poniendo:
//   window.CXP_ORIGEN_LIST_ENABLED = true;  // antes de cargar este script.

(function () {
  const META_BASE = document.querySelector('meta[name="api-base"]')?.content?.trim();
  const API_BASE  = (window.API?.baseUrl?.trim?.() || META_BASE || 'http://localhost:8080').replace(/\/+$/,'');
  const q  = (s, r=document) => r.querySelector(s);
  const qa = (s, r=document) => Array.from(r.querySelectorAll(s));

  // ------------ Helpers sesión/headers ------------
  function parseAuthUser(){
    try{
      if (window.Auth?.user) return window.Auth.user;
      const raw = localStorage.getItem('auth_user');
      return raw ? JSON.parse(raw) : null;
    }catch(_){ return null; }
  }
  function getUserId(){
    const u = parseAuthUser();
    return Number(u?.id || u?.userId || u?.usuarioId || window.API?.userId || 1) || 1;
  }
  function buildHeaders(isJson){
    const h = { 'Accept':'application/json', 'X-User-Id': String(getUserId()) };
    try{
      const sRaw = localStorage.getItem('nt.session');
      const s = sRaw ? JSON.parse(sRaw) : null;
      if (s?.token) h['Authorization'] = 'Bearer ' + s.token;
    }catch{}
    if (isJson) h['Content-Type'] = 'application/json';
    return h;
  }

  // ------------ Toasts ------------
  function showToast(message, type='info', title=null) {
    const iconMap = { success:'bi-check-circle', danger:'bi-x-circle', warning:'bi-exclamation-triangle', info:'bi-info-circle' };
    const id = `t-${Date.now()}-${Math.random().toString(36).slice(2,7)}`;
    const container = q('#toastStack') || (()=>{ const d=document.createElement('div'); d.id='toastStack'; d.className='toast-container position-fixed top-0 end-0 p-3'; document.body.appendChild(d); return d; })();
    const el = document.createElement('div');
    el.className = `toast nt-toast nt-toast-${type}`; el.id = id; el.role='alert'; el.ariaLive='assertive'; el.ariaAtomic='true';
    el.dataset.bsAutohide='true'; el.dataset.bsDelay='3500';
    el.innerHTML = `
      <div class="toast-header">
        <i class="bi ${iconMap[type]||iconMap.info} me-2"></i>
        <strong class="me-auto">${title || 'Notificación'}</strong>
        <small class="text-muted">Ahora</small>
        <button type="button" class="btn-close ms-2 mb-1" data-bs-dismiss="toast" aria-label="Cerrar"></button>
      </div>
      <div class="toast-body">${message}</div>`;
    container.appendChild(el);
    new bootstrap.Toast(el).show();
  }
  const toast = (m,t='info',h=null)=> (window.API?.toast ? window.API.toast(m,t,h) : showToast(m,t,h));

  // ------------ HTTP base ------------
  async function http(path, opts = {}) {
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, {
      method: opts.method || 'GET',
      headers: buildHeaders(!!opts.json),
      body: opts.json ? JSON.stringify(opts.json) : undefined
    });
    const text = await res.text();
    let data = null; try { data = text ? JSON.parse(text) : null; } catch {}
    if (!res.ok) {
      const msg = (data && (data.message || data.error || data.detail)) || text || `HTTP ${res.status}`;
      const err = new Error(msg); err.status = res.status; err.data = data; throw err;
    }
    return data;
  }
  async function del(path) {
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, { method:'DELETE', headers: buildHeaders(false) });
    if (res.ok) return true;
    const txt = await res.text();
    let msg = txt; try{ const j = txt ? JSON.parse(txt) : null; if (j?.message || j?.error || j?.detail) msg = j.message || j.error || j.detail; }catch{}
    const err = new Error(msg || `HTTP ${res.status}`); err.status = res.status; throw err;
  }

  const money = v => `Q ${Number(v||0).toFixed(2)}`;
  const safe  = (s,f='') => (s ?? f);

  // ------------ Confirm modal ------------
  let confirmModal = null, $confirmTitle=null, $confirmMsg=null, $confirmBtn=null;
  (function ensureConfirm(){
    const exists = q('#confirmDanger');
    if (exists) {
      confirmModal = new bootstrap.Modal('#confirmDanger');
      $confirmTitle = q('#confirmDangerTitle');
      $confirmMsg   = q('#confirmDangerMsg');
      $confirmBtn   = q('#confirmDangerBtn');
      return;
    }
    const wrapper = document.createElement('div');
    wrapper.innerHTML = `
      <div class="modal fade" id="confirmDanger" tabindex="-1" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header bg-dark-subtle">
              <h5 class="modal-title" id="confirmDangerTitle">Confirmar</h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body"><p id="confirmDangerMsg" class="mb-0">¿Deseas continuar?</p></div>
            <div class="modal-footer">
              <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button>
              <button type="button" class="btn btn-danger" id="confirmDangerBtn"><i class="bi bi-x-octagon"></i> <span id="confirmDangerBtnText">Anular</span></button>
            </div>
          </div>
        </div>
      </div>`;
    document.body.appendChild(wrapper.firstElementChild);
    confirmModal = new bootstrap.Modal('#confirmDanger');
    $confirmTitle = q('#confirmDangerTitle');
    $confirmMsg   = q('#confirmDangerMsg');
    $confirmBtn   = q('#confirmDangerBtn');
  })();

  let onConfirmCb = null;
  function confirmDestructive({ title='Confirmar acción', message='Esta acción no se puede deshacer.', confirmText='Anular', onConfirm }){
    $confirmTitle.textContent = title;
    $confirmMsg.textContent   = message;
    q('#confirmDangerBtnText').textContent = confirmText;
    onConfirmCb = onConfirm || null;
    confirmModal.show();
  }
  $confirmBtn.addEventListener('click', async ()=>{
    const cb = onConfirmCb; onConfirmCb = null; confirmModal.hide();
    if (typeof cb === 'function') await cb();
  });

  // ------------ Estado & selects ------------
  const state = { docsById:new Map(), pagosById:new Map(), origenCache:new Map() };
  const isAnulado = (r)=> {
    const v = String(r?.estado ?? '').trim().toUpperCase();
    return v === 'A' || v === 'ANULADO';
  };

  // —— FLAGS DE LISTADO DE ORIGEN ——
  // Por defecto: desactivado (modo seguro sin fetch).
  const ORIGEN_LIST_ENABLED = Boolean(window.CXP_ORIGEN_LIST_ENABLED); // si pones true antes de este script, habilita listados
  const ORIGEN_LIST_SUPPORTED = { C: true, F: false }; // si habilitas arriba, puedes ajustar por tipo

  async function fetchDistinctProveedores() {
    try {
      const [docs, pags] = await Promise.allSettled([ http('/api/cxp/documentos'), http('/api/cxp/pagos') ]);
      const pairs = [];
      if (docs.status==='fulfilled' && Array.isArray(docs.value)) docs.value.forEach(d=> d?.proveedor_id && pairs.push([d.proveedor_id, d.proveedor_nombre]));
      if (pags.status==='fulfilled' && Array.isArray(pags.value)) pags.value.forEach(p=> p?.proveedor_id && pairs.push([p.proveedor_id, p.proveedor_nombre]));
      const map = new Map();
      pairs.forEach(([id,name])=>{
        const cur = map.get(id); const cand = (name && String(name).trim()) || null;
        if (!cur) map.set(id,cand); else if (cand && (!cur || cand.length>cur.length)) map.set(id,cand);
      });
      return [...map.entries()].sort((a,b)=>Number(a[0])-Number(b[0])).map(([id,name])=>({id,label:name||`Proveedor #${id}`}));
    } catch { return []; }
  }
  function fillSelect($sel, items, {includeAll=false, allLabel='— Todos —'} = {}) {
    $sel.innerHTML = '';
    if (includeAll) { const o=document.createElement('option'); o.value=''; o.textContent=allLabel; $sel.appendChild(o); }
    items.forEach(it=>{ const o=document.createElement('option'); o.value=String(it.id); o.textContent=it.label; $sel.appendChild(o); });
  }

  // ------------ DOM refs ------------
  const $docFiltroProv = q('#doc-proveedor');
  const $docFiltroTxt  = q('#doc-texto');
  const $docBuscar     = q('#doc-buscar');
  const $docTbody      = q('#doc-tbody');
  const $docNuevo      = q('#doc-nuevo');

  const $docModal = new bootstrap.Modal('#modalDoc');
  const $docForm  = q('#form-doc');
  const $docId    = q('#doc-id');
  const $proveedor_id   = q('#proveedor_id');
  const $origen_tipo    = q('#origen_tipo');
  const $origen_id      = q('#origen_id');
  const $origen_id_sel  = q('#origen_id_sel');
  const $numero_documento = q('#numero_documento');
  const $fecha_emision  = q('#fecha_emision');
  const $fecha_vencimiento = q('#fecha_vencimiento');
  const $moneda         = q('#moneda');
  const $monto_total    = q('#monto_total');
  const $origenHint     = q('#origen_nombre_hint');

  const $pagFiltroProv = q('#pag-proveedor');
  const $pagFiltroTxt  = q('#pag-texto');
  const $pagBuscar     = q('#pag-buscar');
  const $pagTbody      = q('#pag-tbody');
  const $pagNuevo      = q('#pag-nuevo');

  const $pagModal = new bootstrap.Modal('#modalPagoCxp');   // instancia compartida
  const $pagForm  = q('#form-pago-cxp');
  const $pago_id  = q('#pago_id');
  const $_proveedor_id = q('#p_proveedor_id');
  const $fecha_pago = q('#fecha_pago');
  const $forma_pago = q('#p_forma_pago');
  const $_monto_total = q('#p_monto_total');
  const $observaciones = q('#observaciones');

  const $aplPagoId = q('#apl-pago-id');
  const $aplList   = q('#apl-tbody');
  const $aplForm   = q('#form-apl');
  const $aplItems  = q('#apl-items');
  const $aplCargar = q('#apl-cargar');
  const $aplDocsRapidosTbody = q('#apl-docs-rapidos-tbody');

  // ------------ Origen (modo seguro sin fetch por defecto) ------------
  function showOrigenSelect(show){
    $origen_id_sel.style.display = show ? '' : 'none';
    $origen_id.style.display     = show ? 'none' : '';
    $origen_id_sel.required = show;
    $origen_id.required     = !show;
  }

  async function renderOrigenSelector(){
    const tipo = $origen_tipo.value;
    const prov = $proveedor_id.value;
    $origenHint.textContent = '';

    if (!tipo || !prov){
      showOrigenSelect(false); $origen_id.value=''; $origen_id_sel.innerHTML=''; return;
    }

    // Si el modo de listados no está habilitado globalmente o el tipo no está soportado,
    // usamos SIEMPRE el modo manual sin hacer ninguna petición al backend.
    if (!ORIGEN_LIST_ENABLED || !ORIGEN_LIST_SUPPORTED[tipo]) {
      showOrigenSelect(false);
      $origen_id.value = '';
      $origen_id.placeholder = tipo==='C' ? 'ID de compra (manual)' : 'ID de factura (manual)';
      $origenHint.textContent = 'Ingrese el ID manualmente.';
      return;
    }

    // Si lo activas (set window.CXP_ORIGEN_LIST_ENABLED = true), intentamos listar:
    try{
      const items = await (async ()=>{
        const key = `${tipo}|${prov}`;
        if (state.origenCache.has(key)) return state.origenCache.get(key);
        if (tipo==='C'){
          const rows = await http(`/api/compras/select?proveedorId=${encodeURIComponent(prov)}`);
          const list = Array.isArray(rows) ? rows.map(r=>({
            id: r.id ?? r.compra_id ?? r.origen_id,
            label: (r.numero_compra?`C-${r.numero_compra}`:`Compra #${r.id}`)+ (r.id?` (#${r.id})`:``)
          })) : [];
          state.origenCache.set(key,list); return list;
        }
        if (tipo==='F'){
          const rows = await http(`/api/facturas/select?proveedorId=${encodeURIComponent(prov)}`);
          const list = Array.isArray(rows) ? rows.map(r=>({
            id: r.id ?? r.factura_id ?? r.origen_id,
            label: (r.correlativo||`Factura #${r.id}`)+ (r.id?` (#${r.id})`:``)
          })) : [];
          state.origenCache.set(key,list); return list;
        }
        return [];
      })();

      if (items.length>0){
        showOrigenSelect(true);
        fillSelect($origen_id_sel, items, {includeAll:true, allLabel:'— Seleccione —'});
        const clone = $origen_id_sel.cloneNode(true);
        $origen_id_sel.parentNode.replaceChild(clone, $origen_id_sel);
        const sel = q('#origen_id_sel');
        sel.addEventListener('change', ()=>{
          $origen_id.value = sel.value || '';
          const lbl = sel.selectedOptions[0]?.textContent || '';
          $origenHint.textContent = lbl ? `Origen: ${lbl}` : '';
        });
      } else {
        showOrigenSelect(false);
        $origen_id.value='';
        $origen_id.placeholder = tipo==='C' ? 'ID de compra (manual)' : 'ID de factura (manual)';
        $origenHint.textContent = 'No hay opciones. Ingrese el ID manualmente.';
      }
    } catch {
      // Si falla el backend, regresamos a manual sin propagar error ni spamear la consola
      showOrigenSelect(false);
      $origen_id.value='';
      $origen_id.placeholder = tipo==='C' ? 'ID de compra (manual)' : 'ID de factura (manual)';
      $origenHint.textContent = 'El listado no está disponible. Ingrese el ID manualmente.';
    }
  }

  // ------------ Listados / render ------------
  async function docListar() {
    const prov = $docFiltroProv.value || null;
    const txt  = $docFiltroTxt.value.trim() || null;
    const qs = []; if (prov) qs.push(`proveedorId=${encodeURIComponent(prov)}`); if (txt) qs.push(`texto=${encodeURIComponent(txt)}`);
    try {
      const rows = await http(`/api/cxp/documentos${qs.length?`?${qs.join('&')}`:''}`);
      state.docsById.clear(); (Array.isArray(rows)?rows:[]).forEach(r=> state.docsById.set(Number(r.id), r));
      const visibles = (Array.isArray(rows)?rows:[]).filter(r => !isAnulado(r));
      renderDocs(visibles);
    } catch(e){
      toast(`Error listando documentos: ${e.message}`, 'danger', 'Documentos');
      $docTbody.innerHTML = `<tr><td colspan="10" class="text-center text-danger">Error al cargar</td></tr>`;
    }
  }
  function renderDocs(rows){
    $docTbody.innerHTML = rows.length ? '' : `<tr><td colspan="10" class="text-center text-muted">Sin documentos</td></tr>`;
    for (const r of rows){
      const provLbl = r.proveedor_nombre ? `${r.proveedor_nombre} (#${r.proveedor_id})` : `#${r.proveedor_id}`;
      const origenLbl = r.origen_nombre ? `${r.origen_tipo} — ${r.origen_nombre}` : `${r.origen_tipo}-${r.origen_id}`;
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${r.id}</td>
        <td>${provLbl}</td>
        <td>${origenLbl}</td>
        <td>${safe(r.numero_documento)}</td>
        <td>${safe(r.fecha_emision)}</td>
        <td>${safe(r.fecha_vencimiento)}</td>
        <td>${safe(r.moneda)}</td>
        <td class="text-end">${money(r.monto_total)}</td>
        <td class="text-end">${money(r.saldo_pendiente)}</td>
        <td class="text-end">
          <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-secondary btn-doc-edit" data-id="${r.id}" title="Editar" data-bs-toggle="tooltip"><i class="bi bi-pencil"></i></button>
            <button class="btn btn-danger-soft btn-doc-anular" data-id="${r.id}" title="Anular documento" data-bs-toggle="tooltip"><i class="bi bi-x-octagon"></i></button>
          </div>
        </td>`;
      $docTbody.appendChild(tr);
    }
    qa('[data-bs-toggle="tooltip"]').forEach(el=> new bootstrap.Tooltip(el));
    qa('.btn-doc-edit').forEach(b=>b.addEventListener('click', handlers.onDocEditar));
    qa('.btn-doc-anular').forEach(b=>b.addEventListener('click', handlers.onDocAnular));
  }

  async function pagListar(){
    const prov = $pagFiltroProv.value || null;
    const txt  = $pagFiltroTxt.value.trim() || null;
    const qs=[]; if (prov) qs.push(`proveedorId=${encodeURIComponent(prov)}`); if (txt) qs.push(`texto=${encodeURIComponent(txt)}`);
    try {
      const rows = await http(`/api/cxp/pagos${qs.length?`?${qs.join('&')}`:''}`);
      state.pagosById.clear(); (Array.isArray(rows)?rows:[]).forEach(r=> state.pagosById.set(Number(r.id), r));
      renderPagos(Array.isArray(rows)?rows:[]);
      await fillPagosCombo(rows);
    } catch(e){
      toast(`Error listando pagos: ${e.message}`, 'danger', 'Pagos');
      $pagTbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger">Error al cargar</td></tr>`;
    }
  }
  function renderPagos(rows){
    $pagTbody.innerHTML = rows.length ? '' : `<tr><td colspan="8" class="text-center text-muted">Sin pagos</td></tr>`;
    for (const r of rows){
      const provLbl = r.proveedor_nombre ? `${r.proveedor_nombre} (#${r.proveedor_id})` : `#${r.proveedor_id}`;
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${r.id}</td>
        <td>${provLbl}</td>
        <td>${safe(r.fecha_pago)}</td>
        <td>${safe(r.forma_pago)}</td>
        <td class="text-end">${money(r.monto_total)}</td>
        <td>${safe(r.observaciones)}</td>
        <td class="text-end">
          <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-secondary btn-pag-edit" data-id="${r.id}" title="Editar" data-bs-toggle="tooltip"><i class="bi bi-pencil"></i></button>
            <button class="btn btn-danger-soft btn-pag-del" data-id="${r.id}" title="Eliminar" data-bs-toggle="tooltip"><i class="bi bi-trash"></i></button>
          </div>
        </td>
        <td class="text-end">
          <a class="btn btn-sm btn-outline-primary" href="#aplicaciones"
             onclick="document.getElementById('apl-pago-id').value='${r.id}';document.getElementById('tab-aplicaciones').click();">
             <i class="bi bi-arrow-right-circle"></i> Aplicar
          </a>
        </td>`;
      $pagTbody.appendChild(tr);
    }
    qa('[data-bs-toggle="tooltip"]').forEach(el=> new bootstrap.Tooltip(el));
    qa('.btn-pag-edit').forEach(b=>b.addEventListener('click', handlers.onPagEditar));
    qa('.btn-pag-del').forEach(b=>b.addEventListener('click', handlers.onPagEliminar));
  }

  async function fillPagosCombo(pagosList=null){
    let rows = pagosList; if (!Array.isArray(rows)) { try{ rows = await http('/api/cxp/pagos'); }catch{ rows=[]; } }
    const items = rows.map(p=>({ id:p.id, label:`#${p.id} • ${p.proveedor_nombre ? p.proveedor_nombre : `Prov ${p.proveedor_id}`} • ${p.forma_pago||'-'} • ${money(p.monto_total)}` }));
    fillSelect($aplPagoId, items, {includeAll:true, allLabel:'— Seleccione un pago —'});
  }

  async function aplListar(){
    const pagoId = Number($aplPagoId.value);
    if (!pagoId){
      $aplList.innerHTML = `<tr><td colspan="5" class="text-center text-muted">Seleccione un pago</td></tr>`;
      $aplDocsRapidosTbody.innerHTML = `<tr><td colspan="5" class="text-center text-muted">Seleccione un pago para cargar documentos…</td></tr>`;
      return;
    }
    try{
      const rows = await http(`/api/cxp/pagos/${pagoId}/aplicaciones`);
      $aplList.innerHTML = rows.length ? '' : `<tr><td colspan="5" class="text-center text-muted">Sin aplicaciones</td></tr>`;
      for (const r of rows){
        const docNum = r.documento_numero || `#${r.documento_id}`;
        const docInfo = r.documento_fecha_emision ? ` (${r.documento_fecha_emision})` : '';
        const pagoInfo = r.pago_forma_pago ? `${r.pago_forma_pago}${r.pago_fecha ? ' • '+r.pago_fecha : ''}` : `#${r.pago_id}`;
        const tr = document.createElement('tr');
        tr.innerHTML = `
          <td class="text-muted">#${r.id}</td>
          <td>${docNum}${docInfo}</td>
          <td>${pagoInfo}</td>
          <td class="text-end">${money(r.monto_aplicado)}</td>
          <td>${safe(r.fecha_aplicacion)}</td>`;
        $aplList.appendChild(tr);
      }

      const pago = state.pagosById.get(pagoId);
      if (pago?.proveedor_id){
        const docs = await http(`/api/cxp/documentos?proveedorId=${encodeURIComponent(pago.proveedor_id)}`);
        const candidates = (Array.isArray(docs)?docs:[])
          .filter(d=> Number(d.saldo_pendiente||0) > 0 && !isAnulado(d));
        if (!candidates.length){
          $aplDocsRapidosTbody.innerHTML = `<tr><td colspan="5" class="text-center text-muted">No hay documentos con saldo pendiente.</td></tr>`;
        } else {
          $aplDocsRapidosTbody.innerHTML='';
          for (const d of candidates){
            const tr=document.createElement('tr'); const def=Number(d.saldo_pendiente||0).toFixed(2);
            tr.innerHTML = `
              <td>${d.numero_documento || `#${d.id}`}</td>
              <td>${d.origen_nombre ? `${d.origen_tipo} — ${d.origen_nombre}` : `${d.origen_tipo}-${d.origen_id}`}</td>
              <td class="text-end">${money(d.saldo_pendiente)}</td>
              <td class="text-end"><input class="form-control form-control-sm nt-input apl-monto-input" type="number" min="0" step="0.01" value="${def}" style="max-width:150px"></td>
              <td class="text-end"><button class="btn btn-sm btn-outline-primary apl-add-btn"><i class="bi bi-plus-circle"></i></button></td>`;
            tr.dataset.docId = d.id; $aplDocsRapidosTbody.appendChild(tr);
          }
          qa('.apl-add-btn', $aplDocsRapidosTbody).forEach(btn=>{
            btn.addEventListener('click',(e)=>{
              e.preventDefault();
              const row = e.currentTarget.closest('tr');
              const id  = row.dataset.docId;
              const monto = row.querySelector('.apl-monto-input')?.value || '0';
              if (!id || Number(monto)<=0) return;
              const line = `${id}; ${Number(monto).toFixed(2)}`;
              const txt = $aplItems.value.trim();
              $aplItems.value = (txt ? (txt+'\n') : '') + line;
              toast(`Agregado al lote: ${line}`,'success','Aplicaciones');
            });
          });
        }
      }
    } catch(e){ toast(`Error listando aplicaciones: ${e.message}`,'danger','Aplicaciones'); }
  }

  // ------------ Handlers ------------
  const handlers = {
    onDocEditar(ev){
      const id = Number(ev.currentTarget.dataset.id);
      const row = state.docsById.get(id);
      if (!row) return toast('No se encontró el documento en memoria.', 'warning', 'Documentos');
      abrirDocEditar(row);
    },

    async onDocAnular(ev){
      const id = Number(ev.currentTarget.dataset.id);
      const row = state.docsById.get(id);
      confirmDestructive({
        title: 'Anular documento',
        message: `¿Seguro que deseas anular el documento #${id}${row?.numero_documento?` (${row.numero_documento})`:''}? Esta acción no se puede deshacer.`,
        confirmText: 'Anular documento',
        onConfirm: async () => {
          try {
            await del(`/api/cxp/documentos/${id}/anular`);
            toast(`Documento #${id} anulado.`, 'success', 'Documentos');
            await docListar();
          } catch (e) {
            const msg = String(e?.message || '');
            if (/sp_CXP_Documentos_Anular/i.test(msg) || /Could not find stored procedure/i.test(msg)) {
              disableDeleteForDoc(id, 'No disponible: SP de anulación no existe en el backend.');
              toast('No se pudo anular: función no disponible en el servidor (SP faltante).', 'danger', 'Documentos');
              return;
            }
            toast(`No se pudo anular: ${msg}`, 'danger', 'Documentos');
          }
        }
      });
    },

    async onDocSubmit(ev){
      ev.preventDefault();
      const id = $docId.value ? Number($docId.value) : null;
      try{
        if (!id){
          const payload = {
            proveedor_id: Number($proveedor_id.value),
            origen_tipo: $origen_tipo.value,
            origen_id: Number($origen_id_sel.style.display!=='none' ? $origen_id_sel.value : $origen_id.value),
            numero_documento: $numero_documento.value.trim(),
            fecha_emision: $fecha_emision.value,
            fecha_vencimiento: $fecha_vencimiento.value || null,
            moneda: $moneda.value,
            monto_total: Number($monto_total.value)
          };
          await http('/api/cxp/documentos', { method:'POST', json:payload });
          toast('Documento creado.', 'success', 'Documentos');
        } else {
          const payload = {
            fecha_pago: undefined, // no aplica para documento
            numero_documento: $numero_documento.value.trim(),
            fecha_emision: $fecha_emision.value || null,
            fecha_vencimiento: $fecha_vencimiento.value || null,
            moneda: $moneda.value,
            monto_total: Number($monto_total.value)
          };
          await http(`/api/cxp/documentos/${id}`, { method:'PUT', json:payload });
          toast('Documento actualizado.', 'success', 'Documentos');
        }
        $docModal.hide(); await Promise.all([docListar(), initCombos(true)]);
      } catch(e){ toast(`Error guardando: ${e.message}`, 'danger', 'Documentos'); }
    },

    onPagEditar(ev){
      const id = Number(ev.currentTarget.dataset.id);
      const row = state.pagosById.get(id);
      if (!row) return toast('No se encontró el pago en memoria.','warning','Pagos');
      $pagForm.reset(); $pago_id.value=row.id; $_proveedor_id.value=row.proveedor_id;
      $fecha_pago.value=row.fecha_pago||''; $forma_pago.value=row.forma_pago||'';
      $_monto_total.value=row.monto_total||0; $observaciones.value=row.observaciones||'';
      $_proveedor_id.disabled=true;
      $pagModal.show(); // usar SIEMPRE la instancia compartida
    },

    onPagEliminar(ev){
      const id = Number(ev.currentTarget.dataset.id);
      const row = state.pagosById.get(id);
      confirmDestructive({
        title: 'Eliminar pago',
        message: `¿Seguro que deseas eliminar el pago #${id} del proveedor ${row?.proveedor_nombre || row?.proveedor_id || ''}?`,
        confirmText: 'Eliminar pago',
        onConfirm: async () => {
          try { await del(`/api/cxp/pagos/${id}`);
            toast(`Pago #${id} eliminado.`, 'danger', 'Pagos');
            await Promise.all([pagListar(), initCombos(true)]);
          } catch(e){ toast(`Error: ${e.message}`, 'danger', 'Pagos'); }
        }
      });
    },

    async onPagSubmit(ev){
      ev.preventDefault();
      const id = $pago_id.value ? Number($pago_id.value) : null;
      try{
        if (!id){
          const payload = { proveedor_id:Number($_proveedor_id.value), fecha_pago:$fecha_pago.value, forma_pago:$forma_pago.value, monto_total:Number($_monto_total.value), observaciones:$observaciones.value||null };
          await http('/api/cxp/pagos', { method:'POST', json:payload });
          toast('Pago creado.','success','Pagos');
        } else {
          const payload = { fecha_pago:$fecha_pago.value, forma_pago:$forma_pago.value, monto_total:Number($_monto_total.value), observaciones:$observaciones.value||null };
          await http(`/api/cxp/pagos/${id}`, { method:'PUT', json:payload });
          toast('Pago actualizado.','success','Pagos');
        }
        $pagModal.hide();       // cerrar modal con la instancia compartida
        $pagForm.reset();       // limpiar formulario
        await Promise.all([pagListar(), initCombos(true)]);
      } catch(e){
        toast(`Error guardando: ${e.message}`, 'danger', 'Pagos');
      }
    },

    async onAplSubmit(ev){
      ev.preventDefault();
      const pagoId = Number($aplPagoId.value);
      const items = parseItems($aplItems.value);
      if (!pagoId) return toast('Seleccione un pago','warning','Aplicaciones');
      if (!items.length) return toast('No hay items válidos','warning','Aplicaciones');
      try{ await http(`/api/cxp/pagos/${pagoId}/aplicaciones`, { method:'POST', json:{items} });
        toast('Aplicaciones creadas.','success','Aplicaciones'); $aplItems.value=''; aplListar();
      } catch(e){ toast(`Error aplicando: ${e.message}`,'danger','Aplicaciones'); }
    }
  };

  // ------------ Utilidades varias ------------
  function disableDeleteForDoc(docId, title){
    qa(`.btn-doc-anular[data-id="${docId}"]`).forEach(btn=>{
      btn.classList.add('disabled');
      btn.setAttribute('aria-disabled','true');
      btn.title = title || 'No disponible';
      try { new bootstrap.Tooltip(btn); } catch {}
    });
  }

  function abrirDocNuevo(){
    $docForm.reset(); $docId.value='';
    q('#modalDocLabel').textContent='Nuevo documento CxP';
    $proveedor_id.disabled=false; $origen_tipo.disabled=false; $origen_id.disabled=false; $origen_id_sel.disabled=false;
    $origenHint.textContent=''; showOrigenSelect(false); $docModal.show();
  }
  function abrirDocEditar(row){
    $docForm.reset(); $docId.value=row.id;
    $proveedor_id.value=String(row.proveedor_id);
    $origen_tipo.value=row.origen_tipo;
    $origen_id.value=row.origen_id;
    $numero_documento.value=row.numero_documento||'';
    $fecha_emision.value=row.fecha_emision||'';
    $fecha_vencimiento.value=row.fecha_vencimiento||'';
    $moneda.value=row.moneda||'GTQ';
    $monto_total.value=row.monto_total||0;
    $origenHint.textContent = row.origen_nombre ? `Origen: ${row.origen_nombre}` : '';
    q('#modalDocLabel').textContent=`Editar documento #${row.id}`;
    $proveedor_id.disabled=true; $origen_tipo.disabled=true; showOrigenSelect(false); $origen_id.disabled=true;
    $docModal.show();
  }

  function parseItems(txt){
    const items=[]; txt.split(/\r?\n/).forEach(line=>{
      const t=line.trim(); if (!t) return;
      const [doc,mon]=t.split(/[;,]/).map(s=>s.trim());
      const documento_id=Number(doc); const monto_aplicado=Number(mon);
      if (Number.isFinite(documento_id) && Number.isFinite(monto_aplicado)) items.push({documento_id,monto_aplicado});
    }); return items;
  }

  // ------------ Init & eventos ------------
  async function initCombos(keep=false){
    const selDoc = keep ? $docFiltroProv.value : '';
    const selPag = keep ? $pagFiltroProv.value : '';
    const selProvDoc = keep ? $proveedor_id.value : '';
    const selProvPag = keep ? $_proveedor_id.value : '';
    const proveedores = await fetchDistinctProveedores();
    fillSelect($docFiltroProv, proveedores, {includeAll:true});
    fillSelect($pagFiltroProv, proveedores, {includeAll:true});
    fillSelect($proveedor_id, proveedores, {includeAll:false});
    fillSelect($_proveedor_id, proveedores, {includeAll:false});
    if (keep){
      if (qa(`option[value="${selDoc}"]`, $docFiltroProv).length) $docFiltroProv.value = selDoc;
      if (qa(`option[value="${selPag}"]`, $pagFiltroProv).length) $pagFiltroProv.value = selPag;
      if (qa(`option[value="${selProvDoc}"]`, $proveedor_id).length) $proveedor_id.value = selProvDoc;
      if (qa(`option[value="${selProvPag}"]`, $_proveedor_id).length) $_proveedor_id.value = selProvPag;
    }
  }

  $docNuevo.addEventListener('click', abrirDocNuevo);
  $docForm.addEventListener('submit', handlers.onDocSubmit);
  $docBuscar.addEventListener('click', docListar);
  $proveedor_id.addEventListener('change', renderOrigenSelector);
  $origen_tipo.addEventListener('change', renderOrigenSelector);

  $pagNuevo.addEventListener('click', ()=>{ $pagForm.reset(); $pago_id.value=''; $_proveedor_id.disabled=false; $pagModal.show(); });
  $pagForm.addEventListener('submit', handlers.onPagSubmit);
  $pagBuscar.addEventListener('click', pagListar);

  $aplCargar.addEventListener('click', (e)=>{ e.preventDefault(); aplListar(); });
  $aplForm.addEventListener('submit', handlers.onAplSubmit);
  $aplPagoId.addEventListener('change', aplListar);

  (async () => {
    await initCombos(false);
    await Promise.all([docListar(), pagListar()]);
  })();
})();
