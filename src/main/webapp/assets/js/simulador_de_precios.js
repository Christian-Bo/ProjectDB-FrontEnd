(() => {
  const apiBase = window.NT_API_BASE || document.querySelector('meta[name="api-base"]').content || '';
  const headers = { 'Content-Type': 'application/json; charset=UTF-8' };
  const $ = (s) => document.querySelector(s);

  function toast(msg, type='info'){
    const id=`t_${Date.now()}`;
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
    document.getElementById('toastStack').appendChild(box);
    new bootstrap.Toast(box,{delay:2500}).show();
  }

  async function fetchJson(url, opts={}){
    const res = await fetch(url, { headers, ...opts });
    const data = await res.json().catch(()=> ({}));
    return (typeof data.ok !== 'undefined') ? data : { ok: res.ok, message: data?.message || '', data };
  }

  // Suponiendo endpoint tipo: POST /api/precios/simular { productoId, listaId?, clienteId? }
  async function simular(payload){
    return fetchJson(`${apiBase}/api/precios/simular`, { method:'POST', body: JSON.stringify(payload) });
  }

  $('#btnSimular').addEventListener('click', async ()=>{
    const productoId = Number($('#prod_id').value || 0);
    if(!productoId){ toast('Debes indicar un ID de producto.', 'error'); return; }
    const listaId = $('#lista_id').value ? Number($('#lista_id').value) : null;
    const clienteId = $('#cliente_id').value ? Number($('#cliente_id').value) : null;

    const resp = await simular({ productoId, listaId, clienteId });
    if(!resp.ok){ toast(resp.message || 'No se pudo simular', 'error'); return; }

    const r = resp.data || resp;
    // Estructura esperada (ejemplo):
    // { base: 100, ajusteLista: 5, margen: 12, promo: -8, final: 109, breakdown?: {...} }
    $('#cardResultado').style.display='';
    $('#precio_final').textContent = r.final?.toFixed?.(2) ?? r.final ?? '—';
    $('#p_base').textContent  = r.base?.toFixed?.(2) ?? r.base ?? '—';
    $('#p_lista').textContent = r.ajusteLista?.toFixed?.(2) ?? r.ajusteLista ?? '—';
    $('#p_margen').textContent= r.margen?.toFixed?.(2) ?? r.margen ?? '—';
    $('#p_promo').textContent = r.promo?.toFixed?.(2) ?? r.promo ?? '—';
    $('#json_raw').textContent = JSON.stringify(r, null, 2);

    toast('Simulación lista', 'success');
  });

  $('#btnLimpiar').addEventListener('click', ()=>{
    $('#prod_id').value='';
    $('#lista_id').value='';
    $('#cliente_id').value='';
    $('#cardResultado').style.display='none';
    $('#json_raw').textContent='';
  });
})();
