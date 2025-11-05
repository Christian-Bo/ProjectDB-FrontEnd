/*
 * compras_pagos.js — Listado global (un buscador), modal con SELECT de compras
 * y tabla que muestra NOMBRE asociado a compra_id.
 * - Intenta resolver nombres en lote: GET /api/compras?ids=1,2,3
 * - Fallback por id: GET /api/compras/{id}
 * - Confirmación de eliminación con modal estilizado + toast destructivo.
 */

(function () {
  // ===== Helpers =====
  const q  = (s, r=document) => r.querySelector(s);
  const qa = (s, r=document) => Array.from(r.querySelectorAll(s));
  const fmtMonto = (v) => Number(v ?? 0).toLocaleString('es-GT',{minimumFractionDigits:2,maximumFractionDigits:2});
  const uniq = (arr) => [...new Set(arr.filter(x => x!=null && x!=='').map(Number))];

  function getApiBase(){
    try{
      if (window.API?.baseUrl) return String(window.API.baseUrl).trim();
      if (window.API_BASE)      return String(window.API_BASE).trim();
      const meta = document.querySelector('meta[name="api-base"]');
      return meta?.getAttribute('content')?.trim() || '';
    }catch(_){ return ''; }
  }
  const API_BASE    = getApiBase().replace(/\/+$/,'');
  const API_PAGOS   = API_BASE + '/api/compras/pagos';
  const API_COMPRAS = API_BASE + '/api/compras'; // ajusta si tu backend usa otra ruta

  // ===== Refs =====
  let $tblBody, $filtroTexto, $btnBuscar, $btnNuevo;

  // Modal pago
  let modalEl, $form, $id, $compraId, $compraSelect, $formaPago, $monto, $referencia, $btnGuardar;
  let $sumBox, $sumNombre, $sumDoc, $sumTotal;

  // Modal delete
  let modalDelEl, bsModalDel, $btnConfirmDelete, deleteIdPendiente = null, $delNum;

  // ===== Toast =====
  function showToast(msg, type='primary'){
    const toastEl = q('#appToast');
    const toastBody = q('#toastMsg');
    if (toastEl && toastBody) {
      toastEl.classList.remove('text-bg-primary','text-bg-success','text-bg-danger','text-bg-warning');
      toastEl.classList.add(
        type==='success' ? 'text-bg-success' :
        type==='danger'  ? 'text-bg-danger'  :
        type==='warning' ? 'text-bg-warning' : 'text-bg-primary'
      );
      const icon = (
        type==='success' ? '<i class="bi bi-check-circle-fill"></i>' :
        type==='danger'  ? '<i class="bi bi-trash3-fill"></i>' :
        type==='warning' ? '<i class="bi bi-exclamation-triangle-fill"></i>' :
                           '<i class="bi bi-info-circle-fill"></i>'
      );
      toastBody.innerHTML = `<span class="toast-icon">${icon}</span>${msg}`;
      bootstrap.Toast.getOrCreateInstance(toastEl).show();
      return;
    }
    console[type==='danger'?'error':'log'](msg);
  }

  // ===== HTTP =====
  async function httpGet(urlObj){
    const headers = (typeof buildHeaders==='function' ? buildHeaders() : {'Accept':'application/json'});
    const res = await fetch(urlObj.toString(), { headers });
    if (typeof handleResponse==='function') return handleResponse(res);
    if (!res.ok) {
      const txt = await res.text().catch(()=> '');
      throw new Error(`HTTP ${res.status}. ${txt||''}`.trim());
    }
    return res.json().catch(()=>[]);
  }
  async function httpSend(method, url, json){
    const headers = (typeof buildHeaders==='function' ? buildHeaders({'Content-Type':'application/json'}) : {'Accept':'application/json','Content-Type':'application/json'});
    const res = await fetch(url, { method, headers, body: json ? JSON.stringify(json) : null });
    if (typeof handleResponse==='function') return handleResponse(res);
    if (!res.ok) {
      const txt = await res.text().catch(()=> '');
      throw new Error(`HTTP ${res.status} en ${method}. ${txt||''}`.trim());
    }
    return res.json().catch(()=> (method === 'DELETE' ? null : {}));
  }

  // ===== Mapper flexible de compras =====
  function mapCompra(obj){
    const id    = obj.id ?? obj.compra_id ?? obj.compraId ?? obj.Id ?? null;
    const nombre =
      obj.proveedor?.nombre ??
      obj.proveedor_nombre ??
      obj.proveedorNombre ??
      obj.razon_social ??
      obj.nombre ??
      '—';
    const doc =
      obj.documento ??
      obj.serie_numero ??
      obj.numero ??
      obj.num_compra ??
      (id ? `#${id}` : '—');
    const total = Number(obj.total ?? obj.monto_total ?? obj.total_compra ?? obj.totalNeto ?? 0);
    return { id, nombre, doc, total };
  }

  // ===== Cache de compras para no repetir llamadas =====
  const compraCache = new Map(); // id -> {id,nombre,doc,total}

  async function fetchCompraMap(ids){
    const out = {};
    const pendientes = [];

    // 1) Lo que ya está en cache
    for (const id of ids){
      if (compraCache.has(id)) out[id] = compraCache.get(id);
      else pendientes.push(id);
    }
    if (!pendientes.length) return out;

    // 2) Intento en lote: /api/compras?ids=1,2,3
    let fetched = [];
    try{
      const url = new URL(API_COMPRAS);
      url.searchParams.set('ids', pendientes.join(','));
      url.searchParams.set('limit', String(pendientes.length));
      fetched = await httpGet(url);
    }catch(_){ /* ignorar, probamos fallback */ }

    if (Array.isArray(fetched) && fetched.length){
      for (const it of fetched){
        const c = mapCompra(it);
        if (c.id != null){
          compraCache.set(c.id, c);
          out[c.id] = c;
        }
      }
      // Si aún faltan, intenta por id individual
      const faltantes = pendientes.filter(id => !out[id]);
      if (!faltantes.length) return out;
      await fetchComprasIndividuales(faltantes, out);
      return out;
    }

    // 3) Fallback directo por id
    await fetchComprasIndividuales(pendientes, out);
    return out;
  }

  async function fetchComprasIndividuales(ids, out){
    await Promise.all(ids.map(async (id)=>{
      try{
        const url = new URL(`${API_COMPRAS}/${id}`);
        const it = await httpGet(url);
        const c = Array.isArray(it) ? mapCompra(it[0]||{}) : mapCompra(it);
        if (c.id != null){
          compraCache.set(c.id, c);
          out[c.id] = c;
        }
      }catch(_){ /* ignora fallos individuales */ }
    }));
  }

  // ===== Render de tabla (usa compraMap para mostrar nombre asociado) =====
  function renderTabla(rows, compraMap) {
    $tblBody.innerHTML = '';
    if (!rows.length) {
      $tblBody.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-4">Sin pagos para mostrar.</td></tr>`;
      return;
    }
    for (const r of rows) {
      const id         = r.id ?? r.pago_id ?? r.pagoId ?? '-';
      const compraId   = r.compra_id ?? r.compraId ?? null;
      const formaPago  = (r.forma_pago ?? r.formaPago ?? '').toString().toUpperCase();
      const monto      = r.monto ?? r.monto_total ?? 0;
      const referencia = r.referencia ?? '';

      const info = (compraId != null) ? compraMap[Number(compraId)] : null;
      const compraNombre = info?.nombre || '—';
      const compraDoc    = info?.doc || (compraId!=null ? `#${compraId}` : '—');

      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${id}</td>
        <td class="td-compra">
          <span class="compra-name" data-compra-id="${compraId ?? ''}">${compraNombre}</span><br>
          <small>${compraDoc}</small>
        </td>
        <td><span class="badge bg-primary-subtle text-primary badge-forma">${formaPago}</span></td>
        <td class="text-end">Q ${fmtMonto(monto)}</td>
        <td>${referencia}</td>
        <td class="text-end">
          <button class="btn btn-sm btn-outline-secondary me-2 btn-edit" data-id="${id}">
            <i class="bi bi-pencil"></i> Editar
          </button>
          <button class="btn btn-sm btn-outline-danger btn-del" data-id="${id}">
            <i class="bi bi-trash"></i> Eliminar
          </button>
        </td>`;
      $tblBody.appendChild(tr);
    }
    qa('.btn-edit').forEach(b => b.addEventListener('click', onEditarClick));
    qa('.btn-del').forEach(b => b.addEventListener('click', onPrepararEliminar));
  }

  async function cargar() {
    const texto = $filtroTexto.value.trim() || null;
    const url = new URL(API_PAGOS);
    if (texto) url.searchParams.set('texto', texto);
    try {
      const data = await httpGet(url);
      const rows = Array.isArray(data) ? data : [];
      // ids únicos a resolver
      const ids = uniq(rows.map(r => r.compra_id ?? r.compraId ?? null));
      const compraMap = ids.length ? await fetchCompraMap(ids) : {};
      renderTabla(rows, compraMap);
    } catch (e) {
      showToast(`Error al listar pagos: ${e.message}`, 'danger');
      $tblBody.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-4">No se pudieron cargar los pagos.</td></tr>`;
    }
  }

  // ===== Modal: SELECT de compras + resumen + autollenado =====
  function resetModal(){
    $form.reset();
    $id.value = '';
    $compraId.value = '';
    $compraSelect.innerHTML = `<option value="">— Seleccione una compra —</option>`;
    $sumBox.style.display = 'none';
    $sumNombre.textContent = '—';
    $sumDoc.textContent = '—';
    $sumTotal.textContent = 'Q 0.00';
  }

  async function cargarComprasEnSelect(){
    const url = new URL(API_COMPRAS);
    url.searchParams.set('limit','50');
    url.searchParams.set('orden','recientes');
    try{
      const list = await httpGet(url);
      const rows = Array.isArray(list) ? list : [];
      if (!rows.length){
        $compraSelect.innerHTML = `<option value="">(No hay compras para mostrar)</option>`;
        return;
      }
      const opts = [`<option value="">— Seleccione una compra —</option>`];
      for (const it of rows){
        const c = mapCompra(it);
        const label = `${c.nombre} — ${c.doc} — Q ${fmtMonto(c.total)}`;
        opts.push(`<option value="${c.id}" data-monto="${c.total}" data-nombre="${encodeURIComponent(c.nombre)}" data-doc="${encodeURIComponent(c.doc)}">${label}</option>`);
        // cachea para que el listado también lo conozca
        if (c.id != null) compraCache.set(c.id, c);
      }
      $compraSelect.innerHTML = opts.join('');
    }catch(e){
      $compraSelect.innerHTML = `<option value="">(Error cargando compras)</option>`;
      showToast(`Error cargando compras: ${e.message}`, 'danger');
    }
  }

  function abrirCrear() {
    resetModal();
    q('#modalPagoLabel').textContent = 'Nuevo pago de compra';
    cargarComprasEnSelect();
    bootstrap.Modal.getOrCreateInstance(modalEl).show();
  }

  function abrirEditar(row) {
    resetModal();
    q('#modalPagoLabel').textContent = `Editar pago #${row.id}`;
    cargarComprasEnSelect().then(()=>{
      if (row.compra_id){
        $compraSelect.value = String(row.compra_id);
        onCompraChange(); // pinta resumen y monto
      }
      $id.value         = row.id;
      $formaPago.value  = (row.forma_pago ?? row.formaPago ?? '').toString().toLowerCase();
      $monto.value      = row.monto ?? row.monto_total ?? 0;
      $referencia.value = row.referencia || '';
    });
    bootstrap.Modal.getOrCreateInstance(modalEl).show();
  }

  function rowDesdeTr(tr, id) {
    const compraCell = tr.querySelector('.td-compra .compra-name');
    const compraId = compraCell ? Number(compraCell.getAttribute('data-compra-id') || '') : null;
    return {
      id,
      compra_id: compraId,
      forma_pago: tr.querySelector('.badge-forma').textContent.trim().toLowerCase(),
      monto: Number((tr.children[3].textContent || '').replace(/[^\d.]/g,'')),
      referencia: tr.children[4].textContent.trim() || null
    };
  }

  async function onEditarClick(ev) {
    const id = Number(ev.currentTarget.dataset.id);
    const tr = ev.currentTarget.closest('tr');
    abrirEditar(rowDesdeTr(tr, id));
  }

  // ===== Eliminar con confirm modal =====
  function onPrepararEliminar(ev){
    deleteIdPendiente = Number(ev.currentTarget.dataset.id);
    $delNum.textContent = `#${deleteIdPendiente}`;
    bsModalDel.show();
  }

  async function onConfirmDelete(){
    if (!deleteIdPendiente) return;
    try {
      await httpSend('DELETE', `${API_PAGOS}/${deleteIdPendiente}`);
      showToast(`Pago ${deleteIdPendiente} eliminado correctamente.`, 'danger');
      deleteIdPendiente = null;
      bsModalDel.hide();
      cargar();
    } catch (e) {
      showToast(`Error eliminando: ${e.message}`, 'danger');
    }
  }

  // ===== Select change =====
  function onCompraChange(){
    const opt = $compraSelect.selectedOptions[0];
    if (!opt || !opt.value) {
      $compraId.value = '';
      $sumBox.style.display = 'none';
      return;
    }
    $compraId.value = opt.value;

    const nombre = decodeURIComponent(opt.getAttribute('data-nombre') || '');
    const doc    = decodeURIComponent(opt.getAttribute('data-doc') || '');
    const total  = Number(opt.getAttribute('data-monto') || 0);

    $sumNombre.textContent = nombre || '—';
    $sumDoc.textContent    = doc || '—';
    $sumTotal.textContent  = `Q ${fmtMonto(total)}`;
    $sumBox.style.display  = 'block';

    if (!isNaN(total) && total > 0) $monto.value = total.toFixed(2);
  }

  // ===== Guardar =====
  async function onSubmit(ev) {
    ev.preventDefault();
    const mode = ($id.value && $id.value.trim() !== '') ? 'edit' : 'create';

    if (!$compraId.value)  { showToast('Debes seleccionar una compra.', 'warning'); $compraSelect.focus(); return; }
    if (!$formaPago.value) { showToast('Selecciona una forma de pago.', 'warning'); $formaPago.focus(); return; }
    if (!$monto.value || Number($monto.value) <= 0) { showToast('Ingresa un monto válido (> 0).', 'warning'); $monto.focus(); return; }

    const payloadCreate = {
      compra_id:  Number($compraId.value),
      forma_pago: $formaPago.value.trim(),
      monto:      Number($monto.value),
      referencia: $referencia.value.trim() || null
    };
    const payloadEdit = {
      forma_pago: $formaPago.value.trim(),
      monto:      Number($monto.value),
      referencia: $referencia.value.trim() || null
    };

    try {
      if (mode === 'create') await httpSend('POST', API_PAGOS, payloadCreate);
      else                  await httpSend('PUT', `${API_PAGOS}/${Number($id.value)}`, payloadEdit);

      bootstrap.Modal.getOrCreateInstance(modalEl).hide();
      showToast(mode==='create' ? 'Pago creado.' : 'Pago actualizado.', 'success');
      cargar();
    } catch (e) {
      showToast(`Error guardando: ${e.message}`, 'danger');
    }
  }

  // ===== Init =====
  window.addEventListener('DOMContentLoaded', () => {
    console.log('[compras_pagos] API_PAGOS =', API_PAGOS, '| API_COMPRAS =', API_COMPRAS);

    // Refs tabla/buscador
    $tblBody     = q('#pagos-tbody');
    $filtroTexto = q('#filtro-texto');
    $btnBuscar   = q('#btn-buscar');
    $btnNuevo    = q('#btn-nuevo');

    // Modal pago
    modalEl      = q('#modalPago');
    $form        = q('#form-pago');
    $id          = q('#pago-id');
    $compraId    = q('#compra_id');
    $compraSelect= q('#compra_select');
    $formaPago   = q('#forma_pago');
    $monto       = q('#monto');
    $referencia  = q('#referencia');
    $btnGuardar  = q('#btn-guardar');

    // Resumen
    $sumBox      = q('#compra-summary');
    $sumNombre   = q('#sum-nombre');
    $sumDoc      = q('#sum-doc');
    $sumTotal    = q('#sum-total');

    // Modal delete
    modalDelEl       = q('#modalConfirmDelete');
    bsModalDel       = new bootstrap.Modal(modalDelEl);
    $btnConfirmDelete= q('#btn-confirm-delete');
    $delNum          = q('#del-num');

    // Eventos
    $btnBuscar.addEventListener('click', cargar);
    $btnNuevo.addEventListener('click', abrirCrear);
    $form.addEventListener('submit', onSubmit);
    $compraSelect.addEventListener('change', onCompraChange);
    $btnConfirmDelete.addEventListener('click', onConfirmDelete);
  });
})();
