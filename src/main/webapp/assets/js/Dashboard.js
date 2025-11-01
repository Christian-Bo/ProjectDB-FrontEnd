/* =========================================================
 * Dashboard.js — KPIs, tablas y gráfico
 * Incluye shims para getApiBase() y ntGet() si no existen.
 * ========================================================= */

// ---- SHIMS: compatibilidad con common.js actual ----
(function ensureHelpers(){
  // Lee base desde API.baseUrl, window.API_BASE, <meta name="api-base"> o LS
  if (typeof window.getApiBase !== 'function') {
    window.getApiBase = function(){
      try {
        if (window.API && window.API.baseUrl) return String(window.API.baseUrl).trim();
        if (window.API_BASE) return String(window.API_BASE).trim();
        const meta = document.querySelector('meta[name="api-base"]');
        const mval = meta?.getAttribute('content')?.trim() || '';
        if (mval) return mval;
        const fromLS = (localStorage.getItem('api_base') || '').trim();
        return fromLS || '';
      } catch { return ''; }
    };
  }

  // Helper para componer URL absoluta con o sin __absUrl
  function __safeAbs(url){
    if (/^https?:\/\//i.test(url)) return url;
    if (typeof window.__absUrl === 'function') return window.__absUrl(url);
    // Fallback: si empieza con '/', usar origin; si no, dejar relativo
    if (url.startsWith('/')) return new URL(url, window.location.origin).toString();
    return url;
  }

  // GET con headers de common.js (buildHeaders + handleResponse) si existen
  if (typeof window.ntGet !== 'function') {
    window.ntGet = async function(url, params){
      try {
        const base = (typeof getApiBase === 'function' ? (getApiBase() || '') : '');
        // si url no es absoluta, prefija base (si hay) o deja relativo
        if (!/^https?:\/\//i.test(url)) {
          const sep = url.startsWith('/') ? '' : '/';
          url = (base ? (String(base).replace(/\/+$/,'') + sep + url) : url);
        }
        // agrega query params si los mandan
        if (params && typeof params === 'object') {
          const u = new URL(__safeAbs(url));
          Object.entries(params).forEach(([k,v])=>{
            if (v !== undefined && v !== null && v !== '') u.searchParams.append(k, v);
          });
          url = u.toString();
        }
        const headers = (typeof buildHeaders==='function' ? buildHeaders() : { 'Accept':'application/json' });
        const res = await fetch(__safeAbs(url), { headers });
        if (typeof handleResponse === 'function') return handleResponse(res);
        // Fallback si no existe handleResponse
        const txt = await res.text();
        if (!res.ok) throw new Error(txt || `HTTP ${res.status}`);
        try { return txt ? JSON.parse(txt) : null; } catch { return txt; }
      } catch (e) {
        throw e;
      }
    };
  }

  // Alias seguro para toasts si no existiera showToast
  if (typeof window.showToast !== 'function') {
    window.showToast = function(msg, level='info'){ console[level==='error'?'error':'log'](`[${level}] ${msg}`); };
  }
})();

// ====== Base de APIs ======
const API_BASE    = getApiBase() || ''; // puede ser '', y entonces usamos rutas absolutas /api/...
const API_PROV    = `${API_BASE}/api/proveedores`;
const API_COMP    = `${API_BASE}/api/compras`;
const API_CXP_DOC = `${API_BASE}/api/cxp/documentos`;
const API_CXP_PAG = `${API_BASE}/api/cxp/pagos`;

// ====== Helpers de formato ======
const $  = (s,c=document)=>c.querySelector(s);
const $$ = (s,c=document)=>Array.from(c.querySelectorAll(s));
const fmtMoney = v => (v==null?'0.00':Number(v).toLocaleString('es-GT',{minimumFractionDigits:2, maximumFractionDigits:2}));
const ymd = (d)=> (d instanceof Date ? d.toISOString().slice(0,10) : String(d).slice(0,10));

// ====== KPI: Proveedores activos ======
async function kpiProveedoresActivos() {
  try {
    const r1 = await ntGet(`${API_PROV}?activo=true&page=0&size=1`).catch(()=>null);
    if (r1 && typeof r1.totalElements === 'number') {
      $('#kpiProvActivos').textContent = r1.totalElements; return;
    }
    const r2 = await ntGet(`${API_PROV}?activo=true&page=0&size=1000`).catch(()=>null);
    const arr = Array.isArray(r2?.content) ? r2.content : (Array.isArray(r2) ? r2 : []);
    $('#kpiProvActivos').textContent = arr.length || '--';
  } catch (e) {
    showToast(`KPI Proveedores: ${e.message}`, 'error');
    $('#kpiProvActivos').textContent = '--';
  }
}

// ====== KPIs de Compras y CxP ======
async function comprasMes() {
  try {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
    const url = `${API_COMP}?fechaDel=${ymd(inicioMes)}&fechaAl=${ymd(hoy)}`;
    const lista = await ntGet(url);
    const total = (lista||[]).reduce((acc, it)=> acc + (Number(it.total)||0), 0);
    $('#kpiComprasMes').textContent = (lista||[]).length;
    $('#kpiComprasMesTotal').textContent = fmtMoney(total);
  } catch (e) {
    showToast(`Compras (mes): ${e.message}`, 'error');
    $('#kpiComprasMes').textContent = '--';
    $('#kpiComprasMesTotal').textContent = '--';
  }
}

async function cxpSaldoPendiente() {
  try {
    const docs = await ntGet(`${API_CXP_DOC}?proveedorId=&texto=`);
    const arr = Array.isArray(docs) ? docs : [];
    const totalPend = arr
      .filter(d => (d.estado || '').toUpperCase().startsWith('P'))
      .reduce((acc, d)=> acc + (Number(d.saldo_pendiente)||0), 0);
    $('#kpiCxpPendiente').textContent = fmtMoney(totalPend);
  } catch (e) {
    showToast(`CxP pendiente: ${e.message}`, 'error');
    $('#kpiCxpPendiente').textContent = '--';
  }
}

async function cxpPagosMes() {
  try {
    const hoy = new Date();
    const inicioMes = new Date(hoy.getFullYear(), hoy.getMonth(), 1);
    const pagos = await ntGet(`${API_CXP_PAG}?proveedorId=&texto=`);
    const arr = Array.isArray(pagos) ? pagos : [];
    const desde = ymd(inicioMes), hasta = ymd(hoy);
    const suma = arr
      .filter(p => { const f = ymd(p.fecha_pago); return f >= desde && f <= hasta; })
      .reduce((acc, p)=> acc + (Number(p.monto_total)||0), 0);
    $('#kpiPagosMes').textContent = fmtMoney(suma);
  } catch (e) {
    showToast(`Pagos CxP (mes): ${e.message}`, 'error');
    $('#kpiPagosMes').textContent = '--';
  }
}

// ====== Tablas ======
async function ultimosProveedores(limit=3) {
  const tb = $('#tblUltimosProv'); tb.innerHTML = '';
  try {
    let data = await ntGet(`${API_PROV}?page=0&size=${limit}&sort=id,desc`).catch(()=>null);
    if (!data) data = await ntGet(`${API_PROV}/ultimos?limit=${limit}`).catch(()=>null);
    if (!data) {
      const all = await ntGet(`${API_PROV}?page=0&size=1000`).catch(()=>[]);
      const arr = Array.isArray(all?.content) ? all.content : (Array.isArray(all) ? all : []);
      arr.sort((a,b)=> (b.id||0)-(a.id||0));
      data = { content: arr.slice(0, limit) };
    }
    const items = Array.isArray(data?.content) ? data.content : (Array.isArray(data) ? data : []);
    if (!items.length) { tb.innerHTML = `<tr><td colspan="5" class="text-center text-muted py-3">Sin datos</td></tr>`; return; }
    items.forEach(p=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${window.ntEsc?.(p.codigo)||p.codigo||''}</td>
        <td>${window.ntEsc?.(p.nombre)||p.nombre||''}</td>
        <td>${window.ntEsc?.(p.nit)||p.nit||''}</td>
        <td>${window.ntEsc?.(p.telefono)||p.telefono||''}</td>
        <td>${p.diasCredito ?? ''}</td>`;
      tb.appendChild(tr);
    });
  } catch (e) {
    showToast(`Últimos proveedores: ${e.message}`, 'error');
    tb.innerHTML = `<tr><td colspan="5" class="text-center text-muted py-3">Error</td></tr>`;
  }
}

async function ultimasCompras(limit=3) {
  const tb = $('#tblUltimasCompras'); tb.innerHTML = '';
  try {
    const hoy = new Date();
    const hace30 = new Date(hoy.getTime() - 30*24*60*60*1000);
    const lista = await ntGet(`${API_COMP}?fechaDel=${ymd(hace30)}&fechaAl=${ymd(hoy)}`);
    const arr = Array.isArray(lista) ? lista : [];
    arr.sort((a,b)=>{
      const fa = (a.fechaCompra||''); const fb = (b.fechaCompra||'');
      if (fa>fb) return -1; if (fa<fb) return 1;
      return (b.id||0)-(a.id||0);
    });
    (arr.slice(0,limit)).forEach((c,i)=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td>${i+1}</td>
        <td class="fw-semibold">${window.ntEsc?.(c.numeroCompra)||c.numeroCompra||''}</td>
        <td>${window.ntEsc?.(c.fechaCompra)||c.fechaCompra||''}</td>
        <td>${window.ntEsc?.(c.proveedorNombre)||c.proveedorNombre||''}</td>
        <td class="text-end">Q${fmtMoney(c.total)}</td>
        <td><span class="badge ${c.estado==='P'?'bg-secondary':c.estado==='R'?'bg-info':c.estado==='C'?'bg-success':'bg-danger'}">${c.estado||'-'}</span></td>`;
      tb.appendChild(tr);
    });
    if (!arr.length) tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Sin compras recientes</td></tr>`;
  } catch (e) {
    showToast(`Últimas compras: ${e.message}`, 'error');
    tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Error</td></tr>`;
  }
}

