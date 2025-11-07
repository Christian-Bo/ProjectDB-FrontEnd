/* compras.js — combos, autofill y PUT de cabecera con totales coherentes */

/* ====================== util red ====================== */
(function(){
  async function _fetchJson(method, url, body) {
    const opt = { method, headers: {} };
    if (body !== undefined){ opt.headers['Content-Type']='application/json'; opt.body = JSON.stringify(body); }
    const res = await fetch(url, opt);
    const raw = await res.text();
    if (!res.ok){ let msg = raw; try{ const j=JSON.parse(raw); msg=j.error||j.message||j.detail||raw; }catch{}; throw new Error(msg); }
    return raw ? JSON.parse(raw) : null;
  }
  window.ntGet    = window.ntGet    || (url=>_fetchJson('GET',url));
  window.ntPost   = window.ntPost   || ((url,body)=>_fetchJson('POST',url,body));
  window.ntPut    = window.ntPut    || ((url,body)=>_fetchJson('PUT',url,body));
  window.ntDelete = window.ntDelete || (url=>_fetchJson('DELETE',url));
  window.showToast = window.showToast || ((m,t='info',tt='Mensaje')=> console[t==='error'?'error':t==='warning'?'warn':'log'](`[${tt}] ${m}`));
  window.ntEsc = window.ntEsc || (s => String(s ?? '').replace(/[&<>"']/g, m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])));
})();

const API_BASE = (document.querySelector('meta[name="api-base"]')?.content || location.origin).replace(/\/$/,'');
const API = `${API_BASE}/api/compras`;
const $  = (s,c=document)=>c.querySelector(s);
const $$ = (s,c=document)=>Array.from(c.querySelectorAll(s));
const money = v => (v==null?'0.00':Number(v).toLocaleString('es-GT',{minimumFractionDigits:2, maximumFractionDigits:2}));
const V = (x, d='--') => (x===null||x===undefined||x==='') ? d : x;

/* ====================== parsers ====================== */
function toInt(v){ const n = parseInt(String(v??'').replace(/[^\d-]/g,''),10); return Number.isFinite(n)? n : 0; }
function toDec(v){
  if (v==null || v==='') return 0;
  if (typeof v === 'number') return Number.isFinite(v) ? v : 0;
  let s = String(v).trim().replace(/\s/g,'').replace(/[^\d.,-]/g,'');
  const lastComma = s.lastIndexOf(','), lastDot = s.lastIndexOf('.');
  if (lastComma === -1 && lastDot === -1) return Number.parseFloat(s) || 0;
  const sepIndex = Math.max(lastComma, lastDot), sepChar = s[sepIndex];
  s = s.replace(/[.,]/g, ch => ch===sepChar ? '.' : '');
  return Number.parseFloat(s) || 0;
}
const nz = v => (v===undefined||v===null||v==='') ? null : v;
const n0 = v => (v===undefined||v===null||Number.isNaN(v) ? 0 : Number(v));

/* ====================== modal manager ====================== */
class ModalManager{
  constructor(){ this.current=null; this.backdropCleaner=this.backdropCleaner.bind(this); }
  _bs(id){ const el=$(id); if(!el) throw new Error(`No existe ${id}`); return new bootstrap.Modal(el, {backdrop:'static', keyboard:false}); }
  async open(id){
    if (this.current){ await this.close(); }
    await new Promise(res=>{
      const el=$(id); if(!el) return res();
      el.addEventListener('shown.bs.modal', res, {once:true});
      this._bs(id).show();
    });
    this.current=id;
    document.addEventListener('hidden.bs.modal', this.backdropCleaner, {once:true});
  }
  async replace(id){ return this.open(id); }
  async close(){
    if(!this.current) return;
    const id=this.current; this.current=null;
    await new Promise(res=>{
      const el=$(id); if(!el) return res();
      el.addEventListener('hidden.bs.modal', res, {once:true});
      bootstrap.Modal.getInstance(el)?.hide();
    });
    this.cleanupBackdrops();
  }
  backdropCleaner(){ this.cleanupBackdrops(); }
  cleanupBackdrops(){ $$('.modal-backdrop').forEach((b,i)=>{ if(i>0) b.remove(); }); }
}
const mm = new ModalManager();

/* 🔒 Cierre forzado por si Bootstrap se queda con backdrops o instancias “huérfanas” */
function closeAllModals(){
  const opened = $$('.modal.show');
  opened.forEach(el => bootstrap.Modal.getInstance(el)?.hide());
  setTimeout(()=> { $$('.modal-backdrop').forEach(b=>b.remove()); }, 50);
  mm.current = null;
}

/* ====================== estado ====================== */
let compras=[], compraActual=null;
let pendingChanges = false;
const compraCache = new Map();

/* ===== helpers de caché ===== */
function invalidateCompra(id){
  if (!id && id!==0) return;
  compraCache.delete(id);
  if (compraActual?.cabecera?.id === id) compraActual = null;
}

/* ====================== catálogos ====================== */
const CAT = { proveedores:null, bodegas:null, empleados:null, productos:null };

function ensureOption(selectEl, id, label){
  if (!selectEl) return;
  if (!id && id!==0) return;
  const exists = Array.from(selectEl.options).some(opt => String(opt.value)===String(id));
  if (!exists){
    const op = document.createElement('option');
    op.value = String(id); op.textContent = label ?? `ID ${id}`;
    selectEl.appendChild(op);
  }
}
function fillSelect(sel, items, currentId, {placeholder='— Seleccione —'}={}) {
  const el = (typeof sel === 'string') ? $(sel) : sel;
  el.innerHTML = '';
  const opt0 = document.createElement('option');
  opt0.value = ''; opt0.textContent = placeholder;
  el.appendChild(opt0);
  (items||[]).forEach(it=>{
    const op = document.createElement('option');
    op.value = String(it.id);
    op.textContent = it.nombre;
    el.appendChild(op);
  });
  if (currentId!=null && currentId!==''){
    ensureOption(el, currentId, (items||[]).find(i=>String(i.id)===String(currentId))?.nombre);
    el.value = String(currentId);
  }
}

async function loadCatalogOnce(){
  if (!CAT.proveedores) CAT.proveedores = await ntGet(`${API}/catalogos/proveedores?activo=true`).catch(()=>[]);
  if (!CAT.bodegas)     CAT.bodegas     = await ntGet(`${API}/catalogos/bodegas`).catch(()=>[]);
  if (!CAT.empleados)   CAT.empleados   = await ntGet(`${API}/catalogos/empleados`).catch(()=>[]);
}
async function loadProductosOnce(){
  if (CAT.productos) return;
  CAT.productos = await ntGet(`${API}/catalogos/productos?limit=200`).catch(()=>[]);
}
async function cargarCatalogosUI({provId=null, bodegaId=null, compId=null, autoId=null}={}){
  await loadCatalogOnce();
  fillSelect('#cab_proveedorSel', CAT.proveedores, provId);
  fillSelect('#cab_bodegaSel',     CAT.bodegas,     bodegaId);
  fillSelect('#cab_compradorSel',  CAT.empleados,   compId);
  fillSelect('#cab_autorizaSel',   CAT.empleados,   autoId, {placeholder:'— Sin autorizar —'});
}

/* ====================== listado ====================== */
async function enrichListWithNames(list){
  const needs = (list||[]).filter(c => !c?.proveedorNombre || !c?.bodegaDestinoNombre);
  if (!needs.length) return;
  await Promise.all(needs.map(async row=>{
    try{
      let full = compraCache.get(row.id);
      if (!full) { full = await ntGet(`${API}/${row.id}?_=${Date.now()}`); compraCache.set(row.id, full); }
      const cab = full?.cabecera || {};
      row.proveedorNombre     = cab.proveedorNombre     ?? row.proveedorNombre;
      row.bodegaDestinoNombre = cab.bodegaDestinoNombre ?? row.bodegaDestinoNombre;
    }catch{}
  }));
}
async function buscar(){
  const p = new URLSearchParams();
  if($('#fDel').value) p.append('fechaDel', $('#fDel').value);
  if($('#fAl').value)  p.append('fechaAl',  $('#fAl').value);
  if($('#fProveedorId').value) p.append('proveedorId', $('#fProveedorId').value);
  if($('#fEstado').value) p.append('estado', $('#fEstado').value);
  if($('#fTexto').value) p.append('texto', $('#fTexto').value);
  const url = p.toString()? `${API}?${p}`: API;

  try{
    compras = await ntGet(url);
    await enrichListWithNames(compras);
    renderTabla();
  }catch(e){
    showToast(`No se pudo listar compras: ${e.message}`, 'error', 'Compras');
  }
}
function renderTabla(){
  const tb = $('#tblCompras tbody'); tb.innerHTML='';
  (compras||[]).forEach((c,i)=>{
    const tr=document.createElement('tr');
    tr.innerHTML=`
      <td>${i+1}</td>
      <td><span class="fw-semibold">${ntEsc(V(c.numeroCompra,''))}</span></td>
      <td>${ntEsc(V(c.noFacturaProveedor))}</td>
      <td>${ntEsc(V(c.fechaCompra))}</td>
      <td>${ntEsc(V(c.proveedorNombre))}</td>
      <td>${ntEsc(V(c.bodegaDestinoNombre))}</td>
      <td class="text-end">${money(c.subtotal)}</td>
      <td class="text-end">${money(c.descuentoGeneral)}</td>
      <td class="text-end">${money(c.iva)}</td>
      <td class="text-end">${money(c.total)}</td>
      <td>${badge(c.estado)}</td>
      <td>
        <div class="btn-group btn-group-sm">
          <button class="btn btn-outline-primary" data-act="ver" data-id="${c.id}" title="Ver"><i class="bi bi-eye"></i></button>
          <button class="btn btn-outline-secondary" data-act="modo" data-id="${c.id}" title="Elegir modo de edición"><i class="bi bi-sliders"></i></button>
          <button class="btn btn-outline-danger" data-act="anular" data-id="${c.id}" title="Anular"><i class="bi bi-x-circle"></i></button>
        </div>
      </td>`;
    tb.appendChild(tr);
  });
}
const badge = e => {
  const cls = e==='R'?'bg-info':e==='C'?'bg-success':e==='X'?'bg-danger':'bg-secondary';
  return `<span class="badge ${cls} badge-estado">${e||'-'}</span>`;
};

/* ====================== DETALLE: UI + AUTOFILL ====================== */
function resetDetalleRow(tr, { keepQty = true } = {}) {
  if (!tr) return;
  const qtyEl = tr.querySelector('.inp-cantidad, .linea_cant');
  const qtyVal = qtyEl ? qtyEl.value : '';
  const precioEl = tr.querySelector('.inp-precio, .linea_pu');
  const descEl   = tr.querySelector('.inp-descuento, .linea_desc');
  const loteEl   = tr.querySelector('.inp-lote, .linea_lote');
  const venceEl  = tr.querySelector('.inp-vence, .linea_vence');
  if (precioEl) precioEl.value = '';
  if (descEl)   descEl.value   = '';
  if (loteEl)   loteEl.value   = '';
  if (venceEl)  venceEl.value  = '';
  ['.meta-codigo', '.meta-unidad', '.meta-stock'].forEach(sel=>{
    const el = tr.querySelector(sel);
    if (el) el.textContent = '—';
  });
  if (qtyEl && keepQty) qtyEl.value = qtyVal || '1';
}

function appendRowFromTemplate(tbodySel, templateId){
  const tb = $(tbodySel);
  const tpl = $(templateId);
  const node = tpl.content.firstElementChild.cloneNode(true);
  tb.appendChild(node);
  node.querySelector('.btn-del-linea')?.addEventListener('click', ()=> node.remove());
  prepareProductSelect(node.querySelector('select.prod-select'));
  return node;
}

async function prepareProductSelect(selectEl){
  if (!selectEl) return;
  await loadProductosOnce();
  fillSelect(selectEl, CAT.productos, null, {placeholder:'— Seleccione —'});
  const tr = selectEl.closest('tr');
  const hidden = tr?.querySelector('.inp-productoId');
  selectEl.addEventListener('change', async () => {
    if (hidden) hidden.value = selectEl.value || '';
    resetDetalleRow(tr, { keepQty: true });
    await autofillProducto(tr, selectEl.value, $('#cab_bodegaSel')?.value || null);
  });
}

async function autofillProducto(tr, productoId, bodegaId){
  const metaCodigo = tr.querySelector('.meta-codigo');
  const metaUnidad = tr.querySelector('.meta-unidad');
  const metaStock  = tr.querySelector('.meta-stock');
  const inpPrecio  = tr.querySelector('.inp-precio');

  if (!productoId){
    if (metaCodigo) metaCodigo.textContent='—';
    if (metaUnidad) metaUnidad.textContent='—';
    if (metaStock)  metaStock.textContent ='—';
    return;
  }
  try{
    const u = new URL(`${API}/autofill/producto`);
    u.searchParams.set('productoId', productoId);
    if (bodegaId) u.searchParams.set('bodegaId', bodegaId);
    const info = await ntGet(u.toString());
    if (metaCodigo) metaCodigo.textContent = info?.producto_codigo ?? '—';
    if (metaUnidad) metaUnidad.textContent = info?.unidad_medida ?? '—';
    if (metaStock)  metaStock.textContent  = info?.stock_disponible ?? '—';
    if (inpPrecio && (!inpPrecio.value || toDec(inpPrecio.value)===0) && info?.precio_compra){
      inpPrecio.value = info.precio_compra;
    }
  }catch(e){
    console.warn('autofillProducto fallo', e.message);
  }
}

/* 🔁 Refresca las insignias de stock en las filas con producto (post-op) */
async function refreshStockBadges(){
  const bId = $('#cab_bodegaSel')?.value || null;
  // detalle nuevo (crear)
  await Promise.all($$('#tblDetalleNuevo tbody tr').map(async tr=>{
    const pid = tr.querySelector('.inp-productoId')?.value || tr.querySelector('select.prod-select')?.value;
    if (pid) await autofillProducto(tr, pid, bId);
  }));
  // detalle existente (vista maestro–detalle): no muestra meta-stock por defecto, se omite
}

/* ===== Compat: addLinea / recolectarDetalle ==== */
function addLinea(tbodySel){
  const tplId = (tbodySel.includes('Agregar')) ? '#tplFilaDetalleAgregar' : '#tplFilaDetalleNuevo';
  appendRowFromTemplate(tbodySel, tplId);
}
function recolectarDetalle(tbodySel){
  const rows = $$(tbodySel + ' tr');
  return rows.map(row=>{
    let productoId = toInt(row.querySelector('.inp-productoId')?.value || '');
    if (!productoId) productoId = toInt(row.querySelector('select.prod-select')?.value || '');
    if (!productoId) productoId = toInt(row.querySelector('.linea_productoId')?.value || '');
    const cantidadPedida = toInt(row.querySelector('.inp-cantidad, .linea_cant')?.value || '');
    const precioUnitario = toDec(row.querySelector('.inp-precio, .linea_pu')?.value || '');
    const descuentoLinea = row.querySelector('.inp-descuento, .linea_desc')?.value ? toDec(row.querySelector('.inp-descuento, .linea_desc').value) : 0;
    const lote = nz((row.querySelector('.inp-lote, .linea_lote')?.value || '').trim());
    const fechaVencimiento = nz((row.querySelector('.inp-vence, .linea_vence')?.value || '').trim());
    if(productoId>0 && cantidadPedida>0){
      return {productoId,cantidadPedida,precioUnitario,descuentoLinea,lote,fechaVencimiento};
    }
    return null;
  }).filter(Boolean);
}

/* ====================== cabecera: crear/editar ====================== */
async function nuevaCabecera(){
  $('#cabeceraTitle').textContent='Nueva compra';
  $('#cab_compraId').value='';
  $('#cab_usuarioId').value='1';
  $('#cab_numeroCompra').value='';
  $('#cab_noFacturaProveedor').value='';
  $('#cab_fechaCompra').valueAsDate = new Date();
  $('#cab_observaciones').value='';
  await cargarCatalogosUI({});
  $('#tblDetalleNuevo tbody').innerHTML='';
  addLinea('#tblDetalleNuevo tbody');
  await mm.open('#mdlCabecera');
}

function safeTotalsFromCab(cab){
  const subtotal = n0(cab?.subtotal);
  const descuentoGeneral = n0(cab?.descuentoGeneral);
  const iva = n0(cab?.iva);
  let total = cab?.total;
  total = Number.isFinite(Number(total)) ? Number(total) : (subtotal - descuentoGeneral + iva);
  return { subtotal, descuentoGeneral, iva, total: n0(total) };
}

async function guardarCabecera(ev){
  ev.preventDefault();
  const compraId = $('#cab_compraId').value;

  const base = {
    usuarioId: toInt($('#cab_usuarioId').value),
    numeroCompra: $('#cab_numeroCompra').value.trim(),
    noFacturaProveedor: $('#cab_noFacturaProveedor').value.trim(),
    fechaCompra: $('#cab_fechaCompra').value,
    proveedorId: toInt($('#cab_proveedorSel').value),
    empleadoCompradorId: toInt($('#cab_compradorSel').value),
    bodegaDestinoId: toInt($('#cab_bodegaSel').value),
    observaciones: nz($('#cab_observaciones').value?.trim())
  };
  const empAut = $('#cab_autorizaSel').value ? toInt($('#cab_autorizaSel').value) : null;
  if (empAut) base.empleadoAutorizaId = empAut;

  const creando = !compraId;
  const detalle = creando ? recolectarDetalle('#tblDetalleNuevo tbody') : [];

  if(!base.usuarioId || !base.numeroCompra || !base.noFacturaProveedor || !base.fechaCompra ||
     !base.proveedorId || !base.empleadoCompradorId || !base.bodegaDestinoId ||
     (creando && detalle.length===0)){
    showToast('Complete los campos requeridos y agregue al menos una línea', 'warning', 'Validación'); 
    return;
  }

  try{
    if(creando){
      const id = await ntPost(API, { ...base, detalle });
      showToast(`Compra creada #${id}`, 'success', 'Éxito');
      // cierre y refrescos
      closeAllModals();
      invalidateCompra(id);
      await buscar();
      await verCompra(id, true, true);
      await refreshStockBadges();
    }else{
      const idNum = toInt(compraId);
      if (!compraActual || compraActual?.cabecera?.id !== idNum){
        try{ compraActual = await ntGet(`${API}/${idNum}?_=${Date.now()}`); compraCache.set(idNum, compraActual); }catch{}
      }
      const cab = compraActual?.cabecera || {};
      const totals = safeTotalsFromCab(cab);

      const put = {
        ...base,
        ...totals,          // info inofensiva para el backend
        compraId: idNum
      };

      await ntPut(`${API}/${idNum}/cabecera`, put);
      showToast('Cabecera actualizada', 'success', 'Éxito');
      pendingChanges = true;
      closeAllModals();

      // 🔥 refrescar datos: invalidar caché y traer del backend
      invalidateCompra(idNum);
      await verCompra(idNum, true, true);
      await buscar();
      await refreshStockBadges();
    }
  }catch(e){
    showToast(e.message || 'Error al guardar cabecera', 'error', 'Error');
  }
}

/* ====================== ver / detalle ====================== */
async function verCompra(id, abrir, force=false){
  try{
    let full = !force ? compraCache.get(id) : null;
    if (!full){
      // cache-busting para garantizar lectura fresca
      full = await ntGet(`${API}/${id}?_=${Date.now()}`);
      compraCache.set(id, full);
    }
    compraActual = full;

    const c = compraActual?.cabecera || {};
    $('#cmp_numero').textContent = V(c.numeroCompra,'');
    $('#cmp_proveedor').textContent = V(c.proveedorNombre,'');
    $('#cmp_factura').textContent = V(c.noFacturaProveedor,'');
    $('#cmp_bodega').textContent = V(c.bodegaDestinoNombre,'');
    $('#cmp_estado').innerHTML = badge(c.estado);
    const tot = `Subtotal: Q${money(c.subtotal)} | Desc: Q${money(c.descuentoGeneral)} | IVA: Q${money(c.iva)} | Total: Q${money(c.total)}`;
    $('#cmp_totales').textContent = tot;

    const tb = $('#tblDetalleExistente tbody'); tb.innerHTML='';
    (compraActual?.detalle||[]).forEach((d,i)=>{
      const tr=document.createElement('tr');
      tr.innerHTML = `
        <td>${i+1}</td>
        <td>${ntEsc(V(d.productoNombre, `ID ${d.productoId}`))}</td>
        <td class="text-end">${d.cantidadPedida ?? 0}</td>
        <td class="text-end">${money(d.precioUnitario)}</td>
        <td class="text-end">${money(d.descuentoLinea)}</td>
        <td class="text-end">${money(d.subtotal)}</td>
        <td>${ntEsc(d.lote ?? '')}</td>
        <td>${ntEsc(d.fechaVencimiento ?? '')}</td>
        <td>
          <div class="btn-group btn-group-sm">
            <button class="btn btn-outline-secondary" data-edit-linea="${d.id}" title="Editar línea"><i class="bi bi-pencil-square"></i></button>
            <button class="btn btn-outline-danger" data-del-linea="${d.id}" title="Eliminar línea"><i class="bi bi-trash"></i></button>
          </div>
        </td>`;
      tb.appendChild(tr);
    });

    if ( abrir ) await mm.open('#mdlCompra');
  }catch(e){
    showToast(e.message || 'No se pudo obtener la compra', 'error', 'Error');
  }
}

/* ====================== agregar líneas ====================== */
function abrirAgregarLineas(){
  if(!compraActual) return;
  $('#add_compraId').value = compraActual.cabecera.id;
  $('#add_usuarioId').value = 1;
  $('#add_compraTitulo').textContent = compraActual.cabecera.numeroCompra;
  $('#tblDetalleAgregar tbody').innerHTML='';
  addLinea('#tblDetalleAgregar tbody');
  return mm.replace('#mdlAgregarLineas');
}
async function guardarLineas(ev){
  ev.preventDefault();
  const compraId = toInt($('#add_compraId').value);
  const usuarioId = toInt($('#add_usuarioId').value);
  const detalle = recolectarDetalle('#tblDetalleAgregar tbody');

  if(!detalle.length){ showToast('Agrega al menos una línea', 'warning', 'Validación'); return; }
  try{
    await ntPost(`${API}/${compraId}/detalles?usuarioId=${usuarioId}`, detalle);
    showToast('Líneas agregadas', 'success', 'Éxito');
    pendingChanges = true;
    closeAllModals();

    invalidateCompra(compraId);
    await verCompra(compraId, true, true);
    await buscar();
    await refreshStockBadges();
  }catch(e){
    showToast(e.message || 'Error al agregar líneas', 'error', 'Error');
  }
}

/* ====================== editar línea ====================== */
function abrirEditarLinea(detalleId){
  if(!compraActual) return;
  const li = compraActual.detalle.find(x=> x.id === toInt(detalleId));
  if(!li) return;
  $('#ed_compraId').value = compraActual.cabecera.id;
  $('#ed_detalleId').value = li.id;
  $('#ed_usuarioId').value = 1;
  $('#ed_precioUnitario').value = li.precioUnitario ?? 0;
  $('#ed_descuentoLinea').value = li.descuentoLinea ?? 0;
  $('#ed_cantidadPedida').value = li.cantidadPedida ?? 0;
  $('#ed_lote').value = li.lote ?? '';
  $('#ed_fechaVencimiento').value = li.fechaVencimiento ?? '';
  return mm.replace('#mdlEditarLinea');
}
async function guardarLinea(ev){
  ev.preventDefault();
  const compraId  = toInt($('#ed_compraId').value);
  const detalleId = toInt($('#ed_detalleId').value);
  const payload = {
    usuarioId: toInt($('#ed_usuarioId').value),
    detalleId,
    precioUnitario: toDec($('#ed_precioUnitario').value),
    descuentoLinea: $('#ed_descuentoLinea').value ? toDec($('#ed_descuentoLinea').value) : null,
    cantidadPedida: $('#ed_cantidadPedida').value ? toInt($('#ed_cantidadPedida').value) : null,
    lote: nz($('#ed_lote').value),
    fechaVencimiento: nz($('#ed_fechaVencimiento').value)
  };
  try{
    await ntPut(`${API}/${compraId}/detalles/${detalleId}`, payload);
    showToast('Línea actualizada', 'success', 'Éxito');
    pendingChanges = true;
    closeAllModals();

    invalidateCompra(compraId);
    await verCompra(compraId, true, true);
    await buscar();
    await refreshStockBadges();
  }catch(e){
    showToast(e.message || 'Error al editar línea', 'error', 'Error');
  }
}

/* ====================== eliminar línea ====================== */
async function eliminarLinea(detalleId){
  if(!compraActual) return;
  if(!confirm('¿Eliminar la línea seleccionada?')) return;
  const usuarioId=1;
  const compraId = compraActual.cabecera.id;
  try{
    await ntDelete(`${API}/${compraId}/detalles/${detalleId}?usuarioId=${usuarioId}`);
    showToast('Línea eliminada', 'success', 'Éxito');
    pendingChanges = true;

    invalidateCompra(compraId);
    await verCompra(compraId, true, true);
    await buscar();
    await refreshStockBadges();
  }catch(e){
    showToast(e.message || 'Error al eliminar línea', 'error', 'Error');
  }
}

/* ====================== anular compra ====================== */
function abrirAnular(){
  if(!compraActual) return;
  $('#anu_compraId').value = compraActual.cabecera.id;
  $('#anu_usuarioId').value = 1;
  $('#anu_motivo').value = '';
  return mm.replace('#mdlAnular');
}
async function anularCompra(ev){
  ev.preventDefault();
  const compraId = toInt($('#anu_compraId').value);
  const usuarioId = toInt($('#anu_usuarioId').value);
  const motivo = $('#anu_motivo').value.trim();
  if(!motivo){ showToast('Escriba un motivo de anulación', 'warning', 'Validación'); return; }
  try{
    await ntPost(`${API}/${compraId}/anular`, { usuarioId, compraId, motivo });
    showToast('Compra anulada', 'success', 'Éxito');
    pendingChanges = true;
    closeAllModals();

    invalidateCompra(compraId);
    await verCompra(compraId, true, true);
    await buscar();
    await refreshStockBadges();
  }catch(e){
    showToast(e.message || 'Error al anular', 'error', 'Error');
  }
}

/* ====================== selector de modo ====================== */
async function abrirSelectorModo(idCompra){
  $('#modo_compraId').value = idCompra;
  await mm.open('#mdlModoEdicion');
}
async function elegirEditarCabecera(){
  const id = toInt($('#modo_compraId').value);
  await verCompra(id, false, true);  // ⚠️ recarga forzada

  const c = compraActual.cabecera;
  await cargarCatalogosUI({
    provId:   c.proveedorId || null,
    bodegaId: c.bodegaDestinoId || null,
    compId:   c.empleadoCompradorId || null,
    autoId:   c.empleadoAutorizaId || null
  });

  ensureOption($('#cab_proveedorSel'), c.proveedorId, c.proveedorNombre);
  ensureOption($('#cab_bodegaSel'), c.bodegaDestinoId, c.bodegaDestinoNombre);
  ensureOption($('#cab_compradorSel'), c.empleadoCompradorId, c.empleadoCompradorNombre);
  if (c.empleadoAutorizaId) ensureOption($('#cab_autorizaSel'), c.empleadoAutorizaId, c.empleadoAutorizaNombre);

  $('#cabeceraTitle').textContent = `Editar compra ${c.numeroCompra || ''}`;
  $('#cab_compraId').value = c.id;
  $('#cab_usuarioId').value = 1;
  $('#cab_numeroCompra').value = c.numeroCompra || '';
  $('#cab_noFacturaProveedor').value = c.noFacturaProveedor || '';
  $('#cab_fechaCompra').value = c.fechaCompra || '';
  $('#cab_observaciones').value = c.observaciones || '';

  $('#cab_proveedorSel').value  = c.proveedorId || '';
  $('#cab_bodegaSel').value     = c.bodegaDestinoId || '';
  $('#cab_compradorSel').value  = c.empleadoCompradorId || '';
  $('#cab_autorizaSel').value   = c.empleadoAutorizaId || '';

  await mm.replace('#mdlCabecera');
}
async function elegirMaestroDetalle(){
  const id = toInt($('#modo_compraId').value);
  await verCompra(id, true, true);   // ⚠️ recarga forzada
}

/* ====================== botón GUARDAR maestro–detalle ====================== */
async function guardarMaster(){
  if (pendingChanges){
    pendingChanges = false;
    await buscar();
    closeAllModals();
    showToast('Cambios guardados', 'success', 'Compras');
  }else{
    showToast('No hay cambios pendientes', 'info', 'Compras');
  }
}

/* ====================== eventos / init ====================== */
function bind(){
  // filtros
  $('#btnBuscar').addEventListener('click', buscar);
  $('#btnRefrescar').addEventListener('click', buscar);
  $('#fProveedorSel')?.addEventListener('change', e => $('#fProveedorId').value = e.target.value || '');

  // nueva compra
  $('#btnNuevaCompra').addEventListener('click', nuevaCabecera);
  $('#btnAddLinea').addEventListener('click', ()=> addLinea('#tblDetalleNuevo tbody'));
  $('#frmCabecera').addEventListener('submit', guardarCabecera);

  // refrescar metas si cambia bodega
  $('#cab_bodegaSel')?.addEventListener('change', () => {
    const bId = $('#cab_bodegaSel').value || null;
    $$('#tblDetalleNuevo tbody tr').forEach(tr=>{
      const pid = tr.querySelector('.inp-productoId')?.value || tr.querySelector('select.prod-select')?.value;
      if (pid) autofillProducto(tr, pid, bId);
    });
    $$('#tblDetalleAgregar tbody tr').forEach(tr=>{
      const pid = tr.querySelector('.inp-productoId')?.value || tr.querySelector('select.prod-select')?.value;
      if (pid) autofillProducto(tr, pid, bId);
    });
  });

  // tabla principal
  $('#tblCompras').addEventListener('click', async (e)=>{
    const b = e.target.closest('button'); if(!b) return;
    const id = toInt(b.dataset.id);
    if (b.dataset.act==='ver'){ await verCompra(id, true, true); }   // ⚠️ fuerza recarga al abrir
    if (b.dataset.act==='modo'){ await abrirSelectorModo(id); }
    if (b.dataset.act==='anular'){ await verCompra(id, false, true); abrirAnular(); }
  });

  // maestro–detalle
  $('#btnAgregarDetalleModal').addEventListener('click', abrirAgregarLineas);
  $('#btnEditarCabeceraModal').addEventListener('click', elegirEditarCabecera);
  $('#btnAnularCompra').addEventListener('click', abrirAnular);
  $('#btnGuardarMaster').addEventListener('click', guardarMaster);
  $('#tblDetalleExistente').addEventListener('click', (e)=>{
    const ebtn = e.target.closest('[data-edit-linea]');
    const dbtn = e.target.closest('[data-del-linea]');
    if (ebtn) abrirEditarLinea(ebtn.dataset.editLinea);
    if (dbtn) eliminarLinea(dbtn.dataset.delLinea);
  });

  // agregar líneas
  $('#btnAddLinea2').addEventListener('click', ()=> addLinea('#tblDetalleAgregar tbody'));
  $('#frmAgregarLineas').addEventListener('submit', guardarLineas);

  // editar línea
  $('#frmEditarLinea').addEventListener('submit', guardarLinea);

  // anular
  $('#frmAnular').addEventListener('submit', anularCompra);

  // selector modo
  $('#optEditarCabecera').addEventListener('click', elegirEditarCabecera);
  $('#optMaestroDetalle').addEventListener('click', elegirMaestroDetalle);

  // cierre seguro
  document.body.addEventListener('click', async (e)=>{
    const btn = e.target.closest('[data-mm-close]');
    if (!btn) return;
    await mm.close();
  });
}
async function init(){ bind(); await buscar(); }
window.addEventListener('DOMContentLoaded', init);
