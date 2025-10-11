/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

// assets/js/compras.js
// Pantalla Compras: listado + CRUD con modales (consume /api/compras/*)
// compras.js — Módulo Compras con ModalManager para evitar modales apilados

// compras.js — Compras con ModalManager y “Selector de modo de edición”

// compras.js — Compras con ModalManager, selector de modo y botón “Guardar” en maestro–detalle

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

/* ====================== estado ====================== */
let compras=[], compraActual=null;
let pendingChanges = false; // << bandera para botón Guardar

/* ====================== listado ====================== */
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
      <td><span class="fw-semibold">${ntEsc(c.numeroCompra||'')}</span></td>
      <td>${ntEsc(c.noFacturaProveedor||'')}</td>
      <td>${ntEsc(c.fechaCompra||'')}</td>
      <td>${ntEsc(c.proveedorNombre||'')}</td>
      <td>${ntEsc(c.bodegaDestinoNombre||'')}</td>
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

/* ====================== cabecera: crear/editar ====================== */
function nuevaCabecera(){
  $('#cabeceraTitle').textContent='Nueva compra';
  $('#cab_compraId').value='';
  $('#cab_usuarioId').value='1';
  $('#cab_numeroCompra').value='';
  $('#cab_noFacturaProveedor').value='';
  $('#cab_fechaCompra').valueAsDate = new Date();
  $('#cab_proveedorId').value='';
  $('#cab_empleadoCompradorId').value='';
  $('#cab_empleadoAutorizaId').value='';
  $('#cab_bodegaDestinoId').value='';
  $('#cab_observaciones').value='';
  $('#tblDetalleNuevo tbody').innerHTML='';
  $('#panelDetalleInicial').style.display = '';
  addLinea('#tblDetalleNuevo tbody');
}
function addLinea(tbodySel){
  const tb=$(tbodySel); const tr=document.createElement('tr');
  tr.innerHTML=`
    <td><input type="number" class="form-control form-control-sm linea_productoId" min="1" placeholder="ID"></td>
    <td><input type="number" class="form-control form-control-sm linea_cant" min="1" value="1"></td>
    <td><input type="number" step="0.01" class="form-control form-control-sm linea_pu" value="0.00"></td>
    <td><input type="number" step="0.01" class="form-control form-control-sm linea_desc" value="0.00"></td>
    <td><input type="text" class="form-control form-control-sm linea_lote"></td>
    <td><input type="date" class="form-control form-control-sm linea_vence"></td>
    <td><button class="btn btn-sm btn-outline-danger" type="button"><i class="bi bi-trash"></i></button></td>
  `;
  tb.appendChild(tr);
  tr.querySelector('button').addEventListener('click',()=> tr.remove());
}
function recolectarDetalle(tbodySel){
  const rows = $$(tbodySel + ' tr');
  return rows.map(row=>{
    const productoId = parseInt(row.querySelector('.linea_productoId').value||'0',10);
    const cantidadPedida = parseInt(row.querySelector('.linea_cant').value||'0',10);
    const precioUnitario = Number(row.querySelector('.linea_pu').value||0);
    const descuentoLinea = Number(row.querySelector('.linea_desc').value||0);
    const lote = row.querySelector('.linea_lote').value || null;
    const fechaVencimiento = row.querySelector('.linea_vence').value || null;
    if(productoId && cantidadPedida>0){
      return {productoId,cantidadPedida,precioUnitario,descuentoLinea,lote,fechaVencimiento};
    }
    return null;
  }).filter(Boolean);
}
async function guardarCabecera(ev){
  ev.preventDefault();
  const compraId = $('#cab_compraId').value;
  const payload = {
    usuarioId: parseInt($('#cab_usuarioId').value||'0',10),
    numeroCompra: $('#cab_numeroCompra').value.trim(),
    noFacturaProveedor: $('#cab_noFacturaProveedor').value.trim(),
    fechaCompra: $('#cab_fechaCompra').value,
    proveedorId: parseInt($('#cab_proveedorId').value||'0',10),
    empleadoCompradorId: parseInt($('#cab_empleadoCompradorId').value||'0',10),
    empleadoAutorizaId: $('#cab_empleadoAutorizaId').value? parseInt($('#cab_empleadoAutorizaId').value,10): null,
    bodegaDestinoId: parseInt($('#cab_bodegaDestinoId').value||'0',10),
    observaciones: $('#cab_observaciones').value?.trim() || null,
    detalle: recolectarDetalle('#tblDetalleNuevo tbody')
  };

  const creando = !compraId;
  if(!payload.usuarioId || !payload.numeroCompra || !payload.noFacturaProveedor || !payload.fechaCompra ||
     !payload.proveedorId || !payload.empleadoCompradorId || !payload.bodegaDestinoId ||
     (creando && payload.detalle.length===0)){
    showToast('Complete los campos requeridos y agregue al menos una línea', 'warning', 'Validación'); return;
  }

  try{
    if(creando){
      const id = await ntPost(API, payload);
      showToast(`Compra creada #${id}`, 'success', 'Éxito');
      await mm.close();
      await buscar();
      await verCompra(id, true);
    }else{
      const put = {
        usuarioId: payload.usuarioId,
        compraId: parseInt(compraId,10),
        noFacturaProveedor: payload.noFacturaProveedor,
        fechaCompra: payload.fechaCompra,
        proveedorId: payload.proveedorId,
        empleadoCompradorId: payload.empleadoCompradorId,
        empleadoAutorizaId: payload.empleadoAutorizaId,
        bodegaDestinoId: payload.bodegaDestinoId,
        descuentoGeneral: null,
        observaciones: payload.observaciones
      };
      await ntPut(`${API}/${compraId}/cabecera`, put);
      showToast('Cabecera actualizada', 'success', 'Éxito');
      pendingChanges = true; // hubo cambios relevantes
      await mm.close();
      await verCompra(parseInt(compraId,10), true);
      await buscar();
    }
  }catch(e){
    showToast(e.message || 'Error al guardar cabecera', 'error', 'Error');
  }
}