async function ultimosPagosCxp(limit=5) {
  const tb = $('#tblUltimosPagos'); tb.innerHTML = '';
  try {
    const pagos = await ntGet(`${API_CXP_PAG}?proveedorId=&texto=`);
    const arr = Array.isArray(pagos) ? pagos : [];
    arr.sort((a,b)=>{
      const fa = ymd(a.fecha_pago), fb = ymd(b.fecha_pago);
      if (fa>fb) return -1; if (fa<fb) return 1;
      return (b.id||0)-(a.id||0);
    });
    (arr.slice(0,limit)).forEach(p=>{
      const tr = document.createElement('tr');
      tr.innerHTML = `
        <td class="text-muted">#${p.id}</td>
        <td>${p.proveedor_id}</td>
        <td>${window.ntEsc?.(p.fecha_pago)||p.fecha_pago||''}</td>
        <td>${window.ntEsc?.(p.forma_pago)||p.forma_pago||''}</td>
        <td class="text-end">Q${fmtMoney(p.monto_total)}</td>
        <td title="${window.ntEsc?.(p.observaciones)||p.observaciones||''}">${window.ntEsc?.((p.observaciones||'').slice(0,40)) || (p.observaciones||'').slice(0,40)}</td>`;
      tb.appendChild(tr);
    });
    if (!arr.length) tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Sin pagos</td></tr>`;
  } catch (e) {
    showToast(`Últimos pagos CxP: ${e.message}`, 'error');
    tb.innerHTML = `<tr><td colspan="6" class="text-center text-muted py-3">Error</td></tr>`;
  }
}

// ====== Gráfico ======
async function chartCompras6Semanas() {
  try {
    const hoy = new Date();
    const desde = new Date(hoy.getTime() - 41*24*60*60*1000);
    const lista = await ntGet(`${API_COMP}?fechaDel=${ymd(desde)}&fechaAl=${ymd(hoy)}`);
    const porDia = {};
    (lista||[]).forEach(it=>{
      const f = ymd(it.fechaCompra||''); if (!f) return;
      porDia[f] = (porDia[f]||0) + (Number(it.total)||0);
    });

    const dias = []; for (let d = new Date(desde); d <= hoy; d.setDate(d.getDate()+1)) dias.push(ymd(d));
    const labels = [], data = [];
    for (let i=0; i<dias.length; i+=7){
      const slice = dias.slice(i,i+7);
      const suma = slice.reduce((acc, y)=> acc + (porDia[y]||0), 0);
      labels.push(`${slice[0].slice(5)}–${slice[slice.length-1].slice(5)}`);
      data.push(Number(suma.toFixed(2)));
    }

    const ctx = document.getElementById('chartCompras'); if (!ctx) return;
    if (window._chartCompras) window._chartCompras.destroy();

    window._chartCompras = new Chart(ctx, {
      type: 'line',
      data: { labels, datasets: [{ label: 'Total Q por semana', data }] },
      options: {
        responsive: true,
        interaction: { mode: 'index', intersect: false },
        plugins: {
          legend: { labels: { color: '#c4c8d3' } },
          tooltip: { callbacks: { label: (ctx)=> ` Q ${fmtMoney(ctx.parsed.y)}` } }
        },
        scales: {
          x: { ticks: { color: '#c4c8d3' }, grid: { color: 'rgba(255,255,255,.06)' } },
          y: { ticks: { color: '#c4c8d3' }, grid: { color: 'rgba(255,255,255,.06)' } }
        }
      }
    });
  } catch (e) { showToast(`Gráfico compras: ${e.message}`, 'error'); }
}

// ====== Orquestación ======
async function cargarDashboard() {
  await Promise.allSettled([
    kpiProveedoresActivos(),
    comprasMes(),
    cxpSaldoPendiente(),
    cxpPagosMes(),
    ultimosProveedores(3),
    ultimasCompras(3),
    ultimosPagosCxp(5),
    chartCompras6Semanas()
  ]);
}

function bindUI(){ $('#btnRefrescar')?.addEventListener('click', cargarDashboard); }
window.addEventListener('DOMContentLoaded', ()=>{ bindUI(); cargarDashboard(); });
