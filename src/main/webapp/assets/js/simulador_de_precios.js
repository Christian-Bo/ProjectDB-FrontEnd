/* simulador_de_precios.js v9 — sin llamadas a /api/clientes* (evita 500), picker solo para productos */
(() => {
  const API_BASE = (document.querySelector('meta[name="api-base"]')?.content || '').replace(/\/+$/,'');
  const token = (localStorage.getItem('auth_token') || '').trim();

  const $ = (s)=>document.querySelector(s);
  const headers = new Headers({ Accept: 'application/json' });
  if (token) headers.set('Authorization', `Bearer ${token}`);

  const toast = (msg, type='info')=>{
    const box=document.createElement('div');
    box.className=`toast align-items-center nt-toast-${type}`;
    box.innerHTML=`
      <div class="toast-header">
        <i class="bi ${type==='success'?'bi-check-circle':type==='error'?'bi-x-circle':'bi-info-circle'} me-2"></i>
        <strong class="me-auto">Simulador</strong>
        <small>ahora</small>
        <button type="button" class="btn-close" data-bs-dismiss="toast"></button>
      </div>
      <div class="toast-body">${msg}</div>`;
    (document.getElementById('toastStack')||document.body).appendChild(box);
    new bootstrap.Toast(box,{delay:2500}).show();
  };

  const busy = (on)=>{
    const b = $('#btnSimular');
    if(!b) return;
    b.disabled = !!on;
    b.querySelector('.when-idle')?.classList.toggle('d-none', !!on);
    b.querySelector('.when-busy')?.classList.toggle('d-none', !on);
  };

  const EP = {
    productosList:  '/api/productos',           // GET ?soloActivos=true&page=1&pageSize=20
    productosSearch:'/api/productos/search',    // GET ?q=...
    // NO usamos /api/clientes ni /api/clientes/search para evitar 500
    precio:         '/api/clientes-listas-precios/precio' // GET ?clienteId=&productoId=&fecha=
  };

  async function getJson(url){
    let res, txt;
    try { res = await fetch(url, { headers }); txt = await res.text(); }
    catch { return { ok:false, status:0, body:{ message:'Sin conexión con el servidor' } }; }

    let body;
    try { body = txt ? JSON.parse(txt) : {}; } catch { body = { message: txt || 'Respuesta no JSON' }; }

    const ok = (typeof body.ok === 'boolean') ? body.ok : res.ok;
    return { ok, status: res.status, body };
  }

  const normProducto = (r)=>{
    const id = r.id ?? r.productoId ?? r.codigo ?? r.code;
    const nombre = r.nombre ?? r.productoNombre ?? r.descripcion ?? r.name;
    return (id && nombre) ? {id, nombre} : null;
  };

  function escapeHtml(s){ return String(s||'').replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m])); }

  function renderTable(targetSel, rows, onPick){
    const tb = $(targetSel);
    if(!tb) return;
    if(rows?.[0]?.loading){ tb.innerHTML = `<tr><td colspan="3" class="text-center py-4"><div class="spinner-border"></div></td></tr>`; return; }
    if(rows?.[0]?.empty){ tb.innerHTML = `<tr><td colspan="3" class="text-center py-4">Sin resultados</td></tr>`; return; }
    tb.innerHTML = rows.map(r => `
      <tr>
        <td class="text-mono">${escapeHtml(r.id)}</td>
        <td>${escapeHtml(r.nombre)}</td>
        <td class="text-end">
          <button type="button" class="btn btn-sm btn-primary pick-row" data-id="${escapeHtml(r.id)}" data-nombre="${escapeHtml(r.nombre)}">Elegir</button>
        </td>
      </tr>`).join('');
    if(onPick){
      tb.querySelectorAll('.pick-row').forEach(btn=>{
        btn.addEventListener('click', ()=> onPick({ id: btn.dataset.id, nombre: btn.dataset.nombre }) );
      });
    }
  }

  /* ======== PRODUCTOS (lista inicial + buscador) ======== */
  const mdlProd = new bootstrap.Modal('#mdlPickProducto');

  async function cargarProductosInicial(){
    renderTable('#prod_rows', [{loading:true}]);

    const url = new URL(API_BASE + EP.productosList, window.location.origin);
    url.searchParams.set('soloActivos','true');
    url.searchParams.set('page','1');
    url.searchParams.set('pageSize','20');

    const { ok, body } = await getJson(url.toString());
    const list = ok ? (Array.isArray(body?.data) ? body.data : (body?.data?.items || body?.data?.content || [])) : [];
    const rows = list.map(normProducto).filter(Boolean);
    renderTable('#prod_rows', rows.length? rows : [{empty:true}], onPickProducto);
  }

  async function buscarProductos(q){
    if (!q || q.length < 1){ await cargarProductosInicial(); return; }
    renderTable('#prod_rows', [{loading:true}]);

    const url = new URL(API_BASE + EP.productosSearch, window.location.origin);
    url.searchParams.set('q', q);
    const { ok, body } = await getJson(url.toString());
    const list = ok ? (Array.isArray(body?.data) ? body.data : []) : [];
    const rows = list.map(normProducto).filter(Boolean);
    renderTable('#prod_rows', rows.length? rows : [{empty:true}], onPickProducto);
  }

  function onPickProducto(row){
    $('#prod_id').value = row.id;
    $('#prod_display').innerHTML = `<strong>${row.id}</strong> — ${escapeHtml(row.nombre)}`;
    mdlProd.hide();
  }

  $('#btnPickProducto')?.addEventListener('click', ()=>{ $('#prod_q').value=''; mdlProd.show(); cargarProductosInicial(); });
  $('#prod_btnBuscar')?.addEventListener('click', ()=> buscarProductos($('#prod_q').value.trim()));
  $('#prod_q')?.addEventListener('keydown', (e)=>{ if(e.key==='Enter'){ e.preventDefault(); $('#prod_btnBuscar').click(); }});
  $('#btnClearProducto')?.addEventListener('click', ()=>{ $('#prod_id').value=''; $('#prod_display').innerHTML='<span class="muted">Sin seleccionar</span>'; });

  /* ======== SIMULACIÓN ======== */
  async function simularPrecio({ clienteId, productoId, fecha }){
    const url = new URL(API_BASE + EP.precio, window.location.origin);
    url.searchParams.set('clienteId', String(clienteId));
    url.searchParams.set('productoId', String(productoId));
    if (fecha) url.searchParams.set('fecha', fecha);
    return getJson(url.toString());
  }

  function pick(obj, keys){
    for (const k of keys) if (obj && obj[k] !== undefined && obj[k] !== null) return obj[k];
    return undefined;
  }
  function renderResultado(payload){
    const data = payload?.data ?? payload;
    const final  = pick(data, ['final','precio','precioFinal','total']);
    const base   = pick(data, ['base','precioBase']);
    const ajuste = pick(data, ['ajusteLista','ajuste']);
    const margen = pick(data, ['margen','margin']);
    const promo  = pick(data, ['promo','descuento','discount']);

    $('#cardResultado').style.display = '';
    $('#precio_final').textContent = (typeof final==='number') ? final.toFixed(2) : (final ?? '—');
    $('#p_base').textContent       = (typeof base==='number')  ? base.toFixed(2)  : (base  ?? '—');
    $('#p_lista').textContent      = (typeof ajuste==='number')? ajuste.toFixed(2): (ajuste?? '—');
    $('#p_margen').textContent     = (typeof margen==='number')? margen.toFixed(2): (margen?? '—');
    $('#p_promo').textContent      = (typeof promo==='number') ? promo.toFixed(2) : (promo ?? '—');
  }

  async function onSimular(){
    const productoId = Number($('#prod_id').value || 0);
    const clienteId  = Number($('#cliente_id').value || 0);
    const fecha      = $('#fecha')?.value || '';

    if(!productoId){ toast('Selecciona un producto.', 'error'); return; }
    if(!clienteId){  toast('Ingresa el ID del cliente.', 'error'); return; }

    busy(true);
    const { ok, body, status } = await simularPrecio({ clienteId, productoId, fecha });
    busy(false);

    if(!ok){
      toast(body?.message || `No se pudo simular (HTTP ${status})`, 'error');
      $('#cardResultado').style.display='none';
      return;
    }
    renderResultado(body);
    toast('Simulación lista', 'success');
  }
  function onLimpiar(){
    $('#prod_id').value='';
    $('#prod_display').innerHTML = `<span class="muted">Sin seleccionar</span>`;
    $('#cliente_id').value='';
    $('#fecha').value='';
    $('#cardResultado').style.display='none';
  }

  $('#btnSimular')?.addEventListener('click', onSimular);
  $('#btnLimpiar')?.addEventListener('click', onLimpiar);
})();