/* ====================== ver / detalle ====================== */
async function verCompra(id, abrir){
  try{
    compraActual = await ntGet(`${API}/${id}`);
    $('#cmp_numero').textContent = compraActual?.cabecera?.numeroCompra || '';
    $('#cmp_proveedor').textContent = compraActual?.cabecera?.proveedorNombre || '';
    $('#cmp_factura').textContent = compraActual?.cabecera?.noFacturaProveedor || '';
    $('#cmp_bodega').textContent = compraActual?.cabecera?.bodegaDestinoNombre || '';
    $('#cmp_estado').innerHTML = badge(compraActual?.cabecera?.estado);
    const tot = `Subtotal: Q${money(compraActual?.cabecera?.subtotal)} | Desc: Q${money(compraActual?.cabecera?.descuentoGeneral)} | IVA: Q${money(compraActual?.cabecera?.iva)} | Total: Q${money(compraActual?.cabecera?.total)}`;
    $('#cmp_totales').textContent = tot;

    const tb = $('#tblDetalleExistente tbody'); tb.innerHTML='';
    (compraActual?.detalle||[]).forEach((d,i)=>{
      const tr=document.createElement('tr');
      tr.innerHTML = `
        <td>${i+1}</td>
        <td>${ntEsc(d.productoNombre ?? `ID ${d.productoId}`)}</td>
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
  const compraId = parseInt($('#add_compraId').value,10);
  const usuarioId = parseInt($('#add_usuarioId').value,10);
  const detalle = recolectarDetalle('#tblDetalleAgregar tbody');
  if(!detalle.length){ showToast('Agrega al menos una línea', 'warning', 'Validación'); return; }
  try{
    await ntPost(`${API}/${compraId}/detalles?usuarioId=${usuarioId}`, detalle);
    showToast('Líneas agregadas', 'success', 'Éxito');
    pendingChanges = true;
    await mm.close();
    await verCompra(compraId, true);
    await buscar();
  }catch(e){
    showToast(e.message || 'Error al agregar líneas', 'error', 'Error');
  }
}

/* ====================== editar línea ====================== */
function abrirEditarLinea(detalleId){
  if(!compraActual) return;
  const li = compraActual.detalle.find(x=> x.id === parseInt(detalleId,10));
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
  const compraId  = parseInt($('#ed_compraId').value,10);
  const detalleId = parseInt($('#ed_detalleId').value,10);
  const payload = {
    usuarioId: parseInt($('#ed_usuarioId').value,10),
    detalleId,
    precioUnitario: Number($('#ed_precioUnitario').value||0),
    descuentoLinea: $('#ed_descuentoLinea').value ? Number($('#ed_descuentoLinea').value) : null,
    cantidadPedida: $('#ed_cantidadPedida').value ? parseInt($('#ed_cantidadPedida').value,10) : null,
    lote: $('#ed_lote').value || null,
    fechaVencimiento: $('#ed_fechaVencimiento').value || null
  };
  try{
    await ntPut(`${API}/${compraId}/detalles/${detalleId}`, payload);
    showToast('Línea actualizada', 'success', 'Éxito');
    pendingChanges = true;
    await mm.close();
    await verCompra(compraId, true);
    await buscar();
  }catch(e){
    showToast(e.message || 'Error al editar línea', 'error', 'Error');
  }
}

/* ====================== eliminar línea ====================== */
async function eliminarLinea(detalleId){
  if(!compraActual) return;
  if(!confirm('¿Eliminar la línea seleccionada?')) return;
  const usuarioId=1;
  try{
    await ntDelete(`${API}/${compraActual.cabecera.id}/detalles/${detalleId}?usuarioId=${usuarioId}`);
    showToast('Línea eliminada', 'success', 'Éxito');
    pendingChanges = true;
    await verCompra(compraActual.cabecera.id, true);
    await buscar();
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
  const compraId = parseInt($('#anu_compraId').value,10);
  const usuarioId = parseInt($('#anu_usuarioId').value,10);
  const motivo = $('#anu_motivo').value.trim();
  if(!motivo){ showToast('Escriba un motivo de anulación', 'warning', 'Validación'); return; }
  try{
    await ntPost(`${API}/${compraId}/anular`, { usuarioId, compraId, motivo });
    showToast('Compra anulada', 'success', 'Éxito');
    pendingChanges = true;
    await mm.close();
    await verCompra(compraId, true);
    await buscar();
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
  const id = parseInt($('#modo_compraId').value,10);
  await verCompra(id, false);
  $('#cabeceraTitle').textContent = `Editar compra ${compraActual.cabecera.numeroCompra}`;
  $('#cab_compraId').value = compraActual.cabecera.id;
  $('#cab_usuarioId').value = 1;
  $('#cab_numeroCompra').value = compraActual.cabecera.numeroCompra || '';
  $('#cab_noFacturaProveedor').value = compraActual.cabecera.noFacturaProveedor || '';
  $('#cab_fechaCompra').value = compraActual.cabecera.fechaCompra || '';
  $('#cab_proveedorId').value = compraActual.cabecera.proveedorId || '';
  $('#cab_empleadoCompradorId').value = compraActual.cabecera.empleadoCompradorId || '';
  $('#cab_empleadoAutorizaId').value = compraActual.cabecera.empleadoAutorizaId || '';
  $('#cab_bodegaDestinoId').value = compraActual.cabecera.bodegaDestinoId || '';
  $('#cab_observaciones').value = compraActual.cabecera.observaciones || '';
  $('#panelDetalleInicial').style.display = 'none';
  await mm.replace('#mdlCabecera');
}
async function elegirMaestroDetalle(){
  const id = parseInt($('#modo_compraId').value,10);
  await verCompra(id, true);
}

/* ====================== botón GUARDAR maestro–detalle ====================== */
async function guardarMaster(){
  if (pendingChanges){
    // Los cambios ya están persistidos por cada operación; aquí solo confirmamos y refrescamos.
    pendingChanges = false;
    await buscar();          // refresca listado
    await mm.close();        // cierra modal
    showToast('Cambios guardados', 'success', 'Compras');
  }else{
    showToast('No hay cambios pendientes', 'info', 'Compras');
  }
}

/* ====================== eventos / init ====================== */
function bind(){
  $('#btnBuscar').addEventListener('click', buscar);
  $('#btnRefrescar').addEventListener('click', buscar);

  $('#btnNuevaCompra').addEventListener('click', async ()=>{
    nuevaCabecera();
    await mm.open('#mdlCabecera');
  });

  $('#btnAddLinea').addEventListener('click', ()=> addLinea('#tblDetalleNuevo tbody'));
  $('#frmCabecera').addEventListener('submit', guardarCabecera);

  // Tabla principal
  $('#tblCompras').addEventListener('click', async (e)=>{
    const b = e.target.closest('button'); if(!b) return;
    const id = parseInt(b.dataset.id,10);
    if (b.dataset.act==='ver'){ await verCompra(id, true); }
    if (b.dataset.act==='modo'){ await abrirSelectorModo(id); }
    if (b.dataset.act==='anular'){ await verCompra(id, false); abrirAnular(); }
  });

  // Maestro–detalle
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

  // Agregar líneas
  $('#btnAddLinea2').addEventListener('click', ()=> addLinea('#tblDetalleAgregar tbody'));
  $('#frmAgregarLineas').addEventListener('submit', guardarLineas);

  // Editar línea
  $('#frmEditarLinea').addEventListener('submit', guardarLinea);

  // Anular
  $('#frmAnular').addEventListener('submit', anularCompra);

  // Selector modo
  $('#optEditarCabecera').addEventListener('click', elegirEditarCabecera);
  $('#optMaestroDetalle').addEventListener('click', elegirMaestroDetalle);

  // Cierre seguro
  document.body.addEventListener('click', async (e)=>{
    const btn = e.target.closest('[data-mm-close]');
    if (!btn) return;
    await mm.close();
  });
}

async function init(){ bind(); await buscar(); }
window.addEventListener('DOMContentLoaded', init);
